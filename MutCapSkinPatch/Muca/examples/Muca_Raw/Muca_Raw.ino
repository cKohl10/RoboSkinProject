#include <Muca.h>

Muca muca;
const int num_Rx = 21;
const int num_Tx = 1;

void setup() {
  Serial.begin(115200);

  muca.init(false);
  muca.useRawData(true); // If you use the raw data, the interrupt is not working
 // muca.setGain(100);
  muca.setGain(1);
}

void loop() {
  GetRaw();
}

void GetRaw() {

  if (muca.updated()) {
    for (int i = 0; i < num_Rx*num_Tx; i++) {
      Serial.print(muca.grid[i]);
      if (i != num_Rx*num_Tx-1)
        Serial.print(",");
    }
    Serial.println();
  }
}
