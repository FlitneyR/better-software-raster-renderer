class Camera {
  PVector position;
  
  float fov;
  float near, far;
  float yaw, roll, tilt;
  
  Camera(PVector position,
      float yaw, float tilt, float roll,
      float fov, float near, float far
  ) {
    this.position = position;
    
    this.tilt = tilt;
    this.yaw = yaw;
    this.roll = roll;
    
    this.fov = fov;
    this.near = near;
    this.far = far;
  }
  
  int draw(PImage col_buf, float[] depth_buf, Triangle[] scene, int samples) {
    int i = 0;
    for(Triangle t : scene) {
      i++;
      if(in_view(t))
        world_to_screen(t, col_buf.width, col_buf.height)
          .draw(col_buf, depth_buf, samples);
      else i--;
    }
    return i;
  }
  
  int draw_depth_buffer(float[] depth_buf, Triangle[] scene, int width, int height) {
    int i = 0;
    for(Triangle t : scene) {
      i++;
      if(in_view(t))
        world_to_screen(t, width, height)
          .draw(null, depth_buf, samples);
      else i--;
    }
    return i;
  }
  
  PVector forward() {
    return vec_camera_to_world(new PVector(0, 0, 1));
  }
  
  PVector up() {
    return vec_camera_to_world(new PVector(0, 1, 0));
  }
  
  PVector right() {
    return vec_camera_to_world(new PVector(1, 0, 0));
  }
  
  Matrix world_to_camera() {
    float cr = cos(roll);
    float sr = sin(roll);
    
    float ct = cos(tilt);
    float st = sin(tilt);
    
    float cy = cos(yaw);
    float sy = sin(yaw);
    
    return (new Matrix(new float[][]{
      {cr, -sr, 0, 0},
      {sr,  cr, 0, 0},
      { 0,   0, 1, 0},
      { 0,   0, 0, 1}
    })).prod(new Matrix(new float[][]{
      {1,  0,   0, 0},
      {0, ct, -st, 0},
      {0, st,  ct, 0},
      {0,  0,   0, 1}
    })).prod(new Matrix(new float[][]{
      {cy, 0, -sy, 0},
      { 0, 1,   0, 0},
      {sy, 0,  cy, 0},
      { 0, 0,   0, 1}
    })).prod(new Matrix(new float[][]{
      {1,  0, 0, -position.x},
      {0, -1, 0, -position.y}, // -1 here to flip world on y axis
      {0,  0, 1, -position.z},
      {0,  0, 0,       1    }
    }));
  }
  
  Matrix camera_to_world() {
    float cr = cos(-roll);
    float sr = sin(-roll);
    
    float ct = cos(-tilt);
    float st = sin(-tilt);
    
    float cy = cos(-yaw);
    float sy = sin(-yaw);
    
    return (new Matrix(new float[][]{
      {1, 0, 0, position.x},
      {0, 1, 0, position.y},
      {0, 0, 1, position.z},
      {0, 0, 0,      1    }
    })).prod(new Matrix(new float[][]{
      {cy, 0, -sy, 0},
      { 0, 1,   0, 0},
      {sy, 0,  cy, 0},
      { 0, 0,   0, 1}
    })).prod(new Matrix(new float[][]{
      {1,  0,   0, 0},
      {0, ct, -st, 0},
      {0, st,  ct, 0},
      {0,  0,   0, 1}
    }).prod(new Matrix(new float[][]{
      {cr, -sr, 0, 0},
      {sr,  cr, 0, 0},
      { 0,   0, 1, 0},
      { 0,   0, 0, 1}
    })));
  }
  
  Matrix camera_to_view(float d) {
    float w = 1 / tan(radians(fov));
    float h = width / (height * tan(radians(fov)));
    
    float depth_scaler = 0.5 / (float)(far - near);
    float depth_offset = -1.0;
    
    return new Matrix(new float[][]{
      {w / d,   0  ,      0      ,      0      },
      {  0  , h / d,      0      ,      0      },
      {  0  ,   0  , depth_scaler, depth_offset}
    });
  }
  
  Matrix view_to_camera(float d) {
    float w = 1 / tan(radians(fov));
    float h = (width / height) / tan(radians(fov));
    
    float depth_scaler = 0.5 / (float)(far - near);
    float depth_offset = (far + near) / 2;
    
    map(d, -1, 1, near, far);
    
    return new Matrix(new float[][]{
      {d / w,   0  ,         0       ,       0      },
      {  0  , d / h,         0       ,       0      },
      {  0  ,   0  , 1 / depth_scaler, -depth_offset}
    });
  }
  
  Matrix view_to_screen(int width, int height) {
    return new Matrix(new float[][] {
      {width / 2,      0     ,  0 ,  width / 2},
      {    0    , -height / 2,  0 , height / 2},
      {    0    ,      0     , 125,     125   }
    });
  }
  
  Matrix screen_to_view(int width, int height) {
    return new Matrix(new float[][] {
      {2 / width,      0     ,    0   , -1},
      {    0    , -2 / height,    0   ,  1},
      {    0    ,      0     , 1 / 125, -1}
    });
  }
  
  PVector vec_world_to_camera(PVector vec) {
     return world_to_camera().cross_prod(vec);
  }
  
  PVector vec_camera_to_world(PVector vec) {
     return camera_to_world().cross_prod(vec);
  }
  
  PVector vec_camera_to_view(PVector vec) {
    return camera_to_view(vec.z).cross_prod(vec);
  }
  
  PVector vec_view_to_camera(PVector vec) {
    return view_to_camera(vec.z).cross_prod(vec);
  }
  
  PVector vec_view_to_screen(PVector vec, int width, int height) {
    return view_to_screen(width, height).cross_prod(vec);
  }
  
  PVector vec_screen_to_view(PVector vec, int width, int height) {
    return screen_to_view(width, height).cross_prod(vec);
  }
  
  PVector vec_world_to_screen(PVector vec, int width, int height) {
    return
    vec_view_to_screen(
      vec_camera_to_view(
        vec_world_to_camera(
          vec)), width, height);
  }
  
  PVector vec_screen_to_world(PVector vec, int width, int height) {
    //return
    //vec_camera_to_world(
    //  vec_view_to_camera(
    //    vec_screen_to_view(
    //      vec, width, height)));
    
    PVector ret = new PVector(position.x, position.y, position.z);
    
    float real_depth = map(vec.z, -1, 1, near, far);
    float right_most = tan(radians(fov)) / real_depth;
    float up_most = (height / width) * tan(radians(fov)) / real_depth;
    
    ret.add(vec_scale(forward(), map(vec.z, 0, 255, near, far)));
    ret.add(vec_scale(right(), map(vec.x, 0, width, -right_most, right_most)));
    ret.add(vec_scale(up(), map(vec.y, 0, height, up_most, -up_most)));
    
    return ret;
  }
  
  Triangle tri_world_to_camera(Triangle tri) {
    Triangle temp = tri.clone();
    
    for(int i = 0; i < tri.points.length; i++) {
      temp.points[i] = vec_world_to_camera(temp.points[i]);
    }
    
    return temp;
  }
  
  Triangle tri_camera_to_view(Triangle tri) {
    Triangle temp = tri.clone();
    
    for(int i = 0; i < tri.points.length; i++) {
      temp.points[i] = vec_camera_to_view(temp.points[i]);
    }
    
    return temp;
  }
  
  Triangle tri_view_to_screen(Triangle tri, int width, int height) {
    Triangle temp = tri.clone();
    
    for(int i = 0; i < tri.points.length; i++) {
      temp.points[i] = vec_view_to_screen(temp.points[i], width, height);
    }
    
    return temp;
  }
  
  Triangle world_to_screen(Triangle tri, int width, int height) {
    return
    tri_view_to_screen(
      tri_camera_to_view(
        tri_world_to_camera(
          tri)), width, height);
  }
  
  boolean in_view(Triangle tri) {
    Triangle cam_space_tri = tri_world_to_camera(tri);
    
    Triangle view_space_tri = tri_camera_to_view(cam_space_tri);
    
    //print("Testing triangle: ");
    //cam_space_tri.print_data();
    //println();
    
    if((view_space_tri.points[0].z < -1 ||
        view_space_tri.points[1].z < -1 ||
        view_space_tri.points[2].z < -1) ||
       (view_space_tri.points[0].z > 1 ||
        view_space_tri.points[1].z > 1 ||
        view_space_tri.points[2].z > 1)) return false;
    
    if((view_space_tri.points[0].x < -5 ||
        view_space_tri.points[1].x < -5 ||
        view_space_tri.points[2].x < -5) ||
       (view_space_tri.points[0].x > 5 ||
        view_space_tri.points[1].x > 5 ||
        view_space_tri.points[2].x > 5)) return false;
    
    if((view_space_tri.points[0].y < -5 ||
        view_space_tri.points[1].y < -5 ||
        view_space_tri.points[2].y < -5) ||
       (view_space_tri.points[0].y > 5 ||
        view_space_tri.points[1].y > 5 ||
        view_space_tri.points[2].y > 5)) return false;
    
    //println("Triangle in view");
    
    return true;
  }
  
  void clear_depth_buffer(float[] depth_buffer) {
    for(int i = 0; i < depth_buffer.length; i++)
      depth_buffer[i] = 255;
  }
  
  void clear_color_buffer(PImage color_buffer) {
    color_buffer.loadPixels();
    
    for(int i = 0; i < color_buffer.pixels.length; i++)
      color_buffer.pixels[i] = color(0);
    
    color_buffer.updatePixels();
  }
}
