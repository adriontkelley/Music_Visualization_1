///This sketch was modified by undergrad Adrion T. Kelley for University of Oregon Art & Technology (UOAT) 2017
///adrionk@uoregon.edu

////This sketch requires the minim Processing library





// P_1_2_3_04.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * generates a specific color palette and some random "rect-tilings"
 * 
 * MOUSE
 * left click          : new composition
 * 
 * KEYS
 * s                   : save png
 * c                   : save color palette
 */

import generativedesign.*;
import processing.opengl.*;
import java.util.Calendar;

import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer song;
FFT fft;



int colorCount = 20;
int[] hueValues = new int[colorCount];
int[] saturationValues = new int[colorCount];
int[] brightnessValues = new int[colorCount];

int actRandomSeed = 0;


float stepX;
float stepY;

float specLow = 0.01; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 100;


void setup() {
  size(1280, 720, P3D); 
  colorMode(HSB, 360, 100, 100);
  noStroke();
  
  minim = new Minim(this);
  song = minim.loadFile("groove.mp3");
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.play(0);
}

void draw() { 
  //background(0,0,0);
  randomSeed(actRandomSeed);
  
  
  fft.forward(song.mix);
  
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
   scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
  
   for(int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }
  
  
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }
  
  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }
  
  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }


float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;

background(scoreLow/100, scoreMid/100, scoreHi/100);

 float previousBandValue = fft.getBand(0);
float dist = -25;
float heightMult = 2;

  noStroke();
  colorMode(HSB, width*random(scoreLow/3000), height*scoreLow/3000, random(255));
  

  // ------ colors ------
  // create palette
  for (int i=0; i<colorCount; i++) {
    if (i%2 == 0) {
      hueValues[i] = (int) random(0,360);
      saturationValues[i] = 100;
      brightnessValues[i] = (int) random(0,255);
    } 
    else {
      hueValues[i] = 195;
      saturationValues[i] = (int) random(0,255);
      brightnessValues[i] = 255;
    }
  }

  // ------ area tiling ------
  // count tiles
  int counter = 0;
  // row count and row height
  int rowCount = (int)random(5,30);
  float rowHeight = (float)height/(float)rowCount;

  // seperate each line in parts  
  for(int i=rowCount; i>=0; i--) {
    // how many fragments
    int partCount = i+1;
    float[] parts = new float[0];

    for(int ii=0; ii<partCount; ii++) {
      // sub fragments or not?
      if (random(1.0) < 0.075) {
        // take care of big values   
        int fragments = (int)random(2,20);
        partCount = partCount + fragments; 
        for(int iii=0; iii<fragments; iii++) {
          parts = append(parts, random(2));
        }              
      }  
      else {
        parts = append(parts, random(2,20));   
      }
    }

    // add all subparts
    float sumPartsTotal = 0;
    for(int ii=0; ii<partCount; ii++) sumPartsTotal += parts[ii];

    // draw rects
    float sumPartsNow = 0;
    for(int ii=0; ii<parts.length; ii++) {
      sumPartsNow += parts[ii];

      if (random(1.0) < 0.45) {
        float x = map(sumPartsNow, 0,sumPartsTotal, 0,width)+random(-10,10);
        float y = rowHeight*i+random(-10,10);
        float w = map(parts[ii], 0,sumPartsTotal, 0,width)*-1+random(-10,10);
        float h = rowHeight*1.5*scoreLow/100;

        beginShape();
        fill(0,scoreHi,0, random(255));
        vertex(x,y);
        vertex(x+w,y);
        // get component color values + aplha
        int index = counter % colorCount;
        fill(random(hueValues[index]),saturationValues[index],brightnessValues[index]*scoreLow/100,100);
        vertex(x+w,y+h);
        vertex(x,y+h);
        endShape(CLOSE);
      }

      counter++;
      actRandomSeed = (int) random(100000);
    }
  }  
} 



void keyReleased() {  
  if (key == 't' || key == 'T') actRandomSeed = (int) random(100000);
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'c' || key == 'C') {
    // ------ save an ase file (adobe swatch export) ------
    // create palette
    color[] colors = new color[colorCount];
    for (int i=0; i<colorCount; i++) {
      colors[i] = color(hueValues[i],saturationValues[i],brightnessValues[i]);
    }
    GenerativeDesign.saveASE(this, colors, timestamp()+".ase");
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}