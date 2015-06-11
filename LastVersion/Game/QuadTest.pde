
boolean isInTriangle(PVector pt, PVector p0, PVector p1, PVector p2){
  float s = p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * pt.x + (p0.x - p2.x) * pt.y;
  float t = p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * pt.x + (p1.x - p0.x) * pt.y;

  if ((s < 0) != (t < 0))
      return false;

  float A = -p1.y * p2.x + p0.y * (p2.x - p1.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y;
  if (A < 0.0)
  {
      s = -s;
      t = -t;
      A = -A;
  }
  return s > 0 && t > 0 && (s + t) < A;
}

boolean isInQuad(PVector pt, PVector p0, PVector p1, PVector p2, PVector p3){
  return isInTriangle(pt, p0, p1, p2) || isInTriangle(pt, p1, p2, p3) || isInTriangle(pt, p0, p1, p3) || isInTriangle(pt, p0, p1, p3);
}

boolean areAllInQuad(PImage arg, PVector p0, PVector p1, PVector p2, PVector p3){
  int nb = 0;
  for (int x = 0; x < arg.width; x++) {
    for (int y = 0; y < arg.height; y++) {
      int i = y * arg.width + x;
      if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
        if (!isInQuad(new PVector(x, y), p0, p1, p2, p3))
          nb ++;
      }
    }
  }
  
  return nb < 100;
}

int nbInQuad(PImage arg, PVector p0, PVector p1, PVector p2, PVector p3){
  int nb = 0;
  for (int x = 0; x < arg.width; x++) {
    for (int y = 0; y < arg.height; y++) {
      int i = y * arg.width + x;
      if (hue(arg.pixels[i]) >= hueThLow3 && hue(arg.pixels[i]) <= hueThHigh3 && saturation(arg.pixels[i]) >= saturationThLow3 && saturation(arg.pixels[i]) <= saturationThHigh3 && brightness(arg.pixels[i]) >= brightnessThLow3 && brightness(arg.pixels[i]) <= brightnessThHigh3) {
        if (isInQuad(new PVector(x, y), p0, p1, p2, p3))
          nb ++;
      }
    }
  }
  
  return nb;
}
