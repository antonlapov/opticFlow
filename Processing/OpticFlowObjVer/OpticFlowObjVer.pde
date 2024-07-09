import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import org.opencv.core.Point;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.video.Video;
import org.opencv.core.Mat;
import org.opencv.core.MatOfByte;
import org.opencv.core.MatOfFloat;
import org.opencv.core.TermCriteria;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

Capture video;
OpenCV opencv;

Mat prevFrame;

MatOfPoint p0MatofPoint;
MatOfPoint2f p0, p1;

void setup() {
  size(640, 480);
  video = new Capture(this, "pipeline:autovideosrc");
  
  opencv = new OpenCV(this, 640, 480); 
  p0MatofPoint = new MatOfPoint();

  video.start();
  opencv.loadImage(video);
  opencv.useGray();
  prevFrame = opencv.matGray;
  
}

void draw() {
  //background(0);
  opencv.loadImage(video);
  opencv.useGray();
  //PImage img = opencv.getOutput();
  //image(img, 0, 0 );
  
  Imgproc.goodFeaturesToTrack(opencv.matGray, p0MatofPoint,100,0.2,7, new Mat(),7,false,0.04);
  p0 = new MatOfPoint2f(p0MatofPoint.toArray());
  p1 = new MatOfPoint2f();
  
  MatOfByte status = new MatOfByte();
 MatOfFloat err = new MatOfFloat();
 TermCriteria criteria = new TermCriteria(TermCriteria.COUNT + TermCriteria.EPS,10,0.03);
  Video.calcOpticalFlowPyrLK(prevFrame, opencv.matGray, p0, p1, status, err, new Size(15,15),2, criteria);
  
  byte StatusArr[] = status.toArray();
  Point p0Arr[] = p0.toArray();
  Point p1Arr[] = p1.toArray();
  ArrayList<Point> good_new = new ArrayList<>();
  
  for (int i = 0; i<StatusArr.length ; i++ ) {
    if (StatusArr[i] == 1) {
    good_new.add(p1Arr[i]);
    stroke(255,0,0);
    line((float)p1Arr[i].x,(float)p1Arr[i].y,(float)p0Arr[i].x,(float)p0Arr[i].y); 
    //noStroke();
    //fill(0,0,255);
    //ellipse((float)p1Arr[i].x,(float)p1Arr[i].y, 5,5);
     //Imgproc.line(mask, p1Arr[i], p0Arr[i], colors[i],2);
 //Imgproc.circle(frame, p1Arr[i],5, colors[i],-1);
 }
 }
  

  
  /*
  Point p0Arr[]  = p0.toArray();
    noFill();
    stroke(255,0,0);
    strokeWeight(2);
    beginShape();
  for(int i = 0; i < p0Arr.length; i++){  
    vertex((float)(p0Arr[i].x),(float)(p0Arr[i].y));
  }
  endShape();
  */

  prevFrame = opencv.matGray;
}

void captureEvent(Capture c) {
  c.read();
}

void mousePressed(){
  //ArrayList<Point> good_new = new ArrayList<>();
  Point p0Arr[]  = p1.toArray();
  println(p0Arr.length);
  //println(n);
}
