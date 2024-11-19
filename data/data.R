# https://exoplanetarchive.ipac.caltech.edu/cgi-bin/TblView/nph-tblView?app=ExoTbls&config=PS

library(data.table)
library(dplyr)
library(qs2)
library(plotly)
library(ggplot2)

fread("/workspaces/interactive-baseplots/data/PS_2024.11.16_16.28.11.csv") |>
    select(-contains("refname")) |>
    qs2::qs_save(here::here("data/exoplanets.qs2"))

dat <- qs2::qs_read("data/exoplanets.qs2")
dat

ggplot(dat) +
    geom_point(
        aes(
            x = log(pl_orbper),
            y = log(pl_bmasse),
            color = as.factor(disc_year)
        )
    ) +
    facet_wrap(~discoverymethod)

ggplot(dat) +
    geom_point(
        aes(
            x = disc_year,
            y = log(pl_orbper),
            color = disc_facility
        )
    ) +
    facet_wrap(~discoverymethod) +
    theme(legend.position = "none")


dat |>
    dplyr::filter(
        discoverymethod %in% c("Transit", "Radial Velocity", "Transit Timing Variations", "Microlensing")
    ) |>
    ggplot() +
    geom_point(
        aes(
            x = ra,
            y = dec,
            size = pl_bmassj
        ),
        shape = 21
    ) +
    facet_wrap(~discoverymethod) +
    theme(legend.position = "none") +
    scale_x_continuous(limits = c(0, 360), labels = \(x){sprintf("%s°", x)}) +
    scale_y_continuous(limits = c(-90, 90), labels = \(x){sprintf("%s°", x)}) +
    labs(
        x = "Right Ascension",
        y = "Declination",
        title = "Exoplanets discovered by Transit, Radial Velocity, Transit Timing Variations, and Microlensing"
    )


fread("/workspaces/interactive-baseplots/data/Meteorite_Landings_20241116.csv") |>
    janitor::clean_names() |>
    plot_ly(
        x = ~reclong,
        y = ~reclat,
        # color = ~fall,
        size = ~mass_g
    ) |>
    add_markers()


launches <- data.table::fread("/workspaces/interactive-baseplots/data/spacex_launches.csv",
    col.names = c(
        "flight_number",
        "launch_name",
        "date_utc",
        "success",
        "launchpad",
        "rocket"
    )
)
rockets <- data.table::fread("/workspaces/interactive-baseplots/data/spacex_rockets.csv",
    col.names = c(
        "id", "country", "company", "rocket_name", "type", "active", "stages", "boosters", "cost_per_launch", "success_rate_pct"
    )
)

payloads <- fread("/workspaces/interactive-baseplots/data/spacex_payloads.csv",col.names = c("launch",'id', 
'mass_kg', 
'orbit',
'name', 
'type', 
'reused', 
'regime', 
'reference_system'))
payloads


spacex <- launches |>
    left_join(rockets, by = c("rocket" = "id")) |>
    full_join(payloads, by = c("payloads" = "id")) |>
    dplyr::mutate(
        year = lubridate::year(date_utc),
        success = ifelse(success, "Success", "Failure")
    )


launches |>
    left_join(rockets, by = c("rocket" = "id")) |>
    right_join(payloads, by = c("id" = "launch")) |