///modified by Adrion T. Kelley

/*
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

float specLow = 0.03; 
float specMid = 0.125;  
float specHi = 0.20;   

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 25;



boolean savePDF = false;

PImage img;
int drawMode = 1;


void setup() {
  size(603, 873,P3D); 
  smooth();
  
  minim = new Minim(this);
  song = minim.loadFile("song.mp3");
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.play(0);
  
  img = loadImage("pic.png");
  println(img.width+" x "+img.height);
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




  float mouseXFactor = map(mouseX, 0,width, 0.05,1);
  float mouseYFactor = map(mouseY, 0,height, 0.05,1);

  for (int gridX = 0; gridX < img.width; gridX++) {
    for (int gridY = 0; gridY < img.height; gridY++) {
      // grid position + tile size
      float tileWidth = width / (float)img.width;
      float tileHeight = height / (float)img.height;
      float posX = tileWidth*gridX;
      float posY = tileHeight*gridY;

      // get current color
      color c = img.pixels[gridY*img.width+gridX];
      // greyscale conversion
      int greyscale =round(red(c)*0.222+green(c)*0.707+blue(c)*0.071);

      
       //for(int i = 1; i < fft.specSize(); i++)
  //{
     
    //float bandValue = fft.getBand(i)*(1 + (i/50));
    
        stroke(255,greyscale,scoreMid);
        noFill();
        pushMatrix();
        translate(posX, posY);
        rotate(greyscale/255.0 * PI);
        strokeWeight(1 + (scoreGlobal/100));
        rect(0,0,15* scoreLow/20,15* scoreHi/20);
        float w9 = map(greyscale, 0,255, 15,0.1);
        strokeWeight(scoreHi/20);
        stroke(100+scoreLow, 100+scoreMid, 100+scoreHi);
        ellipse(0,0,scoreLow/100,5);
        popMatrix();
        
  
  //}
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}