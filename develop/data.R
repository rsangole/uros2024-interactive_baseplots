library(dplyr)
library(arrow)
library(data.table)
library(duckdb)
library(tictoc)
library(qs2)
library(ggplot2)
load("data/large_timeseries.rda")

dt <- tslabeler_example |>
    janitor::clean_names() |>
    dplyr::arrange(grp, ds)
dt[, value_2 := value + runif(.N, -5, 5)]

dt |>
    group_by(grp) |>
    write_dataset("data/arrow")

open_dataset("data/arrow") |>
    to_duckdb() |>
    distinct(grp) |>
    collect() |>
    pull() |>
    sort()

open_dataset("data/arrow") |>
    to_duckdb() |>
    distinct(tag) |>
    collect() |>
    pull() |>
    sort()


exoplanets <- qs2::qs_read(here::here("data/exoplanets.qs2"))

exoplanets |>
    mutate(
        ra_h = as.numeric(stringr::str_extract(rastr, "\\d{2}(?=h)")),
        ra_m = as.numeric(stringr::str_extract(rastr, "\\d{2}(?=m)")),
        ra_s = as.numeric(stringr::str_extract(rastr, "\\d{2}\\.\\d{1,4}(?=s)")),
        ra_hms = sprintf("%s:%s:%s", ra_h, ra_m, ra_s),
        ra_xaxis = ra - 180
    ) |>
    arrange(ra_h, ra_m, ra_s) -> exoplanets

exoplanets

image <- jpeg::readJPEG("/workspaces/interactive-baseplots/shiny/01 - Basics/images/starmap_2020_4k_print.jpg")
exoplanets |>
    dplyr::filter(
        discoverymethod %in% c("Transit", "Radial Velocity", "Microlensing")
    ) |>
    # head(100) |>
    ggplot() +
    ggpubr::background_image(image) +
    geom_point(
        aes(
            x = ra_xaxis,
            y = dec,
            size = pl_bmassj,
            alpha = pl_bmassj
        ),
        color = "white",
        shape = 22
    ) +
    facet_wrap(~discoverymethod, nrow = 4, strip.position = "left") +
    theme(legend.position = "none") +
    scale_x_continuous(limits = c(-180, 180), breaks = seq(-180, 180, 30), labels = \(x){
        sprintf("%sH", x / 15)
    }) +
    scale_y_continuous(limits = c(-90, 90), labels = \(x){
        sprintf("%s°", x)
    }) +
    # scale_alpha_continuous(range = c(.001, 100)) +
    labs(
        x = "Right Ascension",
        y = "Declination"
    ) +
    theme_minimal()


exoplanets |>
    dplyr::filter(
        ra_m %in% c(0)
    ) |>
    select(ra, ra_h, ra_m, ra_s, ra_hms) |>
    distinct()
