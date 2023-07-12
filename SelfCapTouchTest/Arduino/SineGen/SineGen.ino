int F = 2;
int Fs = 500;
int n = 500;
float t;
int sampling_interval;
byte samples[500];

void setup() {
  // put your setup code here, to run once:
  //For the sine wave generation
  pinMode(10, OUTPUT);
  for (int n=0; n < Fs;n++){
    t = (float) n/Fs;
    samples[n] = (byte) (127.0 * sin(2*3.14*t) + 127.0);
  }
  sampling_interval = 1000000/(F*n);

}

void loop() {
  // put your main code here, to run repeatedly:
  //Sine generation
  for (int j = 0; j<255; j++){
    analogWrite(10, samples[j]);
    delayMicroseconds(sampling_interval);
  }

}
