#include <Muca.h>

Muca muca;

const int BYTE_NUM = 1; // NUM_TX*NUM_RX + 2
const int num_TX = 10;
const int num_RX = 3;

void setup() {
  Serial.begin(115200);
  bool RX_lines[NUM_RX] = {0,0,0,0,0,0,0,0,0,0,0,0}; 			 // RX Lines to skip
  bool TX_lines[NUM_TX] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // TX lines to skip

  Serial.print("RX active lines: ");
  for (int i=0; i<NUM_RX; i++){
    RX_lines[i] = (i < num_RX);
    Serial.print(RX_lines[i]);
  }
  Serial.println();

  Serial.print("TX active lines: ");
  for (int i=0; i<NUM_TX; i++){
    TX_lines[i] = (i < num_TX);
    Serial.print(TX_lines[i]);
  }
  Serial.println();
  //muca.skipLine(TX, (const short[]) { 1, 2, 3, 4 }, 4);
  muca.selectLines(RX_lines, TX_lines);
  muca.init();
  muca.useRawData(true); // If you use the raw data, the interrupt is not working

  delay(50);
  muca.setGain(2);
}

void loop() {
  if (muca.updated()) {
    SendRawString();
    //SendRawByte(); // Faster
  }
  delay(16); // waiting 16ms for 60fps

}

void SendRawString() {
  // Print the array value
  for (int i = 0; i < num_TX * num_RX; i++) {
    if (muca.grid[i] >= 0) Serial.print(muca.grid[i]); // The +30 is to be sure it's positive
    if (i != num_TX * num_RX - 1)
      Serial.print(",");
  }
  Serial.println();

}


void SendRawByte() {
  // The array is composed of 254 bytes. The two first for the minimum, the 252 others for the values.
  // HIGH byte minimum | LOW byte minimum  | value 1

  //unsigned int minimum = 80000;
  uint8_t rawByteValues[BYTE_NUM]; //NUM_TX * NUM_RX + 2

  // for (int i = 0; i < NUM_TX * NUM_RX; i++) {
  // if (muca.grid[i] > 0 && minimum > muca.grid[i])  {
  //     minimum = muca.grid[i]; // The +30 is to be sure it's positive
  //   }
  // }
  // rawByteValues[0] = highByte(minimum);
  // rawByteValues[1] = lowByte(minimum);


  for (int i = 0; i < num_TX * num_RX; i++) {
    rawByteValues[i] = muca.grid[i]; // - minimum;
    //Serial.print(rawByteValues[i]);
    //  Serial.print(",");

  }
  //Serial.println();
  //GetFPS();
  Serial.write(rawByteValues, BYTE_NUM);
  Serial.flush();
  //Serial.println();
}
