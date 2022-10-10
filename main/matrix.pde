class Matrix {
  float[][] values;
  
  Matrix(float[][] values) {
    this.values = values;
  }
  
  int width() {
    return values[0].length;
  }
  
  int height() {
    return values.length;
  }
  
  PVector cross_prod(PVector v) {
    return new PVector(
      get(0, 0) * v.x + get(1, 0) * v.y + get(2, 0) * v.z + get(3, 0),
      get(0, 1) * v.x + get(1, 1) * v.y + get(2, 1) * v.z + get(3, 1),
      get(0, 2) * v.x + get(1, 2) * v.y + get(2, 2) * v.z + get(3, 2)
    );
  }
  
  float get(int c, int r) {
    return values[r][c];
  }
  
  void set(int c, int r, float value) {
    values[r][c] = value;
  }
  
  Matrix prod(Matrix other) {
    Matrix m = new Matrix(new float[other.width()][this.height()]);
    
    for(int x = 0; x < m.width(); x++) {
      for(int y = 0; y < m.height(); y++) {
        m.values[y][x] = 0;
        for(int i = 0; i < this.width(); i++) {
          m.values[y][x] += this.get(i, y) * other.get(x, i);
        }
      }
    }
    
    return m;
  }
  
  
}
