% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/jian_models.R
\name{predict.urbankfs_ann}
\alias{predict.urbankfs_ann}
\title{\code{predict} method for \code{neuralnet} output}
\usage{
\method{predict}{urbankfs_ann}(object, newdata, ...)
}
\arguments{
\item{object}{Object of class inheriting from \code{"lm"}}

\item{newdata}{An optional data frame in which to look for variables with
    which to predict.  If omitted, the fitted values are used.}

\item{...}{Additional arguments to \code{\link[neuralnet:compute]{neuralnet::compute()}}}
}
\description{
\code{predict} method for \code{neuralnet} output
}
\seealso{
fit_jian_ann
}
