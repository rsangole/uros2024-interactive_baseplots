library(shiny)
library(shinyWidgets)
library(bslib)
library(dplyr)
library(ggplot2)

# Load code ----
message("loading code")
lapply(fs::dir_ls(here::here("R")), source)

# Load data ----
message("loading data")
meteorites <- data.table::fread(here::here("data/Meteorite_Landings_20241116.csv")) |>
    janitor::clean_names() |>
    dplyr::arrange(mass_g)
comets <- data.table::fread(here::here("data/comets.csv")) |>
    janitor::clean_names()
exoplanets <- qs2::qs_read(here::here("data/exoplanets.qs2")) |>
    mutate(
        ra_h = as.numeric(stringr::str_extract(rastr, "\\d{2}(?=h)")),
        ra_m = as.numeric(stringr::str_extract(rastr, "\\d{2}(?=m)")),
        ra_s = as.numeric(stringr::str_extract(rastr, "\\d{2}\\.\\d{1,4}(?=s)")),
        ra_hms = sprintf("%s:%s:%s", ra_h, ra_m, ra_s),
        ra_xaxis = ra - 180
    ) |>
    arrange(ra_h, ra_m, ra_s) |>
    dplyr::filter(
        discoverymethod %in% c("Transit", "Radial Velocity", "Microlensing")
    )
image <- jpeg::readJPEG(here::here("images/starmap_2020_4k_print.jpg"))


# UI ----
message("loading UI")
ui <- navbarPage(
    "Interactivity with Base R",
    navmenu_fundamentals(),
    navbarMenu(
        "In Action",
        nav_panel(
            title = "Time-series Analysis",
            ts_UI("ts", "A time-series plot")
        ),
        nav_panel(
            "Scatter",
            scatter_UI("scatter")
        )
    ),
    navbarMenu(
        "Scaling Up",
        nav_panel(
            title = "Shiny modules",
            tabsetPanel(
                tabPanel(
                    "Server Load",
                    ts_UI("ts_server", "")
                ),
                tabPanel(
                    "Electricity Transformer",
                    ts_UI("ts_et", ""),
                ),
                tabPanel(
                    "Twitter Data",
                    ts_UI("ts_twitter", "")
                )
            )
        ),
    )
)


# Server ----
message("loading server")
server <- function(input, output, session) {
    # * Basics ----
    output$scatter_plot <- renderPlot({
        symbols(
            x = meteorites$reclong,
            y = meteorites$reclat,
            circles = log(meteorites$mass_g + 1),
            xlab = "Longitude",
            ylab = "Latitude",
            inches = 0.07,
            fg = "#0c4743",
            bg = rgb(255, 255, 255, 50, maxColorValue = 255),
            xlim = c(-180, 180),
            axes = FALSE
        )
        axis(side = 1, at = axTicks(1), labels = sprintf("%s°", axTicks(1)))
        axis(side = 2, at = axTicks(2), labels = sprintf("%s°", axTicks(2)))
    })
    output$click_info <- renderPrint({
        str(input$plot_click)
    })
    output$hover_info <- renderPrint({
        str(input$plot_hover)
    })
    output$dblclick_info <- renderPrint({
        str(input$plot_dblclick)
    })
    output$brush_info <- renderPrint({
        str(input$plot_brush)
    })
    output$basicplot_UIcode <- renderUI({
        code_joined <- '# UI
plotOutput(
     outputId = "the_plot",
     click = clickOpts(id = "plot_click"),
     dblclick = dblclickOpts(id = "plot_dblclick"),
     hover = hoverOpts(id = "plot_hover"),
     brush = brushOpts(id = "plot_brush"),
)'
        tags$pre(
            tags$code(
                HTML(code_joined)
            )
        )
    })
    output$basicplot_Servercode <- renderUI({
        code_joined <- "# Server
output$click_info <- renderPrint({
    str(input$plot_click)
})"
        tags$pre(
            tags$code(
                HTML(code_joined)
            )
        )
    })

    # * Images ----
    output$erat_img <- renderImage(
        {
            path <- here::here("images/selene.png")
            list(src = path)
        },
        deleteFile = FALSE
    )
    output$img_click_info <- renderPrint({
        str(input$img_click)
    })
    output$img_dblclick_info <- renderPrint({
        str(input$img_dblclick)
    })
    output$img_hover_info <- renderPrint({
        str(input$img_hover)
    })
    output$img_brush_info <- renderPrint({
        str(input$img_brush)
    })

    # * Faceted plots ----
    output$exoplanets_plot <- renderPlot({
        if (input$show_bg) {
            p <- exoplanets |>
                ggplot() +
                ggpubr::background_image(image) +
                geom_point(
                    aes(
                        x = ra_xaxis,
                        y = dec,
                        size = pl_bmassj
                        # alpha = pl_bmassj
                    ),
                    color = "white",
                    shape = 22
                ) +
                facet_wrap(~discoverymethod, nrow = 4, strip.position = "left") +
                theme(legend.position = "none") +
                scale_x_continuous(
                    limits = c(-180, 180),
                    breaks = seq(-180, 180, 30),
                    labels = \(x){
                        sprintf("%sH", x / 15)
                    }
                ) +
                scale_y_continuous(
                    limits = c(-90, 90),
                    labels = \(x){
                        sprintf("%s°", x)
                    }
                ) +
                labs(
                    x = "Right Ascension",
                    y = "Declination"
                )
        } else {
            p <- exoplanets |>
                dplyr::filter(
                    discoverymethod %in% c("Transit", "Radial Velocity", "Transit Timing Variations", "Microlensing")
                ) |>
                ggplot() +
                geom_point(
                    aes(
                        x = ra_xaxis,
                        y = dec,
                        size = pl_bmassj
                        # alpha = pl_bmassj
                    ),
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
                labs(
                    x = "Right Ascension",
                    y = "Declination"
                )
        }
        p
    })

    output$exoplanets_dblclick_info <- renderPrint({
        str(input$exoplanets_dblclick)
    })

    # * Lookup ----
    output$lookup_plot <- renderPlot({
        symbols(
            x = meteorites$reclong,
            y = meteorites$reclat,
            circles = log(meteorites$mass_g + 1),
            xlab = "Longitude",
            ylab = "Latitude",
            inches = 0.07,
            fg = "#0c4743",
            bg = rgb(255, 255, 255, 50, maxColorValue = 255),
            xlim = c(-180, 180),
            axes = FALSE
        )
        axis(side = 1, at = axTicks(1), labels = sprintf("%s°", axTicks(1)))
        axis(side = 2, at = axTicks(2), labels = sprintf("%s°", axTicks(2)))
    })

    output$table_clicked_points <- reactable::renderReactable({
        res <- nearPoints(
            df = meteorites,
            coordinfo = input$lookup_click,
            xvar = "reclong",
            yvar = "reclat",
            threshold = input$max_distance,
            maxpoints = input$max_points,
            addDist = TRUE
        )
        res$dist_ <- round(res$dist_, 1)

        reactable::reactable(
            res,
            compact = TRUE,
            searchable = FALSE,
            filterable = FALSE,
            bordered = TRUE,
            defaultPageSize = 5
        )
    })
    output$lookup_click_UIcode <- renderUI({
        code_joined <- '
reactable::renderReactable({
    nearPoints(
        df = meteorites,
        brush = input$lookup_click,
        xvar = "reclong",
        yvar = "reclat",
        threshold = input$max_distance,
        maxpoints = input$max_points,
        addDist = TRUE
    )
})'
        tags$pre(
            tags$code(
                HTML(code_joined)
            )
        )
    })

    output$table_brushed_points <- reactable::renderReactable({
        res <- brushedPoints(
            df = meteorites,
            brush = input$lookup_brush,
            xvar = "reclong",
            yvar = "reclat"
        )

        reactable::reactable(
            res,
            compact = TRUE,
            searchable = FALSE,
            filterable = FALSE,
            bordered = TRUE,
            defaultPageSize = 5
        )
    })

    output$lookup_brush_UIcode <- renderUI({
        code_joined <- '
reactable::renderReactable({
    brushedPoints(
        df = meteorites,
        brush = input$lookup_brush,
        xvar = "reclong",
        yvar = "reclat"
    )
})'
        tags$pre(
            tags$code(
                HTML(code_joined)
            )
        )
    })

    # * Time-series ----
    ts_server("ts", here::here("data/ts_arrow_1"))
    ts_server("ts_server", here::here("data/ts_arrow_1"))
    ts_server("ts_et", here::here("data/ts_et.arrow"))
    ts_server("ts_twitter", here::here("data/ts_twitter.arrow"))

    # * Scatter ----
    scatter_server("scatter")
}

shinyApp(ui = ui, server = server)
