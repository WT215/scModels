% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{chf_1F1}
\alias{chf_1F1}
\title{Kummer's (confluent hypergeometric) function}
\usage{
chf_1F1(x, a, b)
}
\arguments{
\item{x}{numeric value or vector}

\item{a, b}{numeric parameters of the Kummer function}
}
\description{
Kummer's function (also: confluent hypergeometric function of the first kind)
for numeric (non-complex) values and input parameters.
}
\examples{
x <- chf_1F1(-100:100, 5, 7)
plot(-100:100, x, type='l')
}
