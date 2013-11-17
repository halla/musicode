SqrOsc melody => Pan2 p => dac;
SqrOsc base => Pan2 p2 => dac;
Gain master => dac;
0.9 => float masterGain;


SndBuf snare => Pan2 snarePan => dac; // current snare
SndBuf hihat => master;
SndBuf kick => master;
SndBuf click => master;


["/audio/snare_01.wav", "/audio/snare_02.wav", "/audio/snare_03.wav"] @=> string snareFiles[];


me.dir() + snareFiles[1] => snare.read; // read wav from a string array...
<<< me.dir() + snareFiles[0]>>>;
1 => snare.gain;
0 => snare.pos;
1 => snare.rate;

me.dir() + "/audio/kick_05.wav" => kick.read;
me.dir() + "/audio/hihat_02.wav" => hihat.read;
me.dir() + "/audio/click_01.wav" => click.read;

// dorian scale (first position is a fill)
[ 50, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67, 69, 71, 72, 74] @=> int dorian[];


// a few different melodies to be used in the tune
[5,5,4,4,3,3,2,2,7] @=> int melodyNotes1[];
[3,3,4,4,8,8,9,9,11,11,12,12] @=> int melodyNotes2[];
[5,6,7,8,9,10,11,10,9,8,7,11,12,13,12,11,10,9,8,7,8] @=> int melodyNotes3[];
[5,5,4,4,3,3,2,2,8] @=> int melodyNotes4[];
[5,5,8,8,7,7,9,9,8,8,1,1,1,1,8,8,5,5,3,3,15] @=> int melodyNotes5[];
melodyNotes1 @=> int melodyNotes[]; //current melody

0 => int iMelody; //current melody index

now => time time_start;

0 => int i;
kick.samples() => kick.pos;
hihat.samples() => hihat.pos;

// DEFAULT GAINS
0.0 => hihat.gain;
1 => kick.gain;
0.5 => float snareGain;
0.0 => float baseGain;   
0.0 => float melodyGain;

0.03 => float melodyGainDefault;

// PAN for melody and base
.4 => p.pan;
-.4 => p2.pan;

// DEFAULT RATES
1 => float rate_hihat;
1 => float rate_kick;
0.2 => float rate_snare;
1 => float rate_click; 


// TIMING:
//
// quarter = .25s 
// 30s = 120 quarters
// one loop = sixteenth => one bar = 16 loops
// 120 quarters = 480 sixteenths => 30s = 480 loops
// 480 loops = 30 bars
250::ms => dur quarter;
quarter/2 => dur eight;
eight/2 => dur sixteenth;


// PARTS 
0 => int bar_begin_intro;
4 => int bar_begin_part_a;
24 => int bar_begin_outro;
30 => int bar_end;

// store the info on current part
1 => int is_intro;
0 => int is_part_a;
0 => int is_outro;

// OTHER TERMS
int beat;
int bar;
1 => int is_even_bar;
1 => int is_upbeat;
0 => int is_downbeat;


// SEQUENCER
for (0 => int i; i < 120*4; 1+=>i) {    
    
    // setup human readable variable names
    i % 16 => beat;
    i / 16 => bar;
    (beat % 8 == 0) => is_upbeat;
    ((beat+4) % 8 == 0) => is_downbeat;
    (bar % 2 == 0) => is_even_bar;
    (bar >= bar_begin_intro && bar < bar_begin_part_a) => is_intro;
    (bar >= bar_begin_part_a && bar < bar_begin_outro) => is_part_a;
    (bar >= bar_begin_outro && bar < bar_end) => is_outro;
    

    // INTRODUCTION
    if (is_intro || is_outro) {

        if (bar == bar_begin_intro && beat == 0) {
            <<< "Intro" >>>;    
        }
        Math.random2f(0.1,0.3) => snareGain;
        0 => click.pos;
        1 +=> rate_click;       
      
         
    }
    // PART A
    if (is_part_a) {
        Math.random2f(0.1,0.2) => snareGain; // slight random variation in the volume
        Math.random2f(-0.7,0.7) => snarePan.pan; // pan the snare randomly across the field
        if (bar == bar_begin_part_a && beat == 0) {
            <<< "Part A" >>>;
        }
        0 => hihat.pos;    
        0.1 => hihat.gain;
        if (is_even_bar) {
            0 => snare.pos;            
        } else {
            snare.samples() => snare.pos;
        }
                 
        
        if (bar < (bar_begin_part_a + 4)) {
            if (beat == 0) {            
                1 => kick.gain;            
                1 => rate_kick;            
                0 =>  kick.pos;                                                      
            } 
            if (beat == 0) {
            if (is_even_bar) {
                2 => rate_snare;    
            } else {            
                -2 => rate_snare;
            }                
            1 => rate_hihat;                
        }

        } else {
            if (beat == 0) {            
                1 => kick.gain;            
                1 => rate_kick;            
                0 =>  kick.pos;                    
               
            }
            if (beat == 8) {
                1 => rate_hihat;
                if (is_even_bar) {
                    1 +=> rate_snare;        
                } else {
                    1 -=> rate_snare;    
                }        
            }

        }
        

        if (bar == (bar_begin_part_a + 4)  && beat == 0)  {

            0.05 => baseGain;
            Std.mtof(dorian[5]-24) => base.freq;
            melodyGainDefault => melodyGain;
            0.1 => hihat.gain;
            melodyNotes1 @=> melodyNotes;
            0 => iMelody;             

        }

        if (bar == (bar_begin_part_a + 8) && beat == 0) {
            Std.mtof(dorian[1]-24) => base.freq;
            melodyGainDefault => melodyGain;
            melodyNotes2 @=> melodyNotes;
            0 => iMelody;
        }
        if (bar == (bar_begin_part_a + 12) && beat == 0) {
            Std.mtof(dorian[4]-24) => base.freq;
            melodyGainDefault => melodyGain;
            melodyNotes3 @=> melodyNotes;
            0 => iMelody;
        }
        if (bar == (bar_begin_part_a + 16) && beat == 0) {
            Std.mtof(dorian[1]-24) => base.freq;
            melodyGainDefault => melodyGain;
            melodyNotes4 @=> melodyNotes;
            0 => iMelody;
        }        

        if (bar >= (bar_begin_part_a + 4)) {                                

            dorian[melodyNotes[iMelody]] => int note; 
            Std.mtof(note) => melody.freq;
            if (iMelody < melodyNotes.cap()-1) {               
                1 +=> iMelody;     

            } else {
                
                0.0005 -=> melodyGain;
                
            }
            
            if (beat == 4) {
                if (is_even_bar) {
                    2 => rate_snare;    
                } else {            
                    -2 => rate_snare;
                }                
                1 => rate_hihat;                
            }
        }

        -0.1 +=>  rate_hihat;
        -0.1 +=> rate_kick;

    }
        
    
    // OUTRO
    if (is_outro) {

        if (bar == bar_begin_outro && beat == 0) {
            <<< "Outro" >>>;
            melodyNotes5 @=> melodyNotes;
            0 => iMelody;
            melodyGainDefault => melodyGain;
            
        }
        dorian[melodyNotes[iMelody]] => int note; //  
        Std.mtof(note) => melody.freq;
        Std.mtof(note-24) => base.freq;
        if (iMelody < melodyNotes.cap()-1) {
            1 +=> iMelody;     
        }
        if (bar >= (bar_begin_outro + 2)) {
            if (melodyGain > 0) {
                0.005 -=> melodyGain;
                0.005 -=> baseGain;
            } else {
                0 => baseGain;
            }
        }
        if (bar >= (bar_begin_outro + 4)) {
            if (masterGain > 0) {
                0.1 -=> masterGain;    
            }
            
        }

    }
    //update gains, rates, volumes
    rate_hihat => hihat.rate;
    rate_snare => snare.rate;
    rate_kick => kick.rate;
    rate_click => click.rate;
    melodyGain => melody.gain;
    baseGain => base.gain;
    snareGain => snare.gain;
    masterGain => master.gain;
    sixteenth => now; //run the loop 4x speed so we can fit more stuff in
}


<<< "Time: ", (now - time_start)/second, "seconds." >>>;
