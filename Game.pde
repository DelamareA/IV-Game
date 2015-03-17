float depth = 100;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;
float boardSpeed = 0.7;

float boardSize = 50;

boolean addCylinderMode = false;

PVector ballLocation;
PVector ballVelocity;
PVector gravity;

float cylinderBaseSize = 4;
float cylinderHeight = 9;
int cylinderResolution = 40;

PShape closedCylinder = new PShape();
PShape openCylinder = new PShape();
PShape topCylinder = new PShape();
PShape bottomCylinder = new PShape();

ArrayList<PVector> cylinderList;

Mover ball;

void setup() {
  size(1000, 700, P3D);  // size always goes first!
  if (frame != null) {
    frame.setResizable(true);
  }
  frameRate(60);
  
  ball = new Mover();
  cylinderList = new ArrayList<PVector>();
  
  createCylinder();
}
void draw() {
  
  directionalLight(200, 150, 100, 0, -1, 0);
  directionalLight(130, 130, 130, 100, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  
  if (addCylinderMode == true){
    camera(width/2, 200, 0.1, width/2, height/2, 0, 0, 1, 0);
    
    translate(width/2, height/2, 0);
    pushMatrix();
    scale(1, 0.07, 1);
    fill(60, 130, 170);
    box(boardSize);
    popMatrix();
  }
  else {
    ball.checkEdges();
  
    noStroke();
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
    
    ball.display();
  }
  
  for (int i=0; i<cylinderList.size(); i++){
    pushMatrix();
    translate(cylinderList.get(i).x, 0, cylinderList.get(i).y);
    rotateX(PI/2);
    //rotateY(rotationY);
    //rotateZ(rotationZ);
    shape(closedCylinder);
    popMatrix();
  }
  
  
}

void createCylinder(){
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
  topCylinder.beginShape(TRIANGLES);
  for (int i = 1; i < x.length; i++) {
    topCylinder.vertex(x[i], y[i], 0);
    topCylinder.vertex(x[i-1], y[i-1], 0);
    topCylinder.vertex(0, 0, 0);
  }
  topCylinder.endShape();
  
  bottomCylinder = createShape();
  bottomCylinder.beginShape(TRIANGLES);
  for (int i = 1; i < x.length; i++) {
    bottomCylinder.vertex(x[i], y[i], cylinderHeight);
    bottomCylinder.vertex(x[i-1], y[i-1], cylinderHeight);
    bottomCylinder.vertex(0, 0, cylinderHeight);
  }
  bottomCylinder.endShape();
  
  closedCylinder.addChild(openCylinder);
  closedCylinder.addChild(topCylinder);
  closedCylinder.addChild(bottomCylinder); 
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      rotationY += 0.06 * boardSpeed;
    }
    else if (keyCode == LEFT) {
      rotationY -= 0.06 * boardSpeed;
    }
    else if (keyCode == SHIFT) {
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
  if (addCylinderMode == true){
    if (mouseX >= 250 && mouseX <= 740 && mouseY >= 100 && mouseY <= 590){ // A CHANGER
      float x = map(mouseX, 250, 740, -boardSize/2, boardSize/2);
      float y = map(mouseY, 100, 590, -boardSize/2, boardSize/2);
      
      cylinderList.add(new PVector(x, y));
    }
  }
}

void mouseDragged() {
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

void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0.0){
    boardSpeed /= 1.1;
  }
  else {
    boardSpeed *= 1.1;
  }
}
