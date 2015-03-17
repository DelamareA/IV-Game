class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  Mover() {
    location = new PVector(0, -4.65, 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0.04, 0);
  }
  
  void update() {
    location.add(velocity);
  }
  void display() {
    pushMatrix();
    fill(0, 255, 0);
    translate(location.x, location.y, location.z);
    sphere(ballSize);
    popMatrix();
  }
  void checkEdges() {
    PVector gravityForce = new PVector(sin(rotationZ) * gravity.y, 0, -sin(rotationX) * gravity.y);
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    velocity.add(gravityForce);
    velocity.add(friction);
    
    location.add(velocity);
    
    if (location.x > boardSize/2){
      velocity.x = velocity.x * -1;
      location.x = boardSize/2;
    }
    
    if (location.x < -boardSize/2){
      velocity.x = velocity.x * -1;
      location.x = -boardSize/2;
    }
    
    if (location.z > boardSize/2){
      velocity.z = velocity.z * -1;
      location.z = boardSize/2;
    }
    
    if (location.z < -boardSize/2){
      velocity.z = velocity.z * -1;
      location.z = -boardSize/2;
    }
  }
  
  void checkCylinderCollision(){
    
     for (int i=0; i<cylinderList.size(); i++){
       PVector n = new PVector(location.x, 0, location.z);
       n.sub(new PVector(cylinderList.get(i).x, 0, cylinderList.get(i).y));
       
       if (n.mag() < cylinderBaseSize + ballSize){ // collision
         n.normalize();
         PVector temp = n.get();
         temp.mult(2);
         temp.mult(velocity.dot(n));
         velocity.sub(temp);
         
         location.add(velocity); // detach the ball
       }
       
        
     }
    
  }
}

