#include <DHT.h>

#define PIN_N 12
#define PIN_P 13
#define PIN_K 14
#define PIN_LDR 34
#define PIN_DHT 15
#define PIN_RELAY 26

#define DHTTYPE DHT22
DHT dht(PIN_DHT, DHTTYPE);

float HUM_MIN = 40.0;
float PH_MIN = 5.5;
float PH_MAX = 7.5;

bool rainBlock = false;

float mapPh(int adc) {
  return 14.0f * (float)adc / 4095.0f;
}

bool readBoolBtn(int pin) {
  return digitalRead(pin) == LOW;
}

void readRainFlag() {
  while (Serial.available() > 0) {
    String s = Serial.readStringUntil('\n');
    s.trim(); s.toUpperCase();
    if (s.startsWith("RAIN=")) {
      String v = s.substring(5); v.trim();
      if (v == "1" || v == "TRUE" || v == "ON") rainBlock = true;
      else if (v == "0" || v == "FALSE" || v == "OFF") rainBlock = false;
    }
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(PIN_N, INPUT_PULLUP);
  pinMode(PIN_P, INPUT_PULLUP);
  pinMode(PIN_K, INPUT_PULLUP);
  pinMode(PIN_RELAY, OUTPUT);
  digitalWrite(PIN_RELAY, LOW);
  dht.begin();
  delay(500);
  Serial.println("FarmTech Fase2");
  Serial.println("Comandos: RAIN=0 ou RAIN=1");
}

void loop() {
  readRainFlag();

  bool N = readBoolBtn(PIN_N);
  bool P = readBoolBtn(PIN_P);
  bool K = readBoolBtn(PIN_K);

  int ldr = analogRead(PIN_LDR);
  float ph = mapPh(ldr);

  float hum = dht.readHumidity();
  bool humOk = !isnan(hum);
  if (!humOk) hum = -1.0;

  bool npkOk = (N || P || K);
  bool phOk = (ph >= PH_MIN && ph <= PH_MAX);
  bool needIrr = humOk && hum < HUM_MIN && phOk && npkOk && !rainBlock;

  digitalWrite(PIN_RELAY, needIrr ? HIGH : LOW);

  Serial.print("N:"); Serial.print((int)N);
  Serial.print(" P:"); Serial.print((int)P);
  Serial.print(" K:"); Serial.print((int)K);
  Serial.print(" pH:"); Serial.print(ph, 1);
  Serial.print(" Hum:"); if (humOk) Serial.print(hum, 1); else Serial.print("NaN");
  Serial.print("% RainBlock:"); Serial.print(rainBlock ? "1" : "0");
  Serial.print(" Relay:"); Serial.println(needIrr ? "ON" : "OFF");

  delay(1000);
}
