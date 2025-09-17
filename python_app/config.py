#Esses sistema foca em tratamentos Crop Protection, então não considerei fertilizantes ou 
#sementes por utilizarem outros cálculos de insumos.
 
# definicao culturas do sistema
config_culturas = ["Milho","Soja","Cafe"]

# definicao das classes de manejo
classes_manejo = ["Herbicida", "Fungicida", "Inseticida", "Biologico"]

# listagem dos produtos (ativos) relativos a cada classe em cada cultura
# evitei o uso de marcas comerciais e considerei os principais tratamentos em cada cultura
ativo_cultura_manejo = {
    "Milho": {
        "Herbicida":   ["glyphosate", "atrazine", "nicosulfuron"],
        "Fungicida":   ["azoxystrobin", "propiconazole"],
        "Inseticida":  ["lambda-cyhalothrin", "chlorantraniliprole"],
        "Biologico":   ["Bacillus thuringiensis", "Beauveria bassiana", "Metarhizium anisopliae"],
    },
    "Soja": {
        "Herbicida":   ["glyphosate", "chlorimuron-ethyl", "diclosulam"],
        "Fungicida":   ["azoxystrobin", "tebuconazole"],
        "Inseticida":  ["imidacloprid", "thiamethoxam"],
        "Biologico":   ["Bacillus thuringiensis", "Trichoderma harzianum"],
    },
    "Cafe": {
        "Herbicida":   ["glyphosate"],  # depende do manejo da entrelinha e nivel de avanco
        "Fungicida":   ["tebuconazole", "copper oxychloride"],
        "Inseticida":  ["imidacloprid"],  # pode ser usado em pragas de solo/parte aérea
        "Biologico":   ["Beauveria bassiana", "Metarhizium anisopliae", "Trichoderma harzianum"],
    },
}

# definicao de nomes simplificados na linguagem do produtor rural
label_base = "largura do talhão (m)" # base do talhao
label_altura = "comprimento do talhão (m)" #altura do talhao
label_raio_pivo = "raio do pivô (m)"  # distância do centro ate a borda