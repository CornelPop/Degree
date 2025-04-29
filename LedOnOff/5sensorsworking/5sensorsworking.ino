#include <WiFi.h>

const char* ssid = "Net co";       // WiFi SSID
const char* password = "C0&V14EVER"; // WiFi password

WiFiServer server(80); // Start server on port 80
int flexSensorPin = 34; // Analog pin for flex sensor
int flexSensorValue = 0; // Variable to store sensor value

const int flexSensorPins[5] = {32, 35, 34, 39, 36};

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }

  Serial.println("Connected to WiFi");
  Serial.println(WiFi.localIP());

  server.begin();  // Start the server
}

void loop() {
  WiFiClient client = server.available(); // Check for incoming client connection
  if (client) {
    Serial.println("New Client.");
    String currentLine = "";
    String request = ""; // Variable to store the request path

    while (client.connected()) {
      if (client.available()) {
        char c = client.read(); // Read the incoming character
        Serial.write(c);

        if (c == '\n') {
          if (currentLine.length() == 0) {
            // Check if the request path is "/READ_SENSOR_VALUES"
            if (request.indexOf("GET /READ_FLEX_SENSOR_VALUES") >= 0) {
              client.println("HTTP/1.1 200 OK");
              client.println("Content-Type: text/plain");
              client.println();

              // Read the flex sensor value
              //flexSensorValue = analogRead(flexSensorPin);
              //client.print(flexSensorValue);  // Send the sensor value back to the client
              //Serial.print("Flex Sensor Value: ");
              //Serial.println(flexSensorValue);

              for (int i=0; i<5; i++){
                client.print(analogRead(flexSensorPins[i]));
                client.print(" ");
              }
              client.println();

            } else {
              // If the path doesn't match, return 404
              client.println("HTTP/1.1 404 Not Found");
              client.println("Content-Type: text/plain");
              client.println();
              client.println("Invalid request.");
            }

            break;  // End the client connection after the response
          } else {
            currentLine = "";  // Reset the current line
          }
        } else if (c != '\r') {
          currentLine += c;  // Append character to the current line

          // Capture the first line of the request (which contains the path)
          if (currentLine.startsWith("GET")) {
            request = currentLine;
          }
        }
      }
    }
    client.stop();  // Close the client connection
    Serial.println("Client Disconnected.");
  }
}