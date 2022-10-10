class Triangle implements Cloneable {
  private PVector[] points;
  private PVector[] texture_coords;
  private PImage texture;
  
  private MipMapper mipmap;

  Triangle(PVector  a, PVector  b, PVector  c,
           PVector ta, PVector tb, PVector tc,
           PImage texture)
  {
    points = new PVector[]{a, b, c};
    texture_coords = new PVector[]{ta, tb, tc};
    this.texture = texture;
    mipmap = new MipMapper(texture);
  }
  
  void print_data() {
    print("("+points[0].x+", "+points[0].y+", "+points[0].z+"), ");
    print("("+points[1].x+", "+points[1].y+", "+points[1].z+"), ");
    print("("+points[2].x+", "+points[1].y+", "+points[2].z+")");
  }
  
  Triangle clone_translate(Matrix mat){
    Triangle clone = clone();
    clone.translate(mat);
    return clone;
  }
  
  void translate(Matrix mat) {
    for(int i = 0; i < 3; i++) {
      points[i] = mat.cross_prod(points[i]);
    }
  }

  void draw(PImage col_buf, float[] depth_buf, int samples) {
    col_buf.loadPixels();
    
    draw_top(col_buf, depth_buf, samples);
    draw_low(col_buf, depth_buf, samples);
    
    col_buf.updatePixels();
  }
  
  public Triangle clone() {
    return new Triangle(
      points[0], points[1], points[2],
      texture_coords[0], texture_coords[1], texture_coords[2],
      texture
    );
  }
  
  void update(PVector  a, PVector  b, PVector  c,
              PVector ta, PVector tb, PVector tc,
              PImage texture)
  {
    points = new PVector[]{a, b, c};
    texture_coords = new PVector[]{ta, tb, tc};
    this.texture = texture;
    clear_cache();
  }
  
  private void clear_cache() {
    top_point_cache = null;
    mid_point_cache = null;
    low_point_cache = null;
  }

  private PVector top_point_cache = null;

  PVector top_point() {
    if(top_point_cache != null) return top_point_cache;
    
    PVector temp;

    if (points[0].y < points[1].y) {
      temp = points[0];
    } else {
      temp = points[1];
    }

    if (temp.y < points[2].y) {
      // continue
    } else {
      temp = points[2];
    }
    
    top_point_cache = temp;
    return temp;
  }
  
  private PVector mid_point_cache = null;

  PVector mid_point() {
    if(mid_point_cache != null) return mid_point_cache;
    
    PVector low = low_point();
    PVector top = top_point();

    for (PVector point : points) {
      if (point == low || point == top) {
        continue;
      }
      
      mid_point_cache = point;

      return point;
    }

    return null;
  }
  
  private PVector low_point_cache = null;

  PVector low_point() {
    if(low_point_cache != null) return low_point_cache;
    
    PVector temp;

    if (points[0].y > points[1].y) {
      temp = points[0];
    } else {
      temp = points[1];
    }

    if (temp.y > points[2].y) {
      // continue
    } else {
      temp = points[2];
    }
    
    low_point_cache = temp;
    return temp;
  }

  void draw_top(PImage col_buf, float[] depth_buf, int samples) {
    PVector top = top_point();
    PVector mid = mid_point();
    PVector low = low_point();
    
    if(top.y == mid.y) return;

    int side_mid = round(map(mid.y, top.y, low.y, top.x, low.x));

    int left = min(side_mid, round(mid.x));
    int right = max(side_mid, round(mid.x));
    
    //print("Drawing tri: ");
    //print("("+round(top.x)+", "+round(top.y)+"), ");
    //print("("+round(left)+", "+round(mid.y)+"), ");
    //print("("+round(right)+", "+round(mid.y)+")");
    //println();
    
    int left_most = floor(min(points[0].x, min(points[1].x, points[2].x)));
    int right_most = ceil(max(points[0].x, max(points[1].x, points[2].x)));

    for (int y = round(top.y); y < round(mid.y); y++) {
      int l = floor(map(y, top.y, mid.y, top.x, left));
      int r = ceil(map(y, top.y, mid.y, top.x, right));
      
      l = max(l, left_most);
      r = min(r, right_most);

      for (int x = l; x < r; x++) {
        if(occluded(col_buf, depth_buf, x, y)) continue;
        
        if(col_buf != null)
          draw_pixel(col_buf, x, y, samples);
        
        draw_depth(col_buf, depth_buf, x, y);
      }
    }
  }

  void draw_low(PImage col_buf, float[] depth_buf, int samples) {
    PVector top = top_point();
    PVector mid = mid_point();
    PVector low = low_point();
    
    if(mid.y == low.y) return;

    int side_mid = round(map(mid.y, top.y, low.y, top.x, low.x));

    int left = min(side_mid, round(mid.x));
    int right = max(side_mid, round(mid.x));
    
    //print("Drawing tri: ");
    //print("("+round(left)+", "+round(mid.y)+"), ");
    //print("("+round(right)+", "+round(mid.y)+"), ");
    //print("("+round(low.x)+", "+round(low.y)+")");
    //println();
    
    int left_most = floor(min(points[0].x, min(points[1].x, points[2].x)));
    int right_most = ceil(max(points[0].x, max(points[1].x, points[2].x)));

    for (int y = round(mid.y); y < round(low.y); y++) {
      int l = floor(map(y, mid.y, low.y, left, low.x));
      int r = ceil(map(y, mid.y, low.y, right, low.x));
      
      l = max(l, left_most);
      r = min(r, right_most);

      for (int x = l; x < r; x++) {
        if(occluded(col_buf, depth_buf, x, y)) continue;
        
        if(col_buf != null)
          draw_pixel(col_buf, x, y, samples);
        
        draw_depth(col_buf, depth_buf, x, y);
      }
    }
  }
  
  color texture_color(float x, float y) {
    PVector tp = texture_point(x, y);
    
    return texture.get(round(tp.x) % texture.width, round(tp.y) % texture.height);
  }

  color point_color(float x, float y, int samples) {
    if(samples < 2)
      return texture_color(x, y);
    else
      return texture_color_multi_sample(x, y, samples);
    //return texture_color_linear_sample(x, y);
  }
  
  color texture_color_multi_sample(float x, float y, int subdivs) {
    color[] samples = new color[(int)pow(subdivs, 2)];
    
    for(int u = 0; u < subdivs; u++) {
      for(int v = 0; v < subdivs; v++) {
        int i = v * subdivs + u;
        
        float xoff = map(u, -1, subdivs, -1, 1);
        float yoff = map(v, -1, subdivs, -1, 1);
        
        samples[i] = texture_color(x + xoff, y + yoff);
      }
    }
    
    return color_mean(samples);
  }
  
  color texture_color_linear_sample(float x, float y) {
    int lx = floor(x);
    int hx = ceil(x);
    int ly = floor(y);
    int hy = ceil(y);
    
    color lxly = texture_color(lx, ly);
    color lxhy = texture_color(lx, hy);
    color hxly = texture_color(hx, ly);
    color hxhy = texture_color(hx, hy);
    
    color left_side = col_map(y, ly, hy, lxly, lxhy);
    color right_side = col_map(y, ly, hy, hxly, hxhy);
    
    return col_map(x, lx, hx, left_side, right_side);
  }
  
  PVector texture_point(float x, float y) {
    float lx = local_x(x, y);
    float ly = local_y(x, y);
    
    float d0 = points[0].z;
    float d1 = points[1].z;
    float d2 = points[2].z;
    float mid_point_depth = persp_vec_map(lx, d0, d1, points[0], points[1]).z;
    
    return persp_vec_map(ly, mid_point_depth, d2,
             persp_vec_map(lx, d0, d1,
               texture_coords[0],
               texture_coords[1]),
             texture_coords[2]);
  }
  
  boolean on_screen(PImage col_buf, int x, int y) {
    float z = depth(x, y);
    return (x >= 0 && x < col_buf.width) &&
           (y >= 0 && y < col_buf.height) &&
           (z >= 0 && z <= 255); 
  }
  
  int screen_index(PImage col_buf, int x, int y) {
    return y * col_buf.width + x;
  }
  
  boolean occluded(PImage col_buf, float[] depth_buf, int x, int y) {
    //println("Checking occlusion of pixel (" +x+ "," +y+ ")");
    
    if(!on_screen(col_buf, x, y)) return true;
    
    //println("Pixel is on screen");
    
    //println("Current depth: "+depth_buf[screen_index(col_buf, x, y)]);
    //println("New depth: " + depth(x, y));
    
    return depth_buf[screen_index(col_buf, x, y)] < depth(x, y);
  }
  
  //boolean is_back_face() {
  // TODO!
  //}
  
  void draw_depth(PImage col_buf, float[] depth_buf, int x, int y) {
    if(occluded(col_buf, depth_buf, x, y)) return;
    
    depth_buf[screen_index(col_buf, x, y)] = depth(x, y);
  }
  
  void draw_pixel(PImage col_buf, int x, int y, int samples) {
    int index = screen_index(col_buf, x, y);
    
    if(!on_screen(col_buf, x, y)) return;
    
    col_buf.pixels[index] = point_color(x, y, samples);
  }
  
  float depth(float x, float y) {
    //float l_x = local_x(x, y);
    //float l_y = local_y(x, y);
    
    //float z0 = points[0].z;
    //float z1 = points[1].z;
    //float z2 = points[2].z;
    
    //return map(l_y, 0, 1, map(l_x, 0, 1, z0, z1), z2);
    
    float lx = local_x(x, y);
    float ly = local_y(x, y);
    
    float d0 = points[0].z;
    float d1 = points[1].z;
    float d2 = points[2].z;
    float mid_point_depth = persp_map(lx, d0, d1, points[0].z, points[1].z);
    
    return persp_map(ly, mid_point_depth, d2,
             persp_map(lx, d0, d1,
               points[0].z,
               points[1].z),
             points[2].z);
  }
  
  float local_x(float x, float y) {
    float ly = local_y(x, y);
    
    float offset = local_x_max_offset() * ly;
    
    float lx = (local_x_un_normal(x, y) - offset) / local_x_max();
    
    return lx / (1 - ly);
  }
  
  float local_y(float x, float y) {
    return local_y_un_normal(x, y) / local_y_max();
  }
  
  float local_x_max_offset() {
    return local_x_un_normal(points[2].x, points[2].y);
  }
  
  float local_x_max() {
    return local_x_un_normal(points[1].x, points[1].y);
  }
  
  float local_y_max() {
    return local_y_un_normal(points[2].x, points[2].y);
  }
  
  float local_x_un_normal(float x, float y) {
    PVector p = new PVector(x, y);
    p.sub(points[0]);
    
    PVector x_axis = vec_sub(points[1], points[0]);
    x_axis.z = 0;
    x_axis.normalize();
    
    return dot_prod(p, x_axis);
  }
  
  float local_y_un_normal(float x, float y) {
    PVector p = new PVector(x, y);
    p.sub(points[0]);
    
    PVector x_axis = vec_sub(points[1], points[0]);
    x_axis.z = 0;
    x_axis.normalize();
    
    PVector y_axis = new PVector(x_axis.y, -x_axis.x);
    return dot_prod(p, y_axis);
  }
}
