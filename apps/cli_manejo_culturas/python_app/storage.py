""" 
1) Storage: vetores em memória + CRUD + export CSVs para o R.
2) Áreas por cultura (listas por chave da cultura).
3) Tratamentos (lista global) contendo produtos (lista por tratamento).
4) CSVs com separador ';' e floats no padrão ponto. """

import os, csv, json

#Importa as culturas do config.py
from .config import config_culturas


#---------------------
#VETORES EM MEMÓRIA

areas: dict[str, list[dict]] = {c: [] for c in config_culturas}
tratamentos: list[dict] = []

#---------------------
#CRUD DE ÁREAS

def areas_listar(cultura: str) -> list[dict]:

    #confere se a cultura é válida
    assert_cultura(cultura)

    #retorna as áreas listadas
    return areas[cultura]

def areas_criar(cultura: str, area_dict: dict) -> int:
    
    #confere se a cultura é válida
    assert_cultura(cultura)
    
    #cria uma área para a cultura
    areas[cultura].append(area_dict)
 
    #retorna o índice criado
    return len(areas[cultura]) -1

def areas_atualizar(cultura:  str, idx: int, novo:dict) -> bool:

    #confere se a cultura é válida
    assert_cultura(cultura)

    #atualiza a área no índice e retorna true/false
    vetor = areas[cultura]
    if 0 <= idx < len(vetor):
        vetor[idx] = novo
        return True
    return False

def areas_deletar(cultura: str, idx: int) -> bool:

    #confere se a cultura é válida
    assert_cultura(cultura)

    #remove a área no índice e retorna true/false
    vetor = areas[cultura]
    if 0 <= idx < len(vetor):
        vetor.pop(idx)
        return True
    return False

#---------------------
#CRUD DE TRATAMENTOS

def trat_listar() -> list[dict]:
    #retorna tratamentos listados
    return tratamentos

def trat_criar(trat: dict) -> int:
    #Adiciona um tratamento completo
    tratamentos.append(trat)
    
    #retorna o índice criado
    return len(tratamentos) - 1

def trat_atualizar(idx: int, novo: dict) -> bool:

    #atualiza tratamento pelo índice e retorna true/false
    if 0 <= idx < len(tratamentos):
        tratamentos[idx] = novo
        return True
    return False

def trat_deletar(idx: int) -> bool:
    
    #deleta o tratametno no indice e retornar true/false
    if 0 <= idx < len(tratamentos):
        tratamentos.pop(idx)
        return True
    return False

#---------------------
# EXPORT .CSV PARA R

#Gera 5 arquivos em cvs, sendo:
#  export_areas_<cultura>.csv (1 por cultura = 3 totais)
#  export_tratamentos.csv
#  export_produtos.csv

def export_csv(dirpath: str = "python_app/data") -> None:
    
    #cria a pasta de saida 
    os.makedirs(dirpath, exist_ok=True)
    
    
    for cultura, vetor in areas.items():

    # 1 - Area por cultura

        #gera um arquivo para cada cultura
        fpath = os.path.join(dirpath, f"export_areas_{cultura.lower()}.csv")
        with open(fpath, "w", newline = "", encoding="utf-8") as f:
            #separador com ; para ler no R
            w = csv.writer(f, delimiter=";")
            #define cabecalhos
            w.writerow(["cultura", "geometria", "params_json", "area_m2", "area_ha"])
            #guarda os paramentros como JSON            
            for r in vetor:
                w.writerow([
                    cultura,
                    r.get("geometria", ""),
                    json.dumps(r.get("params", {}), ensure_ascii=False),
                    _fmt_float(r.get("area_m2")),
                    _fmt_float(r.get("area_ha")),
                ])

    # 2 - Tratamentos
    #gera um arquivo com resumo por tratamento
    fpath_t = os.path.join(dirpath, "export_tratamentos.csv")
    with open(fpath_t, "w", newline="", encoding="utf-8") as f:
        #separador com ; para ler no R
        w = csv.writer(f, delimiter=";")
        #define cabecalhos
        w.writerow(["cultura", "manejo", "area_ha", "area_eq_tratada", "n_produtos"])
        for t in tratamentos:
            w.writerow([
                t.get("cultura", ""),
                t.get("manejo", ""),
                _fmt_float(t.get("area_ha")),
                _fmt_float(t.get("area_eq_tratada")),
                len(t.get("produtos", [])),
            ])

    # 3 - Produtos 
    #gera um arquivo com 1 produto por linha
    fpath_p = os.path.join(dirpath, "export_produtos.csv")
    with open(fpath_p, "w", newline="", encoding="utf-8") as f:
        #separador com ; para ler no R
        w = csv.writer(f, delimiter=";")
        #define cabecalhos
        w.writerow(["cultura", "manejo", "ativo", "dose_ha", "unidade", "aplicacoes", "total"])
        for t in tratamentos:
            cultura = t.get("cultura", "")
            manejo = t.get("manejo", "")
            for p in t.get("produtos", []):
                w.writerow([
                    cultura,
                    manejo,
                    p.get("ativo", ""),
                    p.get("dose_ha", ""),
                    p.get("unidade", ""),
                    p.get("aplicacoes", ""),
                    _fmt_float(p.get("total")),
                ])


#---------------------
# FUNCOES INTERNAS

# garante que a cultura exista em areas
def assert_cultura(cultura: str) -> None:
    if cultura not in areas:
        raise ValueError(f"Cultura desconhecida: {cultura}. Selecione uma opcao valida: {list(areas.keys())}")

#converte para decimal e garante 6 casas decimais, senao retona vazio
def _fmt_float(x) -> str:
    try:
        return f"{float(x):.6f}"
    except Exception:
        return ""