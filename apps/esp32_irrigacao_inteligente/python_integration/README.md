# Integração Python (Fase 2)

Scripts em Python para integração com APIs externas (ex.: OpenWeather).  
Objetivo: trazer dados meteorológicos (chuva, clima) para apoiar a decisão de irrigação.

## Integração Python → ESP32 (Wokwi)

Gera um TOKEN meteorológico a partir da API pública Open-Meteo (sem API key) para ser colado no Serial do ESP32/Wokwi e influenciar a decisão de irrigação.

## 📁 Onde estou?
fiap-cap1-farmtech/
└─ apps/
   └─ esp32_irrigacao_inteligente/
      └─ python_integration/   ← (este diretório)
         ├─ __main__.py
         ├─ cli.py
         └─ openmeteo_client.py

## ✅ Pré-requisitos

Python 3.10+ instalado

Internet liberada (para consultar a Open-Meteo)

Executar os comandos dentro de apps/esp32_irrigacao_inteligente/python_integration

Se você rodar a partir da raiz do repositório e aparecer No module named python_integration, é porque o Python não achou o pacote no sys.path. Entre primeiro na pasta acima.

## ⚙️ Passo a passo (Windows / macOS / Linux)
1) Criar e ativar o ambiente virtual

Windows (PowerShell):

cd apps/esp32_irrigacao_inteligente/python_integration
python -m venv .venv
.\.venv\Scripts\Activate.ps1


Windows (Git Bash / CMD):

cd apps/esp32_irrigacao_inteligente/python_integration
python -m venv .venv
source .venv/Scripts/activate


macOS / Linux:

cd apps/esp32_irrigacao_inteligente/python_integration
python3 -m venv .venv
source .venv/bin/activate

2) Instalar a dependência
pip install requests

3) Rodar a aplicação (CLI)
python -m python_integration


Alternativa (se preferir rodar por caminho):
python __main__.py

## ⌨️ Entradas (CLI)

Latitude (ex.: -21.425)

Longitude (ex.: -45.947)
Se você só apertar Enter, a CLI usa valores padrão de exemplo.

📤 Saída esperada

A CLI imprimirá:

TOKEN para colar no ESP32/Wokwi (formato fixo):

TOKEN RAIN_MM=<float>;POP=<int>


Métricas didáticas (para o relatório):

(chuva_12h=<mm> mm | pop_max_12h=<%>)


Decisão sugerida (transparente):

[Decisão sugerida] rain_block = True/False
Regra: bloqueia se precipitação >= 1.0 mm (12h) OU POP >= 60%


Exemplo real:

TOKEN RAIN_MM=2.4;POP=68
(chuva_12h=2.4 mm | pop_max_12h=68%)
[Decisão sugerida] rain_block = True

## 📋 O que fazer com o TOKEN

Copie o TOKEN exibido (ex.: TOKEN RAIN_MM=2.4;POP=68).

Abra seu projeto do ESP32 no Wokwi/PlatformIO e o Serial Monitor (115200).

Cole o TOKEN e pressione Enter.

O ESP32 irá parsear os valores e atualizar as variáveis internas de chuva/probabilidade, afetando a lógica do relé (bomba).

A configuração recomendada do PlatformIO (em esp32_app/platformio.ini):

monitor_speed = 115200
monitor_eol   = LF


Assim, o Enter envia LF e o ESP32 lê a linha corretamente.

## 🧪 Teste offline (sem internet)

Se a rede cair, você pode gerar um TOKEN de controle:

python - <<'PY'
from openmeteo_client import build_token_from_metrics
print(build_token_from_metrics({'rain_mm_12h':3.2,'pop_max_12h':70}))
PY


Saída:

TOKEN RAIN_MM=3.2;POP=70

## 🆘 Erros comuns (e soluções)

No module named python_integration
→ Você não está dentro da pasta do módulo. Rode:

cd apps/esp32_irrigacao_inteligente/python_integration
python -m python_integration


Timeout/Erro de rede
→ Tente novamente mais tarde ou use o Teste offline acima.

## 🔜 Próximo passo

Agora siga o README do ESP32 em:

apps/esp32_irrigacao_inteligente/esp32_app/README.md


Lá você verá como compilar, abrir o Wokwi e colar o TOKEN no Serial para validar o controle de irrigação.