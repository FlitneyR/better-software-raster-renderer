class Spotlight {
  PVector position;
  
  float[] depth_buffer;
  
  float roll, tilt, yaw;
  float near, far, fov;
  
  int width, height;
  
  Camera cam;
  
  Spotlight(PVector position,
            float roll, float tilt, float yaw,
            float near, float far, float fov,
            int width, int height)
  {
    this.position = position;
    
    this.roll = roll;
    this.tilt = tilt;
    this.yaw = yaw;
    
    this.near = near;
    this.far = far;
    this.fov = fov;
    
    this.width = width;
    this.height = height;
    
    depth_buffer = new float[width * height];
  }
  
  Camera make_cam() {
    return new Camera(position, roll, tilt, yaw, near, far, fov);
  }
  
  void update_depth_buffer(Triangle[] scene) {
    cam = make_cam();
    
    cam.clear_depth_buffer(depth_buffer);
    
    cam.draw_depth_buffer(depth_buffer, scene, width, height);
  }
  
  boolean in_view(PVector p) {
    return p.x >= -1 && p.x <= 1 &&
           p.y >= -1 && p.y <- 1 &&
           p.z >= -1 && p.z <- 1;
  }
  
  PVector world_to_depth_buffer(PVector p) {
    return cam.vec_world_to_screen(p, width, height);
  }
  
  float probe_depth_buffer(float x, float y) {
    return depth_buffer[round(y) * width + round(x)];
  }
}
