# -----------------------------------------------------------------------------
# Cliente simples da API Open-Meteo:

from __future__ import annotations
import typing as t
import requests

class OpenMeteoError(RuntimeError):
    pass


## Faz o GET na Open-Meteo para a localização informada.
##    - timezone=auto -> evita ter que converter UTC manualmente
##    - hourly -> pedimos precipitation e precipitation_probability
##    - forecast_days=2 -> garante janela suficiente (>= 12h à frente)
## Retorna o JSON (dict)e lanca OpenMeteoError em caso de erro.
def fetch_forecast(lat: float, lon: float) -> dict:
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": "precipitation,precipitation_probability",
        "forecast_days": 2,
        "timezone": "auto",
    }
    try:
        r = requests.get(url, params=params, timeout=15)
        r.raise_for_status()
        data = r.json()
        if "hourly" not in data:
            raise OpenMeteoError("Resposta sem campo 'hourly'.")
        return data
    except requests.RequestException as e:
        raise OpenMeteoError(f"Erro de rede ao acessar Open-Meteo: {e}") from e


## Resume as proximas 12 horas de precipitacao
## Avalia a precipitacao (mm) e retorna a precipitacao maxima nesse periodo
##    Retorna um dict com:
##      - rain_mm_12h (float, soma mm)
##      - pop_max_12h (int, 0..100)
def summarize_next_12h(data: dict) -> dict:
    hourly = data.get("hourly", {})
    precip = hourly.get("precipitation") or []
    pop = hourly.get("precipitation_probability") or []

    # Garante 12 posições (ou o que houver, no mínimo 1)
    n = min(12, len(precip), len(pop))
    if n <= 0:
        # Se a API retornar sem dados, jogamos 0/0 por segurança
        return {"rain_mm_12h": 0.0, "pop_max_12h": 0}

    # Soma de mm e máximo de POP
    rain_sum = 0.0
    pop_max = 0
    for i in range(n):
        # Tratamento para None/strings caso acnteca
        try:
            rain_val = float(precip[i]) if precip[i] is not None else 0.0
        except (TypeError, ValueError):
            rain_val = 0.0

        try:
            pop_val = int(pop[i]) if pop[i] is not None else 0
        except (TypeError, ValueError):
            pop_val = 0

        rain_sum += rain_val
        pop_max = max(pop_max, pop_val)

    # Arredonda para 2 casas para facilitar entendimento
    return {"rain_mm_12h": round(rain_sum, 2), "pop_max_12h": int(pop_max)}


#gera o TOKEN formatado para ler no ESP32
# Formato: TOKEN RAIN_MM=<float>;POP=<int>
def build_token_from_metrics(m: dict) -> str:
    return f"TOKEN RAIN_MM={m['rain_mm_12h']};POP={m['pop_max_12h']}"

#funcao que busca a previsao, resume as 12h e monta o token atraves das funcoes anteriores
def get_token_and_metrics(lat: float, lon: float) -> tuple[str, dict]:
    data = fetch_forecast(lat, lon)
    metrics = summarize_next_12h(data)
    token = build_token_from_metrics(metrics)
    return token, metrics
