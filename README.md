This directory contains subdirectories for my project on a functional response dataset titled "Holling's disc equation outperforms quadratic and cubic linear models regardless of AIC cut-off threshold". In the Code subdirectory are all the Rscripts that will output results to the Results and Data subdirectories. To run the project and generate the report enter the following command in a linux terminal from the Code directory:

	bash compiler.sh

I will now specify what each file of the Code and Data subdirectories do and what their dependencies are:

Code:
- CompileLatex.sh - shell script that compiles a references latex file
- compiler.sh - shell script to compile this project. Runs the analysis R scripts and makes directories to house their output. Uses the texcount Perl script to count the words in the report and then compiles the report pdf to store it in the Code subdirectory
- data_prep.R - Rscript to subset the data amd output subset .csv's to Data/data_subsets
- model_fitting.R - Rscript that performs OLS and NLLS model fitting for each subset of data and uses estimated and sampled starting values from Results/sample_params. DEPENDENCIES: minpack.lm package
- plotting.R - Rscript that performs model selection and plots the fits of each model to each subset to store these in Results/plots. Also outputs two .csv tables and a .pdf to be included in the report to Results/output_tables. DEPENDENCIES: ggplot2 package 
- report.bib - contains BibTeX of references used in the report
- report.tex - Latex file in which i wrote the report. DEPENDENCIES: packes used are lineno, graphicx, setspace, amsmath, csvsimple, booktabs, tocbibind, caption 
- starting_values.R - Rscript that calculates parameter estimates and samples them. Outputs them per subset to Results/sample_params
- texcount.pl - Perl script to count the words in a Latex file
- wordcount.txt - the compile.sh script makes the output of texcount.pl feed into this .txt file

Data:
- BiotraitsTemplateDescription.pdf - a description of all the metadata fields in the dataset used for the project
- CRat.csv - the dataset used for the project

Languages and versions used:

	R version 4.0.3
	pdfTeX version 3.14159265-2.6-1.40.20 (TeX Live 2019/Debian)
	Perl version v5.30.0
	GNU bash version 5.0.17(1)
