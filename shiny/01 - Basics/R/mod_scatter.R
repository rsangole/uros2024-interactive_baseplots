scatter_UI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Plot",
        shiny::sidebarLayout(
            sidebarPanel = shiny::sidebarPanel(
                width = 2,
                tagList(
                    shinyWidgets::pickerInput(
                        inputId = ns("insp_cat"),
                        label = "Inspection category",
                        choices = c("COMPLAINT", "PERMIT", "PERIODIC", "REGISTRATION"),
                        selected = "PERMIT",
                        options = shinyWidgets::pickerOptions(
                            liveSearch = TRUE,
                            actionsBox = TRUE,
                            size = 10,
                            selectedTextFormat = "count > 3"
                        ),
                        multiple = TRUE
                    ),
                    shinyWidgets::actionBttn(
                        inputId = ns("btn_selectgrp"),
                        label = "Select Group",
                        style = "material-flat",
                        color = "primary",
                        size = "xs"
                    ),
                    shiny::tableOutput(outputId = ns("metatable"))
                )
                # )
            ),
            mainPanel = shiny::mainPanel(
                width = 10,
                tagList(
                    shiny::uiOutput(ns("tsplot_ui"), inline = T),
                    shiny::uiOutput(ns("tsplot_zoomed_ui"), inline = T),
                    shiny::uiOutput(ns("symchart"))
                )
            )
        )
    )
}

scatter_server <- function(id) {
    ns <- NS(id)
    moduleServer(
        id,
        function(input, output, session) {
            arrow_df <- shiny::reactive({
                arrow::open_dataset(here::here("data/violations.arrow"))
            })

            filtered_data <- shiny::eventReactive(input$btn_selectgrp, {
                arrow_df() |>
                    dplyr::filter(inspection_category %in% input$insp_cat) |>
                    dplyr::select(violation_status, inspection_status, latitude, longitude, inspection_status_color) |>
                    dplyr::collect()
            })

            output$plot_ts <- shiny::renderPlot(
                {
                    dat <- filtered_data()
                    legend_dat <- dat |>
                        distinct(inspection_status, inspection_status_color)

                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    plot(
                        dat$longitude,
                        dat$latitude,
                        xlab = "Longitude",
                        ylab = "Latitude",
                        pch = 19,
                        col = dat$inspection_status_color
                    )
                    legend(
                        "topleft",
                        legend = legend_dat$inspection_status,
                        col = legend_dat$inspection_status_color,
                        bg = "white",
                        lwd = 2
                    )
                },
                res = 65
            )

            #
            output$tsplot_ui <- shiny::renderUI({
                shiny::plotOutput(
                    ns("plot_ts"),
                    brush = brushOpts(
                        id = ns("user_brush"),
                        direction = input$brush_direction # "xy"
                    ),
                    dblclick = ns("user_dblclick"),
                    height = "700px"
                )
            })

            output$tsplot_zoomed_ui <- shiny::renderUI({
                shiny::plotOutput(
                    ns("plot_tszoomed"),
                    brush = brushOpts(
                        id = ns("user_brush_zoomed"),
                        direction = input$brush_direction
                    ),
                    dblclick = ns("user_dblclick_zoomed"),
                    height = "400px",
                    width = "400px"
                )
            })

            selectedPoints <- shiny::reactive({
                shiny::brushedPoints(
                    df = filtered_data(),
                    brush = input$user_brush,
                    xvar = "longitude",
                    yvar = "latitude"
                )
            })

            output$plot_tszoomed <- shiny::renderPlot(
                {
                    shiny::req(selectedPoints())
                    dat <- selectedPoints()
                    legend_dat <- dat |>
                        distinct(inspection_status, inspection_status_color)

                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    plot(
                        dat$longitude,
                        dat$latitude,
                        xlab = "Longitude",
                        ylab = "Latitude",
                        pch = 20,
                        col = dat$inspection_status_color,
                        asp = 1
                    )
                    legend(
                        "topleft",
                        legend = legend_dat$inspection_status,
                        col = legend_dat$inspection_status_color,
                        bg = "white",
                        lwd = 2
                    )
                },
                res = 65
            )

            output$symchart <- shiny::renderPlot({
                dat <- selectedPoints() |>
                    dplyr::count(violation_status) |>
                    dplyr::mutate(floorn = floor(n / 10))
                print(dat[["floorn"]])
                symbolsChart(
                    dat[["floorn"]],
                    bar_width = 10,
                    col = c("red", "blue", "green", "yellow")
                )
            })

            output$metatable <- shiny::renderTable(
                {
                    shiny::req(filtered_data())
                    tibble::tibble(
                        Parameter = c(
                            "# Groups",
                            "# Pts"
                        ),
                        Value = c(
                            sprintf("%s/4", length(input$insp_cat)),
                            scales::label_comma()(nrow(filtered_data()))
                        )
                    )
                },
                spacing = "s",
                colnames = FALSE,
                bordered = FALSE
            )
        }
    )
}
