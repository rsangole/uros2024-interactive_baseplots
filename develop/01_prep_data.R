library(data.table)
library(dplyr)
library(qs2)
library(plotly)
library(ggplot2)
library(arrow)


# Exoplanets data from the NASA Exoplanet Archive
## Source: https://exoplanetarchive.ipac.caltech.edu/cgi-bin/TblView/nph-tblView?app=ExoTbls&config=PS
## Converted to qs2 format
# data.table::fread(here::here("data/PS_2024.11.16_16.28.11.csv")) |>
#     dplyr::select(-contains("refname")) |>
#     qs2::qs_save(here::here("data/exoplanets.qs2"))


#  Electricity Transformer dataset
## Source: https://github.com/zhouhaoyi/ETDataset/tree/main
# data.table::fread(here::here("data/ETTh1.csv")) |>
#     janitor::clean_names() |>
#     tidyr::pivot_longer(-date, names_to = "grp", values_to = "value") |>
#     dplyr::mutate(tag = "", anomaly = 0) |>
#     dplyr::rename(ds = date) |>
#     dplyr::group_by(grp) |>
#     arrow::write_dataset(here::here("data/ts_et.arrow"))


# Twitter volume dataset
# bind_rows(
#     fread(here::here("data/Twitter_volume_AAPL.csv")) |>
#         dplyr::mutate(grp = "AAPL", tag = "", anomaly = 0),
#     fread(here::here("data/Twitter_volume_GOOG.csv")) |>
#         dplyr::mutate(grp = "GOOG", tag = "", anomaly = 0)
# ) |>
#     dplyr::rename(ds = timestamp) |>
#     dplyr::group_by(grp) |>
#     arrow::write_dataset(here::here("data/ts_twitter.arrow"))
