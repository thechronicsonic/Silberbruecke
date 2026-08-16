$src = @'
using System;
public class Step2 {
  public static double[] Biquad(double[] x, double fs, double f0, double Q, string type){
    double w0 = 2*Math.PI*f0/fs, cw = Math.Cos(w0), sw = Math.Sin(w0);
    double alpha = sw/(2*Q);
    double b0,b1,b2,a0,a1,a2;
    if(type=="lp"){ b0=(1-cw)/2; b1=1-cw; b2=(1-cw)/2; }
    else          { b0=alpha;    b1=0;    b2=-alpha;   }
    a0=1+alpha; a1=-2*cw; a2=1-alpha;
    b0/=a0; b1/=a0; b2/=a0; a1/=a0; a2/=a0;
    double[] y=new double[x.Length]; double x1=0,x2=0,y1=0,y2=0;
    for(int n=0;n<x.Length;n++){ double v=b0*x[n]+b1*x1+b2*x2-a1*y1-a2*y2; x2=x1;x1=x[n];y2=y1;y1=v;y[n]=v; }
    return y;
  }
  public static void Main2(){
    int sr=44100; double v=0.2201;          // gemessene RMS-Sprunghoehe des LF-Anteils
    double[] step=new double[sr/10];
    for(int n=sr/20;n<step.Length;n++) step[n]=v;   // isolierter Sprung, nur die Stoerung
    string[] names={"Regen  bp 2100 Q0.55","Wind   lp  340 Q0.70","Statik bp 2900 Q0.90"};
    double[] f0={2100,340,2900}; double[] Q={0.55,0.70,0.90}; string[] ty={"bp","lp","bp"};
    double[] busRms={0.1811,0.1925,0.1622};
    double[] busGain={0.085,0.13,0.085};
    Console.WriteLine("Isolierte Nahtstoerung (Sprung "+v.ToString("F3")+") durch die drei Busfilter:");
    Console.WriteLine();
    for(int k=0;k<3;k++){
      double[] y=Biquad(step,sr,f0[k],Q[k],ty[k]);
      double pk=0; int pkAt=0;
      for(int n=sr/20;n<y.Length;n++){ double d=Math.Abs(y[n]-(ty[k]=="lp"?v:0)); if(d>pk){pk=d;pkAt=n;} }
      // Uebergangsdauer beim Tiefpass: 10%->90%
      Console.WriteLine(names[k]);
      Console.WriteLine("   Spitzenauslenkung der Stoerung : "+pk.ToString("F4"));
      Console.WriteLine("   relativ zum Dauer-RMS des Busses: "+(pk/busRms[k]).ToString("F2")+" x  ("+(20*Math.Log10(pk/busRms[k])).ToString("F1")+" dB)");
      Console.WriteLine("   Pegel am Master (Busgain "+busGain[k]+", Master 0.7): "+(pk*busGain[k]*0.7).ToString("F5"));
      if(ty[k]=="lp"){
        int i10=0,i90=0;
        for(int n=sr/20;n<y.Length;n++){ if(i10==0&&y[n]>=0.1*v) i10=n; if(i90==0&&y[n]>=0.9*v){i90=n;break;} }
        Console.WriteLine("   Uebergang 10%->90% dauert      : "+(1000.0*(i90-i10)/sr).ToString("F2")+" ms");
        Console.WriteLine("   (natuerliche Zeitkonstante des LF-Anteils selbst: 1.15 ms / Eckfrequenz 138 Hz)");
      }
      Console.WriteLine();
    }
  }
}
'@
Add-Type -TypeDefinition $src -Language CSharp
[Step2]::Main2()
