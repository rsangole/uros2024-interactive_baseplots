navmenu_fundamentals <- function() {
    navbarMenu(
        "Fundamentals",
        nav_panel(
            "A basic plot",
            fluidPage(
                layout_columns(
                    col_widths = c(4, 8),
                    tagList(
                        card(
                            plotOutput(
                                outputId = "scatter_plot",
                                height = 400,
                                click = clickOpts(id = "plot_click"),
                                dblclick = dblclickOpts(id = "plot_dblclick"),
                                hover = hoverOpts(id = "plot_hover"),
                                brush = brushOpts(id = "plot_brush"),
                            ),
                            em("34,513 meteorite landings from 2015-2023"),
                            em("Source: The Meteoritical Society"),
                            fill = FALSE
                        ),
                        uiOutput("basicplot_UIcode"),
                        uiOutput("basicplot_Servercode")
                    ),
                    layout_columns(
                        col_widths = 1 / 4,
                        card(code("str(input$plot_click)"), verbatimTextOutput("click_info"), fill = FALSE),
                        card(code("str(input$plot_dblclick)"), verbatimTextOutput("dblclick_info"), fill = FALSE),
                        card(code("str(input$plot_hover)"), verbatimTextOutput("hover_info"), fill = FALSE),
                        card(code("str(input$plot_brush)"), verbatimTextOutput("brush_info"), fill = FALSE)
                    )
                )
            )
        ),
        nav_panel(
            "A basic image",
            fluidPage(
                layout_columns(
                    col_widths = c(4, 8),
                    tagList(
                        card(
                            plotOutput(
                                outputId = "erat_img",
                                width = 600,
                                height = 600,
                                click = clickOpts(id = "img_click"),
                                dblclick = dblclickOpts(id = "img_dblclick"),
                                hover = hoverOpts(id = "img_hover"),
                                brush = brushOpts(id = "img_brush"),
                            ),
                            fill = FALSE,
                            max_height = 700
                        ),
                        em("Vase Painting of Selene and Her Horses, Brygos Painter, c. 490 BCE."),
                        em("Source: Ancient History Encyclopedia")
                    ),
                    layout_columns(
                        card(code("str(input$img_click)"), verbatimTextOutput("img_click_info")),
                        card(code("str(input$img_dblclick)"), verbatimTextOutput("img_dblclick_info")),
                        card(code("str(input$img_hover)"), verbatimTextOutput("img_hover_info")),
                        card(code("str(input$img_brush)"), verbatimTextOutput("img_brush_info"))
                    )
                )
            )
        ),
        nav_panel(
            "A faceted plot",
            fluidPage(
                layout_columns(
                    col_widths = c(6, 6),
                    tagList(
                        card(
                            plotOutput(
                                outputId = "exoplanets_plot",
                                width = 600,
                                height = 600,
                                click = clickOpts(id = "exoplanets_click"),
                                dblclick = dblclickOpts(id = "exoplanets_dblclick"),
                                hover = hoverOpts(id = "exoplanets_hover"),
                                brush = brushOpts(id = "exoplanets_brush")
                            ),
                            fill = FALSE,
                            max_height = 700
                        ),
                        em("36,278 Exoplanets discovered from 2013-2024"),
                        em("Source: NASA Exoplanet Archive"),
                        shinyWidgets::prettyCheckbox("show_bg", "Show Starmap", FALSE)
                    ),
                    card(code("str(input$exoplanets_dblclick)"), verbatimTextOutput("exoplanets_dblclick_info"))
                )
            )
        ),
        nav_panel(
            "Data lookup",
            fluidPage(
                inputPanel(
                    sliderInput("max_distance", "Max distance (pixels)",
                        min = 1, max = 20, value = 5, step = 1, ticks = FALSE
                    ),
                    sliderInput("max_points", "Max rows",
                        min = 1, max = 100, value = 100, step = 1, ticks = FALSE
                    )
                ),
                fluidRow(
                    shiny::column(
                        width = 4,
                        plotOutput(
                            outputId = "lookup_plot",
                            height = 300,
                            click = clickOpts(id = "lookup_click"),
                            dblclick = dblclickOpts(id = "lookup_dblclick"),
                            hover = hoverOpts(id = "lookup_hover"),
                            brush = brushOpts(id = "lookup_brush")
                        )
                    ),
                    shiny::column(
                        width = 4,
                        uiOutput("lookup_click_UIcode"), # , fill = FALSE),
                    ),
                    column(
                        width = 4,
                        uiOutput("lookup_brush_UIcode") # , fill = FALSE)
                    )
                ),
                fluidRow(
                    navset_tab(
                        nav_panel(
                            title = "Clicked Points",
                            card(reactable::reactableOutput("table_clicked_points"))
                        ),
                        nav_panel(
                            title = "Brushed Points",
                            card(reactable::reactableOutput("table_brushed_points"))
                        )
                    )
                )
            )
        )
    )
}
