🌾 FIAP CAP 1 – FarmTech Solutions

  Projeto acadêmico desenvolvido no curso de Inteligência Artificial (FIAP), com foco em soluções para Agricultura Digital.
  O grupo FarmTech Solutions propõe o desenvolvimento de sistemas inteligentes para monitoramento, automação e análise de dados agrícolas, integrando Python, R e IoT (ESP32).

___________________________________________________________________________
🗂 ESTRUTURA GERAL

    fiap-cap1-farmtech/
    │
    ├─ docs/                                # Documentação, imagens e relatórios
    │   ├─ fase1_manejo_culturas/
    │   └─ fase2_irrigacao_inteligente/
    │   └─ fase.../
    │
    ├─ apps/
    │   ├─ cli_manejo_culturas/             # Fase 1 (Python + R)
    │   │   ├─ python_app/
    │   │   └─ r_app/
    │   │
    │   └─ esp32_irrigacao_inteligente/     # Fase 2 (ESP32 + API + R)
    │   │   ├─ esp32_app/
    │   │   ├─ python_integration/
    │   │   └─ r_integration/
    │   │
    │   └─ novos_projetos.../               # Fase...
    │   
    └─ README.md                            # Este arquivo

___________________________________________________________________________
📘 FASE 1 - MANEJO E CALCULO DE INSUMOS

Nesta primeira fase, foi desenvolvido um sistema em Python e R para o planejamento de manejo agrícola, permitindo o cálculo de áreas, doses de produtos e análise de tratamentos.

🔹 Funcionalidades principais

      Cálculo de área plantada (retangular ou pivô circular)

      Estimativa de insumos e aplicações por hectare

      Registro de manejos e produtos utilizados

      Exportação de dados em CSV para análise no R

🔗 Saiba mais: apps/cli_manejo_culturas/python_app/README.md


___________________________________________________________________________
📘 FASE 2 - SISTEMA DE IRRIGCAÇAO INTELIGENTE (IoT + API)

Evolução do projeto para um sistema automatizado de irrigação, utilizando o ESP32 no Wokwi e integração com dados meteorológicos via API pública (Open-Meteo).

🎯 Objetivo

    Acionar automaticamente a bomba d’água (relé) com base em:

    Níveis de nutrientes simulados (NPK)

    Faixa de pH ideal (via LDR)

    Umidade mínima (via DHT22)

    Previsão de chuva e probabilidade de precipitação (POP) fornecidas pela integração Python

🔧 Sensores simulados no Wokwi

    Parâmetro	      Sensor/Ferramenta      Pino ESP32
    Nitrogênio (N)	  Botão verde          12
    Fósforo (P)	      Botão verde          13
    Potássio (K)      Botão verde          14
    pH                LDR                  34
    Umidade	          DHT22                15
    Bomba             Relé                 26

🔬 Lógica de decisão da irrigação

O ESP32 avalia continuamente as leituras dos sensores e o token meteorológico.

    Condição                                  Ação
    Umidade < 40%                             Irrigação permitida
    pH entre 5.5 e 7.5	                      pH ok
    Pelo menos 1 botão NPK ativo	            Nutrientes ok
    Chuva prevista (rainBlock = true)	        Irrigação bloqueada
    Todas as condições válidas	              Relé (bomba) ligado

🔗 Guia detalhado de execução:
    
    apps/esp32_irrigacao_inteligente/esp32_app/README.md


___________________________________________________________________________
🚀 Próximos passos

     Ir além – Análise em R (opcional 2):
     
     Finalizar vídeo de demonstração (≤ 5 min)

     Submeter documentação no portal FIAP

     
___________________________________________________________________________   
👥 Equipe FarmTech Solutions

    Everton
    Xavier	           
    Nayara	            
    Julia
    Matheus

___________________________________________________________________________
🧾 Licença

    Projeto acadêmico, de uso educacional, desenvolvido no âmbito da disciplina
    CAP 1 – Campo da Inovação (FIAP).
