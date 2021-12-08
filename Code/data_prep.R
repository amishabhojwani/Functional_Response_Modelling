# set start
# setwd("~/Documents/CMEECourseWork/CMEEMiniproject/Code")

# load data
data <- read.csv("../Data/CRat.csv")

# explore data
# str(data) #ID is integer, N_TraitValue is num, ResDensity is num
# Look at where there are NA's:
# NAcols <- apply(data, 2, anyNA)
# which(NAcols == TRUE) #located NAs, not in any of our columns of interest
# NaNcols <- apply(data, 2, function(x) sum(is.nan(x)))
# which(NaNcols > 0) #no NaNs
# nIDs <- length(unique(data$ID)) #308 IDs

# length_subsets <- c() #explore length of subsets
# for (iden in unique(data$ID)) {
#   len <- nrow(subset(data, data$ID==iden))
#   length_subsets <- append(length_subsets, len)
# }
# 
# leq10 <- count(length_subsets<=10)/length(unique(data$ID))
# leq100_50 <- count(length_subsets>=50 & length_subsets<=100)/length(unique(data$ID))
# meq100 <- count(length_subsets>=100)/length(unique(data$ID))


# create data subsets for each ID (iden=identity)
success_ID <- c()
for (iden in unique(data$ID)) {
  subdata <- subset(data, data$ID == iden)
  write.csv(subdata, paste("../Data/data_subsets/subset_", iden, ".csv", sep=""))
  success_ID <- append(success_ID, iden)
}

IDs <- unique(data$ID)
if (length(list.files("../Data/data_subsets"))==308) {
  print("Created subsets of data for each functional response in ../Data/data_subsets")
} else { print(paste("Failed to create subsets for the following ID's of functional responses: ", setdiff(IDs, success_IDs), sep = "")) }