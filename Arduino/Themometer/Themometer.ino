

// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(115200);  
}

// the loop routine runs over and over again forever:
void loop() {
  //detect in value between 1 to 1023
  int detect_value = analogRead(A3);
  //transform voltage
  float Vcc = 3.3;
  float volt =( (float)detect_value * Vcc)/1023.;
  
  Serial.print("volt (V): ");       
  Serial.print(volt, 2); 
  Serial.println("");  
  Serial.print("analog (-): ");       
  Serial.print(detect_value);
  Serial.println(""); 

  delay(1000);	// wait for a second 
}
