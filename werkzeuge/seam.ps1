$src = @'
using System;
public class Seam {
  // RBJ biquad, wie in Web Audio BiquadFilterNode
  public static double[] Biquad(double[] x, double fs, double f0, double Q, string type){
    double w0 = 2*Math.PI*f0/fs, cw = Math.Cos(w0), sw = Math.Sin(w0);
    double alpha = sw/(2*Q);
    double b0,b1,b2,a0,a1,a2;
    if(type=="lp"){ b0=(1-cw)/2; b1=1-cw; b2=(1-cw)/2; }
    else          { b0=alpha;    b1=0;    b2=-alpha;   }
    a0=1+alpha; a1=-2*cw; a2=1-alpha;
    b0/=a0; b1/=a0; b2/=a0; a1/=a0; a2/=a0;
    double[] y = new double[x.Length];
    double x1=0,x2=0,y1=0,y2=0;
    for(int n=0;n<x.Length;n++){
      double v = b0*x[n]+b1*x1+b2*x2-a1*y1-a2*y2;
      x2=x1; x1=x[n]; y2=y1; y1=v; y[n]=v;
    }
    return y;
  }

  public static void Main2(){
    int sr = 44100; int nlen = sr*3;
    Random rnd = new Random(12345);

    // ---- Ensemble: wie gross ist der LF-Zustand am Pufferende? ----
    double sumsq=0, maxabs=0; int trials=40;
    for(int t=0;t<trials;t++){
      double last=0;
      for(int j=0;j<nlen;j++){ double w=rnd.NextDouble()*2-1; last=(last+0.02*w)/1.02; }
      double v = last*3.2;
      sumsq += v*v; if(Math.Abs(v)>maxabs) maxabs=Math.Abs(v);
    }
    Console.WriteLine("LF-Sprunghoehe am Naht v=3.2*last_end : RMS="+Math.Sqrt(sumsq/trials).ToString("F4")+"  max("+trials+" Laeufe)="+maxabs.ToString("F4"));

    // ---- Ein konkreter Puffer ----
    double[] nd = new double[nlen];
    double lst=0;
    for(int j=0;j<nlen;j++){ double w=rnd.NextDouble()*2-1; lst=(lst+0.02*w)/1.02; nd[j]=w*0.6+lst*3.2; }
    double seamJump = Math.Abs(nd[0]-nd[nlen-1]);
    // Verteilung der normalen Sample-zu-Sample-Spruenge
    double ss=0, mx=0; int bigger=0;
    for(int j=1;j<nlen;j++){ double d=Math.Abs(nd[j]-nd[j-1]); ss+=d*d; if(d>mx)mx=d; if(d>seamJump) bigger++; }
    Console.WriteLine("Nahtsprung |nd[0]-nd[N-1]| = "+seamJump.ToString("F4"));
    Console.WriteLine("interne Spruenge: RMS="+Math.Sqrt(ss/(nlen-1)).ToString("F4")+"  max="+mx.ToString("F4"));
    Console.WriteLine("Anteil interner Spruenge GROESSER als der Nahtsprung: "+(100.0*bigger/(nlen-1)).ToString("F2")+" %");
    Console.WriteLine("  -> d.h. rund "+((long)(bigger/3.0))+" mal PRO SEKUNDE tritt ein groesserer Sprung auf.");
    Console.WriteLine();

    // ---- Vier Perioden aneinanderhaengen (= s.loop=true) ----
    int reps=4; double[] x = new double[nlen*reps];
    for(int r=0;r<reps;r++) Array.Copy(nd,0,x,r*nlen,nlen);

    string[] names = {"Regen  bandpass 2100 Hz Q=0.55","Wind   lowpass  340 Hz Q=0.70","Statik bandpass 2900 Hz Q=0.90"};
    double[] f0s = {2100,340,2900}; double[] Qs={0.55,0.70,0.90}; string[] ty={"bp","lp","bp"};

    for(int k=0;k<3;k++){
      double[] y = Biquad(x, sr, f0s[k], Qs[k], ty[k]);
      // Fenster von 5 ms, nur ab Periode 2 (Filter eingeschwungen)
      int wlen = (int)(sr*0.005);
      int start = nlen;                 // erste Naht liegt bei Index nlen
      int nwin = (x.Length-start)/wlen;
      double[] peak = new double[nwin]; double[] slew = new double[nwin];
      for(int i=0;i<nwin;i++){
        double p=0,s2=0;
        for(int n=start+i*wlen; n<start+(i+1)*wlen; n++){
          if(Math.Abs(y[n])>p) p=Math.Abs(y[n]);
          double d=Math.Abs(y[n]-y[n-1]); if(d>s2) s2=d;
        }
        peak[i]=p; slew[i]=s2;
      }
      // Welche Fenster enthalten eine Naht? Naht bei nlen, 2*nlen, 3*nlen
      int wSeam2 = (2*nlen-start)/wlen;
      int rankP=0, rankS=0;
      for(int i=0;i<nwin;i++){ if(peak[i]>peak[wSeam2]) rankP++; if(slew[i]>slew[wSeam2]) rankS++; }
      double rms=0; for(int n=start;n<x.Length;n++) rms+=y[n]*y[n];
      rms=Math.Sqrt(rms/(x.Length-start));
      Console.WriteLine(names[k]);
      Console.WriteLine("   Dauer-RMS am Bus                : "+rms.ToString("F4"));
      Console.WriteLine("   Spitze im Naht-Fenster          : "+peak[wSeam2].ToString("F4")+"   (= "+(peak[wSeam2]/rms).ToString("F2")+" x RMS)");
      Console.WriteLine("   Fenster mit GROESSERER Spitze   : "+rankP+" von "+nwin+"  ("+(100.0*rankP/nwin).ToString("F1")+" %)");
      Console.WriteLine("   Fenster mit GROESSEREM Slew     : "+rankS+" von "+nwin+"  ("+(100.0*rankS/nwin).ToString("F1")+" %)");
      Console.WriteLine();
    }
  }
}
'@
Add-Type -TypeDefinition $src -Language CSharp
[Seam]::Main2()
