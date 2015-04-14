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

  image(sobel(hueTh(convolute(img))), 0, 0);
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

