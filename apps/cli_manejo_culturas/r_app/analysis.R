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

#exibicao em formato tabela
print_table <- function(df, title=NULL) {
  if (!is.null(title)) cat("\n", title, "\n", sep="")
  if (is.null(df) || nrow(df)==0) { cat("(vazio)\n"); return(invisible(NULL)) }
  print(df, row.names = FALSE, right = FALSE)
}

#contagem de linhas exibidas e totais para head
print_head <- function(df, title=NULL, n=5) {
  if (!is.null(title)) cat("\n", title, "\n", sep="")
  if (is.null(df) || nrow(df)==0) { cat("(vazio)\n"); return(invisible(NULL)) }
  cat(sprintf("(mostrando as %d primeiras de %d linhas)\n", min(n, nrow(df)), nrow(df)))
  print(utils::head(df, n), row.names = FALSE, right = FALSE)
}

# -------------------------
# Caminhos
# - Detecta automaticamente a pasta 'python_app/data' tanto
#   quando os CSVs forem gerados dentro de apps/cli_manejo_culturas
#   quanto quando forem gerados na raiz do projeto.
# -------------------------
resolve_data_dir <- function() {
  candidates <- c(
    "../python_app/data",            # esperado quando executa de apps/cli_manejo_culturas
    "../../python_app/data",         # caso o working dir mude um nível acima
    "python_app/data",               # quando gerado na raiz e executado da raiz
    "../../../python_app/data"       # fallback extra
  )
  for (p in candidates) {
    if (dir.exists(p)) return(p)
  }
  return(candidates[1])
}

DATA_DIR <- resolve_data_dir()
trat_path <- file.path(DATA_DIR, "export_tratamentos.csv")
prod_path <- file.path(DATA_DIR, "export_produtos.csv")

trat <- read_csv_safe(trat_path)
prod <- read_csv_safe(prod_path)

# BLOCO 1 — RESUMO
cat("\n
# =========================================================
# BLOCO 1 — RESUMOS E TOTAIS
# =========================================================\n")

print_head(trat, title="-- Tratamentos cadastrados --", n=5)
print_head(prod, title="-- Produtos utilizados --",     n=5)

##Áreas por cultura (média/desvio de ha) 
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_ha <- num(trat$area_ha)

  agg_mean_area <- aggregate(area_ha ~ cultura, data = trat, mean, na.rm = TRUE)
  agg_sd_area   <- aggregate(area_ha ~ cultura, data = trat, sd,   na.rm = TRUE)
  areas_kpi <- merge(agg_mean_area, agg_sd_area, by = "cultura", all = TRUE)

  names(areas_kpi) <- c("Cultura", "Média Ha", "Desvio Ha")
  areas_kpi$`Média Ha`  <- round(areas_kpi$`Média Ha`,  4)
  areas_kpi$`Desvio Ha` <- round(areas_kpi$`Desvio Ha`, 4)

  print_table(areas_kpi[order(areas_kpi$Cultura), ],
              "-- Áreas por cultura --")
} else {
  cat("\n-- Áreas por cultura --\n(vazio)\n")
}

## -- Total consumido por produto
if (!is.null(prod) && nrow(prod) > 0) {
  prod$total <- num(prod$total)
  total_por_ativo <- aggregate(total ~ ativo + unidade, data = prod, sum, na.rm = TRUE)
  names(total_por_ativo) <- c("Ativo", "Unidade", "Total Kg/Lt.")
  total_por_ativo$`Total Kg/Lt.` <- round(total_por_ativo$`Total Kg/Lt.`, 4)

  print_table(total_por_ativo[order(-total_por_ativo$`Total Kg/Lt.`), ],
              "-- Total consumido por produto --")
} else {
  cat("\n-- Total consumido por produto --\n(vazio)\n")
}



# BLOCO 2 — ANALYTIC
cat("\n
# =========================================================
# BLOCO 2 — ANALÍTICO
# =========================================================\n")

##Nº de aplicações por manejo (estimado) -- (apps_est = ha_aplic / ha)
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
              "-- Nº de aplicações por tratamento --")
} else {
  cat("\n-- Nº de aplicações por tratamento --\n(vazio)\n")
}

## Top 5 produtos por consumo
if (!is.null(prod) && nrow(prod) > 0) {
  prod$total <- num(prod$total)
  top5 <- aggregate(total ~ ativo + unidade, data = prod, sum, na.rm = TRUE)
  top5 <- top5[order(-top5$total), ]
  top5$Rank <- seq_len(nrow(top5))
  top5 <- head(top5, 5)
  names(top5) <- c("Ativo", "Unidade", "Total Kg/Lt.", "Rank")
  top5$`Total Kg/Lt.` <- round(top5$`Total Kg/Lt.`, 4)
  print_table(top5[, c("Rank","Ativo","Unidade","Total Kg/Lt.")],
              "-- Top 5 produtos por consumo --")
} else {
  cat("\n-- Top 5 produtos por consumo --\n(vazio)\n")
}

##Dose/ha medio por ativo
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
              "-- Dose/ha por produto --")
} else {
  cat("\n-- Dose/ha por produto --\n(vazio)\n")
}

## Área total equivalente tratada por cultura 
if (!is.null(trat) && nrow(trat) > 0) {
  trat$area_eq_tratada <- num(trat$area_eq_tratada)
  area_eq_cult <- aggregate(area_eq_tratada ~ cultura, data = trat, sum, na.rm = TRUE)
  names(area_eq_cult) <- c("Cultura", "Hectares")
  area_eq_cult$Hectares <- round(area_eq_cult$Hectares, 4)

  print_table(area_eq_cult[order(area_eq_cult$Cultura), ],
              "-- Área total equivalente --")
} else {
  cat("\n-- Área total equivalente --\n(vazio)\n")
}

# BLOCO 3 — PREVISÃO METEOROLÓGICA (7 dias) + JANELAS DE APLICAÇÃO
cat("\n
# =========================================================
# BLOCO 3 — PREVISÃO METEOROLÓGICA (7 dias) + JANELAS DE APLICAÇÃO
# =========================================================\n")

#validacao de biblioteca json
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
library(jsonlite)

#parâmetros para analise cruzada
LAT <- -23.55   # São Paulo (exemplo). Troque p/ a fazenda do cliente.
LON <- -46.63
WX_DAYS <- 7
LIM_CHUVA_MM <- 2       # até 2 mm/dia = ok
LIM_VENTO_KMH <- 18     # até 18 km/h = ok para pulverização
TEMP_MIN_OK  <- 15      # 15–32 °C = janela boa
TEMP_MAX_OK  <- 32

safe_fromJSON <- function(url) {
  tryCatch(jsonlite::fromJSON(url), error = function(e) { message("Falha na API: ", e$message); NULL })
}

#requisicao pela ap open-meteo
get_weather <- function(lat, lon, start = Sys.Date(), days = WX_DAYS) {
  end <- start + (days - 1)
  url <- paste0(
    "https://api.open-meteo.com/v1/forecast?",
    "latitude=", lat,
    "&longitude=", lon,
    "&daily=temperature_2m_mean,precipitation_sum,wind_speed_10m_max",
    "&timezone=auto",
    "&start_date=", format(as.Date(start), "%Y-%m-%d"),
    "&end_date=",   format(as.Date(end),   "%Y-%m-%d")
  )
  x <- safe_fromJSON(url)
  if (is.null(x) || is.null(x$daily)) return(NULL)
  d <- as.data.frame(x$daily)
  names(d) <- c("Data", "Temp_media_C", "Precip_mm", "Vento_max_kmh")
  d$Data <- as.Date(d$Data)
  d
}

classificar_janela <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(df)
  df$Janela <- ifelse(df$Precip_mm > LIM_CHUVA_MM, "Ruim (chuva)",
                 ifelse(df$Vento_max_kmh > LIM_VENTO_KMH, "Ruim (vento)",
                   ifelse(df$Temp_media_C < TEMP_MIN_OK | df$Temp_media_C > TEMP_MAX_OK,
                          "Alerta (temp)", "Boa")))
  df
}

wx <- classificar_janela(get_weather(LAT, LON))

if (is.null(wx) || nrow(wx) == 0) {
  cat("(sem dados da API no momento)\n")
} else {
  cat("\n-- Local São Paulo-SP --\n")
  print(utils::head(wx, 7), row.names = FALSE, right = FALSE)

  boas <- subset(wx, Janela == "Boa")
  if (!is.null(boas) && nrow(boas) > 0) {
    cat("\nJanelas recomendadas (\"Boa\"):\n")
    print(boas[, c("Data", "Temp_media_C", "Precip_mm", "Vento_max_kmh")],
          row.names = FALSE, right = FALSE)
  } else {
    cat("\nJanelas recomendadas: (nenhuma 'Boa' pelos thresholds definidos)\n")
  }
}

# BLOCO 4 — VALIDACAO E TESTE DE SANIDADE
cat("\n
# =========================================================
# BLOCO 4 — VALIDACAO E TESTE DE SANIDADE
# =========================================================\n")

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