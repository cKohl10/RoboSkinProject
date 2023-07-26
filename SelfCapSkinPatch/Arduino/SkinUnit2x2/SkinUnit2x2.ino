#include <CapacitiveSensor.h>

/*
* For the 4 sensor skin patch
*
* Ordering:
*   1 2
*   3 4
*/

CapacitiveSensor caps1 = CapacitiveSensor(2, 3);        // 10M resistor between pins 4 & 2, pin 2 is sensor pin, add a wire and or foil if desired
CapacitiveSensor caps2 = CapacitiveSensor(5, 6);
CapacitiveSensor caps3 = CapacitiveSensor(8, 9);
CapacitiveSensor caps4 = CapacitiveSensor(11, 12);
int readings;
const int threshold = 80;  // Value that must be overcome to show as "activated"
const String delim = ",";

//CapacitiveSensor   cs_4_6 = CapacitiveSensor(4,6);        // 10M resistor between pins 4 & 6, pin 6 is sensor pin, add a wire and or foil

void setup()                    
{
  caps1.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  caps2.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  caps3.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  caps4.set_CS_AutocaL_Millis(0xFFFFFFFF); 

  readings = 0;
   Serial.begin(115200);
}

void loop()                    
{
  long total1 =  caps1.capacitiveSensor(30);
  long total2 =  caps2.capacitiveSensor(30);
  long total3 =  caps3.capacitiveSensor(30);
  long total4 =  caps4.capacitiveSensor(30);
  // if (total > threshold){
  //   readings = 1;
  // } else{
  //   readings = 0;
  // }
  //Serial.print(total);
  //Serial.print(delim);
  //Serial.print(millis() - start);        // check on performance in milliseconds
  //Serial.print("\n");                    // tab character for debug windown spacing
  long time = millis();
  //Serial.print(time);
  String outputData = total1 + delim + total2 + delim + total3 + delim + total4 + delim + time;
  Serial.println(outputData);
  
  // Serial.print(readings[2] + delim + readings[5] + delim + readings[8]);                  // print sensor output 1
  // Serial.print("\n");
  // Serial.print(readings[1] + delim + readings[4] + delim + readings[7]);                  // print sensor output 1
  // Serial.print("\n");
  // Serial.print(readings[0] + delim + readings[3] + delim + readings[6]);                  // print sensor output 1
  // Serial.print("\n");
  delay(50);                             // arbitrary delay to limit data to serial port 
}
