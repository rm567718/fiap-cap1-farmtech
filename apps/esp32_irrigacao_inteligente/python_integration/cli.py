# CLI minimalista para gerar o TOKEN do clima e colar no Serial do Wokwi.

from __future__ import annotations
from .openmeteo_client import get_token_and_metrics, OpenMeteoError

# recebe localizacao para gerar token



def run():
    print("\n=== Integração Open-Meteo → TOKEN para ESP32 (Wokwi) ===")
    try:
        lat_str = input("Latitude  (ex. -22.07): ").strip() or "-22.07"
        lon_str = input("Longitude (ex. -45.56): ").strip() or "-45.56"
        lat = float(lat_str.replace(",", "."))
        lon = float(lon_str.replace(",", "."))

        token, m = get_token_and_metrics(lat, lon)

        print("\n--- Cole a linha abaixo no Serial Monitor do Wokwi ---")
        print(token)
        print(f"(chuva_12h={m['rain_mm_12h']} mm | pop_max_12h={m['pop_max_12h']}%)")
        print("-------------------------------------------------------")

        # Regra de decisão (didática e transparente)
        rain_block = (m["rain_mm_12h"] >= 1.0) or (m["pop_max_12h"] >= 60)
        print(f"\n[Decisão sugerida] rain_block = {rain_block}")
        print("  Regra: bloqueia se precipitacao for maior que 1.0 mm ou a probabilidade for maior que 60%\n")

    except ValueError:
        print("Entrada de latitude/longitude inválida.")
    except OpenMeteoError as e:
        print(f"Falha ao obter previsão: {e}")
    except Exception as e:
        print(f"Erro inesperado: {e}")
