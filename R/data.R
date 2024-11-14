#' Example time series data.table
#'
#' A data.table containing time-series data for 64 groups for a period
#' of Jan-01 to Nov-15 at a 1-hour interval.
#'
#' @format A data frame with 489088 rows and 5 variables:
#' \describe{
#'   \item{ds}{date-time, POSIXct, UTC}
#'   \item{.grp}{group variable, like keys in a `tsibble`}
#'   \item{value}{numeric measure of the time series}
#'   \item{.anomaly}{0/1 indicating presence of an anomaly}
#'   \item{.tag}{string tagging anomaly. empty string if anomaly=0}
#' }
"large_timeseries"
