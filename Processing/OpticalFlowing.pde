//16x9
//160x90
import gab.opencv.*;
import gohai.glvideo.*;

GLCapture video;

//custom openCV object for flow matrix manipulations
CVFlow cvf;
// array for storing average regiobal flow vectorw
PVector[] regVecs;
//!! num of width regions to devide flow matrix  global
int widthRegions = 8;

void setup() {
  //size(64, 64, P2D);
  size(640, 360, P2D);
  
  String[] devices = GLCapture.list();
  println("Devices:");
  printArray(devices);
  if (0 < devices.length) {
    String[] configs = GLCapture.configs(devices[0]);
    println("Configs:");
    printArray(configs);
  }
  
  int cvWidth = 160;
  int cvHeight = 90;
  video = new GLCapture(this, devices[0], cvWidth, cvHeight);
  video.start();  

  cvf = new CVFlow(this, cvWidth, cvHeight, widthRegions, "192.168.8.2", 9999);
  
  rectMode(CENTER);

}

void draw() {
  background(0);
  
  if (video.available()) {
    video.read();
  }
  
  if (video.width == 0 || video.height == 0)
    return;
  
  cvf.calcFlow(video);
  //image(video, 0, 0, width, height);
  cvf.regionsFlow();
  stroke(255, 0, 255);
  cvf.drawRegsFlow(width,height, 2);
  stroke(0,255,0);
  //cvf.drawScaled(width, height, 4); 
  
  cvf.sendFlow();

}
