#include <CapacitiveSensor.h>


/*
* Code for the shoebox test setup with nine sensors rrandomly spread out
*
* Ordering:
*   3 6 9
*   2 5 8 
*   1 4 7
*/


CapacitiveSensor caps = CapacitiveSensor(4, 2);        // 10M resistor between pins 4 & 2, pin 2 is sensor pin, add a wire and or foil if desired
int readings;
const int threshold = 80;  // Value that must be overcome to show as "activated"
const String delim = ",";

//CapacitiveSensor   cs_4_6 = CapacitiveSensor(4,6);        // 10M resistor between pins 4 & 6, pin 6 is sensor pin, add a wire and or foil

void setup()                    
{
  caps.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  readings = 0;
   Serial.begin(9600);
   Serial.println("CS_1, Time (ms)");

  
}

void loop()                    
{

  

  long total =  caps.capacitiveSensor(30);
  if (total > threshold){
    readings = 1;
  } else{
    readings = 0;
  }
  //Serial.print(total);
  //Serial.print(delim);
  //Serial.print(millis() - start);        // check on performance in milliseconds
  //Serial.print("\n");                    // tab character for debug windown spacing
  long time = millis();
  //Serial.print(time);
  String outputData = total + delim + time;
  Serial.println(outputData);
  
  // Serial.print(readings[2] + delim + readings[5] + delim + readings[8]);                  // print sensor output 1
  // Serial.print("\n");
  // Serial.print(readings[1] + delim + readings[4] + delim + readings[7]);                  // print sensor output 1
  // Serial.print("\n");
  // Serial.print(readings[0] + delim + readings[3] + delim + readings[6]);                  // print sensor output 1
  // Serial.print("\n");
  delay(100);                             // arbitrary delay to limit data to serial port 
}
