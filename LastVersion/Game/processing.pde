
public PImage convolute(PImage arg) {
  float[][] kernel = { 
    { 
      30, 20, 30
    }
    , 
    { 
      20, 0, 20 // slightly modified, to remove more noise
    }
    , 
    { 
      30, 20, 30
    }
  };
  float weight = 200.0;
  PImage result = createImage(arg.width, arg.height, RGB);

  for (int y = 0; y < arg.height; y++) {
    for (int x = 0; x < arg.width; x++) {
      float r = 0.0;
      float g = 0.0;
      float b = 0.0;

      for (int i = 0; i <= 2; i++) {
        for (int j = 0; j <= 2; j++) {
          int clampedX = x + i - 1;
          if (x + i - 1 < 0) {
            clampedX = 0;
          } else if (x + i - 1 >= arg.width) {
            clampedX = arg.width - 1;
          }

          int clampedY = y + j - 1;
          if (y + j - 1 < 0) {
            clampedY = 0;
          } else if (y + j - 1 >= arg.height) {
            clampedY = arg.height - 1;
          }

          r += red( arg.pixels[clampedY * arg.width + clampedX]) * kernel[i][j];
          g += green( arg.pixels[clampedY * arg.width + clampedX]) * kernel[i][j];
          b += blue( arg.pixels[clampedY * arg.width + clampedX]) * kernel[i][j];
        }
      }

      result.pixels[y * arg.width + x] = color(r / weight, g / weight, b / weight);
    }
  }

  return result;
}

public PImage sobel(PImage arg, PVector[][] gradient) {
  int nOfThreads = 8;
  Thread[] tabThread = new Thread[nOfThreads];
    
  PImage result = createImage(arg.width, arg.height, RGB);
  
  for (int i=0; i<nOfThreads; i++){
    tabThread[i] = new Thread(new RunnableSobel(i, i * arg.height/nOfThreads, (i+1) * arg.height/nOfThreads, arg, result, arg.width, arg.height, gradient)); // create the threads
    tabThread[i].start();  // and start them, each threads takes care of one part of the image
  }
  
  for (int i=0; i<nOfThreads; i++){
    try {
      tabThread[i].join();
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }
  return result;
}


public PImage preHueTh(PImage arg) { // this function replace the center of the board by a white quad, it's not perfect, but it removes most of the reflections, and only keeps the part of the image where the board is
  PImage thImg = createImage(arg.width, arg.height, RGB);
  int minX, maxX, minY, maxY;
  minX = arg.width - 1;
  maxX = 0;
  minY = arg.height - 1;
  maxY = 0;
  int count = 0;

  for (int x = 0; x < arg.width; x++) {
    for (int y = 0; y < arg.height; y++) {
      int i = y * arg.width + x;
      thImg.pixels[i] = arg.pixels[i];
      if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
        count++;
        if (x < minX)
          minX = x;
        
        if (x > maxX)
          maxX = x;
          
        if (y < minY)
          minY = y;
          
        if (y > maxY)
          maxY = y;
      }
    }
  }
  if (count < 200){ // the board is not on the picture
    return thImg;
  }
  
  int margin = 0;
  
  PVector p0, p1, p2, p3; // these points represent the 'guessed' position of the corners
  PVector[] p0t = new PVector[2];
  PVector[] p1t = new PVector[2];
  PVector[] p2t = new PVector[2];
  PVector[] p3t = new PVector[2];
  p0 = new PVector(minX - margin, -1);
  p1 = new PVector(maxX + margin, -1);
  p2 = new PVector(-1, minY - margin);
  p3 = new PVector(-1, maxY + margin);
  p0t[0] = new PVector(minX - margin, -1);
  p1t[0] = new PVector(maxX + margin, -1);
  p2t[0] = new PVector(-1, minY - margin);
  p3t[0] = new PVector(-1, maxY + margin);
  p0t[1] = new PVector(minX - margin, -1);
  p1t[1] = new PVector(maxX + margin, -1);
  p2t[1] = new PVector(-1, minY - margin);
  p3t[1] = new PVector(-1, maxY + margin);
  
  // p0t[0] represents the leftmost point of the board with the smallest y value,  p0t[1] represents the leftmost point of the board with the biggest y value, and so on
  
  int smallY = maxY, bigY = minY;
  for (int y = 0; y < arg.height; y++) {
    int i = y * arg.width + minX;
    if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
      if (y < smallY)
        smallY = y;
        
      if (y > bigY)
        bigY = y;
    }
  }
  p0t[0].y = smallY - margin;
  p0t[1].y = bigY + margin;
  
  smallY = maxY;
  bigY = minY;
  for (int y = 0; y < arg.height; y++) {
    int i = y * arg.width + maxX;
    if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
      if (y < smallY)
        smallY = y;
        
      if (y > bigY)
        bigY = y;
    }
  }
  p1t[0].y = smallY - margin;
  p1t[1].y = bigY + margin;
  
  int smallX = maxX, bigX = minX;
  for (int x = 0; x < arg.width; x++) {
    int i = minY * arg.width + x;
    if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
      if (x < smallX)
        smallX = x;
        
      if (x > bigX)
        bigX = x;
    }
  }
  p2t[0].x = smallX - margin;
  p2t[1].x = bigX + margin;
  
  smallX = maxX;
  bigX = minX;
  for (int x = 0; x < arg.width; x++) {
    int i = maxY * arg.width + x;
    if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
      if (x < smallX)
        smallX = x;
        
      if (x > bigX)
        bigX = x;
    }
  }
  p3t[0].x = smallX - margin;
  p3t[1].x = bigX + margin;
  
  float a0 = area(p0t[1], p2t[0], p1t[0], p3t[1]);
  float a1 = area(p0t[0], p2t[1], p1t[1], p3t[0]);
  
  if (a0 > a1){ // we select the most probable quad, which is the bigger one
    p0 = p0t[1];
    p1 = p1t[0];
    p2 = p2t[0];
    p3 = p3t[1];
  }
  else {
    p0 = p0t[0];
    p1 = p1t[1];
    p2 = p2t[1];
    p3 = p3t[0];
  }

  for (int x = 0; x < arg.width; x++) {
    for (int y = 0; y < arg.height; y++) {
      if (isInQuad(new PVector(x, y), p0, p1, p2, p3)){ // if the pixel is in the board with probability 100%, we paint it green
        thImg.pixels[y * arg.width + x] = color(22, 109, 85);
      }
      if (x < minX || x > maxX || y < minY || y > maxY){ // if the pixel is not in the board with probability 100%, we paint it black
        thImg.pixels[y * arg.width + x] = color(0);
      }
    }
  }
  return thImg;
}

public PImage hueTh (PImage arg) {
  PImage thImg = createImage(arg.width, arg.height, RGB);

  for (int i = 0; i < arg.width * arg.height; i++) {
    if (hue(arg.pixels[i]) >= hueThLow && hue(arg.pixels[i]) <= hueThHigh && saturation(arg.pixels[i]) >= saturationThLow && saturation(arg.pixels[i]) <= saturationThHigh && brightness(arg.pixels[i]) >= brightnessThLow && brightness(arg.pixels[i]) <= brightnessThHigh) {
      thImg.pixels[i] = color(255);
    } else {
      thImg.pixels[i] = color(0);
    }
  }

  return thImg;
}

public PImage whiteTh (PImage arg) {
  PImage thImg = createImage(arg.width, arg.height, RGB);

  for (int i = 0; i < arg.width * arg.height; i++) {
    if (brightness(arg.pixels[i]) >= 200) { //  && brightness(arg.pixels[i]) <= 255
      thImg.pixels[i] = color(255);
    } else {
      thImg.pixels[i] = color(0);
    }
  }

  return thImg;
}

public PImage hough(PImage edgeImg, int nLines, PVector[][] gradient) {
  float discretizationStepsPhi = 0.04f;
  float discretizationStepsR = 0.9f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  double rMax = rDim;
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  //println("Size : " + accumulator.length);

  // pre-compute the sin and cos values, using maps, as array give bad result
  HashMap<Float, Float> mapCos = new HashMap<Float, Float>();
  HashMap<Float, Float> mapSin = new HashMap<Float, Float>();
  for (float phi = 0.0f; phi < Math.PI; phi += discretizationStepsPhi) {
    mapCos.put((Float)phi, ((Double) Math.cos(phi)).floatValue());
    mapSin.put((Float)phi, ((Double) Math.sin(phi)).floatValue());
  }

  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        float beg = 0.0f;
        float end = (float)Math.PI;
        float badInterBeg = -1.0f;
        float badInterEnd = -1.0f;
        
        /*float margin = 10 * discretizationStepsPhi;
        
        double gradientAngle = Math.atan(gradient[x][y].x / gradient[x][y].y);
        gradientAngle = gradientAngle % Math.PI;
        
        if (gradientAngle < 0)
          gradientAngle += Math.PI;
          
          
        beg = (float)gradientAngle - margin;
        end = (float)gradientAngle + margin;
        
        if (end > Math.PI){
          badInterBeg = end - (float)Math.PI;
          badInterEnd = beg;
        }
        else if (beg < 0){
          badInterBeg = end;
          badInterEnd = beg + (float)Math.PI;
        }*/

        for (float phi = 0.0f; phi < Math.PI; phi += discretizationStepsPhi) {
          if (!(phi >= badInterBeg && phi <= badInterEnd) && (phi >= beg && phi < end)){
            double r = (x * mapCos.get(phi) + y * mapSin.get(phi)) / discretizationStepsR;
            r += (rDim - 1) / 2;
            accumulator[(int) ((phi / discretizationStepsPhi + 1) * (rDim + 2) +r)] ++;
          }
          
        }
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
      }  
    }
  }


  /*PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
   for (int i = 0; i < accumulator.length; i++) {
   houghImg.pixels[i] = color(min(255, accumulator[i]));
   }
   houghImg.updatePixels();*/

  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  boolean[] valid = new boolean[(phiDim + 2) * (rDim + 2)];
  int minVotes = 40;

  int neighbourhoodPhi = 10;
  int neighbourhoodR = 35;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhoodPhi/2; dPhi < neighbourhoodPhi/2+1 && bestCandidate; dPhi++) {
          int phi = accPhi+dPhi;
          if (phi < 0)
            phi = phiDim + accPhi+dPhi;
          if (phi >= phiDim)
            phi = -phiDim + accPhi+dPhi;
          
          //int neighbourhoodR = (int)accR * neighbourhood * 0.05;
          for (int dR=-neighbourhoodR/2; dR < neighbourhoodR/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (phi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
            else if (accumulator[idx] == accumulator[neighbourIdx] && valid[neighbourIdx]) {
              bestCandidate=false;
              break;
            }
            if (accPhi * discretizationStepsPhi < 0.17 || accPhi * discretizationStepsPhi > Math.PI - 0.17) { // if near vertical, check for opposite r
              if (rDim-accR-1+dR < 0 || rDim-accR-1+dR >= rDim) continue;
              neighbourIdx = (phi + 1) * (rDim + 2) + rDim-accR-1 + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
              else if (accumulator[idx] == accumulator[neighbourIdx] && valid[neighbourIdx]) {
                bestCandidate=false;
                break;
              }
            }
          }
          
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
          valid[idx] = true;
        }
      }
    }
  }

  Collections.sort(bestCandidates, new HoughComparator(accumulator));

  ArrayList<PVector> lines = new ArrayList<PVector>(); 


  for (int i = 0; i < bestCandidates.size() && i < nLines; i++) { //  && i < nLines
    
    int idx = bestCandidates.get(i);
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    println("r" + i + " = " + r);
    println("accR" + i + " = " + accR);
    println("rDim" + i + " = " + rDim);
    println("phi" + i + " = " + phi);
    println("acc : " + accumulator[idx]);

    lines.add(new PVector(r, phi));

    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    
    
    stroke(200, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
    
  }
  /* A DECOMMENTER

  getIntersections(lines);

  build(lines, edgeImg.width, edgeImg.height);

  ArrayList<int[]> oldquads = findCycles();

  ArrayList<int[]> quads = new ArrayList<int[]>();

  for (int i = 0; i < oldquads.size (); i++) {
    if (oldquads.get(i).length == 4) {
      quads.add(oldquads.get(i));
    }
  }
  
  //println("Size : " + quads.size());
  
  

  for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    
    if (validArea(c12, c23, c34, c41, 150000, 12000) && isConvex(c12, c23, c34, c41) && nonFlatQuad(c12, c23, c34, c41)){
      // Choose a random, semi-transparent colour
      
      Random random = new Random();
      fill(color(255, 255, 255));
      //quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      
      List<PVector> listePoints = new ArrayList<PVector>();
      listePoints.add(c12);
      listePoints.add(c23);
      listePoints.add(c34);
      listePoints.add(c41);
      
      TwoDThreeD b = new TwoDThreeD(img.width, img.height);
      
      PVector a = b.get3DRotations(sortCorners(listePoints));
      
      //println("rx : " + a.x * 180.0 / Math.PI + " , ry : " + a.y * 180.0 / Math.PI + " , rz : " + a.z * 180.0 / Math.PI );
      
      rotationX = (rotationX+a.x)/4; //  /4 to prevent too great rotation
      rotationZ = (rotationZ+a.y)/4;
    }
  }


  //houghImg.resize(400, 400);
*/
  return null;
  
}

public PVector intersection(PVector l1, PVector l2){
  ArrayList<PVector> lines = new ArrayList<PVector>();
  lines.add(l1);
  lines.add(l2);
  return getIntersections(lines).get(0);
}

public ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size () - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size (); j++) {
      PVector line2 = lines.get(j);
      // compute the intersection and add it to 'intersections'
      // draw the intersection
      double d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);
      int x = (int) ((line2.x * sin(line1.y) - line1.x * sin(line2.y)) / d);
      int y = (int) (( - line2.x * cos(line1.y) + line1.x * cos(line2.y)) / d);

      intersections.add(new PVector(x, y, 1));
      fill(255, 128, 0);
      ellipse(x, y, 10, 10);
    }
  }
  return intersections;
}

class HoughComparator implements Comparator<Integer> {
  int[] accumulator;
  public HoughComparator(int[] accumulator) {
    this.accumulator = accumulator;
  }
  @Override
    public int compare(Integer l1, Integer l2) {
    if (accumulator[l1] > accumulator[l2]
      || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
    return 1;
  }
}

