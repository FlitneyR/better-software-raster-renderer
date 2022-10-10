void setup() {
  size(700, 700);

  depth_buffer = new float[width * height];

  cam = new Camera(
    new PVector(0, 0, 0),
    0, 0, 0,
    40, 0.1, 10);

  color_buf = new PImage(width, height);

  tex = loadImage("../textures/test_texture.jpg");
  tex.filter(BLUR, texture_pre_blur);

  make_wood_box();
  
  Model tile = new Model(new Triangle[]{
    new Triangle(
      new PVector(-6, 0, -6),
      new PVector(-6, 0,  6),
      new PVector( 6, 0, -6),
      new PVector(0, 0),
      new PVector(0, 235 * 6),
      new PVector(235 * 6, 0),
      tex
    ),
    new Triangle(
      new PVector(-6, 0,  6),
      new PVector( 6, 0, -6),
      new PVector( 6, 0,  6),
      new PVector(0, 235 * 6),
      new PVector(235 * 6, 0),
      new PVector(235 * 6, 235 * 6),
      tex
    ),
  }, new PVector(0, 0, 0), 0, 0, 0);

  scene = new Model[]{
    wood_box.clone_move(new PVector( 0, 0, -4), 0, 0, 1),
    wood_box.clone_move(new PVector( 0, 0,  0), 0, 0, 2),
    wood_box.clone_move(new PVector( 0, 0, -8), 0, 0, 3),
    wood_box.clone_move(new PVector(-4, 0, -4), 0, 0, 4),
    wood_box.clone_move(new PVector( 4, 0, -4), 0, 0, 5),
    wood_box.clone_move(new PVector(-3, 0, -1), 0, 0, 6),
    wood_box.clone_move(new PVector(-3, 0, -7), 0, 0, 7),
    wood_box.clone_move(new PVector( 3, 0, -1), 0, 0, 8),
    wood_box.clone_move(new PVector( 3, 0, -7), 0, 0, 9),
    tile.clone_move(new PVector(0, -1.01, -4), 0, 0, 0),
  };
  
  sp = new Spotlight(
    new PVector(0, 10, 5),
    0, -PI / 2, 0,
    0.1, 100, 30,
    500, 500
  );

  frameRate(30);
}

PImage color_buf;
float[] depth_buffer;

Model wood_box;
Model[] scene;

float texture_pre_blur = 1.2;
int samples = 0;
PImage tex;

Spotlight sp;

Camera cam;

void draw() {
  cam.clear_depth_buffer(depth_buffer);
  cam.clear_color_buffer(color_buf);

  ArrayList<Triangle> tris = new ArrayList();

  for (Model model : scene) {
    for (Triangle tri : model.world_space_tris()) {
      tris.add(tri);
    }
  }
  
  Triangle[] scene_tris = tris.toArray(new Triangle[tris.size()]);

  float theta = frameCount / 60.0;

  cam.position.z = 4 - 10 * cos(theta);
  cam.position.x = -10 * sin(theta);
  cam.position.y = 7 * sin(theta * 0.8);

  cam.tilt = -sin(theta * 0.8) * PI / 4.0;

  cam.yaw = theta;

  int tris_drawn = cam.draw(color_buf, depth_buffer, scene_tris, samples);
  
  sp.update_depth_buffer(scene_tris);
  
  //apply_spotlight_depth_buffer();

  image(color_buf, 0, 0);
  //visualise_depth_buffer(depth_buffer);

  text("Frame rate: "+(int)frameRate, 5, 15);
  text("Tris drawn: "+tris_drawn, 5, 30);
}

void apply_spotlight_depth_buffer() {
  color_buf.loadPixels();
  
  for(int y = 0; y < color_buf.height; y++) {
    for(int x = 0; x < color_buf.width; x++) {
      int index = y * color_buf.width + x;
      
      //if(depth_buffer[index] == 255) continue;
      
      //println("Screen point ("+x+", "+y+", "+depth_buffer[index]+")");
      
      //PVector p = new PVector(x, y, depth_buffer[index]);
      //p = cam.vec_screen_to_world(p, color_buf.width, color_buf.height);
      ////p = sp.world_to_depth_buffer(p);
      
      //print("Testing point: ");
      //print("("+p.x+", "+p.y+", "+p.z+")");
      //println();
      
      //if(!sp.in_view(p)) {
      //  color_buf.pixels[index] = color(0);
      //  continue;
      //}
      
      ////if(sp.probe_depth_buffer(p.x, p.y) < p.z)
      ////  color_buf.pixels[index] = color(0);
      
      float depth = depth_buffer[index];
      
      float red = (float)red(color_buf.pixels[index]);
      float green = (float)green(color_buf.pixels[index]);
      float blue = (float)blue(color_buf.pixels[index]);
      
      red = map(depth, 0, 255, red, 0);
      green = map(depth, 0, 255, green, 0);
      blue = map(depth, 0, 255, blue, 0);
      
      color_buf.pixels[index] = color(red, green, blue);
    }
  }
  
  color_buf.updatePixels();
}

void visualise_depth_buffer(float[] depth_buffer) {
  loadPixels();

  for (int i = 0; i < pixels.length; i++) {
    pixels[i] = color(depth_buffer[i]);
  }

  updatePixels();
}
