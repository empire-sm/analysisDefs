/* Pitch-following badassery. Basically
   the same effect at the end of MAN
   QUA MAN
*/
(
SynthDef("noise-pitchFollow1",{
    var in, amp, freq, hasFreq, out;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05);
    # freq, hasFreq = Tartini.kr(in, 0.93,1024,512,512);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), amp));
    6.do({
        out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
    });
    Out.ar(0,out)
}).play(s);
)


/* Listens to Input 0
   and polls:
      FREQUENCY
      MIDI VALUE
      CERTAINTY
*/
(
a= SynthDef("trackFreq",{
    var in, freq, hasFreq, mid, note, out;

    in=SoundIn.ar(0);

    # freq, hasFreq = Tartini.kr(in);

	mid = freq.cpsmidi.round(1);
	note = mid;

	freq.poll(Impulse.kr(hasFreq), \freq);
	mid.poll(Impulse.kr(hasFreq), \midi);
    //hasFreq.poll;

    //Out.ar(0,[SinOsc.ar(freq,0.1)]);
}).play(s);
)

a.free;



/* Polls the onset intensity level of the mic input
    Values range 0...1 (0 = quietest, 1 = loudest)
   Can be used to track dynamics of attack values over time
*/
(
SynthDef("trackOnsets", {
	var sounds = Mix.new(SoundIn.ar([0,1]));
	var detect = Decay2.kr(Coyote.kr(sounds, fastMul: 0.9, thresh: 0.8), 0.01, 0.2);
	detect.poll(Impulse.kr(detect), \onset);
} ).play(s);
)



/* Creates a histogram which returns 4 analyses after receiving a trigger:
  [0] entropy of beat histogram
  [1] ratio of the largest to the second largest entries in the beat histogram
  [2] diversity (Simpson's D measure) of beat histogram
  [3] metricity (consistency of high energy histogram entries to integer multiples or divisors of strongest entry)
*/
(
SynthDef("trackHistogram", {
	var source = Mix.new(SoundIn.ar([0, 1]));

    //var source = PlayBuf.ar(1,b,loop:1);

    var analysis =
    BeatStatistics.kr(FFT(LocalBuf(1024),source));

    analysis.poll(2); // TODO: Find a better trigger
} ).play;
)


/* Outputs an array representing 10 bands of spectral entropy */
(
SynthDef("trackEntropy", {

var in, fft, entropy, amplitude;

in= SoundIn.ar;

amplitude = Amplitude.kr(in);

fft = FFT(LocalBuf(1024), in);

entropy=SpectralEntropy.kr(fft,1024,10);//10 bands

entropy = entropy * (amplitude.min(0.2)*5.0); //scale by amplitude to avoid low amplitude noise issues

entropy.poll;

//Out.ar(0,Pan2.ar(0.1*Blip.ar((entropy[0])*200,entropy[1].sqrt)));

// Out.ar(0,Splay.ar(0.1*Blip.ar((entropy)*200,entropy.sqrt)));
}).play
)





/* Plots the crest factor of the input over 5 seconds */
(
SynthDef("trackCrest", {
var sig = Mix.new(SoundIn.ar([0,1]));
//var sig = (SoundIn.ar(0).clip2(1));
var val = Crest.kr(sig, 440).poll;
Out.ar(0, sig * 0.1.dup);
K2A.ar(val);
}).plot(5, minval:1, maxval: 4)
)