import papaya.*;

import processing.video.*;
import java.util.Comparator;
import java.util.Collections;
import java.util.Random;

float depth = 100;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;
float boardSpeed = 0.7;

float boardSize = 50;
float ballSize = 2;

boolean addCylinderMode = false;

PVector gravity;

float cylinderBaseSize = 1;
float cylinderHeight = 9;
int cylinderResolution = 40;

PShape closedCylinder = new PShape();
PShape openCylinder = new PShape();
PShape topCylinder = new PShape();
PShape bottomCylinder = new PShape();

PShape sheep_shape_alive = new PShape();
PShape sheep_shape_dead = new PShape();
ArrayList<Sheep> sheeps;
int sheeps_num = 5;
PImage background;

ArrayList<PVector> cylinderList;

float coin1; // coin du plateau 1 
float coin2; // coin du plateau 2 

PGraphics backgroundSurface;
PGraphics topViewSurface;
PGraphics scoreSurface;
PGraphics barChartSurface;

float score;
float totalScore;
int nbCurrentScore = 0;
int nbScoreMax;

int timeSinceLastEvent = 0;

float[] tabScore;

Mover ball;
HScrollbar hs;

//Capture cam;
Movie cam;
PImage img;
PImage imgTest;
PImage sob;
PImage back;

int hueThLow = 105;
int hueThHigh = 140;
int saturationThLow = 115;
int saturationThHigh = 255;
int brightnessThLow = 65;
int brightnessThHigh = 255;

int hueThLow3 = 110; // used for a better detection of the board, used in the 'preHueTh' function
int hueThHigh3 = 130;
int saturationThLow3 = 115;
int saturationThHigh3 = 255;
int brightnessThLow3 = 65;
int brightnessThHigh3 = 255;

ArrayList<int[]> cycles = new ArrayList<int[]>();
int[][] graph;


void setup() {
  size(1000, 700, P3D);  // size always goes first!
  if (frame != null) {
    frame.setResizable(true);
  }
  frameRate(60);
  
  back = loadImage("background.jpg");
  back.resize(width, height);

  backgroundSurface = createGraphics(width, 150, P2D);
  topViewSurface = createGraphics(backgroundSurface.height - 10, backgroundSurface.height - 10, P2D);
  scoreSurface = createGraphics(120, backgroundSurface.height - 10, P2D);
  barChartSurface = createGraphics(backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, backgroundSurface.height - 40, P2D);
  nbScoreMax = (int)(barChartSurface.width/(pow(4.0, 0.5)));
  tabScore = new float[nbScoreMax];

  ball = new Mover();
  cylinderList = new ArrayList<PVector>();
  closedCylinder = loadShape("tourTextUnit.obj");
  closedCylinder.scale(0.12f);
  closedCylinder.rotateX(PI/2);
  
  sheeps = new ArrayList<Sheep>();
  createSheeps();
  sheep_shape_alive = loadShape("Sheep.obj");
  sheep_shape_alive.scale(10.f);
  sheep_shape_dead = loadShape("blood2.obj");
  sheep_shape_dead.scale(20.0f, 20.f, 10.0f);
  sheep_shape_dead.rotateX(PI/2);

  score = 0.0;
  totalScore = 0.0;

  hs = new HScrollbar(topViewSurface.width + scoreSurface.width +50, height - 40, backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, 20);
  
  /*String[] cameras = Capture.list(); // Code for webcam
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[7]);
    cam.start();
  }*/
  
  cam = new Movie(this, "C:/Users/HP/Documents/EPFL/4/InfoVisuel/Game/testvideo.mp4");
  cam.loop();

}


void createSheeps(){
    for (int i = 0; i < sheeps_num; i++){
      sheeps.add(new Sheep(new PVector(random(-boardSize/2, boardSize/2),random(-boardSize/2, boardSize)/2), boardSize));
      sheeps.get(i).sheep_orientation = random(-PI, PI); 
    }
    
}

void draw() {
  pushMatrix();
  
  
  directionalLight(200, 150, 100, 0, -1, 0);
  directionalLight(130, 130, 130, 100, 1, 0);
  directionalLight(130, 130, 130, 0, 0, -1);
  ambientLight(102, 102, 102);
  image(back, 0, 0);

  noStroke();

  if (addCylinderMode == true) {
    camera(width/2, 200, 0.1, width/2, height/2, 0, 0, 1, 0);

    translate(width/2, height/2, 0);
    pushMatrix();
    scale(1, 0.07, 1);
    fill(0, 91, 0);
    box(boardSize);
    popMatrix();
    // on determine la positions des coins sur l'ecran
    coin1 = screenX(-boardSize/2, 0, boardSize/2);
    coin2 = screenX(boardSize/2, 0, boardSize/2);
  } else {
    ball.checkEdges();
    ball.checkCylinderCollision();


    camera(width/2, height/2 - 20, depth, width/2, height/2, 0, 0, 1, 0);

    translate(width/2, height/2, 0);

    rotateX(rotationX);
    rotateY(rotationY);
    rotateZ(rotationZ);

    pushMatrix();
    scale(1, 0.07, 1);
    fill(0, 91, 0);
    box(boardSize);
    popMatrix();
  }

  ball.display();

  for (int i=0; i<cylinderList.size (); i++) {
    pushMatrix();
    translate(cylinderList.get(i).x, -1, cylinderList.get(i).y);
    rotateX(PI/2);
    shape(closedCylinder);
    popMatrix();
  }
  
  for (int i = 0 ; i < sheeps.size(); i ++){
    sheeps.get(i).Sheep_move();
     pushMatrix();
     if (sheeps.get(i).sheep_is_alive){
        translate(sheeps.get(i).sheep_position.x, -3.2 - sheeps.get(i).sheep_height , sheeps.get(i).sheep_position.y);
     }
     else{
         translate(sheeps.get(i).sheep_position.x, -1.65 , sheeps.get(i).sheep_position.y); 
     }
    rotateX(PI/2);
    rotateZ(sheeps.get(i).sheep_orientation);
    if (sheeps.get(i).sheep_is_alive){
      shape(sheep_shape_alive);
    }
    else{
       shape(sheep_shape_dead); 
    }
    popMatrix();
  }

  popMatrix();

  drawBackgroundSurface();
  drawScoreSurface();
  drawBarChartSurface();
  drawTopViewSurface();
  image(backgroundSurface, 0, height - backgroundSurface.height);
  image(topViewSurface, 5, height-backgroundSurface.height+5);
  image(scoreSurface, topViewSurface.width + 20, height - scoreSurface.height - 5);
  image(barChartSurface, topViewSurface.width + scoreSurface.width +50, height - scoreSurface.height - 5);

  hs.update();
  hs.display();
  
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  //img = loadImage("testReflet.png");
  img.resize(320, 240);
  image(img, 0, 0);
  
  //sob = sobel(whiteTh(convolute(hueTh(convolute(convolute(convolute(img)))))));
  PVector[][] gradient = new PVector[img.width][img.height];
  for (int i = 0; i < img.width; i++){
    for (int j = 0; j < img.height; j++){
      gradient[i][j] = new PVector();
    }
  }
  sob = sobel(whiteTh(convolute(hueTh(preHueTh(convolute(convolute(convolute(img))))))) , gradient);
  //sob = sobel(testQuad(img));
  //image(imgTest, 0, 0);
  //image(whiteTh(convolute(hueTh(preHueTh(convolute(convolute(img)))))), 0, 0);
  //image(sob, 0, 0);
  //image(preHueTh3(convolute(convolute(img))), 0, 0);
  
  //sob = sobel(preHueTh2(convolute(convolute(img))));
  hough(sob, 4, gradient);
  
  fill(255);
}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      addCylinderMode = true;
    }
  }
  
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      addCylinderMode = false;
    }
  }
}

void mouseClicked() {
  if (addCylinderMode == true) {

    float boardWidthOnScreen = coin2 - coin1;
    float zoom = boardSize/boardWidthOnScreen;
    float x = mouseX - width/2;
    float y = mouseY - height/2;

    if (width/2 - boardWidthOnScreen/2 <= mouseX && mouseX <= width/2 + boardWidthOnScreen/2 && height/2 - boardWidthOnScreen/2 <= mouseY && mouseY <= height/2 + boardWidthOnScreen) { // PAS CHANGER

      PVector n = new PVector(ball.location.x, 0, ball.location.z);
      n.sub(new PVector(x*zoom, 0, y*zoom));

      if (n.mag() > cylinderBaseSize + ballSize) { // cylindre pas dans ball
        cylinderList.add(new PVector(x*zoom, y*zoom));
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0.0) {
    boardSpeed /= 1.1;
  } else {
    boardSpeed *= 1.1;
  }
}

