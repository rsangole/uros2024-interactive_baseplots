ts_UI <- function(id) {
    ns <- NS(id)
    nav_panel(
        title = "Plot",
        shiny::sidebarLayout(
            sidebarPanel = shiny::sidebarPanel(
                width = 3,
                tagList(
                    # fluidPage(
                    #     tags$style(
                    #         type = "text/css",
                    #         ".selectize-input {font-size: 13px; line-height: 13px;}
                    #                                                 .selectize-dropdown { font-size: 13px; line-height: 13px; } .filter-option-inner-inner {font-size: 13px; line-height: 13px;} .shiny-date-range-input {font-size: 13px; line-height: 13px;}"
                    #     ),
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
                    shiny::tableOutput(outputId = ns("labeler_metatable"))
                )
                # )
            ),
            mainPanel = shiny::mainPanel(
                width = 9,
                tagList(
                    shiny::plotOutput(
                        ns("labeler_plot_tsplot"),
                        brush = brushOpts(
                            id = ns("user_brush")
                            # direction = plotopts$brush_direction
                        ),
                        dblclick = ns("user_dblclick"),
                        height = "390px"
                    ),
                    # shiny::uiOutput(ns("tsplot"), inline = T),
                    shiny::uiOutput(ns("tsplot_zoomed"), inline = T)
                    # DT::dataTableOutput(outputId = "DT_selectionpreview")
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

            plotopts <- shiny::reactiveValues(
                # labeler_chkbox_plotopts = c("Show Legend"),
                brush_direction = "xy",
                brush_direction_zoomed = "xy"
            )

            arrow_df <- shiny::reactive({
                arrow::open_dataset("data/arrow")
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

            output$labeler_plot_tsplot <- shiny::renderPlot(
                {
                    dat <- filtered_data()
                    par(mar = c(3, 2, 0.2, 0.2)) # (bottom, left, top, right)
                    ts_plotter(
                        dat = dat,
                        plotopts = input$labeler_chkbox_plotopts
                        # grp_unique_list = input$selected_grps
                    )
                },
                res = 65
            )

            # output$tsplot <- shiny::renderUI({
            #     # shinycssloaders::withSpinner(
            #     shiny::plotOutput(
            #         ns("labeler_plot_tsplot"),
            #         brush = brushOpts(
            #             id = ns("user_brush"),
            #             direction = plotopts$brush_direction
            #         ),
            #         dblclick = ns("user_dblclick"),
            #         height = "390px"
            #     )
            #     # )
            # })

            output$tsplot_zoomed <- shiny::renderUI({
                # shinycssloaders::withSpinner(
                shiny::plotOutput(
                    ns("labeler_tsplot_zoomed"),
                    brush = brushOpts(
                        id = ns("user_brush_zoomed"),
                        direction = plotopts$brush_direction_zoomed
                    ),
                    dblclick = ns("user_dblclick_zoomed"),
                    height = "390px"
                )
                # )
            })

            shiny::observeEvent(input$user_dblclick, {
                if (plotopts$brush_direction == "xy") {
                    plotopts$brush_direction <- "x"
                } else {
                    plotopts$brush_direction <- "xy"
                }
            })

            shiny::observeEvent(input$user_dblclick_zoomed, {
                if (plotopts$brush_direction_zoomed == "xy") {
                    plotopts$brush_direction_zoomed <- "x"
                } else {
                    plotopts$brush_direction_zoomed <- "xy"
                }
            })

            selectedPoints <- shiny::reactive({
                shiny::brushedPoints(
                    df = filtered_data(),
                    brush = input$user_brush,
                    xvar = "ds",
                    yvar = "value"
                )
            })

            output$labeler_tsplot_zoomed <- shiny::renderPlot(
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
                            sprintf("%s/%s", length(input$selected_grps), length(metadata$grp_unique_list)),
                            scales::label_comma()(nrow(filtered_data())),
                            scales::label_comma()(nrow(selectedPoints()))
                        )
                    )
                },
                spacing = "s",
                colnames = FALSE,
                bordered = FALSE
            )

            # output$DT_selectionpreview <- DT::renderDT({
            #     shiny::req(input$user_brush)
            #     # shiny::req(input$user_brush_zoomed)
            #     dat <- selectedPoints_zoomed()
            #     if (nrow(dat) == 0) {
            #         dat <- selectedPoints()
            #     }
            #     DT::datatable(dat,
            #         autoHideNavigation = T,
            #         class = "cell-border compact",
            #         options = list(
            #             dom = "ft",
            #             deferRender = TRUE,
            #             scrollY = 100,
            #             scroller = TRUE
            #         ),
            #         extensions = "Scroller",
            #         caption = htmltools::tags$caption(
            #             style = "caption-side: bottom; text-align: center;",
            #             "", htmltools::em(paste0(dat[, .N], " points selected"))
            #         )
            #     ) %>%
            #         DT::formatDate(
            #             columns = metadata$col_list$datecol,
            #             method = "toISOString"
            #         )
            # })
        }
    )
}
