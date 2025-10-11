// ------------------------------------------------------------
//  Projeto: FarmTech Solutions - Fase 2
//  Objetivo: Sistema de irrigação automatizado com ESP32
//  Sensores simulados no Wokwi: NPK (botões), pH (LDR), Umidade (DHT22)
//  Atuador: Relé (simula bomba d’água)
// ------------------------------------------------------------


// Biblioteca do sensor DHT (umidade e temperatura)
#include <DHT.h>

// Definicao de pinos:
#define PIN_N 12        //Botao do Nitrogenio
#define PIN_P 13        //Botao do Fosforo
#define PIN_K 14        //Botao do Potassio
#define PIN_LDR 34      //Sensor LDR (usado para simular medidor de PH)
#define PIN_DHT 15      //Sensor DHT22 (usado para simular medidor de umidade solo)
#define PIN_RELAY 26    //Rele que aciona a bomba d'agua

#define RAIN_MM_THRESHOLD  1.0f     // ajuste o limiar que VOCÊ quer
#define POP_THRESHOLD      60       // ajuste o limiar que VOCÊ quer

// Configura DHT no pino definido 
#define DHTTYPE DHT22
DHT dht(PIN_DHT, DHTTYPE);

// limites de decisao
float HUM_MIN = 40.0;   //umidade minima
float PH_MIN = 5.5;     //ph minimo
float PH_MAX = 7.5;     //ph maximo
float RAIN_MM = 0.0f;   // precipitacao
int   POP     = 0;      // probabilidade de chuva

//controle de chuva: se tiver previsao de chuva interrompe a irrigacao
bool rainBlock = false;

// === Cole aqui o TOKEN (formato: TOKEN RAIN_MM=2.4;POP=68) ===
// Quando quiser atualizar, basta mudar esta string e recompilar.
String WEATHER_TOKEN = "TOKEN RAIN_MM=0.8;POP=55";

// converte o valor analogico do LDR para escala de PH (0-14)
float mapPh(int adc) {
  return 14.0f * (float)adc / 4095.0f;
}

// retorna true se o botao estiver pressionado
bool readBoolBtn(int pin) {
  return digitalRead(pin) == LOW;
}


// analisa o token e compara com o threshold para validar se vai ou noa chover
static void parseWeatherToken(const String& token) {
  String s = token; 
  s.trim();

  int rainIdx = s.indexOf("RAIN_MM=");
  if (rainIdx >= 0) {
    int end = s.indexOf(';', rainIdx);
    String val = (end > 0) ? s.substring(rainIdx + 8, end) : s.substring(rainIdx + 8);
    RAIN_MM = val.toFloat();
  }

  int popIdx = s.indexOf("POP=");
  if (popIdx >= 0) {
    int end = s.indexOf(';', popIdx);
    String val = (end > 0) ? s.substring(popIdx + 4, end) : s.substring(popIdx + 4);
    POP = val.toInt();
  }
  rainBlock = (RAIN_MM >= RAIN_MM_THRESHOLD) || (POP >= POP_THRESHOLD);
}

// lê o TOKEN interno e depois lê comandos enviados via Monitor Serial para simular chuva 
void readRainFlag() {
  // 1) Sempre lê o TOKEN interno (colado na variável)
  if (WEATHER_TOKEN.length() > 0) {
    parseWeatherToken(WEATHER_TOKEN);
  }

  // 2) Compatibilidade legada: aceitar RAIN=1/0/ON/OFF/TRUE/FALSE via Serial (opcional)
  while (Serial.available() > 0) {
    String s = Serial.readStringUntil('\n');
    s.trim(); s.toUpperCase();
    if (s.startsWith("RAIN=")) {
      String v = s.substring(5); v.trim(); v.toUpperCase();
      if (v == "1" || v == "TRUE" || v == "ON")       rainBlock = true;
      else if (v == "0" || v == "FALSE" || v == "OFF") rainBlock = false;
    }
  }
}


// executado uma vez na inicialzacao do ESP32
void setup() {
  Serial.begin(115200);           //inicializa a comunicao serial 
  
  //define pinos de entrada e saida
  pinMode(PIN_N, INPUT_PULLUP);   
  pinMode(PIN_P, INPUT_PULLUP);
  pinMode(PIN_K, INPUT_PULLUP);
  pinMode(PIN_RELAY, OUTPUT);

  // rele inicia desligado
  digitalWrite(PIN_RELAY, LOW);

  //liga o sensor DHT
  dht.begin();
  delay(500);

  // mensagem inicial
  Serial.println("FarmTech Fase2");
  Serial.println("RAIN=0 (sem previsao de chuva) ou RAIN=1 (com previsao de chuva)");
}

// loop para leitura dos sensores e decide se ativa ou nao o Rele
void loop() {

  //le comandos do serial monitor
  readRainFlag();

  //confere se algum botao esta pressionado
  bool N = readBoolBtn(PIN_N);
  bool P = readBoolBtn(PIN_P);
  bool K = readBoolBtn(PIN_K);

  //Le o LDR e ja converte para PH
  int ldr = analogRead(PIN_LDR);
  float ph = mapPh(ldr);

  // le a umidade do DHT
  float hum = dht.readHumidity();

  // verifica se a leitura é valida e caso nao seja define -1
  bool humOk = !isnan(hum);     
  if (!humOk) hum = -1.0;       

  // teste logico para ligar o rele
  bool npkOk = (N || P || K);     //precisa de pelo menos um botao ativo
  bool phOk = (ph >= PH_MIN && ph <= PH_MAX); //valida se o PH esta na faixa ideal
  
  // condicoes para ligar:
  //    1_ umidade valida e menor que o minimo
  //    2_ ph entre o PH_MIN e PH_MAX
  //    3_ Algum botao de NPK ativo
  //    4_ Nao houver bloqueio por chuva
  bool needIrr = humOk && hum < HUM_MIN && phOk && npkOk && !rainBlock; 

  //Liga e desliga o Rele conforme condicoes
  digitalWrite(PIN_RELAY, needIrr ? HIGH : LOW);

  // envia as informacoes para o monitor serial
  Serial.print("N:"); Serial.print((int)N);
  Serial.print(" P:"); Serial.print((int)P);
  Serial.print(" K:"); Serial.print((int)K);
  Serial.print(" pH:"); Serial.print(ph, 1);
  Serial.print(" Hum:"); if (humOk) Serial.print(hum, 1); else Serial.print("NaN");
  Serial.print("% RainBlock:"); Serial.print(rainBlock ? "1" : "0");
  Serial.print(" Relay:"); Serial.println(needIrr ? "ON" : "OFF");

  // leitura com intevalos de 1 segundo (1000)
  delay(1000);
}
