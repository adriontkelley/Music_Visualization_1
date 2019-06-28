///This sketch was modified by undergrad Adrion T. Kelley for University of Oregon Art & Technology (UOAT) 2017
///adrionk@uoregon.edu


////This sketch requires the minim Processing library



// P_2_1_2_04.pde
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
 * moving corners of rectangles in a grid
 * 	 
 * MOUSE
 * position x          : corner position offset x
 * position y          : corner position offset y
 * left click          : random position
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer song;
FFT fft;



boolean savePDF = false;

 
int tileCount = 20;
int rectSize = 30;

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

void setup(){
  size(1280, 720);
  
   minim = new Minim(this);
  song = minim.loadFile("groove.mp3");
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.play(0);
  
}



void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  
  
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
  

  colorMode(HSB, 360, 150, random(100), 1);
  //background(360);
  smooth();
  noStroke();

  fill(255*scoreLow/100,100,64,scoreLow*60);

  randomSeed(actRandomSeed);

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {
      
      int posX = width/tileCount * gridX;
      int posY = height/tileCount * gridY;

      float shiftX1 = scoreLow/20 * random(-1, 1);
      float shiftY1 = scoreLow/20 * random(-1, 1);
      float shiftX2 = scoreLow/20 * random(-1, 1);
      float shiftY2 = scoreLow/20 * random(-1, 1);
      float shiftX3 = scoreLow/20 * random(-1, 1);
      float shiftY3 = scoreLow/20 * random(-1, 1);
      float shiftX4 = scoreLow/20 * random(-1, 1);
      float shiftY4 = scoreLow/20 * random(-1, 1);
     
      beginShape();
      vertex(posX+shiftX1, posY+shiftY1);
      vertex(posX+rectSize+shiftX2, posY+shiftY2);
      vertex(posX+rectSize+shiftX3, posY+rectSize+shiftY3);
      vertex(posX+shiftX4, posY+rectSize+shiftY4);
      endShape(CLOSE);
    }
  } 
  
  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void mousePressed() {
  actRandomSeed = (int) random(100000);
}


void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}