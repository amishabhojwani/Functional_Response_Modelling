# set start
# setwd("~/Documents/CMEECourseWork/CMEEMiniproject/Code")

#dependencies
require(minpack.lm)

# load data
data <- read.csv("../Data/CRat.csv")

print("Fitting three models per subset of data: quadratic, cubic and Holling Type II. For the last one we need to obtain optimal parameter estimates first. This will take about 7 minutes.")

# define function for the Holling type II model
Holl.type2 <- function(x, a, h) {
  (a*x)/(1+a*h*x)
}

AICc <- function(n, RSS, p) {
  n + 2 + n*log(2*pi/n) + n*log(RSS) + 2*p + (2*p^(2)+2*p)/(n-p-1)
}

BIC_calc <- function(n, RSS, p) {
  n + 2 + n*log(2*pi/n)+n*log(RSS)+p*log(n)
}

AIC_results <- matrix(ncol = 4)
colnames(AIC_results) <- c("ID", "AIC_lm2", "AIC_lm3", "AIC_HollT2")

BIC_results <- matrix(ncol = 4)
colnames(BIC_results) <- c("ID", "BIC_lm2", "BIC_lm3", "BIC_HollT2")

R2_results <- matrix(ncol = 4)
colnames(R2_results) <- c("ID", "Rsq_lm2", "Rsq_lm3", "Rsq_HollT2")

# fit all the models
for (iden in unique(data$ID)) {
  
  # load subsets of data and sample parameters for each data subset
  subdata <- read.csv(paste("../Data/data_subsets/subset_", iden, ".csv", sep=""))
  params <- read.csv(paste("../Results/sample_params/subset_",iden, "_sample_params.csv", sep = ""))
  
  # fit quadratic model
  try(lm2fit <- lm(N_TraitValue ~ poly(x=ResDensity, degree=2, raw = TRUE), data=subdata), silent = TRUE)
  
  # fit cubic model
  try(lm3fit <- lm(N_TraitValue ~ poly(x=ResDensity, degree=3, raw = TRUE), data=subdata), silent = TRUE)
  
  # fit the holling type II model for every sampled pair of parameters
  results_Holl2 <- matrix(ncol = 2) #write a results matrix for each subset, to be able to pick out the best fit
  colnames(results_Holl2) <- c("param_row", "AIC")
  
  # loop_counter <- 0
  for(ah.values in 1:nrow(params)) {
    # fit
    try({HollT2.fit <- nlsLM(N_TraitValue ~ Holl.type2(ResDensity, a, h), data = subdata, start = params[ah.values,], lower = c(0, 0), upper = c(5e08, 5e08), control = list(maxiter=100))}, silent = TRUE)
    
    # calculate AIC for these starting params
    n = nrow(subdata) #sample size
    pHollT2 = length(coef(HollT2.fit)) #number of parameters
    RSS_HollT2 = sum(residuals(HollT2.fit)^2) #residual sum of squares
    AIC = AICc(n, RSS_HollT2, pHollT2)
    
    # write results
    results_Holl2 <- rbind(results_Holl2, c(ah.values, AIC))
    # loop_counter <- loop_counter + 1
  }
  
  # output results
  results_Holl2 <- results_Holl2[-1,] #remove first row - superfluous
  row_best_params <- which.min(results_Holl2[,2])
  
  # the final fit for the Holling type II model and output a data frame with which to plot
  try({HollT2.fit <- nlsLM(N_TraitValue ~ Holl.type2(ResDensity, a, h), data = subdata, start = params[row_best_params[1],], lower = c(0, 0), upper = c(5e08, 5e08), control = list(maxiter=100))}, silent=TRUE) 
  testDens <- seq(min(subdata$ResDensity), max(subdata$ResDensity), (abs(max(subdata$ResDensity))-abs(min(subdata$ResDensity)))/500)
  Pred.HollT2 <- Holl.type2(testDens, coef(HollT2.fit)["a"], coef(HollT2.fit)["h"])

  sub_df <- data.frame(testDens, Pred.HollT2)
  names(sub_df) <- c("ResDensity", "N_TraitValue")
  
  write.csv(sub_df, paste("../Results/HollT2_plotting_dfs/HollT2_dfplot_subset_", iden, ".csv", sep=""), row.names = FALSE) #plotting df
  
  # compare the models and output to results table
  n = nrow(subdata)
  TSS_data = sum((subdata$N_TraitValue - mean(subdata$N_TraitValue))^2) #total sum of squares in data
  
  RSS_lm2 = sum(residuals.lm(lm2fit)^2) #residual sums of squares for each model that has been fitted
  RSS_lm3 = sum(residuals.lm(lm3fit)^2)
  RSS_HollT2 = sum(residuals(HollT2.fit)^2)
  
  plm2 = length(coef(lm2fit)) #number of coefficients for each model fitted
  plm3 = length(coef(lm3fit))
  pHollT2 = length(coef(HollT2.fit))
  
  Rsq_lm2 = summary(lm2fit)[["r.squared"]] #comparing models using R squared
  Rsq_lm3 = summary(lm3fit)[["r.squared"]]
  Rsq_HollT2 = 1 - (RSS_HollT2/TSS_data)
  
  AIC_lm2 <- AICc(n, RSS_lm2, plm2) #comparing models using AICc
  AIC_lm3 <- AICc(n, RSS_lm3, plm3)
  AIC_HollT2 <- AICc(n, RSS_HollT2, pHollT2)
  
  BIC_lm2 <- BIC_calc(n, RSS_lm2, plm2) #comparing models using BIC
  BIC_lm3 <- BIC_calc(n, RSS_lm3, plm3)
  BIC_HollT2 <- BIC_calc(n, RSS_HollT2, pHollT2)
  
  AIC_results <- rbind(AIC_results, c(iden, AIC_lm2, AIC_lm3, AIC_HollT2))
  BIC_results <- rbind(BIC_results, c(iden, BIC_lm2, BIC_lm3, BIC_HollT2))
  R2_results <- rbind(R2_results, c(iden, Rsq_lm2, Rsq_lm3, Rsq_HollT2))
  
}

# output results
AIC_results <- AIC_results[-1,]
write.csv(AIC_results, "../Results/model_selection/AIC_results.csv", row.names = FALSE)

BIC_results <- BIC_results[-1,]
write.csv(BIC_results, "../Results/model_selection/BIC_results.csv", row.names = FALSE)

R2_results <- R2_results[-1,]
write.csv(R2_results, "../Results/model_selection/Rsq_results.csv", row.names = FALSE)

print("Output 3 results tables as .csv files in ../Results/model_selection.")
