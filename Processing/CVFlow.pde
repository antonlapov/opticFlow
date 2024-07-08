import gab.opencv.*;
import gohai.glvideo.*;
import oscP5.*;
import netP5.*;


class CVFlow{
  
  OpenCV cv;
  PApplet app;
  //array for storing average flow vectors values
  PVector[] averageVectors;
   //array for storing  magnitudes of each average vectors val
  float[] vecMagnitudes;
  //array for storing rotations angle for each average vectors val [in radians]
  float[] rotAngle;
  //array for storing rotations angle for each average vectors val [in 360 degrees]
  float[] rotAngleD;
  int numOfReg;
  
  //variables forOSC
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  
  //constructor
  CVFlow(PApplet parent, int flowWidth, int flowHeight, int numberOfWidthRegions, String remoteAddr, int oscPort){
    this.app = parent;
    this.cv = new OpenCV(app, flowWidth, flowHeight);
    this.averageVectors =  new PVector[numberOfWidthRegions];
    this.vecMagnitudes =  new float[numberOfWidthRegions];
    this.rotAngle =  new float[numberOfWidthRegions];
    this.rotAngleD =  new float[numberOfWidthRegions];
    this.numOfReg = numberOfWidthRegions;
    
    this.oscP5 = new OscP5(app,oscPort);
    this.myRemoteLocation = new NetAddress(remoteAddr,oscPort);
  }
  
  //calculate OpticalFlow
  void calcFlow(GLCapture video){
     cv.loadImage(video);
     cv.calculateOpticalFlow();
  }
  
  
  //function for drawing smaller CV flow matrix onto bigger renderer sizes
  void drawScaled(int parent_width, int parent_height, int step){
      int stepSize = step;
      
      for(int y = 0; y < cv.flow.height(); y+=stepSize){
        for(int x = 0; x < cv.flow.width(); x+=stepSize){
            PVector flowVec = cv.flow.getFlowAt(x,y);
            float scaledX = map(x, 0, cv.flow.width(), 0, parent_width);
            float scaledY = map(y, 0, cv.flow.height(), 0, parent_height);
            line(scaledX, scaledY, scaledX+flowVec.x, scaledY+flowVec.y);
        }
      }
 }
 
 //func for retreieving average flow vectors in respective regions inside flow matrix
  void regionsFlow(){
    
    for(int i = 0; i < averageVectors.length; i++){
        //defining x position if region + width of region
        int xPos = i*(cv.flow.width()/numOfReg);
        int regWidth = cv.flow.width()/numOfReg;
        
        //storing values into array
        averageVectors[i] = cv.flow.getAverageFlowInRegion(xPos, 0, regWidth, cv.flow.height()); 
        
        //!add lerp!!
        
        //calculating and storing magnitudes for each region
        PVector centerOfRegion = new PVector(xPos+regWidth*0.5, cv.flow.height()*0.5, 0); 
        PVector flowPoint = new PVector(centerOfRegion.x+averageVectors[i].x, centerOfRegion.y+averageVectors[i].y, 0); 
        vecMagnitudes[i] = centerOfRegion.dist(flowPoint);
        
        //calculate and store rotation in radians and 360 degrees
        PVector normalized = averageVectors[i].normalize();
        rotAngle[i] = atan2(normalized.y, normalized.x);
        rotAngleD[i] = abs(degrees(rotAngle[i])-180);
        //println(i + "ROT--> " + rotAngle[1]);
      }
  }
  
  //method for osc sending flow values
  void sendFlow(){
    //send all data as a osc bundle
    OscBundle flowBundle = new OscBundle();
    //sending magnitudes
    OscMessage myMessage = new OscMessage("/flow");
    //format list for usage with Pd abstractions (triplesL: index + MagValue + rotValue)
    for (int i = 0; i < vecMagnitudes.length; i++){
      myMessage.add(i);
      myMessage.add(vecMagnitudes[i]);
      myMessage.add(rotAngleD[i]);
    }
    //myMessage.add(vecMagnitudes); 
    flowBundle.add(myMessage);
    //myMessage.clear();
    /*
    myMessage.setAddrPattern("/flow/rots");
    for (int i = 0; i < rotAngleD.length; i++){
      myMessage.add(i);
      myMessage.add(rotAngleD[i]);  
    }
    */
   // flowBundle.add(myMessage);
    flowBundle.setTimetag(flowBundle.now() + 10000);
    /* send the message */
    oscP5.send(flowBundle, myRemoteLocation); 
  }
  
  void drawRegsFlow(int parent_width, int parent_height, int magnification){
    //this.regionsFlow(); 
    for(int i = 0; i < averageVectors.length; i++){
      float x = i*(parent_width/numOfReg) + parent_width/numOfReg;
      float y = parent_height*0.5;
      //line(x,y, x + averageVectors[i].x * magnification,  y + averageVectors[i].y * magnification);
      pushMatrix();
         translate(x-parent_width/numOfReg*0.5,y);
         rotate(rotAngle[i]);
         //noStroke();
         strokeCap(SQUARE);
         strokeWeight(4);
         stroke(map(vecMagnitudes[i], 0, 10, 0, 255));
         line(0,0,0,35);
      popMatrix();
         
        if(averageVectors[i].x > 0.75 || averageVectors[i].y > 0.75){
               fill(255);
               textSize(12);
               //text(i +" :: x->"+ averageVectors[i].x + " y->"+ averageVectors[i].y + " :: rotation->"+ rotAngle[i], 20, 20+i*12 );
               //text(i +" :: mag"+ vecMagnitudes[i], 20, 20+i*12 );
          
      }
    }
    /*
    if(vecMagnitudes[7]>0.1){
        fill(255,0,0);
        text("[7]" +":: mag--> "+ vecMagnitudes[7], 7*(width/numOfReg)-100, height/2-20 );
    }
    */
  }
  
  
}
