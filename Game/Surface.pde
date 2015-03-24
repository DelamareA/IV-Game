void drawBackground(){
   background.beginDraw();
   background.background(255, 0, 0);
   //background.fill(255);
   background.endDraw();
}

void drawTopViewSurface(){
   topViewSurface.beginDraw();
   topViewSurface.background(127);
   float zoom = boardSize/topViewSurfaceSize;
   for (int i = 0; i < cylinderList.size(); i ++){
      float posX =  (boardSize/2 + cylinderList.get(i).x) / zoom;
      float posY = (boardSize/2 + cylinderList.get(i).y) / zoom;
      topViewSurface.ellipse(posX, posY, 2*cylinderBaseSize/zoom, 2*cylinderBaseSize/zoom);
   } 
   float ballPosX = (ball.location.x + boardSize/2)/zoom; //adding topViewSurfaceSize/2 because the ball isa at position 0, 0 at thecenter of the plate.
   float ballPosY = (ball.location.z  + boardSize/2)/zoom;
   topViewSurface.ellipse(ballPosX, ballPosY, 2*ballSize/zoom, 2*ballSize/zoom);
   topViewSurface.endDraw();
}
