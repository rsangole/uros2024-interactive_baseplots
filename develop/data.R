library(dplyr)
library(arrow)
library(data.table)
library(duckdb)
library(tictoc)

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
