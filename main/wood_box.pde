void make_wood_box() {
  wood_box = new Model(new Triangle[]{
    new Triangle(
      new PVector(1, 1, 1),
      new PVector(1, -1, 1),
      new PVector(-1, -1, 1),
      new PVector(0, 0),
      new PVector(235, 0),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(-1, 1, 1),
      new PVector(-1, -1, 1),
      new PVector(1, 1, 1),
      new PVector(0, 235),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    ), new Triangle(
      new PVector(1, 1, 1),
      new PVector(1, 1, -1),
      new PVector(-1, 1, -1),
      new PVector(0, 0),
      new PVector(235, 0),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(-1, 1, 1),
      new PVector(-1, 1, -1),
      new PVector(1, 1, 1),
      new PVector(0, 235),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    ), new Triangle(
      new PVector(1, -1, 1),
      new PVector(1, -1, -1),
      new PVector(-1, -1, -1),
      new PVector(0, 0),
      new PVector(235, 0),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(-1, -1, 1),
      new PVector(-1, -1, -1),
      new PVector(1, -1, 1),
      new PVector(0, 235),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    ), new Triangle(
      new PVector(1, -1, 1),
      new PVector(1, -1, -1),
      new PVector(1, 1, -1),
      new PVector(0, 0),
      new PVector(0, 235),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(1, 1, 1),
      new PVector(1, 1, -1),
      new PVector(1, -1, 1),
      new PVector(235, 0),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    ), new Triangle(
      new PVector(-1, -1, 1),
      new PVector(-1, -1, -1),
      new PVector(-1, 1, -1),
      new PVector(0, 0),
      new PVector(0, 235),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(-1, 1, 1),
      new PVector(-1, 1, -1),
      new PVector(-1, -1, 1),
      new PVector(235, 0),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    ), new Triangle(
      new PVector(1, 1, -1),
      new PVector(1, -1, -1),
      new PVector(-1, -1, -1),
      new PVector(0, 0),
      new PVector(235, 0),
      new PVector(235, 235),
      tex
    ), new Triangle(
      new PVector(-1, 1, -1),
      new PVector(-1, -1, -1),
      new PVector(1, 1, -1),
      new PVector(0, 235),
      new PVector(235, 235),
      new PVector(0, 0),
      tex
    )
  }, new PVector(0, 0, 0), 0, 0, 0);
}
