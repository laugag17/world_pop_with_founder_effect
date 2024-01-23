######
## Created by Claudia Moreau
#
## Edit by : 
## Laurence Gagnon
## August 2023
## Plot total IBD sharing length between pairs of individudals
######


### Packages ###
rm(list = ls());
library('ggplot2')
library("ggpubr")
library("gridExtra")


### Set work directory ###
work_dir <- "/your/work/directory/"
setwd(work_dir)


### Get the info about the different population ###
## Needed to compite the proportion of pairs sharing 
pops <-  c("himba", "hutterites", "quebec", "ashkenazi_jews", "ctls_CEU_GBR", "ctls_JPT_CHB", "ctls_MSL") 
inds <- c(131, 77, 941, 2052, 190, 207, 85)
color <- c("purple4", "green4", "hotpink", "deepskyblue", "steelblue4", "aquamarine", "plum1")
pairs_vec <- (inds * (inds - 1) / 2) 

df_info <- data.frame(pop = pops, number = inds, pairs = pairs_vec, cols = color)


### Get the IBD sharing across the genome ###
df2fill <- data.frame()

for (ipop in 1:nrow(df_info)) {
  print(df_info[ipop, 1])
  
  ### Open file
  files = paste0(df_info[ipop, 1], "_your_file_chr", c(1:22),".sharing.by.pos") ### Data from : IBDsharing_byPosition.py
  data_list = lapply(files, read.table, colClasses="numeric",header=FALSE)
  pat_sharing <- do.call(rbind, data_list)
  
  ### Add info
  pat_sharing$pop <- df_info[ipop, 1]
  pat_sharing$prop <- pat_sharing[,3] / df_info[ipop, 3]
  
  ### Table
  table_df <- data.frame(Population = df_info[ipop, 1], Mean = round(mean(pat_sharing$prop) * 100, 3), Maximum = round(max(pat_sharing$prop) * 100, 3), Minimum = round(min(pat_sharing$prop) * 100, 3))
  
  ### Save file
  df2fill <- rbind(df2fill, table_df)

}

## Saving
write.table(df2fill, "/your/path/output.txt", sep="\t",  quote = F, row.names = F)



