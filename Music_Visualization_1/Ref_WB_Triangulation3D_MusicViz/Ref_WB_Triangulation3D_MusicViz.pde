///This sketch was modified by undergrad Adrion T. Kelley for University of Oregon Art & Technology (UOAT) 2017
///adrionk@uoregon.edu

////This sketch requires the hemesh and minim Processing libraries




import wblut.geom.*;
import wblut.processing.*;

import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer song;
FFT fft;



WB_RandomPoint source;
WB_Render3D render;
WB_Point[] points;
int numPoints;
int[] tetrahedra;

boolean savePDF = false;

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
  smooth(8);
  
  minim = new Minim(this);
  song = minim.loadFile("groove.mp3");
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.play(0);
  
  
  source=new WB_RandomBox().setSize(500,500,500);
  render=new WB_Render3D(this);
  numPoints=100;
  points=new WB_Point[numPoints];
  for (int i=0; i<numPoints; i++) {
    points[i]=source.nextPoint();
  }
  WB_Triangulation3D triangulation=WB_Triangulate.triangulate3D(points);
  tetrahedra=triangulation.getTetrahedra();// 1D array of indices of tetrahedra, 4 indices per tetrahedron
  println("First tetrahedron: ["+tetrahedra[0]+", "+tetrahedra[1]+", "+tetrahedra[2]+", "+tetrahedra[3]+"]");
 

}


void draw() {
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
  
  
  background(0);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  fill(255*scoreMid/1000,200*scoreHi/1000,255*scoreLow/1000);
  strokeWeight(3*scoreLow/100);
  stroke(random(255),random(255),random(255));
  translate(width/2, height/2);
  rotateY(mouseX*1.0f/width*TWO_PI);
  rotateX(mouseY*1.0f/height*TWO_PI);
  WB_Point center;
  for(int i=0;i<tetrahedra.length;i+=4){
    pushMatrix();
    center=new WB_Point(points[tetrahedra[i]]).addSelf(points[tetrahedra[i+1]]).addSelf(points[tetrahedra[i+2]]).addSelf(points[tetrahedra[i+3]]).mulSelf(0.25+0.25*sin(0.005*frameCount));
  render.translate(center);
  render.drawTetrahedron(points[tetrahedra[i]],points[tetrahedra[i+1]],points[tetrahedra[i+2]],points[tetrahedra[i+3]]);
  popMatrix();
}
}