% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_genes.R
\name{filter_genes}
\alias{filter_genes}
\title{Filter genes considered for compute_localization by mutation frequency, fraction of nonsynonymous mutations, and negative correlations between expression and mutation data}
\usage{
filter_genes(
  TDAmut_object,
  freq_threshold = 0.02,
  top_nonsyn_fraction = 350,
  upper_correlations_threshold = 0.9,
  lower_correlations_threshold = 1e-04
)
}
\arguments{
\item{TDAmut_object}{object of class TDAmut with expression data, mutation data, nerve complexes}

\item{freq_threshold}{threshold mutation frequency. Genes below this value are not considered in analysis. By default is 0.02}

\item{top_nonsyn_fraction}{number of genes to keep with greatest nonsyn/nonsyn+syn fraction. By default is 350.}

\item{upper_correlations_threshold}{upper q value theshold to keep genes displaying positive correlations between mutation and expression data. Genes with a median q value across all complexes exceeding this threshold are considered for further analysis. By default is 0.9.}

\item{lower_correlations_threshold}{lower q value theshold to keep genes displaying negative correlations between mutation and expression data. Genes with a median q value across all complexes below this threshold are considered for further analysis. By default is 1e-4.}
}
\value{
Returns a TDAmut object populated with filtered genes to consider in compute_gene_localization. Optionally returns p and q values quantifying negative correlations between expression and mutation profiles of filtered genes.
}
\description{
Filter genes considered for compute_localization by mutation frequency, fraction of nonsynonymous mutations, and negative correlations between expression and mutation data
}
