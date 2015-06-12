public class RunnableSobel implements Runnable { // class used to provide sobel algorithm in parallel
  int id;
  int starting_row;
  int ending_row;
  PImage original_image;
  PImage result_image;
  int width;
  int height;
  int threshold;
  float[] buffer;
  PVector[][] gradient;

  int[][] kernelX= {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
  int[][] kernelY= {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

  public RunnableSobel(int id, int starting_row, int ending_row,
      PImage original_image, PImage result_image, int width,
      int height, PVector[][] gradient) {
    super();
    this.id = id;
    this.starting_row = starting_row;
    this.ending_row = ending_row;
    this.original_image = original_image;
    this.result_image = result_image;
    this.width = width;
    this.height = height;
    this.threshold = threshold;
    this.buffer = new float[original_image.width * original_image.height];
    this.gradient = gradient;
    
  }

  public void run() {
    float max = 0;
    for (int y = starting_row; y < ending_row; y++) {
      for (int x = 0; x < width; x++) {
        int sum_h = 0;
        int sum_v = 0;

        for (int i = 0; i <= 2; i++) {
          for (int j = 0; j <= 2; j++) {
            int clampedX = x + i - 1;
            if (x + i - 1 < 0) {
              clampedX = 0;
            } else if (x + i - 1 >= width) {
              clampedX = width - 1;
            }

            int clampedY = y + j - 1;
            if (y + j - 1 < 0) {
              clampedY = 0;
            } else if (y + j - 1 >= height) {
              clampedY = height - 1;
            }

            sum_h += original_image.pixels[clampedY * width + clampedX]
                * kernelX[i][j];
            sum_v += original_image.pixels[clampedY * width + clampedX]
                * kernelY[i][j];
          }
        }
        
        gradient[x][y].x = sum_h;
        gradient[x][y].y = sum_v;
        
        buffer[y * width + x] = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        
        if (buffer[y * width + x] > max) {
          max = buffer[y * width + x];
        }

        if (buffer[y * width + x] > max * 0.3f) {
          result_image.pixels[y * width + x] = color(255);
        } else {
          result_image.pixels[y * width + x] = color(0);
        }
      }
    }
    result_image.updatePixels();
  }
}
