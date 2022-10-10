PVector vec_sub(PVector a, PVector b) {
  return new PVector(
    a.x - b.x,
    a.y - b.y,
    a.z - b.z
  );
}

PVector vec_add(PVector a, PVector b) {
  return new PVector(
    a.x + b.x,
    a.y + b.y,
    a.z + b.z
  );
}

PVector vec_scale(PVector v, float s) {
  return new PVector(v.x * s, v.y * s, v.z * s);
}

PVector vec_map(float s, PVector f, PVector t) {
  return vec_add(vec_scale(f, 1 - s), vec_scale(t, s));
}

PVector persp_vec_map(float s, float da, float db, PVector f, PVector t) {
  PVector fp = vec_scale(f, 1 / da);
  PVector tp = vec_scale(t, 1 / db);
  
  PVector i = vec_add(vec_scale(fp, 1 - s), vec_scale(tp, s));
  
  return vec_scale(i, 1 / ((1 - s) / da + s / db));
}

float persp_map(float s, float da, float db, float f, float t) {
  float fp = f / da;
  float tp = t / db;
  
  float i = (fp * (1 - s)) + (tp * s);
  
  return i / ((1 - s) / da + s / db);
}

float dot_prod(PVector a, PVector b) {
  return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

color color_mean(color[] cols) {
  float rsum = 0;
  float gsum = 0;
  float bsum = 0;
  
  for(color col : cols) {
    rsum += red(col);
    gsum += green(col);
    bsum += blue(col);
  }
  
  int r = round(rsum / cols.length);
  int g = round(gsum / cols.length);
  int b = round(bsum / cols.length);
  
  return color(r, g, b);
}

color col_map(float factor, float low, float high, color from, color to) {
  if(factor <= low) return from;
  if(factor >= high) return to;
  
  float f = factor - low;
  float d = high - low;
  
  float s = f / d;
  
  float r = red(from) * (1.0 - s) + red(to) * s;
  float g = green(from) * (1.0 - s) + green(to) * s;
  float b = blue(from) * (1.0 - s) + blue(to) * s;
  
  return color(r, g, b);
}
