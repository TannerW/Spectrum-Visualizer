/*
 * Audio Spectrum Analyzer and Visualizer Using Processing and Arduino
 * By Owen Tanner Wilkerson
 * 
 * If you would like the hardware list and Fritz diagrams then please contact me.
 * I'd be happy to send them to you.
 * 
 * Summary:
 * Recieves data through Firmata from Processing that is then interpretted
 * to alter the columns of LEDs in order to visualize the spectrum through hardware.
 * Uses the TLC 5940 LED Driver IC from Texas Instruments and corresponding library
 * in order to control the amount of LEDs needed for the project.
 * 
 * 
 * Note:
 * Uses Processing to analyze the Audio signal,
 * generate the LED data, then uses Firmata Library to write to Arduino.
 * Get more info and view the Processing code at: 
 * https://github.com/TannerW/Spectrum-Visualizer/blob/master/Processing_Analyzing_and_Sending.pde
 * 
 * Resources:
 * http://www.ti.com/lit/ds/symlink/tlc5940.pdf
 * http://playground.arduino.cc/Learning/TLC5940
 * https://github.com/firmata/arduino
*/

#include <Tlc5940.h>
#include <Firmata.h>

//These arrays hold the TLC pin values for the LEDs corresponding to each of the 4 columns.
int col1_LED_pins[6] = {22,21,20,19,18,17};
int col2_LED_pins[6] = {30,29,28,27,26,25};
int col3_LED_pins[6] = {6,5,4,3,2,1};
int col4_LED_pins[6] = {14,13,12,11,10,9};

void setup()
{
  //sets version of Firmata
  Firmata.setFirmwareVersion(FIRMATA_MAJOR_VERSION, FIRMATA_MINOR_VERSION);

  //Attaches a callback function to the analog messages Processing is sending.
  //(if it processes an analog message then it will run analogWriteCallback())
  Firmata.attach(ANALOG_MESSAGE, analogWriteCallback);

  //constructor set at the approprite Baud Rate
  Firmata.begin(250000);

  //initiation of the TLC chips
  Tlc.init();
}

void loop()
{
  //waits for Firmata activity.
  while (Firmata.available())
  {
    //processes the incoming message to determine what it is 
    Firmata.processInput();
  }
}

//When an analog message is processed, this function is ran.
//Using analogWrite with Processing, we are able to send the column of LEDs
//and the number of LEDs to turn on. This write method is typically used to send
//pin numbers and corresponding values as arguments but I implemented it differently.
void analogWriteCallback(byte column, int value)
{
  //Checks which column value was sent and the does one FOR loop to set all LED states to 0
  //and then a second FOR loop to change the state to always on (4095) for the correct number
  //of LEDs corresponding to the value sent by Processing. 
  if (column == 1)
  {
    for (int j = 0; j < 6; j++)
    {
      Tlc.set(col1_LED_pins[j],0);
    }
    
    for (int i = 0; i < value; i++)
    {
      Tlc.set(col1_LED_pins[i],4095);
    }
  }

  if (column == 2)
  {
    for (int j = 0; j < 6; j++)
    {
      Tlc.set(col2_LED_pins[j],0);
    }
    
    for (int i = 0; i < value; i++)
    {
      Tlc.set(col2_LED_pins[i],4095);
    }
  }

  if (column == 3)
  {
    for (int j = 0; j < 6; j++)
    {
      Tlc.set(col3_LED_pins[j],0);
    }
    
    for (int i = 0; i < value; i++)
    {
      Tlc.set(col3_LED_pins[i],4095);
    }
  }

  if (column == 4)
  {
    for (int j = 0; j < 6; j++)
    {
      Tlc.set(col4_LED_pins[j],0);
    }
    
    for (int i = 0; i < value; i++)
    {
      Tlc.set(col4_LED_pins[i],4095);
    }
  }

  //updates the LEDs states
  Tlc.update();
}
