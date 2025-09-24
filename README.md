# FIAP CAP 1 - FarmTech Solutions

Projeto acadêmico desenvolvido no curso de Inteligência Artificial (FIAP), com foco em soluções para Agricultura Digital.

---

## 📌 Fase 1
- Cálculo de área plantada
- Monitoramento climático
- Scripts em Python e R para análise de dados
- Estrutura inicial disponível em:
  - `python_app/`
  - `r_app/`
  

---

## 📌 Fase 2 – Sistema de Irrigação Inteligente
Nesta etapa, evoluímos para a simulação de um **sistema automatizado de irrigação** utilizando **ESP32 no Wokwi**.  

### 🔧 Sensores e substituições
- **Nitrogênio (N)** → Botão verde
- **Fósforo (P)** → Botão verde
- **Potássio (K)** → Botão verde
- **pH da terra** → LDR (Light Dependent Resistor)
- **Umidade do solo** → DHT22 (sensor de umidade)
- **Bomba d’água** → Relé

### 🎯 Objetivo
Acionar automaticamente a irrigação (relé) de acordo com:
- Níveis de NPK
- Faixa de pH ideal para a cultura escolhida
- Umidade mínima necessária

---


---

## ▶️ Como rodar
1. Abra o circuito no [Wokwi](https://wokwi.com/).  
2. Carregue o código em `esp32_app/src/`.  
3. Use o **Serial Monitor** para visualizar leituras (NPK, pH, umidade).  
4. Simule chuva via teclado/Serial (opcional, integração Python).  

---

## 🚀 Próximos passos
- [ ] Montagem inicial do circuito no Wokwi  
- [ ] Código base ESP32 (setup + sensores)  
- [ ] Documentação da lógica de irrigação para uma cultura escolhida  
- [ ] Gravação do vídeo de até 5 minutos (demonstração)  

---

## 👥 Equipe
- Everton  
- Matheus
- Xavier
- Nayara  
- Julia  



