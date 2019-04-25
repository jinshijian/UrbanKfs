#' Predict soil conductivity for a set of bootstrapped models
#'
#' @param data Soil structure data for prediction. Must be a
#'   `data.frame` with columns `Percent_Sand`, `Percent_Silt`,
#'   `Percent_Clay`, and `Top_Type`.
#' @param fitted_models Nested `data.frame` containing fitted models.
#'   Default is package data.
#' @return Nested `data.frame` of predicted soil conductivities for
#'   each model sample.
#' @author Alexey Shiklomanov
#' @export
#' @examples
#' df <- data.frame(
#'   Percent_Sand = c(14, 15, 18, 18),
#'   Percent_Silt = c(63, 15, 59, 60),
#'   Percent_Clay = c(23, 70, 23, 22),
#'   Top_Type = rep("blocky", 4),
#'   stringsAsFactors = FALSE
#' )
#' raw_pred <- predict_bootstrap(df)
#' # Tidy summary
#' summary(raw_pred)
predict_bootstrap <- function(data, fitted_models = fitted_models) {
  cols <- colnames(data)
  need_cols <- c(
    paste0("Percent_", c("Sand", "Silt", "Clay")),
    "Top_Type"
  )
  missing_cols <- setdiff(need_cols, cols)
  if (length(missing_cols) > 0) {
    stop("Missing the following columns: ",
         paste(missing_cols, collapse = ", "))
  }

  data_sub <- data %>%
    dplyr::select(need_cols) %>%
    dplyr::mutate(Top_Type = factor(Top_Type, soil_type_levels()))
  n_na <- is.na(data_sub[["Top_Type"]])
  if (any(n_na)) {
    warning("Found ", sum(n_na), " NA values in `Top_Type` after coercing to factor. ",
            "Only soil types in `soil_type_levels()` are supported (see also `soil_types()`). ",
            "Dropping NA levels.")
    data_sub <- dplyr::filter(data_sub, !is.na(Top_Type))
  }
  out <- fitted_models %>%
    dplyr::mutate(
      data = list(data_sub),
      predicted = purrr::map(model_fit, predict, newdata = data_sub)
    )
  class(out) <- c("urbankfs_prediction", class(out))
  out
}

#' Summary method for output of [predict_bootstrap()].
#'
#' @param object Output of [predict_bootstrap()]
#' @param quantiles Numeric vector of quantiles for summary
#'   statistics. Default = `c(0.05, 0.5, 0.95)`.
#' @return `data.frame` of prediction summaries
summary.urbankfs_prediction <- function(object, quantiles = c(0.05, 0.5, 0.95), ...) {
  qfuns <- purrr::map(quantiles, ~purrr::partial(quantile, probs = .x))
  names(qfuns) <- sprintf("q%03.f", quantiles * 1000)
  object %>%
    tidyr::unnest(data, predicted) %>%
    dplyr::group_by_at(dplyr::vars(-sample, -predicted)) %>%
    dplyr::summarize_at(dplyr::vars(predicted), rlang::list2(
      mean = mean,
      sd = sd,
      !!!qfuns))
}