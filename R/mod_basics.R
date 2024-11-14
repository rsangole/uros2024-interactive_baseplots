basics_UI <- function(id) {
    ns <- NS(id)
    navset_card_pill(
        nav_panel(
            title = "Plot",
            bslib::layout_column_wrap(
                width = 1 / 2,
                plotOutput(ns("scatter_plot"),
                    height = 350,
                    click = clickOpts(id = ns("plot_click")),
                    dblclick = dblclickOpts(id = ns("plot_dblclick")),
                    hover = hoverOpts(id = ns("plot_hover")),
                    brush = brushOpts(id = ns("plot_brush"))
                ),
                column(
                    width = 12,
                    verbatimTextOutput(ns("click_info")),
                    verbatimTextOutput(ns("dblclick_info"))
                )
            ),
            # fluidRow(
            #     column(
            #         width = 3,
            #         verbatimTextOutput(ns("click_info"))
            #     ),
            #     column(
            #         width = 3,
            #         verbatimTextOutput(ns("dblclick_info"))
            #     ),
            #     column(
            #         width = 3,
            #         verbatimTextOutput(ns("hover_info"))
            #     ),
            #     column(
            #         width = 3,
            #         verbatimTextOutput(ns("brush_info"))
            #     )
            # )
        ),
        nav_panel(title = "Code", "Panel 2 content")
    )
}

basics_server <- function(id) {
    ns <- NS(id)
    moduleServer(
        id,
        function(input, output, session) {
            output$scatter_plot <- renderPlot({
                plot(mtcars$wt, mtcars$mpg)
            })

            output$click_info <- renderPrint({
                cat("input$plot_click:\n")
                str(input$plot_click)
            })
            output$hover_info <- renderPrint({
                cat("input$plot_hover:\n")
                str(input$plot_hover)
            })
            output$dblclick_info <- renderPrint({
                cat("input$plot_dblclick:\n")
                str(input$plot_dblclick)
            })
            output$brush_info <- renderPrint({
                cat("input$plot_brush:\n")
                str(input$plot_brush)
            })
        }
    )
}
