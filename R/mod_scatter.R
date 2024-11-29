scatter_UI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Plot",
        fluidPage(
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
                        br(),
                        hr(),
                        shiny::tableOutput(outputId = ns("metatable"))
                    )
                    # )
                ),
                mainPanel = shiny::mainPanel(
                    width = 10,
                    fluidRow(
                        column(
                            width = 4,
                            shiny::uiOutput(ns("xy_ui"), inline = T)
                        ),
                        column(
                            width = 4,
                            shiny::uiOutput(ns("xy_zoom_ui"), inline = T)
                        )
                        # column(
                        #     width = 4,
                        #     shiny::plotOutput(ns("plot_symchart"))
                        # )
                    )
                    # fluidRow(
                    #     column(
                    #         width = 12,
                    #         shiny::plotOutput(ns("plot_symchart"))
                    #     )
                    # )
                    # bslib::page_fluid(
                    #     bslib::layout_columns(
                    # card(shiny::uiOutput(ns("xy_ui"), inline = T)),
                    # card(shiny::uiOutput(ns("xy_zoom_ui"), inline = T))
                    #     ),
                    #     shiny::plotOutput(ns("plot_symchart"))
                    # )
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

            output$plot_xy <- shiny::renderPlot(
                {
                    dat <- filtered_data() #|>
                    # slice_sample(n = 20e3)
                    legend_dat <- dat |>
                        distinct(inspection_status, inspection_status_color)

                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    plot(
                        dat$longitude,
                        dat$latitude,
                        xlab = "Longitude",
                        ylab = "Latitude",
                        pch = 1,
                        cex = 0.5,
                        col = scales::alpha(I("black"), 0.05) # I("gray")
                        # col = dat$inspection_status_color
                    )
                    # legend(
                    #     "topleft",
                    #     legend = legend_dat$inspection_status,
                    #     col = legend_dat$inspection_status_color,
                    #     bg = "white",
                    #     lwd = 2
                    # )
                },
                res = 65
            )

            output$xy_ui <- shiny::renderUI({
                shiny::plotOutput(
                    ns("plot_xy"),
                    brush = brushOpts(
                        id = ns("user_brush"),
                        direction = input$brush_direction # "xy"
                    ),
                    dblclick = ns("user_dblclick")
                    # height = "400px",
                    # width = "400px"
                )
            })

            output$xy_zoom_ui <- shiny::renderUI({
                shiny::plotOutput(
                    ns("plot_xy_zoom")
                    # brush = brushOpts(
                    #     id = ns("user_brush_zoomed"),
                    #     direction = input$brush_direction
                    # ),
                    # dblclick = ns("user_dblclick_zoomed")
                    # height = "400px",
                    # width = "400px"
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

            output$plot_xy_zoom <- shiny::renderPlot(
                {
                    # shiny::req(selectedPoints())
                    dat <- selectedPoints()

                    if (nrow(dat) == 0) {
                        return(NULL)
                    }

                    legend_dat <- dat |>
                        distinct(inspection_status, inspection_status_color)

                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    plot(
                        dat$longitude,
                        dat$latitude,
                        xlab = "Longitude",
                        ylab = "Latitude",
                        pch = 1,
                        col = dat$inspection_status_color,
                        asp = 1
                    )
                    legend(
                        "topleft",
                        legend = legend_dat$inspection_status,
                        col = legend_dat$inspection_status_color,
                        bg = "white",
                        pch = 1
                    )
                },
                res = 65
            )

            output$plot_symchart <- shiny::renderPlot({
                dat <- selectedPoints() |>
                    dplyr::count(inspection_status) |>
                    dplyr::mutate(cat_pc = ceiling(100 * n / sum(n))) |>
                    arrange(inspection_status)
                print(dat)
                legend_dat <- selectedPoints() |>
                    distinct(inspection_status, inspection_status_color) |>
                    arrange(inspection_status)
                print(legend_dat)
                symbolsChart(
                    dat[["cat_pc"]],
                    # bar_width = 20,
                    col = legend_dat$inspection_status_color
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
