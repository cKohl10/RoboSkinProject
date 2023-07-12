#include <Wire.h>

const int INT = 13; //INT pin on D13 
const int RESET = 8;
const int slaveAddress = 0x25;

void setup() {
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
  pinMode(INT, INPUT);
  pinMode(RESET, OUTPUT);
  digitalWrite(RESET, LOW);
  delay(50);
  digitalWrite(RESET, HIGH);
  delay(100);
  while(digitalRead(INT)==HIGH){
    Serial.println("Waiting for LOW INT");
    delay(100);
  }
}

void loop() {
  String str1 = "INT Status: ";
  String message = str1 + digitalRead(INT);
  Serial.println(message);
  ComDeviceID();
  Wire.requestFrom(slaveAddress, 10);    // request 6 bytes from peripheral device #8
  //Wire.beginTransmission(37);
  while(Wire.available()) {
    char c = Wire.read();    // Receive a byte as character
    Serial.println(c, BIN);         // Print the character
  }

  delay(500);
}

void ComDeviceID(){
  Wire.beginTransmission(slaveAddress);
  Wire.write(0x4a);
  Wire.write(0x55);
  Wire.write(0x01);
  Wire.write(0x83);
  Wire.endTransmission();
}