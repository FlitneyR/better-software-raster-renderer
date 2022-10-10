class MipMapper {
  PImage source;
  int count;

  PImage[] scales;
  PImage rgbRep;

  MipMapper(PImage source) {
    int m = min(source.width, source.height);
    count = floor(log(m) / log(2));
    this.source = source;
  }

  MipMapper(PImage source, int count) {
    this.source = source;
    this.count = count;
  }

  void update() {
    scales = updateScales();
    rgbRep = updateRGBRep();
  }
  
  // x, y are the pixels on the original texture
  // blur is the amount of blur, i.e. blur = 3 means sampling the 3rd blur level
  //color probe(int x, int y, int blur) {
    
  //}
  
  PImage downScaled(int i) {
    i = max(0, min(i, scales.length - 1));
    PImage out = scales[i].copy();
    out.resize(source.width, source.height);
    return out;
  }

  PImage halfScale(PImage from) {
    PImage to = from.copy();
    to.resize(from.width / 2, from.height / 2);
    return to;
  }

  PImage[] updateScales() {
    scales = new PImage[count];
    PImage curr = source.copy();
    for (int i = 0; i < count; i++) {
      scales[i] = curr;
      curr = halfScale(curr);
    }
    return scales;
  }

  PImage updateRGBRep() {
    rgbRep = new PImage(source.width * 2, source.height * 2);

    int x = 0;
    int y = 0;

    for (int i = 0; i < scales.length; i++) {
      PImage curr = scales[i];

      for (int dy = 0; dy < curr.height; dy++) {
        for (int dx = 0; dx < curr.width; dx++) {
          color c = getPixel(curr, dx, dy);

          float r = red(c);
          float g = green(c);
          float b = blue(c);

          setPixel(rgbRep, x + dx, y + dy, color(r, 0, 0));
          setPixel(rgbRep, x + curr.width + dx, y + dy, color(0, g, 0));
          setPixel(rgbRep, x + dx, y + curr.height + dy, color(0, 0, b));
        }
      }

      x += curr.width;
      y += curr.height;
    }

    return rgbRep;
  }
}

color getPixel(PImage img, int x, int y) {
  img.loadPixels();
  return img.pixels[x + img.width * y];
}

void setPixel(PImage img, int x, int y, color c) {
  img.loadPixels();
  img.pixels[x + img.width * y] = c;
  img.updatePixels();
}
