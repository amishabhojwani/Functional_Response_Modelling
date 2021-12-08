# set start
# setwd("~/Documents/CMEECourseWork/CMEEMiniproject/Code")

# load data
data <- read.csv("../Data/CRat.csv")

##########################################################
# get sample params for every subset to fit HollT2 model #
##########################################################

#if parameter estimate is negative, set it to 0
set0 <- function(number) {
  if(number < 0) number = 0
  return(number)
}

success_counter <- c()
for (iden in unique(data$ID)) {
  
  # load subset
  subdata <- read.csv(paste("../Data/data_subsets/subset_", iden, ".csv", sep=""))
  
  #calculate Fmax and Nhalf according to Rosenbaum 2018 (where q=0)
  Fmax=max(subdata$N_TraitValue)
  halfFmax.index=which.min(abs(subdata$N_TraitValue-(Fmax/2)))
  Nhalf=subdata$ResDensity[halfFmax.index]
  
  # calculate parameter estimates
  h.est=1/Fmax
  a.est=Fmax/Nhalf
  
  # sample the estimates
  a = runif(1000, min = a.est - abs(a.est), max = a.est + abs(a.est))
  h = runif(1000, min = h.est - abs(h.est), max = h.est + abs(h.est))
  
  for (i in 1:length(a)) set0(i) #there cannot be negative parameters so we set negative values to 0
  for (i in 1:length(h)) set0(i)
  
  sample.params = cbind(a, h) #output parameters table
  write.csv(sample.params, paste("../Results/sample_params/subset_", iden, "_sample_params.csv", sep=""), row.names = FALSE)
  success_counter <- append(success_counter, iden)
}

# check which subsets have failed
IDs <- unique(data$ID)
failed_subsets <- setdiff(IDs, success_counter)

if (length(failed_subsets)==0) { #feedback
  print("Computed sample parameters for all the subsets in ../Results/sample_params")
} else { print(paste("Failed to compute sample parameters for the following subsets:", failed_subsets, sep = "")) }