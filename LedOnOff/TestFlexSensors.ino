#include <Arduino.h>

const int flexSensorPins[5] = {A0, A1, A2, A3, A4};
int flexSensorValues[5] = {0}; 

void setup() {
    Serial.begin(115200);
}

void loop() {
    for (int i = 0; i < 5; i++) {
        flexSensorValues[i] = analogRead(flexSensorPins[i]);
        Serial.print("Flex Sensor ");
        Serial.print(i + 1);
        Serial.print(": ");
        Serial.println(flexSensorValues[i]);
    }
    
    Serial.println("----------------------"); // Separator for readability
    delay(500); // Small delay to avoid flooding the serial monitor
}
