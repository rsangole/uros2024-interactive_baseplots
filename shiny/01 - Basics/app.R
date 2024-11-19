library(shiny)
library(shinyWidgets)
library(bslib)
library(dplyr)
library(ggplot2)

lapply(fs::dir_ls(here::here("shiny/01 - Basics/R")), source)

meteorites <- data.table::fread(here::here("data/Meteorite_Landings_20241116.csv")) |>
    janitor::clean_names() |>
    dplyr::arrange(mass_g)
comets <- data.table::fread(here::here("data/comets.csv")) |>
    janitor::clean_names()
exoplanets <- qs2::qs_read(here::here("data/exoplanets.qs2"))


# UI ----
ui <- navbarPage(
    "Interactivity with Base R",
    tabPanel("Intro"),
    tabPanel("Motivation"),
    navmenu_fundamentals()
)


# Server ----
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
            path <- here::here("shiny/01 - Basics/images/selene.png")
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
        exoplanets |>
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
            facet_wrap(~discoverymethod, nrow=4) +
            theme(legend.position = "none") +
            scale_x_continuous(limits = c(0, 360), labels = \(x){
                sprintf("%s°", x)
            }) +
            scale_y_continuous(limits = c(-90, 90), labels = \(x){
                sprintf("%s°", x)
            }) +
            labs(
                x = "Right Ascension",
                y = "Declination"
                # title = "Exoplanets discovered by Transit, Radial Velocity, Transit Timing Variations, and Microlensing"
            )
    })
    # output$spacex_click_info <- renderPrint({
    #     str(isolate(input$spacex_click))
    # })
    output$exoplanets_dblclick_info <- renderPrint({
        str(input$exoplanets_dblclick)
    })
    # output$spacex_hover_info <- renderPrint({
    #     str(input$spacex_hover)
    # })
    # output$spacex_brush_info <- renderPrint({
    #     str(input$spacex_brush)
    # })
}

shinyApp(ui = ui, server = server)
