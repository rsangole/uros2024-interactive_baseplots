ts_UI <- function(id) {
    ns <- NS(id)
    tabPanel(
        title = "Plot",
        shiny::sidebarLayout(
            sidebarPanel = shiny::sidebarPanel(
                width = 3,
                tagList(
                    shinyWidgets::pickerInput(
                        inputId = ns("selected_grps"),
                        label = "Group",
                        choices = paste("Group", 1:64),
                        selected = "Group 1",
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
                    shinyWidgets::awesomeCheckboxGroup(
                        inputId = ns("labeler_chkbox_plotopts"),
                        label = "",
                        choices = c(
                            # "Show Anomalies",
                            "Show Legend"
                        ),
                        status = "danger"
                    ),
                    radioButtons(ns("brush_direction"),
                        "Brush direction", c("xy", "x"),
                        inline = TRUE
                    ),
                    shiny::tableOutput(outputId = ns("labeler_metatable"))
                )
                # )
            ),
            mainPanel = shiny::mainPanel(
                width = 9,
                tagList(
                    shiny::uiOutput(ns("tsplot_ui"), inline = T),
                    shiny::uiOutput(ns("tsplot_zoomed_ui"), inline = T),
                    reactable::reactableOutput(ns("dt_selectedpoints"))
                )
            )
        )
    )
}



ts_server <- function(id) {
    ns <- NS(id)
    moduleServer(
        id,
        function(input, output, session) {
            metadata <- shiny::reactiveValues(
                tag_values = NULL,
                tag_choices = NULL,
                total_pts = NULL,
                total_grps = NULL,
                count_existing_anomalies = NULL,
                grp_unique_list = NULL,
                col_list = NULL,
                tag_selected = NULL,
                grp_selected = NULL,
                tag_color = NULL,
                pts_selected_grps = NULL
            )

            arrow_df <- shiny::reactive({
                arrow::open_dataset(here::here("data/arrow"))
            })

            filtered_data <- shiny::eventReactive(input$btn_selectgrp, {
                out <- arrow_df() |>
                    dplyr::filter(grp %in% input$selected_grps) |>
                    dplyr::collect() |>
                    dplyr::arrange(grp, ds)

                metadata$tag_choices <- out |>
                    dplyr::distinct(tag) |>
                    dplyr::filter(tag != "") |>
                    dplyr::pull()

                out
            })

            output$plot_ts <- shiny::renderPlot(
                {
                    dat <- filtered_data()
                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    ts_plotter(
                        dat = dat,
                        plotopts = input$labeler_chkbox_plotopts
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
                    height = "390px"
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
                    height = "390px"
                )
            })

            selectedPoints <- shiny::reactive({
                shiny::brushedPoints(
                    df = filtered_data(),
                    brush = input$user_brush,
                    xvar = "ds",
                    yvar = "value"
                )
            })

            selectedPoints_zoomed <- shiny::reactive({
                shiny::brushedPoints(
                    df = selectedPoints(),
                    brush = input$user_brush_zoomed,
                    xvar = "ds",
                    yvar = "value"
                )
            })

            output$plot_tszoomed <- shiny::renderPlot(
                {
                    shiny::req(selectedPoints())
                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    ts_plotter(
                        dat = selectedPoints(),
                        plotopts = input$labeler_chkbox_plotopts
                    )
                },
                res = 65
            )

            output$labeler_metatable <- shiny::renderTable(
                {
                    shiny::req(filtered_data())
                    tibble::tibble(
                        Parameter = c(
                            "# Groups",
                            "# Pts Above",
                            "# Pts Below"
                        ),
                        Value = c(
                            sprintf("%s/64", length(input$selected_grps)),
                            scales::label_comma()(nrow(filtered_data())),
                            scales::label_comma()(nrow(selectedPoints()))
                        )
                    )
                },
                spacing = "s",
                colnames = FALSE,
                bordered = FALSE
            )

            output$dt_selectedpoints <- reactable::renderReactable({
                shiny::req(input$user_brush)
                shiny::req(input$user_brush_zoomed)
                shiny::req(selectedPoints())
                dat <- selectedPoints_zoomed()

                reactable::reactable(
                    dat,
                    compact = TRUE,
                    searchable = FALSE,
                    filterable = FALSE,
                    bordered = TRUE,
                    defaultPageSize = 5
                )
            })
        }
    )
}
