<<< "Assignment_2_RandorianCadence." >>>;


//two oscillators for melody: silent and loud.
SinOsc melody => Pan2 p => dac;
SqrOsc melody2 => Pan2 p2 => dac;
//three oscs to create chords
SinOsc chord1 => Pan2 pChd1 => dac;
SinOsc chord2 => Pan2 pChd2 => dac;
SinOsc chord3 => Pan2 pChd3 => dac;
[chord1, chord2, chord3] @=> SinOsc chord[];


.25::second => dur quarter; // quarter note duration

[50, 52, 53, 55, 57, 59, 60, 62] @=> int scale[]; //dorian scale


[1,3,5] @=> int chd1[]; //1st chord 
[1,4,6] @=> int chd4[]; //4th
[2,5,7] @=> int chd5[]; //5th 
[1,3,6] @=> int chd6[]; //6th
[2,4,7] @=> int chd7[]; //7th
chd1 @=> int chordCurrent[]; //current chord notes

// set initial gains and pan
1 => float melodygain;
0 => float melody2gain;
0 => float chd1gain;
0 => float chd2gain;
0 => float chd3gain;

-0.4 => pChd1.pan;
0 => pChd2.pan;
0.4 => pChd3.pan;
-0.60 => float myPan;

//raise melody one octave when chord plays
1 => int melodyMultiplier;

// quarter per loop => 4 loops per bar, 120 quarters => 30 seconds
for (0 => int i; i < 120; 1 +=> i) {
    if (myPan < 1.0) {
        0.01 +=> myPan; // gradually pan the melody across the field
    } else {
	-1.0 => myPan; // should not get here but reset just in case
    }	
    p.pan(myPan);
    p2.pan(myPan);
    if (i == 16) { // unmute the chord
    	0.3 => chd1gain;	
	    0.3 => chd2gain;
    	0.3 => chd3gain;
        0.1 => melodygain;  // to minimize clipping
    } else if (i > 16 && i < 24) {
        0.010 +=> melody2gain;  // cross fade the melodyy oscillators
        if (melodygain > 0) {      
            0.1 -=> melodygain;
        }
    } else if (i == 32) { //chord cadence continues
        0 => melodygain;
	    chd5 @=> chordCurrent;
    } else if (i == 48) {
    	chd1 @=> chordCurrent;
    } else if (i == 56) {
        chd6 @=> chordCurrent;
    } else if (i == 64) {
        chd4 @=> chordCurrent;
    } else if (i == 72) {
        chd5 @=> chordCurrent;
    } else if (i == 80) {
        chd1 @=> chordCurrent;
        0.005 -=> melody2gain;
    } else if (i > 96 && i < 106 ) { //fade out chord, crossfade melody oscillators
        0.04 -=> chd1gain;
        0.04 -=> chd2gain;
        0.04 -=> chd3gain; 
        if (melody2gain > 0) {        
            0.01 -=> melody2gain;
        }
        0.05 +=> melodygain;   
    } else if (i == 106) { 
        0 => chd1gain;
        0 => chd2gain;
        0 => chd3gain;
        Std.mtof(scale[0]) => melody.freq => melody2.freq;
    } else if (i > 106 && i < 116) { //fade out melody
        0 => melody2gain;
        if (melodygain > 0) {       
            0.05 -=> melodygain;
        }   
    } else if (i == 116) {
        0 => melodygain;
    }


    for (0 => int i; i<chordCurrent.cap(); 1 +=> i) { //update the chord
	  Std.mtof(scale[chordCurrent[i]-1]) =>  chord[i].freq;;
    }
    // set the gain and pan on every loop (mainly to avoid copy-paste code)
    melodygain => melody.gain;
    melody2gain => melody2.gain;
    chd1gain => chord1.gain;
    chd2gain => chord2.gain;
    chd3gain => chord3.gain;
    scale[Math.random2(0, scale.cap()-1)] => int note; // the melody comes by picking random notes from the dorian scale
    if (i < 106) { //dont overwrite endnote    
        Std.mtof(melodyMultiplier*note)  => melody.freq;
        Std.mtof(melodyMultiplier*note)  => melody2.freq;
    }

    quarter => now; // tempo is one quarter per loop
}

