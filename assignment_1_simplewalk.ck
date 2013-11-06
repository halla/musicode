<<< "Assignment_1_SimpleWalk." >>>;

SqrOsc base => dac;
SinOsc melody => dac;

0.3 => base.gain;
now => time timeStart;
<<< "Start time:", timeStart >>>;

// setup note durations
700::ms => dur whole;
whole/8 => dur eight;
whole/4 => dur quarter;

10 => int nBars; //number of bars in the song

[220, 330, 440, 550] @=> int walk1[]; // the bass line
[440, 550, 330, 400] @=> int mel1[]; // melody
1 => int walkDivisor; // to lower the base line one octave when the melody starts

for (0 => int iBar; iBar < nBars; 1 +=> iBar) {
    
    if (iBar >= 2) {
        mel1[(iBar-2)%4] => melody.freq;    
        2 => walkDivisor; //lower the bass line
    } else {
        0 => melody.freq; //mute the melody
    }
    
    for (0 => int i; i < walk1.size() ; 1 +=> i) {
        walk1[i] / walkDivisor => base.freq;
        quarter => now;    
    }
    0 => base.freq;
    whole => now;

    [330, 440, 550, 660] @=> int walk2[];

    for (0 => int i; i < walk2.size() ; 1 +=> i) {
        walk2[i] / walkDivisor => base.freq;
        quarter => now;    
    }
    0 => base.freq;
    whole => now;

}
now => time timeNow;
(timeNow - timeStart) => dur durationNow;
30::second => dur durationFull;
durationFull - durationNow => dur fill;

//final note
220 => base.freq;
440 => melody.freq;
fill => now;

now => time timeEnd;
(timeEnd - timeStart) / 48000 => dur duration;
<<< "Song duration (in seconds, assuming 48000 samplerate): ", duration >>>;
