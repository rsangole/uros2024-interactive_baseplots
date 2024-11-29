#' ts plotter for labeler tab
#'
#' (Internal function)
#'
#' @param dat selected/zoomed dataframe
#' @param plotopts plot options like grp and anomaly legends
#' @param colors tag colors
#' @param col_list column list
#' @param grp_unique_list unique group list
#'
#' @return plot object
#' @importFrom graphics axis legend lines plot points
ts_plotter <- function(
    dat,
    plotopts,
    colors = c(
        "#f94144ff",
        "#f3722cff",
        "#f8961eff",
        "#f9844aff",
        "#f9c74fff",
        "#90be6dff",
        "#43aa8bff",
        "#4d908eff",
        "#577590ff",
        "#277da1ff"
    ),
    tag_choices_df) {
    grps <- unique(dat$grp)

    plot(
        dat[dat$grp == grps[1], "ds"][[1]],
        dat[dat$grp == grps[1], "value"][[1]],
        type = "l",
        ylim = c(
            min(dat$value, na.rm = T),
            max(dat$value, na.rm = T)
        ),
        xlab = "",
        ylab = "",
        yaxt = "n",
        col = colors[10]
    )

    y_at <- pretty(dat$value)
    y_label <- scales::label_comma()(y_at)
    axis(2, at = y_at, labels = y_label)

    if (length(grps) > 1) {
        for (i in 2:length(grps)) {
            lines(
                dat[dat$grp == grps[i], "ds"][[1]],
                dat[dat$grp == grps[i], "value"][[1]],
                type = "l",
                col = sample(colors, 1),
                lty = 1,
                lwd = 1.5
            )
        }
    }

    if ("Show Anomalies" %in% plotopts) {
        subdat <- dat |>
            dplyr::filter(tag != "") |>
            dplyr::filter(anomaly == 1)

        if (nrow(subdat) > 0) {
            points(
                x = subdat$ds,
                y = subdat$value,
                col = subdat$tag_color,
                pch = 19
            )
            legend(
                "topright",
                legend = tag_choices_df$tag,
                col = tag_choices_df$tag_color,
                bg = "white",
                pch = 19,
                lwd = 0
            )
        }

        # for (i in 1:length(grps)) {
        #     subdat <- dat |>
        #         dplyr::filter(grp == grps[i], anomaly == 1) |>
        #         dplyr::left_join(
        #             tag_color_df,
        #             by = "tag"
        #         )

        # }
        # if (length(tags) > 0) {
        #     legend(
        #         "topright",
        #         legend = tags,
        #         col = tag_colors,
        #         bg = "white",
        #         pch = 19,
        #         lwd = 0
        #     )
        # }
    }

    if ("Show Legend" %in% plotopts) {
        legend(
            "topleft",
            legend = grps,
            col = 1:length(grps),
            bg = "white",
            lwd = 2
        )
    }
}



# Wrap it into a function.
symbolsChart <- function(
    values,
    col = rep("black", length(values)),
    bar_width = round(.10 * max(values)),
    shape = "squares",
    border = "white") {
    max_val <- max(values)
    padding <- .15 * bar_width

    # Recyle colors if fewer specfied than there are values.
    if (length(col) < length(values)) {
        mult <- ceiling(length(values) / length(col))
        col <- rep(col, mult)
    }

    # Setup blank plot.
    xlim <- c(0, (bar_width + padding) * length(values))
    ylim <- c(0, ceiling(max_val / bar_width))
    plot(0, 0, type = "n", xlab = "", ylab = "", bty = "n", xlim = xlim, ylim = ylim, asp = 1, axes = FALSE)

    # Get coordinates for each element.
    for (i in 1:length(values)) {
        xleft <- (i - 1) * (bar_width + padding)
        num_rows <- ceiling(values[i] / bar_width)
        x <- rep(xleft:(xleft + bar_width - 1), num_rows)[1:values[i]]
        y <- rep(1:num_rows, each = bar_width)[1:values[i]]

        # Circles or squares.
        if (shape == "circles") {
            symbols(x, y, circles = rep(.5, length(x)), inches = FALSE, add = TRUE, bg = col[i], fg = border)
        } else {
            symbols(x, y, squares = rep(1, length(x)), inches = FALSE, add = TRUE, bg = col[i], fg = border)
        }
    }
}
