% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_mx_discordance.R
\name{plot_mx_discordance}
\alias{plot_mx_discordance}
\title{Visualize Otsu discordance scores by marker and slide}
\usage{
plot_mx_discordance(mx_data)
}
\arguments{
\item{mx_data}{\code{mx_dataset} object that been used with \code{run_otsu_discordance()} to compute Otsu discordance scores. Note that the table attribute must be set when running \code{run_otsu_discordance()}.}
}
\value{
\code{ggplot2} object with Otsu discordance scores plot
}
\description{
Visualize Otsu discordance scores by marker and slide
}
\examples{
mx_data = mx_dataset(mxnorm::mx_sample, "slide_id", "image_id",
  c("marker1_vals","marker2_vals","marker3_vals"),
  c("metadata1_vals"))
mx_data = mx_normalize(mx_data, transform="log10",method="None")
## using `threshold_override` here in case users haven't installed `scikit-image`
mx_data = run_otsu_discordance(mx_data, table="normalized",
threshold_override = function(thold_data){quantile(thold_data, 0.5)})
plot_mx_discordance(mx_data)
}
