# ESP32 App – Fase 2: Irrigação Inteligente 💧

Simulação do sistema de irrigação automatizado da FarmTech Solutions, utilizando o ESP32 no Wokwi e integração opcional com o TOKEN meteorológico gerado pelo módulo Python (python_integration).

## 📁 Estrutura da pasta
esp32_app/
├─ progInC.ino        # código-fonte principal (C++)
├─ platformio.ini     # configuração do PlatformIO
├─ diagram.json       # diagrama do circuito (Wokwi)
├─ wokwi.toml         # linka o firmware compilado ao Wokwi
└─ README.md          # este arquivo

## ⚙️ Pré-requisitos

VS Code instalado

Extensão PlatformIO IDE ativa

Conta no Wokwi (https://wokwi.com
)

Projeto clonado localmente

## 🧱 Componentes simulados
Componente	Pino ESP32	Função
Botão N	12	Nitrogênio (N)
Botão P	13	Fósforo (P)
Botão K	14	Potássio (K)
LDR	34	Simula pH
DHT22	15	Umidade do solo
Relé	26	Bomba d’água

## 🚀 Como compilar e simular
1️⃣ Abrir o projeto

No VS Code, abra a pasta:

apps/esp32_irrigacao_inteligente/esp32_app

2️⃣ Conferir o platformio.ini

Garanta que contém:

monitor_speed   = 115200
monitor_eol     = LF
monitor_filters = direct, send_on_enter

3️⃣ Compilar sempre que alterar o código

Clique no ✔ (Build) da barra inferior do VS Code ou use:

Ctrl + Alt + B


O PlatformIO irá gerar o novo firmware em
.pio/build/esp32/firmware.bin.

⚠️ Importante:
Se não fizer Build, o Wokwi continuará usando o binário antigo!

4️⃣ Executar no Wokwi

Com o build concluído, abra o painel do Wokwi → Run Simulation (▶)
O circuito do diagram.json será carregado automaticamente.

5️⃣ Abrir o Serial Monitor

No PlatformIO:

PlatformIO → Monitor (Ctrl + Alt + M)


Deve aparecer:

FarmTech Fase 2
Comandos: RAIN=0 ou RAIN=1

## 🌦️ Integrando com o TOKEN meteorológico

No arquivo progInC.ino, localize a variável:

String WEATHER_TOKEN = "TOKEN RAIN_MM=1.1;POP=65";


Substitua pelos valores gerados pelo módulo Python:

TOKEN RAIN_MM=<mm>;POP=<probabilidade>


Clique em Build (✔) novamente.

Execute a simulação no Wokwi.

O ESP32 interpretará os valores e atualizará rainBlock automaticamente.

## 🔬 Testes rápidos
Cenário	Token	Resultado esperado
Sol / seco	TOKEN RAIN_MM=0.0;POP=5	Irrigação liga
Chuva leve	TOKEN RAIN_MM=1.0;POP=30	Pode ligar, se umidade baixa
Alta probabilidade de chuva	TOKEN RAIN_MM=0.5;POP=80	Desliga
Chuva forte	TOKEN RAIN_MM=5.0;POP=90	Desliga

## 🧩 Comandos manuais (Serial)

Você também pode testar manualmente no Serial Monitor:

RAIN=1   → força bloqueio por chuva
RAIN=0   → libera irrigação

## 📋 Boas práticas no PlatformIO
Ação	Atalho	Descrição
Build	Ctrl + Alt + B	Compila e atualiza o binário
Run Simulation (Wokwi)	—	Roda o circuito com firmware novo
Monitor	Ctrl + Alt + M	Abre o console serial
Rebuild → Run	—	Use após qualquer edição no código

## ✅ Resultado esperado

Durante a simulação, o console exibirá leituras e decisões:

N:1 P:1 K:0 pH:6.5 Hum:35.4% RainBlock:1 Relay:OFF


RainBlock: 1 → bloqueio de irrigação (chuva esperada)

Relay: ON → bomba acionada

Relay: OFF → irrigação suspensa

## 🔗 Próximo passo

➡️ Gerar o TOKEN com o módulo Python:

apps/esp32_irrigacao_inteligente/python_integration/README.md


E copie o valor exibido para a variável WEATHER_TOKEN.