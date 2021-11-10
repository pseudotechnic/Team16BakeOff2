import java.util.ArrayList;
import java.util.Collections;
import java.util.*;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

Slider slider1, slider2;

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
  
  slider1 = new Slider(width/4, height-30, width/3, 40, 0, 180, "Rotation");
  slider2 = new Slider(width*3/4, height-30, width/3, 40, 10, 500, "Size");
}

void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
  
  slider1.update();
  slider2.update();
  slider1.displayRot();
  slider2.displayScale();
  
  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  if(checkForSuccess())
  {
    stroke(0, 255, 0); 
  }
  else 
  {
    noStroke();
  }
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  //clickAndDrag();
  sliderLogic(); 
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/3, inchToPix(.4f));
  if (dist(2*width/3, inchToPix(.4f), mouseX, mouseY)<inchToPix(.4f))
  {
    //fill(0,255,0);
    fill(0,133,66);
  }
  else
  {
    fill(255, 0, 0);
  }
  textSize(25);
  text("SUBMIT", 2*width/3, inchToPix(.4f));
  
}

//slide controls
void sliderLogic()
{
  logoRotation = slider1.getVal();
  logoZ = slider2.getVal();
}

void mouseDragged()
{
  if (dist(logoX, logoY, mouseX, mouseY)<inchToPix(.8f)) 
  {
    logoX = mouseX;
    logoY = mouseY;
  }
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  //check to see if user clicked near submit button
  if (dist(2*width/3, inchToPix(.4f), mouseX, mouseY)<inchToPix(.4f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

public boolean checkForRot()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  return closeRotation;
}

public boolean checkForZ()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1" 
  return closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}

class Slider {
  float barX, barY;  // center x, y pos of the whole slide bar
  int barW, barH, sliderW, sliderH;
  int min, max;
  float sliderX, sliderY; // center x, y of slider
  float val;
  String name;
  
  Slider (float x, float y, int w, int h, int val_min, int val_max, String _name) 
  {
    barX = x;
    barY = y;
    sliderX = x;
    sliderY = y;
    barW = w;
    barH = h;
    min = val_min;
    max = val_max;
    val = (max - min) / 2;
    sliderW = 20;
    sliderH = barH;
    name = _name;
  }
  
  void update()
  {
    if (overEvent() && mousePressed)
    {
      float temp;
      if (mouseX < barX-barW/2)
      {
        temp = barX-barW/2;
      } 
      else if (mouseX > barX + barW/2 - sliderW)
      {
        temp = barX + barW/2 - sliderW;
      }
      else
      {
        temp = mouseX;
      }
      
      sliderX = temp;
    }
    
    val = map(sliderX, barX-barW/2, barX+barW/2-sliderW, min, max);
  }
  
  void displayRot()
  {
    noStroke();
    fill(204);
    rect(barX, barY, barW, barH);
    
    if (overEvent())
    {
      fill(0, 0, 0);
    }
    else
    {
      fill(102, 102, 102);
    }
    
    if(checkForRot())
    {
      //fill(0,255,0);
      fill(0,133,66);
    }
    rect(sliderX, sliderY, sliderW, sliderH);
    //display slider labels
    textSize(30);
    fill(0, 408, 612, 204);
    text("CCW", barX-barW/2+25, barY-22);
    text("CW", barX+barW/2-sliderW, barY-22);
    text(name, barX, barY-22);
  }
  
  void displayScale()
  {
    noStroke();
    fill(204);
    rect(barX, barY, barW, barH);
    
    if (overEvent())
    {
      fill(0, 0, 0);
    }
    else
    {
      fill(102, 102, 102);
    }
    
    if(checkForZ())
    {
      //fill(0,255,0);
      fill(0,133,66);
    }
    rect(sliderX, sliderY, sliderW, sliderH);
    //display labels
    textSize(30);
    fill(0, 408, 612, 204);
    text("-", barX-barW/2+15, barY-22);
    text("+", barX+barW/2-sliderW, barY-22);
    text(name, barX, barY-22);
  }
   
   
  boolean overEvent() 
  {
    if (dist(sliderX, sliderY, mouseX, mouseY)<inchToPix(.8f))
    {
      return true;
    }
    else 
    {
      return false;
    }
  }
  
  float getVal()
  {
    println(val);
    return val;
  }
}
