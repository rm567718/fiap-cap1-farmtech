"""
CLI: interação via terminal (menus, inputs, prints).
"""

from typing import Optional
from python_app.config import (
    config_culturas,
    classes_manejo,
    ativo_cultura_manejo,
    label_base,
    label_altura,
    label_raio_pivo,
)


from python_app import services as svc
from python_app import storage as st

# ------------------------
# validacao de input numerico e retorno de registros

# validacao de input decimal
def ler_float(msg: str) -> float:
    while True:
        try:
            return float(input(msg).replace(",", ".").strip())
        except ValueError:
            print("Valor inválido. Tente novamente (número).")


#valida o input inteiro
def ler_int(msg: str) -> int:
    while True:
        try:
            return int(input(msg).strip())
        except ValueError:
            print("Valor inválido. Tente novamente (inteiro).")

#Exibe lista numerada e retorna a string escolhida ou None."""
def escolher_em_lista(titulo: str, opcoes: list) -> Optional[str]:
    print(f"\n{titulo}")
    for i, v in enumerate(opcoes, 1):
        print(f"[{i}] {v}")
    op = ler_int("Opção: ")
    if 1 <= op <= len(opcoes):
        return opcoes[op - 1]
    print("Opção inválida.")
    return None

#busca cultura com escolher_em_lista
def escolher_cultura() -> Optional[str]:
    return escolher_em_lista("Escolha a cultura:", config_culturas)

#busca manejo/tratamento com escolher_em_lista
def escolher_manejo() -> Optional[str]:
    return escolher_em_lista("Escolha o manejo:", classes_manejo)


# ------------------------
# AREAS - CRUD por cultura

#de acordo com a cultura selecionada, solicita o formato da area a ser calculada
def areas_inserir():
    cultura = escolher_cultura()
    if not cultura:
        return
    print("\nGeometria do talhão:")
    print("[1] Retangular")
    print("[2] Circular (pivo)")
    op = ler_int("Opção: ")

    #retorna o label conforme a opcao escolhida em formato, valida invalidos e erros
    try:
        if op == 1:
            largura = ler_float(f"{label_base}: ")
            comp = ler_float(f"{label_altura}: ")
            area = svc.calc_area_retangulo(largura, comp)
        elif op == 2:
            raio = ler_float(f"{label_raio_pivo}: ")
            area = svc.calc_area_circulo(raio)
        else:
            print("Opção invalida!")
            return
    except ValueError as e:
        print(f"Erro: {e}")
        return
    
    #cria um index conforme registro e retorna mensagem
    idx = st.areas_criar(cultura, area)
    print(f" Área adicionada em {cultura}. Ind: {idx} | {area['area_ha']:.4f} ha no formato {area["geometria"]}")

# lista as areas registradas na cultura, traz retorno se vazio 
def areas_listar():
    cultura = escolher_cultura()
    if not cultura:
        return
    vetor = st.areas_listar(cultura)
    if not vetor:
        print(f"Não há áreas cadastradas para {cultura}.")
        return
    print(f"\nÁreas de {cultura}:")
    for i, r in enumerate(vetor):
        print(f"[{i}] {r['geometria']} params={r['params']} "
              f"area_m2={r['area_m2']:.2f} area_ha={r['area_ha']:.4f}")

# verifica se tem area ja cadastrada e traz seus indices, depois permite selecionar 
# novamente a geometria, calcula a nova area, atualiza o registro e por fim confirma. 
# Trata opcao invalida e erro.
def areas_atualizar():
    cultura = escolher_cultura()
    if not cultura:
        return
    vetor = st.areas_listar(cultura)
    if not vetor:
        print("Nenhuma área para atualizar.")
        return
    areas_listar_especifica(cultura)
    idx = ler_int("Índice a atualizar: ")

    print("\nNova geometria:")
    print("[1] Retângulo")
    print("[2] Círculo (pivô)")
    op = ler_int("Opção: ")
    try:
        if op == 1:
            largura = ler_float(f"{label_base}: ")
            comp = ler_float(f"{label_altura}: ")
            novo = svc.calc_area_retangulo(largura, comp)
        elif op == 2:
            raio = ler_float(f"{label_raio_pivo}: ")
            novo = svc.calc_area_circulo(raio)
        else:
            print("Opção inválida.")
            return
        ok = st.areas_atualizar(cultura, idx, novo)
        print("Registro atualizado!" if ok else "Índice inválido.")
    except ValueError as e:
        print(f"Erro: {e}")

# verifica se tem area ja cadastrada e depois permite deletar com base no indice do registro.
def areas_deletar():
    cultura = escolher_cultura()
    if not cultura:
        return
    vetor = st.areas_listar(cultura)
    if not vetor:
        print("Nenhuma área para deletar.")
        return
    areas_listar_especifica(cultura)
    idx = ler_int("Índice a deletar: ")
    ok = st.areas_deletar(cultura, idx)
    print("Deletado." if ok else "Índice inválido.")


#permite listar as areas cadastradas das culturas
def areas_listar_especifica(cultura: str):
    vetor = st.areas_listar(cultura)
    print(f"\nÁreas de {cultura}:")
    for i, r in enumerate(vetor):
        print(f"[{i}] {r['geometria']} params={r['params']} "
              f"area_m2={r['area_m2']:.2f} area_ha={r['area_ha']:.4f}")
        

# ------------------------
# TRATAMENTOS - CRUD 

def tratamentos_inserir():
    cultura = escolher_cultura()
    if not cultura:
        return

    #Com base no formato do talhao define a area
    print("\nGeometria do talhão:")
    print("[1] Retângulo")
    print("[2] Círculo (pivô)")
    op = ler_int("Opção: ")
    try:
        if op == 1:
            largura = ler_float(f"{label_base}: ")
            comp = ler_float(f"{label_altura}: ")
            area = svc.calc_area_retangulo(largura, comp)
        elif op == 2:
            raio = ler_float(f"{label_raio_pivo}: ")
            area = svc.calc_area_circulo(raio)
        else:
            print("Opção inválida.")
            return
    except ValueError as e:
        print(f"Erro: {e}")
        return
    area_ha = area["area_ha"]

    # 2) Manejo
    manejo = escolher_manejo()
    if not manejo:
        return
    
    # 3) Ativos sugeridos para a cultura/manejo
    sugeridos = ativo_cultura_manejo.get(cultura, {}).get(manejo, [])
    produtos = []
    soma_apps = 0

    #retorna a lista de ativos e permite o cadastro de novas opcoes, conforme necessidade do produtor
    while True:
        print("\nProduto do manejo:")
        ativo = None
        if sugeridos:
            print("Ativos sugeridos (nomes científicos):")
            for i, a in enumerate(sugeridos, 1):
                print(f"[{i}] {a}")
            print(f"[{len(sugeridos)+1}] Outro (digitar manualmente)")
            esc = ler_int("Opção: ")
            if 1 <= esc <= len(sugeridos):
                ativo = sugeridos[esc-1]
            elif esc == len(sugeridos) + 1:
                ativo = input("Informe o nome científico do ativo: ").strip()
            else:
                print("Opção inválida.")
                continue
        else:
            ativo = input("Informe o nome científico do ativo: ").strip()

        dose_ha = ler_float("Dose por hectare (apenas número, ex.: 1.2): ")
        unidade = input("Unidade (ex.: L/ha, kg/ha): ").strip() or "L/ha"
        aplicacoes = ler_int("Número de aplicações: ")

        #valida os inputs 
        try:
            total = svc.total_produto(area_ha, dose_ha, aplicacoes)
        except ValueError as e:
            print(f"Erro: {e}")
            continue
        
        #cadastra o produto no tratamento/manejo
        produtos.append({
            "ativo": ativo,
            "dose_ha": dose_ha,
            "unidade": unidade,
            "aplicacoes": aplicacoes,
            "total": total,
        })
        soma_apps += aplicacoes

        #confirma necessidade de mais cadastro de produtos
        add_mais = input("Adicionar mais um produto a este manejo? (s/n): ").strip().lower()
        if add_mais != "s":
            break

    # calculo da area equivalente tratada 
    try:
        area_eq = svc.area_equivalente_tratada(area_ha, soma_apps) if soma_apps > 0 else 0.0
    except ValueError:
        area_eq = 0.0
    
    # retorna resumo do tratamento com base no indice
    tratamento = {
        "cultura": cultura,
        "manejo": manejo,
        "area_ha": area_ha,
        "produtos": produtos,
        "area_eq_tratada": area_eq,
    }
    idx = st.trat_criar(tratamento)
    _print_resumo_tratamento(idx, tratamento)

#exibicao do tratamento no sistema 
def _print_resumo_tratamento(idx: int, t: dict):
    print("\n======= RESUMO DO TRATAMENTO =======")
    print(f"Índice: {idx} | Cultura: {t['cultura']} | Manejo: {t['manejo']}")
    print(f"Área do talhão: {t['area_ha']:.4f} ha")
    print("Produtos:")
    for i, p in enumerate(t["produtos"], 1):
        print(f"  {i}) {p['ativo']} | dose={p['dose_ha']} {p['unidade']} "
              f"| aplicações={p['aplicacoes']} | TOTAL={p['total']:.4f}")
    print(f"Área equivalente tratada (ha-aplic): {t['area_eq_tratada']:.4f}")

#funcao apra retornar os tratamentos cadastrados
def tratamentos_listar():
    vetor = st.trat_listar()
    if not vetor:
        print("(vazio) Nenhum tratamento cadastrado.")
        return
    print("\nTratamentos:")
    for i, t in enumerate(vetor):
        print(f"[{i}] {t['cultura']} | {t['manejo']} | área={t['area_ha']:.4f} ha "
              f"| ha-aplic={t['area_eq_tratada']:.4f} | n_produtos={len(t['produtos'])}")

# permite validar os cadastros existentes para somente deletar e inserir novo registro
def tratamentos_atualizar():
    vetor = st.trat_listar()
    if not vetor:
        print("Nenhum tratamento para atualizar.")
        return
    tratamentos_listar()
    idx = ler_int("Índice a recriar (deletar e inserir de novo): ")
    if 0 <= idx < len(vetor):
        ok = st.trat_deletar(idx)
        if ok:
            print("Tratamento removido. Vamos cadastrá-lo novamente.")
            tratamentos_inserir()
        else:
            print("Índice inválido.")
    else:
        print("Índice inválido.")

# permite validar os cadastros existentes para somente deletar
def tratamentos_deletar():
    vetor = st.trat_listar()
    if not vetor:
        print("Nenhum tratamento para deletar.")
        return
    tratamentos_listar()
    idx = ler_int("Índice a deletar: ")
    ok = st.trat_deletar(idx)
    print("Deletado." if ok else "Índice inválido.")

# ------------------------
# EXPORT CSV 

#exporta csv e retorna confirmacao
def exportar_csvs():
    st.export_csvs()
    print("CSVs gerados em python_app/data/")



# ------------------------
# MENU PRINCIPAL

#exibe os itens e busca a funcao conforme input
#permite validar o input e encerrar corretamente o sistema
def menu():
    while True:
        print("\n===== FarmTech Solutions =====")
        print("ÁREAS")
        print("[1] Inserir  [2] Listar  [3] Atualizar  [4] Deletar")
        print("TRATAMENTOS")
        print("[5] Inserir  [6] Listar  [7] Atualizar  [8] Deletar")
        print("[9] Exportar CSVs (para R)")
        print("[0] Sair")
        op = input("Opção: ").strip()
        if   op == "1": areas_inserir()
        elif op == "2": areas_listar()
        elif op == "3": areas_atualizar()
        elif op == "4": areas_deletar()
        elif op == "5": tratamentos_inserir()
        elif op == "6": tratamentos_listar()
        elif op == "7": tratamentos_atualizar()
        elif op == "8": tratamentos_deletar()
        elif op == "9": exportar_csvs()
        elif op == "0":
            print("Encerrando...")
            break
        else:
            print("Opção inválida.")
