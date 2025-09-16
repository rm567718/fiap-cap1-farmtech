# --- deps mínimas ---
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
library(jsonlite)

#requisicao pela ap open-meteo
get_weather <- function(lat, lon, start = Sys.Date(), end = Sys.Date() + 6) {
  url <- paste0(
    "https://api.open-meteo.com/v1/forecast?",
    "latitude=", lat,
    "&longitude=", lon,
    "&daily=temperature_2m_mean,precipitation_sum,wind_speed_10m_max",
    "&timezone=auto",
    "&start_date=", format(as.Date(start), "%Y-%m-%d"),
    "&end_date=", format(as.Date(end), "%Y-%m-%d")
  )
  x <- jsonlite::fromJSON(url)
  if (is.null(x$daily)) return(NULL)
  d <- as.data.frame(x$daily)
  names(d) <- c("data", "temp_media_C", "precip_mm", "vento_max_kmh")
  d$data <- as.Date(d$data)
  d
}

classificar_janela <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(df)
  df$janela <- ifelse(df$precip_mm > 2, "Ruim (chuva)",
                 ifelse(df$vento_max_kmh > 18, "Ruim (vento)",
                   ifelse(df$temp_media_C < 15 | df$temp_media_C > 32, "Alerta (temp)", "Boa")))
  df
}

#A latitude e longitude podem ser alteradas para a localicao do cliente
lat <- -23.55   # exemplo: São Paulo capital
lon <- -46.63

wx <- get_weather(lat, lon)
wx <- classificar_janela(wx)

cat("\n== Previsão diária (próximos 7 dias) ==\n")
print(wx, row.names = FALSE, right = FALSE)

cat("\n== Melhores janelas (classificação 'Boa') ==\n")
print(subset(wx, janela == "Boa"), row.names = FALSE, right = FALSE)

# =========================================================
# BLOCO 4 — PREVISÃO METEOROLÓGICA (7 dias) + JANELAS DE APLICAÇÃO
# =========================================================
cat("\n=== Bloco 4: Previsão meteorológica + Janelas de aplicação ===\n")

#dependência leve
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
library(jsonlite)

#parâmetros (ajuste se quiser)
WX_DAYS <- 7
LIM_CHUVA_MM <- 2       # até 2 mm/dia = ok
LIM_VENTO_KMH <- 18     # até 18 km/h = ok para pulverização
TEMP_MIN_OK  <- 15      # 15–32 °C = janela boa
TEMP_MAX_OK  <- 32

safe_fromJSON <- function(url) {
  tryCatch(jsonlite::fromJSON(url), error = function(e) { message("Falha na API: ", e$message); NULL })
}

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

print_head_weather <- function(df, title) {
  if (is.null(df) || nrow(df) == 0) {
    cat("\n", title, "\n(vazio)\n", sep = "")
    return(invisible(NULL))
  }
  cat("\n", title, "\n", sep = "")
  print(utils::head(df, 7), row.names = FALSE, right = FALSE)
}

# --- lê config de locais, se existir; senão usa fallback ---
cfg_path <- "weather_config.csv"
locais <- NULL
if (file.exists(cfg_path)) {
  locais <- tryCatch(read.csv(cfg_path, stringsAsFactors = FALSE),
                     error = function(e) { message("Erro lendo weather_config.csv: ", e$message); NULL })
}
if (is.null(locais) || nrow(locais) == 0) {
  locais <- data.frame(local = "Fallback (São Paulo)",
                       lat = -23.55, lon = -46.63, cultura = "",
                       stringsAsFactors = FALSE)
}

# --- para cada local, puxa previsão e imprime janelas ---
for (i in seq_len(nrow(locais))) {
  loc <- locais[i, ]
  wx  <- get_weather(loc$lat, loc$lon)
  wx  <- classificar_janela(wx)

  titulo <- paste0("-- ", loc$local,
                   if (!is.null(loc$cultura) && nzchar(loc$cultura)) paste0(" (Cultura: ", loc$cultura, ")"),
                   " --")
  print_head_weather(wx, titulo)

  boas <- subset(wx, Janela == "Boa")
  if (!is.null(boas) && nrow(boas) > 0) {
    cat("\nJanelas recomendadas (\"Boa\"):\n")
    print(boas[, c("Data", "Temp_media_C", "Precip_mm", "Vento_max_kmh")],
          row.names = FALSE, right = FALSE)
  } else {
    cat("\nJanelas recomendadas: (nenhuma 'Boa' pelos thresholds definidos)\n")
  }
}
