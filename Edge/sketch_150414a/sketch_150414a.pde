PImage img;
PImage result;
float th;

HScrollbar thresholdBar1;
HScrollbar thresholdBar2;

public void setup() {
  size(800, 600);
  img = loadImage("board4.jpg");
  //thresholdBar1 = new HScrollbar(0, 550, 800, 20);
  thresholdBar2 = new HScrollbar(0, 580, 800, 20);

  result = createImage(width, height, RGB); // create a new, initially transparent, 'result' image
}
void draw() {
  background(color(0, 0, 0));

  //result = createImage(width, height, RGB); // create a new, initially transparent, 'result' image
  //for (int i = 0; i < img.width * img.height; i++) {
  //  float value = brightness(img.pixels[i]);
  //  if (hue(img.pixels[i]) >= thresholdBar1.getPos() * 255 && hue(img.pixels[i]) <= thresholdBar2.getPos() * 255) {
  //    result.pixels[i] = img.pixels[i];
  // } else {
  //   result.pixels[i] = color(0);
  //    }
  //  }
 //image((sobel(hueTh(convolute(img)))), 0, 0);
 image(img, 0, 0);
 hough(sobel(hueTh(convolute(img))));
  //image(hough(sobel(hueTh(convolute(img)))), 0, 0);

  //thresholdBar1.display();
  //thresholdBar1.update();
  thresholdBar2.display();
  thresholdBar2.update();
}

public PImage convolute(PImage arg) {
  float[][] kernel = { 
    { 
      9, 12, 9
    }
    , 
    { 
      12, 0, 12 // slightly modified, to remove green pixels
    }
    , 
    { 
      9, 12, 9
    }
  };
  float weight = 84.0;
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

  // kernel size N = 3
  //
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by the weight
  // - set result.pixels[y * img.width + x] to this value
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
      if (buffer[y * arg.width + x] > (int)(max * thresholdBar2.getPos())) { // 30% of the max
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
    if (hue(arg.pixels[i]) >= 90 && hue(arg.pixels[i]) <= 140 && saturation(arg.pixels[i]) >= 60 && saturation(arg.pixels[i]) <= 255 && brightness(arg.pixels[i]) >= 20 && brightness(arg.pixels[i]) <= 180) {
      thImg.pixels[i] = color(255);
    } else {
      thImg.pixels[i] = color(0);
    }
  }

  return thImg;
}

public PImage hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.03f;
  float discretizationStepsR = 1f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  double rMax = rDim;
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        for (float i = 0.0f; i < Math.PI; i += discretizationStepsPhi) {
          double r = (x * cos(i) + y * sin(i)) / discretizationStepsR;
          r += (rDim - 1) / 2;
          accumulator[(int) ((i / discretizationStepsPhi + 1) * (rDim + 2) +( r))] += 1;
        }
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
      }
    }
  }


  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  houghImg.updatePixels();


  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 100) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
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
  }


houghImg.resize(400, 400);

  return houghImg;
}

