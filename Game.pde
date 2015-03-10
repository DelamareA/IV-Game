float depth = 100;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;
float boardSpeed = 0.7;

float boardSize = 50;

PVector ballLocation;
PVector ballVelocity;
PVector gravity;

void setup() {
  size(1000, 700, P3D);  // size always goes first!
  if (frame != null) {
    frame.setResizable(true);
  }
  frameRate(60);
  
  ballLocation = new PVector(0, -4.65, 0);
  ballVelocity = new PVector(0, 0, 0);
  gravity = new PVector(0, 0.04, 0);
}
void draw() {
  movement();
  
  noStroke();
  camera(width/2, height/2 - 20, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(200, 150, 100, 0, -1, 0);
  directionalLight(130, 130, 130, 100, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  
  pushMatrix();
  translate(width/2, height/2, 0);
  
  rotateX(rotationX);
  rotateY(rotationY);
  rotateZ(rotationZ);
  pushMatrix();
  scale(1, 0.07, 1);
  
  
  fill(60, 130, 170);

  box(boardSize);
  popMatrix();
  fill(0, 255, 0);
  translate(ballLocation.x, ballLocation.y, ballLocation.z);
  sphere(3);
  popMatrix();
}

void movement(){
  PVector gravityForce = new PVector(sin(rotationZ) * gravity.y, 0, -sin(rotationX) * gravity.y);
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  PVector friction = ballVelocity.get();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);
  
  ballVelocity.add(gravityForce);
  ballVelocity.add(friction);
  
  ballLocation.add(ballVelocity);
  
  if ((ballLocation.x > boardSize/2) || (ballLocation.x < -boardSize/2)) {
    ballVelocity.x = ballVelocity.x * -1;
  }
  if ((ballLocation.z > boardSize/2) || (ballLocation.z < -boardSize/2)) {
    ballVelocity.z = ballVelocity.z * -1;
  }

}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      rotationY += 0.06 * boardSpeed;
    }
    else if (keyCode == LEFT) {
      rotationY -= 0.06 * boardSpeed;
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
