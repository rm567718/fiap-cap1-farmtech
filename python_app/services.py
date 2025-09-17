# Services: possui as regras de negocio e os calculos
# OBS: sem input(), somente as funcoes

# definicao de pi para calculo de area circular
pi = 3.141592653589793

# converter m2 para hectares
def m2_to_ha(area_m2: float) -> float:
    return float(area_m2) / 10000

# valida se o valor de ## é positivo e o nome é valido
def validar_positivo(valor: float, nome: str) -> None:
    
    # tenta colocar valor em float
    try:
        v = float(valor)
    
    # se nao satisfeito, avisa o nome do campo e o valor incorreto
    except Exception as e:
        raise ValueError(f"{nome} inválido: {v}") from e
    
    # se satisfeito mas o valor é negativo, avisa o valor incorreto
    if v <=0:
        raise ValueError(f"{nome} deve ser > 0. Recebido: {v}")


# ------------------------
# CALCULO DAS AREAS 

# calculo da area  retangular
def calc_area_retangulo(largura_m: float, comprimento_m: float) -> dict:
    
    #confere se largura é valido
    validar_positivo(largura_m, "largura (m)")

    #confere se comprimento é valido
    validar_positivo(comprimento_m, "comprimento (m)")

    #calcula a area em metros quadrados
    area_m2 = float(largura_m) * float(comprimento_m)

    #retorno do calculo com parametros calculados
    return{
        "geometria": "retangulo",
        "params": {"largura_m": float(largura_m), "comprimento_m": float(comprimento_m)},
        "area_m2": area_m2,
        "area_ha": m2_to_ha(area_m2),
    }

# calculo da area circular
def calc_area_circulo(raio_pivo_m: float) -> dict:

    #confere se raio é valido
    validar_positivo(raio_pivo_m, "raio pivo (m)")

    #calcula a area em metros quadrados
    area_m2 = pi * (float(raio_pivo_m) **2 )

    #retorno do calculo com parametros calculados
    return{
        "geometria": "circulo",
        "params": {"raio_m": float(raio_pivo_m)},
        "area_m2": area_m2,
        "area_ha": m2_to_ha(area_m2),
    }

# ------------------------
# MANEJO / TRATAMETNO

# calculo do volume total em cada produto a ser aplicado
def total_produto(area_ha: float, dose_por_ha: float, aplicacoes: int) -> float:

    # confere se area é valida
    validar_positivo(area_ha, "area (ha)")

    #confere se dose é valida
    validar_positivo(dose_por_ha, "dose/ha")

    #valida se o valor de aplicacao é positivo para poder depois calcular o volume total dos produtos
    if int(aplicacoes) <=0:
        raise ValueError("Numero de aplicacoes deve ser maior que 0.")
    return float(area_ha) * float(dose_por_ha) * float(aplicacoes)

# area equivalente tratada é um indicador para montar o cronograma/capacidade do pulverizador
def area_equivalente_tratada(area_ha: float, soma_aplicacoes: int) -> float:
    
    #confere se area é valida
    validar_positivo(area_ha, "área (ha)")
    
    # se a soma das aplicacoes é positiva, multiplica a area pela soma das aplicacoes
    if int(soma_aplicacoes) <=0:
        raise ValueError("soma de aplicações deve ser maior que 0.")
    return float(area_ha) * float(soma_aplicacoes)