/*
  Audio Spectrum Analyzer and Visualizer Using Processing and Arduino
  By Owen Tanner Wilkerson
  
  I always try to document thoroughly but feel free to contact me through "Issues"
  on GitHub if you are interested in pursuing a similar project and/or have questions.
  I will try my best to help!
  
  
  Project Summary:
  Analyzes an audio signal through a function that generates the Free Fourier Transform
  and visualizes that frequency spectrum.
  This code visualizes the spectrum through software and
  sends the data to Arduino to visualize on hardware.
  
  Notes on my procedure:
  I used the Processing Sound Library to analyze the signal
  (and visualize it through software).
  
  To visualize on hardware, I used the Processing Serial and
  contributed Firmata Libraries to help me send the analyzed data to an Arduino.
  The Arduino then interprets that data according.
  
  In this case, I used LEDs to visualize this data on hardware
  but these concepts could be tweaked fairly easily and applied
  to many means of visualization (please see the Arduino code for more info).
  
  Please refer to the resources used if asking any questions about any
  undocumented methods or functions. Processing has great documentation
  on their/Contributed libraries!

  Resources:
  https://processing.org/reference/libraries/
  https://github.com/processing/processing
*/

import processing.sound.*;
import processing.serial.*;
import cc.arduino.*;
import org.firmata.*;
Arduino arduino;
Serial myPort;
FFT fft;
AudioIn AudIn;

//rectangle width
float rect_width;

//used to slow the decay on your visualized values
//(makes visualization appear smoother)
float slow_factor = 0.3;

//used to scale visualized values
//(helps fine tweak the way your visualization looks and appears)
int scale_factor = 2;

//number of bands that you wish the signal to be divided into
int bands = 4;

//where raw fft data is stored
float[] spectrum = new float[bands];

//fft data after adding the slow factor
float[] total = new float[bands];

//the amplitude of each band
//used to calculate the data to send to Arduino
float[] height_array = {0, 0, 0, 0};

//converted values of the height_array for the Arduino to interpret
int[] LED_conversion = {0, 0, 0, 0};

void setup()
{
  size (1250, 800);

  //the width of the rectangles used in the software visualization
  rect_width= width/float(bands);

  fft = new FFT(this);
  AudIn = new AudioIn(this, 0); //uses your computer's mic to get audio input
  arduino = new Arduino(this, Arduino.list()[7], 250000);

  AudIn.start();

  fft.input(AudIn, bands);
}

void draw()
{
  background(0, 102, 0); //background color
  fill(255); //fill of the rectangles
  noStroke(); //takes bordering black lines off of drawn objects

  fft.analyze(spectrum);

  //Calculates the total and height arrays and
  //draws the rectangles used in the software visualization.
  for (int i = 0; i < bands; i++)
  {
    total[i] += (spectrum[i] - total[i]) * slow_factor;
    
    height_array[i] = total[i] * height * scale_factor;

    //(can be commented out or deleted if this visualization is not desired)
    rect(i * rect_width, height, rect_width, -total[i] * height * scale_factor);
  }
  
  //Converts the height_array elements to values used
  //to send to the Arduino for it to interpret
  //how many LEDs to light in each band (this code is for 6 LEDs in each band).
  //This is more of a quality of life thing
  //that makes tracking the sent data easier when tweaking or debugging code.
  for (int j = 0; j < bands; j++)
  {
    if (height_array[j] >= 1200)
    {
      LED_conversion[j] = 6;
    } 
    
    else
    {
      if (height_array[j] >= 800)
      {
        LED_conversion[j] = 5;
      }
      
      else
      {
        if (height_array[j] >= 600)
        {
          LED_conversion[j] = 4;
        }
        
        else
        {
          if (height_array[j] >= 400)
          {
            LED_conversion[j] = 3;
          }
          
          else
          {
            if (height_array[j] >= 200)
            {
              LED_conversion[j] = 2;
            }
            
            else
            {
              if (height_array[j] >= 50)
              {
                LED_conversion[j] = 1;
              }
              
              else
              {
                LED_conversion[j] = 0;
              }
            }
          }
        }
      }
    }
  }
  

  //Writes the LED values to the Arduino.
  int k = 0;
  while (k < 4)
  {
    //column of LEDs being altered
    int column_rotation= k+1;
    
    //number of LEDs needed in that column
    int array_rotation= k;
    
    //writes data to Arduino through Firmata
    arduino.analogWrite(column_rotation, LED_conversion[array_rotation]);
    
    // This print statement helps with debugging and tweaking if needed.
    // println("Sending: ", column_rotation, " LEDs: ", LED_conversion[array_rotation]);
    
    k++;
    
    //short delay to avoid overloading the Arduino with data to read
    delay(.01);
  }
}


//A basic delay function used to give a
//small delay in between sending data to the Arduino.
void delay(float delay)
{
  float time = millis();
  while (millis() - time <= delay){};
}
