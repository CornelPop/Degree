// int pinDegetMare = 32;
// int pinDegetAratator = 36;
// int pinDegetMijlociu = 39;
// int pinDegetInelar = 34;
// int pinDegetMic = 35;
const int flexSensorPins[5] = {32, 35, 34, 39, 36};
void setup() {
  Serial.begin(9600);
  for (int i=0; i<5; i++)
    pinMode(flexSensorPins[i], INPUT);
}

void loop() {
  for (int i=0; i<5; i++){
    Serial.print(analogRead(flexSensorPins[i]));
    Serial.print("   ");
  }
  Serial.println();
}
