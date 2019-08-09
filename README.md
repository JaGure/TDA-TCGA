# TCGA-TDA
Pipeline for the identification of novel driver genes using TDA on TCGA data used in:

Rabadan R, Mohamedi Y, Rubin U, Chu T, Elliott O, Ares L, Cal S, Obaya AJ, Levine AJ, and Camara PG, _"Identification of Relevant Genetic Alterations in Cancer using Topological Data Analysis"_. Submitted.

The pipeline currently consists on the sequential application of several scripts located in the folder ```Scripts```. The scripts `tpm_matrix.R`, `maf_process3.R`, and `Big_matrix.R` pre-process the expression and mutation data and summarizes them into tables that can be taken by `ayasdi_test.py` and `connectivity8.R`, which implement the actual algorithm. 

### tpm_matrix.R

This script is used to convert a set of RSEM expression files (one for each tumor sample) into an expression table. It takes the following parameters:

       -d  Specifies the name of the folder containing the RSEM expression files (for example `LUAD/RSEM`)
       -i  Specifies the name of the index file (e.g. `sdrf.txt`) listing all the RSEM files
       -p  Specifies the name of the cohort (for exaple `LUAD`)
       -a  Specifies the path to the file `Annotations.csv` (provided in the folder `Annotations` of this repository)
       -o  Specifies the path to the file `Anno_old_new.csv` (provided in the folder `Annotations` of this repository)
       
The output of `tpm_matrix.R` is a `csv` file (`*_Full_TPM_matrix.csv`) containing the expression table of the cohort.

### maf_process3.R

This script is used to convert a set of Onconator files (e.g. downloaded from Firehose Broad GDAC) into mutation tables. It takes the following arguments:

       -f  Specifies the path to a 'tar.gz' file containing the Onconator files
       -p  Specifies the name of the cohort (for exaple `LUAD`)

The output of `maf_process3.R` is three `csv` files (`*_Full_Mutations_synonymous.csv`, `*_Full_Mutations_non_synonymous.csv`, and `*_Full_Mutations_binary.csv`). `*_Full_Mutations_synonymous.csv` is a table containing the number of synonymous somatic mutations in each gene and sample; `*_Full_Mutations_non_synonymous.csv` is a table containing the number of non-synonymous somatic mutations in each gene and sample; and `*_Full_Mutations_binary.csv` is a binary table indicating whether each gene is non-synonymously mutated or not for all genes and samples. In addition, it produces a combined `*.maf` file for the cohort.

### Big_matrix.R

This script is used to combine the outputs of `tpm_matrix.R` and `maf_process3.R` into a single file. It takes the following arguments:

       -e  Specifies the path to the file `*_Full_TPM_matrix.csv` generated by `tpm_matrix.R`
       -b  Specifies the path to the file `*_Full_Mutations_binary.csv` generated by `maf_process3.R`
       -s  Specifies the path to the file `*_Full_Mutations_synonymous.csv` generated by `maf_process3.R`
       -n  Specifies the path to the file `*_Full_Mutations_non_Synonymous.csv` generated by `maf_process3.R`

The outputs are the files `*.h5` and `*_BIG_matrix.csv` containing combined tables that can be used by `ayadi_test.py` and `connectivity8.R`.

### ayasdi_test.py

This script uses the implementation of the Mapper algorithm in the software Ayasdi to generate network representations of the expression space of the cohort across the parameter space of Mapper. It takes as input the name of the analysis (specified by the `-p` argument in `tpm_matrix.R` and `maf_process3.R`) and the combined input table `*_BIG_matrix.csv` generated by `Big_matrix.R`. For instance,

```python ayasdi_test.py LUAD ./LUAD_BIG_matrix.csv```

We expect to release a version of this script based on the R package `TDAmapper` in the near future.

### connectivity8.R

This script can be used in two different different modes. In the mode `--mutload TRUE` it assesses the amount of localization of the mutational load in the expression networks generated by `ayasdi_test.py`. In this mode, the script takes the following parameters:

       -p  Specifies the number of permutations used in the permutation test to asses the significance of the mutational load localization (see the reference above for details)
       -m  Specifies the path to the `*.h5` file generated by `Big_matrix.R`

In the mode `--mutload FALSE`, the script assess the amount of localization of each non-synonymously mutated gene in the expression networks generated by `ayasdi_test.py`. In this mode, the script takes the dollowing parameters:

       -p  Specifies the number of permutations used in the permutation test to asses the significance of the mutational load localization (see the reference above for further details)
       -m  Specifies the path to the `*.h5` file generated by `Big_matrix.R`
       -q  Specifies the number of threads used by the script.
       -t  Specifies a threhold in the mutation frequency. Genes that are somatically mutated in a fraction of patients smaller than this threshold are not considered in the analysis.
       -r  Specifies a threshold in log10 scale for downsampling mutations. If specified, mutations in tumors that have more mutations than this threshold are downsampled (see the reference above for further details). 
       --maf  Specifies the path to the `*.maf` file generated by `maf_process3.R`
       -g  Specifies a threshold on the number of genes with highest ratio between non-synonymous and total number of mutations to be considered in the analysis.

Parameter choice guidelines:

- For cohorts consisting of hundreds to few thousands of tumors, 10,000 permutations typically provides enough accuracy in the estimation of p-values. Increassing the number of permutations will increase the accuracy, but will also substantially increase the running time and memory usage.

- To avoid a too large correction from multiple hypothesis testing it is recommented to use the parameters `-t` and `-g` to limit the number of tumors considered in the analysis. In general, `-r 350` is a reasonable choice for most cases. Having `-r` larger than 350 can lead to large corrections that reduce the sensitivity of the algorithm.

- The choice of `-t` wil depend on the size of the cohort. For cohorts with a few thousands of tumors, `-t 0.01` is a reasonable choice. For cohorts with a few hundreds of tumors, `-t 0.05` is a reasonable choice.

- The parameter `-r` should be only used in cohorts containing both hypermutated and not-hypermutated tumors. In those cases, its value should be set such that the threshold separates hyper-muated from non-hypermutated tumors based on their total number of mutations.

