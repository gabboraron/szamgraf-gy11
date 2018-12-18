Camera camera;

ParamSphere sphere = new ParamSphere();
ParamCylinder cylinder = new ParamCylinder();
ParamWave wave = new ParamWave();

CatmullRom spline = new CatmullRom();

ParamSphere skybox = new ParamSphere();

PShape boat;
SpaceShip ship;

ArrayList<Projectile> projectiles = new ArrayList<Projectile>();

ArrayList<Enemy> enemies = new ArrayList<Enemy>();

PImage tex_earth;
PImage tex_csirke;
PImage tex_texture;

int camera_mode = 1; // 1 - free, 2 - curve
float camera_t = 1.0;
int last_time;

void setup() {
  size(800, 600, P3D);
  last_time = millis();
  
  tex_earth = loadImage("earth.jpg");
  tex_csirke = loadImage("csirke.jpg");
  tex_texture = loadImage("texture.bmp");
  
  skybox.tex = loadImage("skybox.png");
  
  boat = loadShape("OldBoat.obj");
  PShape spaceShipBody = loadShape("space_frigate.obj");
  ship = new SpaceShip(spaceShipBody);
  
  sphere.tex = tex_earth;
  cylinder.tex = tex_csirke;
  wave.tex = tex_texture;
  
  camera = new Camera();
  
  PVector enemiPos1 = new PVector(5, 0, 5);
  PVector enemiPos2 = new PVector(-5, 0, -5);
  PVector enemiPos3 = new PVector(5, 0, -5);
  PVector enemiPos4 = new PVector(-5, 0, 5);
  enemies.add(new Enemy(spaceShipBody, enemiPos1));
  enemies.add(new Enemy(spaceShipBody, enemiPos2));
  enemies.add(new Enemy(spaceShipBody, enemiPos3));
  enemies.add(new Enemy(spaceShipBody, enemiPos4));
    
  PVector p1 = new PVector(3, 0.8, 3);
  PVector p2 = new PVector(3, -0.4, -3);
  PVector p3 = new PVector(-3, 0.8, -3);
  PVector p4 = new PVector(-3, -0.2, 3);
  
  PVector boatPos = wave.GetPos(0.5, 0.5).add(5, 5 - 2, 0);
  
  spline.AddControllPoint(boatPos.copy().add(p1));
  spline.AddControllPoint(boatPos.copy().add(p2));
  spline.AddControllPoint(boatPos.copy().add(p3));
  spline.AddControllPoint(boatPos.copy().add(p4));
  spline.AddControllPoint(boatPos.copy().add(p1));
  spline.AddControllPoint(boatPos.copy().add(p2));
  spline.AddControllPoint(boatPos.copy().add(p3));
}

void update() {
  
  float delta_time = (millis() - last_time) / 1000.0f;
  last_time = millis();
  
  for (int i = projectiles.size() - 1; i >= 0; --i) {
    Projectile p = projectiles.get(i);
    if (p.pos.mag() > 300) {
      projectiles.remove(i);
    } else {
     p.update();
    }
  }
   
  for (Enemy e : enemies) {
    PVector shipPos = ship.position.copy(); 
     e.update(shipPos); 
  }
  
  if (camera_mode == 1) {
   camera.update();
  } else if (camera_mode == 2) {
    camera_t += 0.4 * delta_time;
    
    if (camera_t > spline.bases.size() - 2) {
      camera_t = 1.0f;
    }
    
    int ind = (int)camera_t - 1;
    float t = camera_t - (int)camera_t + 1;
    PVector cameraPos = spline.Eval(ind, t);
    
    camera.eye = cameraPos;
    camera.at = wave.GetPos(0.5, 0.5).add(5, 5 - 2, 0);
    camera.ApplyCamera();
  }
 ship.update();
}

void keyReleased() {
   if (key == 'w') {
    camera.MoveForwad(false); 
   } else if (key == 's') {
    camera.MoveBackward(false); 
   } else if (key == 'd') {
    camera.MoveRight(false); 
   } else if (key == 'a') {
    camera.MoveLeft(false); 
   }
   
  if(keyCode == UP) {
   ship.MoveForward(false); 
  } else if(keyCode == DOWN) {
   ship.MoveBackward(false); 
  } else if(keyCode == LEFT) {
   ship.RotateLeft(false);
  } else if(keyCode == RIGHT) {
   ship.RotateRight(false);
  }
}


void keyPressed() {
 if (key == 'w') {
  camera.MoveForwad(true); 
 } else if(key == 's') {
   camera.MoveBackward(true);
 } else if (key == 'd') {
  camera.MoveRight(true); 
 } else if (key == 'a') {
  camera.MoveLeft(true); 
 }
  
  
  if(keyCode == UP) {
   ship.MoveForward(true); 
  } else if(keyCode == DOWN) {
   ship.MoveBackward(true);
  } else if(keyCode == LEFT) {
   ship.RotateLeft(true);
  } else if(keyCode == RIGHT) {
   ship.RotateRight(true);
  }
  
  if (key == ' ') {
    PVector pos = ship.position.copy();
    PVector dir = ship.GetForward();
    Projectile p = new Projectile(pos, dir); 
    
    projectiles.add(p); //<>//
  }
  
  if (key == '1') {
    camera_mode = 1;
  } else if (key == '2') {
   camera_mode = 2; 
  }
}

void draw() {
  update();
  SetLights();  
  draw3D();
  drawSkybox();
  drawGUI();
}

void drawGUI() {
  hint(DISABLE_DEPTH_TEST);
    camera();
    text("asdasd", 100, 100);
  hint(ENABLE_DEPTH_TEST);
}

void drawSkybox() {
 noLights();
 
 pushMatrix();
   PVector camPos = camera.eye;
   translate(camPos.x, camPos.y, camPos.z);
   scale(20, 20, 20);
   skybox.Draw();
 popMatrix();
 
 lights();
}

void SetLights() {
  lights();
  directionalLight(0, 30, 200, 0, -1, 0);
}

void draw3D() {
  background(127);
  
  pushMatrix();
    rotateZ(millis()/1000.0);
    translate(0, 0, -1);
    pyramid();
    rotateY(PI);
    pyramid();
  popMatrix();
  
  pushMatrix();
    rotateZ(millis()/1000.0);
    translate(0, 0, 1);
    pyramid();
    rotateY(PI);
    pyramid();
  popMatrix();
  
  
  pushMatrix();
    rotateZ(-millis()/400.0);
    scale(1, 0.4, 0.4);
    translate(1,0,0);
    rotateY(PI/2);
    pyramid();
    rotateY(PI);
    pyramid();
  popMatrix();
  
  
  pushMatrix();
    translate(5, 0, 0);
    sphere.Draw();
  popMatrix();
  
  
  pushMatrix();
    translate(-5, 0, 0);
    cylinder.Draw();
  popMatrix();
  
  
  pushMatrix();
    translate(5, 5, 0);
    wave.offset.x = millis() / 500.0f;
    wave.offset.y = millis() / 500.0f;
    wave.Draw();
    
    PVector pos = wave.GetPos(0.5, 0.5);
    
    PVector normal = wave.GetNormal(0.5, 0.5);
    PVector du = wave.GetDiffU(0.5, 0.5);
    PVector dv = wave.GetDiffV(0.5, 0.5);
    
    normal.normalize();
    du.normalize();
    dv.normalize();
    
    stroke(255, 0, 0);
    line(pos.x, pos.y, pos.z, 
        pos.x + normal.x, pos.y + normal.y, pos.z + normal.z);
        
    stroke(0, 255, 0);
    line(pos.x, pos.y, pos.z, 
        pos.x + du.x, pos.y + du.y, pos.z + du.z);
        
    stroke(0, 0, 255);
    line(pos.x, pos.y, pos.z, 
        pos.x + dv.x, pos.y + dv.y, pos.z + dv.z);
    noStroke();
    
    pushMatrix();
      translate(pos.x, pos.y - 0.02, pos.z);
      applyMatrix(
      du.x, normal.x, dv.x, 0,
      du.y, normal.y, dv.y, 0,
      du.z, normal.z, dv.z, 0,
      0, 0, 0, 1);
      scale(0.02);
      
      shape(boat);
    popMatrix();
  popMatrix();
  
  ship.Draw();
  
  for (Projectile p : projectiles) {
   p.Draw(); 
  }
  
  for (Enemy e : enemies) {
   e.Draw(); 
  }
  
  
  stroke(255, 0, 0);
    spline.Draw();
  noStroke();
}
void pyramid() {
 beginShape(TRIANGLES); 
 vertex(-1, -1, 0);
 vertex(1, -1, 0);
 vertex(-1, 1, 0);
 
 vertex(1, -1, 0);
 vertex(1, 1, 0);
 vertex(-1, 1, 0);
 
 vertex(-1, -1, 0);
 vertex( 1, -1, 0);
 vertex(0, 0, 1);
 
 vertex(1, -1, 0);
 vertex( 1, 1, 0);
 vertex(0, 0, 1);
 
 vertex(1, 1, 0);
 vertex( -1, 1, 0);
 vertex(0, 0, 1);
 
 vertex(-1, 1, 0);
 vertex( -1, -1, 0);
 vertex(0, 0, 1);
 endShape();
}
