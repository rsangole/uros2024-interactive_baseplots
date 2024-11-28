# https://exoplanetarchive.ipac.caltech.edu/cgi-bin/TblView/nph-tblView?app=ExoTbls&config=PS

library(data.table)
library(dplyr)
library(qs2)
library(plotly)
library(ggplot2)
library(arrow)

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
    scale_x_continuous(limits = c(0, 360), labels = \(x){
        sprintf("%s°", x)
    }) +
    scale_y_continuous(limits = c(-90, 90), labels = \(x){
        sprintf("%s°", x)
    }) +
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

payloads <- fread("/workspaces/interactive-baseplots/data/spacex_payloads.csv", col.names = c(
    "launch", "id",
    "mass_kg",
    "orbit",
    "name",
    "type",
    "reused",
    "regime",
    "reference_system"
))
payloads


spacex <- launches |>
    left_join(rockets, by = c("rocket" = "id")) |>
    full_join(payloads, by = c("payloads" = "id")) |>
    dplyr::mutate(
        year = lubridate::year(date_utc),
        success = ifelse(success, "Success", "Failure")
    )




# https://data.cityofchicago.org/Buildings/Building-Violations/22u3-xenr/about_data
violations <- fread("data/Building_Violations_20241123.csv")
violations <- violations |>
    janitor::clean_names()
violations
violations |>
    # to_duckdb() |>
    dplyr::mutate(
        inspection_status_color = dplyr::recode(
            inspection_status,
            "PASSED" = "#43aa8bff",
            "FAILED" = "#f94144ff",
            "HOLD" = "#f3722cff",
            "CLOSED" = "#277da1ff",
            .default = "#f9c74fff"
        ),
        violation_status_color = dplyr::recode(
            violation_status,
            "COMPLIED" = "#43aa8bff",
            "OPEN" = "#f3722cff",
            "NO ENTRY" = "#277da1ff",
            .default = "#f9c74fff"
        )
        # department_bureau_color = dplyr::recode(
        #     department_bureau,
        #     "BOILER" = "#2D0849",
        #     "CONSERVATION" = "#0C125A",
        #     "VENTILATION" = "#10526A",
        #     "SPECIAL TASK FORCE" = "#157A53",
        #     "REFRIGERATION" = "#1E891A",
        #     "ELEVATOR" = "#729720",
        #     "ELECTRICAL" = "#A57B27",
        #     "PLUMBING" = "#B2302E",
        #     "SPECIAL INSPECTION PROGRAM" = "#BF368A",
        #     "NEW CONSTRUCTION" = "#A344C5",
        #     "IRON" = "#6057C7",
        #     "DEMOLITION" = "#699FC9",
        #     "SIGNS" = "#7BCCBA",
        #     "CONSTRUCTION EQUIPMENT" = "#8CCF95",
        #     "WATER" = "#B9D39C"
        # )
    ) |>
    group_by(violation_status, inspection_status) |>
    arrow::write_dataset(here::here("data/violations.arrow/"))


violations <- arrow::open_dataset(here::here("data/violations.arrow/")) |>
    arrow::to_duckdb()
violations

violations |>
    group_by(department_bureau,inspection_status, violation_status) |>
    dplyr::count() |>
    dplyr::filter(violation_status == "OPEN") |>
    collect() |>
    arrange(-n) -> n_dept
n_dept


n_yaxis <- length(unique(n_dept$department_bureau)))

par(mfrow = c(, 1), mar = c(1, 20, 0, 1), oma = c(2, 2, 2, 2))
for (i in 1:n_yaxis) {

    # curr <- occs[occs$category == n_dept[i, "category"], ]
    stripchart(
        n_dept[i, "n"],
        method = "overplot",
        pch = 19,
        col = "#000000b6",
        cex = 2, 
        xlim = c(0, max(n_dept$n)), 
        axes = FALSE
    )
    mtext(n_dept[i, "department_bureau"], 2, las = 1, cex = 1)
}


dt <- violations |>
    # dplyr::filter(inspection_category %in% input$insp_cat) |>
    dplyr::select(department_bureau, violation_status, inspection_status, latitude, longitude, inspection_status_color) |>
    dplyr::collect()
dt

dt |>
    dplyr::filter(inspection_status == "FAILED") |>
    mutate(
        longitude = round(longitude, 2),
        latitude = round(latitude, 2)
    ) |>
    group_by(longitude, latitude) |>
    count() -> count_failed_dt
count_failed_dt

library(ggplot2)

count_failed_dt |>
    ggplot( aes(x =longitude, y =  latitude, size = n^2)) +
    geom_point(color = "#7A0018", alpha = 0.4) +
    theme_void() +
    theme(legend.position = "none") +
    scale_size_area(max_size = 15)
