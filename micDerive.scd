/* Separate a mono input's harmonic and percussive elements
    Expensive process to run, so should be triggered by another event
    Save these to a buffer for later use, instead of simply outputting to master bus
*/
(
{
var harmonic, percussive;
	var source = SoundIn.ar(0);
var fft = FFT(LocalBuf(1024),source);

#harmonic,percussive = MedianSeparation(fft,FFTTrigger(LocalBuf(1024)),FFTTrigger(LocalBuf(1024)),1024,17);

[IFFT(harmonic),IFFT(percussive)]    //reconstruct harmonic to left ear, percussive to right

}.play
)












(
SynthDef("detectSilence-help", { arg out;
    var z;
	z = Mix.new(SoundIn.ar([0,1]));
    DetectSilence.ar(z, doneAction: Done.freeSelf);
    Out.ar(out, z);
}).add;
)

Synth("detectSilence-help");

