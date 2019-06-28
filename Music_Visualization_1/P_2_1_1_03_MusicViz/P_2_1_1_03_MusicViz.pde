///This sketch was modified by undergrad Adrion T. Kelley for University of Oregon Art & Technology (UOAT) 2017
///adrionk@uoregon.edu

////This sketch requires the minim Processing library


// P_2_1_1_03.pde
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
 * changing number, color and strokeweight on diagonals in a grid
 * 	 
 * MOUSE
 * position x          : diagonal strokeweight
 * position y          : number diagonals
 * left click          : new random layout
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 * 1                   : color left diagonal
 * 2                   : color right diagonal
 * 3                   : switch transparency left diagonal on/off
 * 4                   : switch transparency right diagonal on/off
 * 0                   : default
 */

import processing.pdf.*;
import java.util.Calendar;

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;


boolean savePDF = false;

color colorBack = color(255);
color colorLeft = color(0);
color colorRight = color(0);

float tileCount = 1;
boolean transparentLeft = false;
boolean transparentRight = false;
float alphaLeft = 100;
float alphaRight = 100;

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
  size(1280, 720);

minim = new Minim(this);
  song = minim.loadFile("groove.mp3");
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.play(0);

  colorMode(HSB, 360, random(360), random(360), 100);
  colorLeft = color(323, 100, 77);
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


  colorMode(HSB, 360, random(360), 360, scoreMid/100);
  //background(colorBack);
  smooth();
  noFill();
  randomSeed(actRandomSeed);
  strokeWeight(random(15));

  tileCount = 15*scoreLow/100;

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {

      float posX = width/tileCount*gridX;
      float posY = height/tileCount*gridY;

      if (transparentLeft == true) alphaLeft = gridY*10; 
      else alphaLeft = 300;

      if (transparentRight == true) alphaRight = 100-gridY*10; 
      else alphaRight = 300;

      int toggle = (int) random(0,2);

      if (toggle == 0) {
        stroke(colorLeft, alphaLeft*scoreMid/10);
        line(posX, posY, posX+(width/tileCount)/2, posY+height/tileCount);
        line(posX+(width/tileCount)/2, posY, posX+(width/tileCount), posY+height/tileCount);
      }
      if (toggle == 1) {
        stroke(colorRight, alphaRight*scoreLow/10);
        line(posX, posY+width/tileCount, posX+(height/tileCount)/2, posY);
        line(posX+(height/tileCount)/2, posY+width/tileCount, posX+(height/tileCount), posY);
      }
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

  if (key == '1'){
    if (colorLeft == color(273, 73, 51)) {
      colorLeft = color(323, 100, 77);
    } 
    else {
      colorLeft = color(273, 73, 51);
      //      colorLeft = color(0);
    } 
  }
  if (key == '2'){
    if (colorRight == color(0)) {
      colorRight = color(192, 100, 64);
    } 
    else {
      colorRight = color(0);
    } 
  }
  if (key == '3'){
    transparentLeft =! transparentLeft;
  }
  if (key == '4'){
    transparentRight =! transparentRight;
  }

  if (key == '0'){
    transparentLeft = false;
    transparentRight = false;
      colorLeft = color(323, 100, 77);
      colorRight = color(0);
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}