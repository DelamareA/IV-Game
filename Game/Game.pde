float depth = 100;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;
float boardSpeed = 0.7;

float boardSize = 50;
float ballSize = 3;

boolean addCylinderMode = false;

PVector gravity;

float cylinderBaseSize = 4;
float cylinderHeight = 9;
int cylinderResolution = 40;

PShape closedCylinder = new PShape();
PShape openCylinder = new PShape();
PShape topCylinder = new PShape();
PShape bottomCylinder = new PShape();

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

void setup() {
  size(1000, 700, P3D);  // size always goes first!
  if (frame != null) {
    frame.setResizable(true);
  }
  frameRate(60);

  backgroundSurface = createGraphics(width, 150, P2D);
  topViewSurface = createGraphics(backgroundSurface.height - 10, backgroundSurface.height - 10, P2D);
  scoreSurface = createGraphics(120, backgroundSurface.height - 10, P2D);
  barChartSurface = createGraphics(backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, backgroundSurface.height - 40, P2D);
  nbScoreMax = (int)(barChartSurface.width/(pow(4.0, 0.5)));
  tabScore = new float[nbScoreMax];

  ball = new Mover();
  cylinderList = new ArrayList<PVector>();

  createCylinder();

  score = 0.0;
  totalScore = 0.0;

  hs = new HScrollbar(topViewSurface.width + scoreSurface.width +50, height - 40, backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, 20);
}
void draw() {

  pushMatrix();

  directionalLight(200, 150, 100, 0, -1, 0);
  directionalLight(130, 130, 130, 100, 1, 0);
  ambientLight(102, 102, 102);
  background(200);

  noStroke();

  if (addCylinderMode == true) {
    camera(width/2, 200, 0.1, width/2, height/2, 0, 0, 1, 0);

    translate(width/2, height/2, 0);
    pushMatrix();
    scale(1, 0.07, 1);
    fill(60, 130, 170);
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
    fill(60, 130, 170);
    box(boardSize);
    popMatrix();
  }

  ball.display();

  for (int i=0; i<cylinderList.size (); i++) {
    pushMatrix();
    translate(cylinderList.get(i).x, 0, cylinderList.get(i).y);
    rotateX(PI/2);
    shape(closedCylinder);
    popMatrix();
  }

  popMatrix();

  directionalLight(130, 130, 130, 0, 0, -1);

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

  fill(255);
}

void createCylinder() {

  noStroke();
  fill(255, 0, 0);
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  closedCylinder = createShape(GROUP);

  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();

  topCylinder = createShape();
  topCylinder.beginShape(TRIANGLE_FAN);
  topCylinder.vertex(0, 0, 0);
  for (int i = 0; i < x.length; i++) {
    topCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  topCylinder.endShape();

  bottomCylinder = createShape();
  bottomCylinder.beginShape(TRIANGLE_FAN);
  bottomCylinder.vertex(0, 0, cylinderHeight);
  for (int i = 0; i < x.length; i++) {
    bottomCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  bottomCylinder.endShape();

  closedCylinder.addChild(openCylinder);
  closedCylinder.addChild(topCylinder);
  closedCylinder.addChild(bottomCylinder);
}

void keyPressed() {
  if (key == CODED) {
    /*sif (keyCode == RIGHT) {
     rotationY += 0.06 * boardSpeed;
     } else if (keyCode == LEFT) {
     rotationY -= 0.06 * boardSpeed;
     } else */    if (keyCode == SHIFT) {
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

void mouseDragged() {
  if (!hs.locked) {
    rotationX = -map(mouseY - height/2, -height/2, height/2, -PI/3, PI/3) * boardSpeed;
    if (rotationX < -PI/3)
      rotationX = -PI/3;

    if (rotationX > PI/3)
      rotationX = PI/3;

    rotationZ = map(mouseX - width/2, -width/2, width/2, -PI/3, PI/3) * boardSpeed;
    if (rotationZ < -PI/3)
      rotationZ = -PI/3;

    if (rotationZ > PI/3)
      rotationZ = PI/3;
  }
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0.0) {
    boardSpeed /= 1.1;
  } else {
    boardSpeed *= 1.1;
  }
}

