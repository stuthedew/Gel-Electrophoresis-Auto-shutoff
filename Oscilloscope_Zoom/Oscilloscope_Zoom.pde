  /*
 * Oscilloscope
 * Gives a visual rendering of analog pin 0 in realtime.
 * 
 * This project is part of Accrochages
 * See http://accrochages.drone.ws
 * 
 * (c) 2008 Sofian Audry (info@sofianaudry.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 
import processing.serial.*;

Serial port;  // Create object from Serial class
int val1;      // Data received from the serial port
int[] values;
float zoom;
int value = 0;
int dValue = 1;

String buff = "";
int wRed, wGreen, wBlue, wClear;
String hexColor = "ffffff";

void setup() 
{
  size(1280, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, "/dev/tty.usbmodem1421", 115200);
  values = new int[width];
  zoom = 1.0f;
  smooth();
  background(0);
  drawGrid();
}

int getY(int val) {
  return (int)(height - val / 1023.0f * (height - 1));
}

int getValue() {
//int value=-1;
//  while (port.available() >= 3) {
//    if (port.read() == 0xff) {
//      value = (port.read() << 8) | (port.read());
//    }

  //}
 if(value > height || value < 0){
   dValue *= -1;
 }
value += dValue;
  return value;
}

void pushValue(int Value) {
  for (int i=0; i<width-1; i++)
    values[i] = values[i+1];
  values[width-1] = Value;
}

void drawLines() {
  stroke(0,255,0);
  
  int displayWidth = (int) (width / zoom);
  
  int k = values.length - displayWidth;
  
  int x0 = 0;
  int y0 = getY(values[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int y1 = getY(values[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}

void drawGrid() {
  stroke(0, 255, 0);
  line(0, height/2, width, height/2);
}

void keyReleased() {
  switch (key) {
    case '+':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case '-':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}

void draw()
{
  
  while(port.available() > 0) {
   serialEvent(port.read());
 }
 
  while(port.available() ==0);
  
}

void serialEvent(int serial) {
  val1 = -1;
 if(serial != '\n') {
   buff += char(serial);
 } else {
   //println(buff);
   
   int cRed = buff.indexOf("R");
   int cGreen = buff.indexOf("G");
   int cBlue = buff.indexOf("B");
   int clear = buff.indexOf("C");
   if(clear >=0){
     String val = buff.substring(clear+3);
     
     val = val.split("\t")[0]; 
     print("val C: ");
     println(val);

   } else { return; }
   
   if(cRed >=0){
     String val = buff.substring(cRed+3);
     val = val.split("\t")[0];
    print("val R: ");
     println(val); 
     wRed = Integer.parseInt(val.trim());
   } else { return; }
   
   if(cGreen >=0) {
     String val = buff.substring(cGreen+3);
     val = val.split("\t")[0]; 
     print("val G: ");
     println(val);
     wGreen = Integer.parseInt(val.trim());
   } else { return; }
   
   if(cBlue >=0) {
     String val = buff.substring(cBlue+3);
     val = val.split("\t")[0]; 
     print("val B: ");
     println(val);
     wBlue = Integer.parseInt(val.trim());
   } else { return; }
   
   print("Red: "); print(wRed);
   print("\tGrn: "); print(wGreen);
   print("\tBlue: "); print(wBlue);
   print("\tClr: "); println(wClear);
   
   val1 = int(map(wGreen, 0, 6000, 20, height - 20));
   background(0);
   drawGrid();
   if (val1 != -1) {
    pushValue(val1);
    
  }
  drawLines();
   
//   wRed *= 255; wRed /= wClear;
//   wGreen *= 255; wGreen /= wClear; 
//   wBlue *= 255; wBlue /= wClear; 
//
//   hexColor = hex(color(wRed, wGreen, wBlue), 6);
//   println(hexColor);
//   buff = "";
   
 }
}
