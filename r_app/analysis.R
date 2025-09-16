# analysis.R — FIAP CAP1
# Rode com: source("r_app/analysis.R", chdir = TRUE)

message("== Análise estatística (R) ==")

# -------------------------
# Helpers
# -------------------------
read_csv_safe <- function(path) {
  if (!file.exists(path)) {
    message(sprintf("(!) Arquivo não encontrado: %s", path))
    return(NULL)
  }
  df <- tryCatch(
    read.csv(path, sep = ";", dec = ".", stringsAsFactors = FALSE),
    error = function(e) { message(sprintf("Erro lendo %s: %s", path, e$message)); NULL }
  )
  df
}

num <- function(x) suppressWarnings(as.numeric(x))

print_table <- function(df, title=NULL) {
  if (!is.null(title)) cat("\n", title, "\n", sep="")
  if (is.null(df) || nrow(df)==0) { cat("(vazio)\n"); return(invisible(NULL)) }
  print(df, row.names = FALSE, right = FALSE)
}

print_head <- function(df, title=NULL, n=5) {
  if (!is.null(title)) cat("\n", title, "\n", sep="")
  if (is.null(df) || nrow(df)==0) { cat("(vazio)\n"); return(invisible(NULL)) }
  cat(sprintf("(mostrando as %d primeiras de %d linhas)\n", min(n, nrow(df)), nrow(df)))
  print(utils::head(df, n), row.names = FALSE, right = FALSE)
}

# -------------------------
# Caminhos
# -------------------------
trat_path <- "../python_app/data/export_tratamentos.csv"
prod_path <- "../python_app/data/export_produtos.csv"

trat <- read_csv_safe(trat_path)
prod <- read_csv_safe(prod_path)

# =========================================================
# BLOCO 1 — DADOS DA TABELA CSV (HEAD)
# =========================================================
cat("\n=== Bloco 1: Dados brutos (head) ===\n")

print_head(trat, title="-- export_tratamentos.csv (head) --", n=5)
print_head(prod, title="-- export_produtos.csv (head) --",     n=5)

# =========================================================
# BLOCO 2 — RESUMO
# =========================================================
cat("\n=== Bloco 2: Resumo ===\n")

## -- Áreas por cultura (média/desvio de ha) --  (usa area_ha do tratamentos)
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_ha <- num(trat$area_ha)

  agg_mean_area <- aggregate(area_ha ~ cultura, data = trat, mean, na.rm = TRUE)
  agg_sd_area   <- aggregate(area_ha ~ cultura, data = trat, sd,   na.rm = TRUE)
  areas_kpi <- merge(agg_mean_area, agg_sd_area, by = "cultura", all = TRUE)

  names(areas_kpi) <- c("Cultura", "Média Ha", "Desvio Ha")
  areas_kpi$`Média Ha`  <- round(areas_kpi$`Média Ha`,  4)
  areas_kpi$`Desvio Ha` <- round(areas_kpi$`Desvio Ha`, 4)

  print_table(areas_kpi[order(areas_kpi$Cultura), ],
              "-- Áreas por cultura (média/desvio de ha) --")
} else {
  cat("\n-- Áreas por cultura (média/desvio de ha) --\n(vazio)\n")
}

## -- Nº de aplicações por manejo (estimado) -- (apps_est = ha_aplic / ha)
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_ha          <- num(trat$area_ha)
  trat$area_eq_tratada  <- num(trat$area_eq_tratada)
  trat$apps_est <- ifelse(trat$area_ha > 0, trat$area_eq_tratada / trat$area_ha, NA_real_)

  agg_mean_apps <- aggregate(apps_est ~ manejo, data = trat, mean, na.rm = TRUE)
  agg_sd_apps   <- aggregate(apps_est ~ manejo, data = trat, sd,   na.rm = TRUE)
  apps_kpi <- merge(agg_mean_apps, agg_sd_apps, by = "manejo", all = TRUE)

  names(apps_kpi) <- c("Manejo", "Aplicação média", "Aplicação desvio")
  apps_kpi$`Aplicação média`  <- round(apps_kpi$`Aplicação média`,  3)
  apps_kpi$`Aplicação desvio` <- round(apps_kpi$`Aplicação desvio`, 3)

  print_table(apps_kpi[order(apps_kpi$Manejo), ],
              "-- Nº de aplicações por manejo (estimado) --")
} else {
  cat("\n-- Nº de aplicações por manejo (estimado) --\n(vazio)\n")
}

## -- Dose/ha por ativo (média/desvio) --
if (!is.null(prod) && nrow(prod) > 0) {
  prod$dose_ha <- num(prod$dose_ha)

  agg_mean_dose <- aggregate(dose_ha ~ ativo + unidade, data = prod, mean, na.rm = TRUE)
  agg_sd_dose   <- aggregate(dose_ha ~ ativo + unidade, data = prod, sd,   na.rm = TRUE)
  dose_stats <- merge(agg_mean_dose, agg_sd_dose, by = c("ativo","unidade"), all = TRUE)

  names(dose_stats) <- c("Ativo", "Unidade", "Dose média", "Dose desvio")
  dose_stats$`Dose média`  <- round(dose_stats$`Dose média`,  4)
  dose_stats$`Dose desvio` <- round(dose_stats$`Dose desvio`, 4)

  print_table(dose_stats[order(dose_stats$Ativo, dose_stats$Unidade), ],
              "-- Dose/ha por ativo (média/desvio) --")
} else {
  cat("\n-- Dose/ha por ativo (média/desvio) --\n(vazio)\n")
}

## -- Total consumido por ativo (somatório) --
if (!is.null(prod) && nrow(prod) > 0) {
  prod$total <- num(prod$total)
  total_por_ativo <- aggregate(total ~ ativo + unidade, data = prod, sum, na.rm = TRUE)
  names(total_por_ativo) <- c("Ativo", "Unidade", "Total Kg/Lt.")
  total_por_ativo$`Total Kg/Lt.` <- round(total_por_ativo$`Total Kg/Lt.`, 4)

  print_table(total_por_ativo[order(-total_por_ativo$`Total Kg/Lt.`), ],
              "-- Total consumido por ativo (somatório) --")
} else {
  cat("\n-- Total consumido por ativo (somatório) --\n(vazio)\n")
}

## -- Área equivalente tratada por cultura (soma) --
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_eq_tratada <- num(trat$area_eq_tratada)
  area_eq_cult <- aggregate(area_eq_tratada ~ cultura, data = trat, sum, na.rm = TRUE)
  names(area_eq_cult) <- c("Cultura", "Hectares")
  area_eq_cult$Hectares <- round(area_eq_cult$Hectares, 4)

  print_table(area_eq_cult[order(area_eq_cult$Cultura), ],
              "-- Área equivalente tratada por cultura (soma) --")
} else {
  cat("\n-- Área equivalente tratada por cultura (soma) --\n(vazio)\n")
}

# =========================================================
# BLOCO 3 — ANALÍTICO
# =========================================================
cat("\n=== Bloco 3: Analítico ===\n")

## Top 5 ativos por consumo
if (!is.null(prod) && nrow(prod) > 0) {
  prod$total <- num(prod$total)
  top5 <- aggregate(total ~ ativo + unidade, data = prod, sum, na.rm = TRUE)
  top5 <- top5[order(-top5$total), ]
  top5$Rank <- seq_len(nrow(top5))
  top5 <- head(top5, 5)
  names(top5) <- c("Ativo", "Unidade", "Total Kg/Lt.", "Rank")
  top5$`Total Kg/Lt.` <- round(top5$`Total Kg/Lt.`, 4)
  print_table(top5[, c("Rank","Ativo","Unidade","Total Kg/Lt.")],
              "-- Top 5 ativos por consumo --")
} else {
  cat("\n-- Top 5 ativos por consumo --\n(vazio)\n")
}

## Área média de talhão por cultura (via tratamentos)
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_ha <- num(trat$area_ha)
  area_media <- aggregate(area_ha ~ cultura, data = trat, mean, na.rm = TRUE)
  names(area_media) <- c("Cultura", "Média Ha")
  area_media$`Média Ha` <- round(area_media$`Média Ha`, 4)
  print_table(area_media[order(area_media$Cultura), ],
              "-- Área média de talhão por cultura --")
} else {
  cat("\n-- Área média de talhão por cultura --\n(vazio)\n")
}

## Ativos com unidades divergentes
if (!is.null(prod) && nrow(prod) > 0) {
  unidades_por_ativo <- aggregate(unidade ~ ativo, data = prod, function(u) length(unique(u)))
  diverg <- subset(unidades_por_ativo, unidade > 1)
  if (nrow(diverg) > 0) {
    names(diverg) <- c("Ativo", "Qtd_unidades_distintas")
    print_table(diverg[order(-diverg$Qtd_unidades_distintas, diverg$Ativo), ],
                "-- Ativos com unidades divergentes --")
  } else {
    cat("\n-- Ativos com unidades divergentes --\n(nenhum)\n")
  }
} else {
  cat("\n-- Ativos com unidades divergentes --\n(vazio)\n")
}

## Zeros/negativos (checagem de sanidade)
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_ha         <- num(trat$area_ha)
  trat$area_eq_tratada <- num(trat$area_eq_tratada)
  invalid_trat <- sum(trat$area_ha <= 0 | trat$area_eq_tratada < 0, na.rm = TRUE)
  message(sprintf("Checagem: tratamentos com área<=0 ou ha-aplic<0: %d", invalid_trat))
} else {
  message("Checagem: tratamentos (vazio).")
}

if (!is.null(prod) && nrow(prod) > 0) {
  prod$dose_ha    <- num(prod$dose_ha)
  prod$aplicacoes <- num(prod$aplicacoes)
  invalid_prod <- sum(prod$dose_ha <= 0 | prod$aplicacoes <= 0, na.rm = TRUE)
  message(sprintf("Checagem: produtos com dose<=0 ou aplicações<=0: %d", invalid_prod))
} else {
  message("Checagem: produtos (vazio).")
}

cat("\nOK: análise concluída.\n")
