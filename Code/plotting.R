# set start
# setwd("~/Documents/CMEECourseWork/CMEEMiniproject/Code")

#dependencies
require(ggplot2)

# load data
data <- read.csv("../Data/CRat.csv")

count <- function(expression) {
  length(which(expression))
}

AIC_results <- read.csv("../Results/model_selection/AIC_results.csv", header = TRUE)
BIC_results <- read.csv("../Results/model_selection/BIC_results.csv", header = TRUE)
Rsq_results <- read.csv("../Results/model_selection/Rsq_results.csv", header = TRUE)

#global cutoffs with AIC
cutoff <- c() 
lowest_model_AIC <- c()
for (row in 1:nrow(AIC_results)) {
  sorted <- sort(AIC_results[row, 2:4], decreasing = TRUE)
  lowest_model_AIC <- append(lowest_model_AIC, colnames(sorted)[3])
  if (abs(sorted[2]-sorted[3]) > 6) { #if the lowest AIC value is more than 6 units smaller than the next lowest cutoff = 1 and this cutoff means the best model is only one. if it goes to the next else if, if change is <=6, it means that at if we consider a cutoff of 6 at least the two lowest AIC values are within the confidence set
    cutoff <- append(cutoff, 1)
  } else if (abs(sorted[2]-sorted[3]) > 2) {
    cutoff <- append(cutoff, 2) #if its more than 2 cutoff = 2 and this cutoff means the best model is only one. if it goes to the next else, if change is <=2 it means that at if we consider a cutoff of 2 at least the two lowest AIC values are within the confidence set
  } else cutoff <- append(cutoff, 0) #if its less than 2 cutoff = 0 and it means that this model and at least the one before it are in the confidence set
}

#what does the lowest AIC say WITHOUT a cutoff? how does cutoff affect each model?
AIC_lm2_success <- count(lowest_model_AIC=="AIC_lm2")/length(lowest_model_AIC)
AIC_lm3_success <- count(lowest_model_AIC=="AIC_lm3")/length(lowest_model_AIC)
AIC_HollT2_success <- count(lowest_model_AIC=="AIC_HollT2")/length(lowest_model_AIC)

#work WITH cutoff values for picking a best model in AIC GLOBALLY
cutoff6 <- count(cutoff==1)/length(cutoff)
cutoff2_6 <- count(cutoff==2)/length(cutoff) #differences between 2-6 in AIC values between models
cutoff2 <- (count(cutoff==2)+count(cutoff==1))/length(cutoff)

#what does the lowest AIC say WITH cutoff PER MODEL?
AIC_lm2_cutoff6 <- count(lowest_model_AIC=="AIC_lm2" & cutoff == 1)/length(lowest_model_AIC)
AIC_lm3_cutoff6 <- count(lowest_model_AIC=="AIC_lm3" & cutoff == 1)/length(lowest_model_AIC)
AIC_HollT2_cutoff6 <- count(lowest_model_AIC=="AIC_HollT2" & cutoff == 1)/length(lowest_model_AIC)
AIC_lm2_cutoff2 <- (count(lowest_model_AIC=="AIC_lm2" & cutoff == 2)+count(lowest_model_AIC=="AIC_lm2" & cutoff == 1))/length(lowest_model_AIC)
AIC_lm3_cutoff2 <- (count(lowest_model_AIC=="AIC_lm3" & cutoff == 2)+count(lowest_model_AIC=="AIC_lm3" & cutoff == 1))/length(lowest_model_AIC)
AIC_HollT2_cutoff2 <- (count(lowest_model_AIC=="AIC_HollT2" & cutoff == 2)+count(lowest_model_AIC=="AIC_HollT2" & cutoff == 1))/length(lowest_model_AIC)

#making an output table for AIC
AIClist_nocutoff <- list(Quadratic=AIC_lm2_success, Cubic=AIC_lm3_success, HollingT2=AIC_HollT2_success, Overall=1)
AIClist_cutoff6 <- list(Quadratic = AIC_lm2_cutoff6, Cubic = AIC_lm3_cutoff6, HollingT2 = AIC_HollT2_cutoff6, Overall = cutoff6)
AIClist_cutoff2 <- list(Quadratic = AIC_lm2_cutoff2, Cubic = AIC_lm3_cutoff2, HollingT2 = AIC_HollT2_cutoff2, Overall = cutoff2)
AIC_table <- cbind(unlist(AIClist_nocutoff), unlist(AIClist_cutoff2), unlist(AIClist_cutoff6))
AIC_table <- round(as.matrix(AIC_table), 2)
colnames(AIC_table) <- c("No cut-off", "Cut-off 2", "Cut-off 6")
write.csv(AIC_table, "../Results/output_tables/AIC_table.csv", quote = FALSE)

#analyse BIC
best_model_BIC <- c()
for (row in 1:nrow(BIC_results)) {
  sorted <- sort(BIC_results[row, 2:4], decreasing = TRUE)
  best_model_BIC <- append(best_model_BIC, colnames(sorted)[3])
}

BIC_lm2_success <- count(best_model_BIC=="BIC_lm2")/length(best_model_BIC)
BIC_lm3_success <- count(best_model_BIC=="BIC_lm3")/length(best_model_BIC)
BIC_HollT2_success <- count(best_model_BIC=="BIC_HollT2")/length(best_model_BIC)

#analyse Rsq
best_model_Rsq <- c()
for (row in 1:nrow(Rsq_results)) {
  sorted <- sort(Rsq_results[row, 2:4])
  best_model_Rsq <- append(best_model_Rsq, colnames(sorted)[3])
}

Rsq_lm2_success <- count(best_model_Rsq=="Rsq_lm2")/length(best_model_Rsq)
Rsq_lm3_success <- count(best_model_Rsq=="Rsq_lm3")/length(best_model_Rsq)
Rsq_HollT2_success <- count(best_model_Rsq=="Rsq_HollT2")/length(best_model_Rsq)

#output table for Rsq and BIC
Rsqlist <- list(Quadratic=Rsq_lm2_success, Cubic=Rsq_lm3_success, HollingT2=Rsq_HollT2_success)
BIClist <- list(Quadratic=BIC_lm2_success, Cubic=BIC_lm3_success, HollingT2=BIC_HollT2_success)
Rsq_BIC_table <- rbind(unlist(Rsqlist), unlist(BIClist))
Rsq_BIC_table <- round(as.matrix(Rsq_BIC_table), 2)
rownames(Rsq_BIC_table) <- c("R-squared", "BIC")
write.csv(Rsq_BIC_table, "../Results/output_tables/Rsq_BIC_table.csv", quote = FALSE)

# plotting
print("Plotting model curves on the data and saving pdf files for each subset. This will take about 1 minute.")
# pdf("../Results/plots/allplots.pdf")
for (iden in unique(data$ID)) {
  pdf(file = paste("../Results/plots/", iden,"_plot.pdf", sep="")) # write pdf with all plots

  subdata <- read.csv(paste("../Data/data_subsets/subset_", iden, ".csv", sep="")) # read full subset
  sub_df <- read.csv(paste("../Results/HollT2_plotting_dfs/HollT2_dfplot_subset_", iden, ".csv", sep="")) # read Holling subset
  
  p <- ggplot(subdata, aes(x=ResDensity, y=N_TraitValue)) + geom_point() +
    geom_smooth(data=sub_df, method=loess, formula = y ~ x, aes(x=ResDensity, y=N_TraitValue , colour = "green")) +
    geom_smooth(method = lm, formula = y ~ poly(x, degree = 2, raw = TRUE), se=FALSE, aes(colour = "blue")) +
    geom_smooth(method = lm, formula = y ~ poly(x, degree = 3, raw = TRUE), se=FALSE, aes(colour = "red")) +
    labs(x="Resource Density", y="Individual Trait Value", title = paste("Functional Response Models between ", sub("(\\w+\\s+\\w+).*", "\\1", subdata$ConTaxa[1]), " (consumer)\nand ", sub("(\\w+\\s+\\w+).*", "\\1", subdata$ResTaxa[1]), " (resource)", sep=""), subtitle = paste("ID: ", iden, sep = "")) +
    theme(plot.title = element_text(hjust = 0.5, size = "13"), legend.position = "bottom") +
    scale_color_manual(name = NULL, values = c("green", "blue", "red"), labels = c("Holling Type II model", "Quadratic model", "Cubic model"))
  
  print(p)
  graphics.off() # save plot in pdf
  
}
# graphics.off()

#output plots to include in the report
plotting_subs <- subset(data, data$ID==39838 | data$ID==39889 | data$ID==39893) #these are the subsets i want to show in the report

for (iden in unique(plotting_subs$ID)) { #create a data frame for all their HollT2 plotting values by ID
  tmp <- read.csv(paste("../Results/HollT2_plotting_dfs/HollT2_dfplot_subset_", iden, ".csv", sep=""))
  ID <- rep(iden, nrow(as.matrix(tmp)))
  assign(paste("subs", iden, sep=""), cbind(ID, tmp))
}

plotting_subs_HollT2 <- rbind(subs39838, subs39889, subs39893) #created a HOLLT2 plotting

pdf("../Results/output_tables/plots.pdf", width = 7, height = 4) #open a save pdf

p <- ggplot(plotting_subs, aes(x=ResDensity, y=N_TraitValue)) + geom_point() + #facet plot them 
  geom_smooth(data=plotting_subs_HollT2, method=loess, formula = y ~ x, aes(x=ResDensity, y=N_TraitValue, colour = "green")) +
  geom_smooth(method = lm, formula = y ~ poly(x, degree = 2, raw = TRUE), se=FALSE, aes(colour = "blue", x=ResDensity, y=N_TraitValue)) +
  geom_smooth(method = lm, formula = y ~ poly(x, degree = 3, raw = TRUE), se=FALSE, aes(colour = "red", x=ResDensity, y=N_TraitValue)) +
  facet_grid(facets = .~ ID, scales = "free") +
  labs(x="Resource Density", y="Individual Trait Value") +
  theme(legend.position = "bottom") +
  scale_color_manual(name = NULL, values = c("green", "blue", "red"), labels = c("Holling Type II model", "Quadratic model", "Cubic model"))

print(p)
graphics.off() #saves pdf


print("Finished plotting and saving the .pdf's to ../Results/plots. Ran all the data analysis scripts.")
