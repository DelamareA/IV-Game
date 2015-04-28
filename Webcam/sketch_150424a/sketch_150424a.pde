import processing.video.*;
import java.util.Comparator;
import java.util.Collections;

Capture cam;
PImage img;
PImage sob;
public void setup() {
  size(640, 480);
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[5]);
    cam.start();
  }
}
public void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  sob = sobel(hueTh(convolute(img)));
  image(hueTh(convolute(img)), 0, 0);
  //image(img, 0, 0);
  hough(sob, 4);
}

public PImage convolute(PImage arg) {
  float[][] kernel = { 
    { 
      30, 20, 30
    }
    , 
    { 
      20, 0, 20 // slightly modified, to remove green pixels
    }
    , 
    { 
      30, 20, 30
    }
  };
  float weight = 200.0;
  // create a greyscale image (type: ALPHA) for output
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


public PImage sobel(PImage arg) {
  float[][] hKernel = { 
    { 
      0, 1, 0
    }
    , 
    { 
      0, 0, 0
    }
    , 
    { 
      0, -1, 0
    }
  };
  float[][] vKernel = { 
    { 
      0, 0, 0
    }
    , 
    { 
      1, 0, -1
    }
    , 
    { 
      0, 0, 0
    }
  };

  PImage thImg = createImage(arg.width, arg.height, RGB);

  for (int i = 0; i < arg.width * arg.height; i++) {
    float value = brightness(arg.pixels[i]);
    if (hue(arg.pixels[i]) >= 40 && hue(img.pixels[i]) <= 150) {
      thImg.pixels[i] = img.pixels[i];
    } else {
      thImg.pixels[i] = color(0);
    }
  }

  PImage result = createImage(arg.width, arg.height, ALPHA);
  // clear the image
  for (int i = 0; i < arg.width * arg.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[arg.width * arg.height];


  for (int y = 0; y < arg.height; y++) {
    for (int x = 0; x < arg.width; x++) {
      float sum_h = 0.0;
      float sum_v = 0.0;

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

          sum_h += brightness( arg.pixels[clampedY * arg.width + clampedX]) * hKernel[i][j];
          sum_v += brightness( arg.pixels[clampedY * arg.width + clampedX]) * vKernel[i][j];
        }
      }

      buffer[y * arg.width + x] = sqrt(pow(sum_h, 2) + pow(sum_v, 2));

      if (buffer[y * arg.width + x] > max) {
        max = buffer[y * arg.width + x];
      }
    }
  }

  for (int y = 2; y < arg.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < arg.width - 2; x++) { // Skip left and right
      if (buffer[y * arg.width + x] > max * 0.3) { // 30% of the max
        result.pixels[y * arg.width + x] = color(255);
      } else {
        result.pixels[y * arg.width + x] = color(0);
      }
    }
  }
  return result;
}


public PImage hueTh (PImage arg) {
  PImage thImg = createImage(arg.width, arg.height, RGB);

  for (int i = 0; i < arg.width * arg.height; i++) {
    float value = brightness(arg.pixels[i]);
    if (hue(arg.pixels[i]) >= 60 && hue(arg.pixels[i]) <= 170 && saturation(arg.pixels[i]) >= 30 && saturation(arg.pixels[i]) <= 240 && brightness(arg.pixels[i]) >= 30 && brightness(arg.pixels[i]) <= 240) {
    //if (hue(arg.pixels[i]) >= 120 /*&& hue(arg.pixels[i]) <= 140 && saturation(arg.pixels[i]) >= 60 */&& saturation(arg.pixels[i]) <= 140 && brightness(arg.pixels[i]) >= 110 /*&& brightness(arg.pixels[i]) <= 180*/) {
      thImg.pixels[i] = color(255);
    } else {
      thImg.pixels[i] = color(0);
    }
  }

  return thImg;
}

public PImage hough(PImage edgeImg, int nLines) {
  float discretizationStepsPhi = 0.03f;
  float discretizationStepsR = 1f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  double rMax = rDim;
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }


  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        for (float i = 0.0f; i < Math.PI; i += discretizationStepsPhi) {
          double r = (x * tabCos[(int) (i / discretizationStepsPhi)] + y * tabSin[(int) (i / discretizationStepsPhi)]) / discretizationStepsR;
          r += (rDim - 1) / 2;
          accumulator[(int) ((i / discretizationStepsPhi + 1) * (rDim + 2) +( r))] += 1;
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
  int minVotes = 60;

  // size of the region we search for a local maximum
  int neighbourhood = 55;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
        }
      }
    }
  }

  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  ArrayList<PVector> lines = new ArrayList<PVector>(); 


  for (int i = 0; i < bestCandidates.size () && i < nLines; i++) {
    int idx = bestCandidates.get(i);
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    
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
    stroke(204, 102, 0);
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
  
  getIntersections(lines);


  //houghImg.resize(400, 400);

  return null;
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
      
      intersections.add(new PVector(x, y));
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
