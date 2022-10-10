class Model {
  Triangle[] tris;
  
  PVector position;
  float roll, tilt, yaw;
  
  Model(Triangle[] tris, PVector position, float roll, float tilt, float yaw) {
    this.tris = tris;
    this.position = position;
    this.roll = roll;
    this.tilt = tilt;
    this.yaw = yaw;
  }
  
  Model clone() {
    return new Model(
      tris.clone(),
      new PVector(
        position.x,
        position.y,
        position.z
      ),
      roll,
      tilt,
      yaw
    );
  }
  
  Model clone_move(PVector position, float roll, float tilt, float yaw) {
    Model m = clone();
    m.position = position;
    m.roll = roll;
    m.tilt = tilt;
    m.yaw = yaw;
    return m;
  }
  
  Triangle[] world_space_tris() {
    Triangle[] ret = new Triangle[tris.length];
    
    Matrix transformer = get_transform_matrix();
    
    for(int i = 0; i < tris.length; i++) {
      ret[i] = tris[i].clone_translate(transformer);
    }
    
    return ret;
  }
  
  Matrix get_transform_matrix() {
    float cr = cos(roll);
    float sr = sin(roll);
    float ct = cos(tilt);
    float st = sin(tilt);
    float cy = cos(yaw);
    float sy = sin(yaw);
    
    return (new Matrix(new float[][]{
      {1, 0, 0, -position.x},
      {0, 1, 0, -position.y},
      {0, 0, 1, -position.z},
      {0, 0, 0,       1    }
    })).prod(new Matrix(new float[][]{
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
    }));
  }
}
