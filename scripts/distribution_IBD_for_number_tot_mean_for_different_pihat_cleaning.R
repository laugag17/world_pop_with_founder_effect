######
## Laurence Gagnon
## June 2023
## IBD test for different cleaning of pihat for mean, total and sum
######


### Library ###
rm(list = ls());
library("plyr")
library("dplyr")
library("ggplot2")
library("ggpubr")

### Work directory ###
data_path = "/your/work/directory/"
setwd(data_path)



### Open .fam file for the different cleaning ###
pihatNO <- read.table("data_no_cleaning.fam")
pihatNO <- pihatNO[, c(1,2)]
colnames(pihatNO) <- c("fam_id", "ind_id")

pihat0.125 <- read.table("data_pihat0.125.fam")
pihat0.125 <- pihat0.125[, c(1,2)]
colnames(pihat0.125) <- c("fam_id", "ind_id")

pihat0.25 <- read.table("data_pihat0.25.fam")
pihat0.25 <- pihat0.25[, c(1,2)]
colnames(pihat0.25) <- c("fam_id", "ind_id")


### Open population file ###
pop <- read.delim("pop_info_file.txt") ## File with the fam_id, ind_id and the population


### Join .fam and population file ###
pihatNO_fam <- join(pihatNO, pop, by = c("ind_id", "fam_id"))
pihat0.125_fam <- join(pihat0.125, pop, by = c("ind_id", "fam_id"))
pihat0.25_fam <- join(pihat0.25, pop, by = c("ind_id", "fam_id"))


### Do graphic fo the different pihat cleaning ###
for (i in c("NO", "0.25", "0.125")) {
  print(paste0("pihat : ", i))
  
  ## Pick the good pihat file
  pihat2use <- get(paste0("pihat", i, "_fam"))
  pihat2use$IND1 <- paste0(pihat2use$fam_id, "_", pihat2use$ind_id)
  pihat2use <- pihat2use[, c(4,3)]
  number <- table(pihat2use$Dataset_Continent)
  names(number) <- NULL
  
  
  ## Open IBD file
  all_chr_file <- intersect(list.files(pattern = "IBD_file"), list.files(pattern = ".merged.ibd")) ### IBD file .merged.ibd from refinedIBD (run_refinedIBD.sh)
  nom_col <- c("IND1","haplotype1", "IND2", "haplotype2", "chr", "start", "end", "LOD", "IBD_segment")
  data_list = lapply(all_chr_file, read.table, dec="." , header = FALSE, col.names = nom_col)
  IBD <- do.call(rbind, data_list)

  
  ## Keep the good individual according to pihat
  IBD_clean <- IBD[IBD$IND1 %in% pihat2use$IND1, ]
  IBD_clean <- IBD_clean[IBD_clean$IND2 %in% pihat2use$IND1, ]
  print(paste0("  - Before cleaning : ", length(unique(c(IBD$IND1, IBD$IND2))), " inds"))
  print(paste0("  - After cleaning : ", length(unique(c(IBD_clean$IND1, IBD_clean$IND2))), " inds"))
  
  
  ## Add population
  IBD_clean <- join(IBD_clean, pihat2use, by = "IND1")
  

  ## Keep only segments more than 2 cM
  IBD_clean_2cM <- IBD_clean[IBD_clean$IBD_segment >= 2, ]
  
  
  ## Get info for total and number of IBD segments
  data_nbr_tot <- IBD_clean_2cM %>% group_by(IND1, IND2) %>% transmute(Total=sum(IBD_segment), Count=n(), Dataset_Continent)
  data_nbr_tot <- data_nbr_tot[!duplicated(data_nbr_tot[,c(1,2)]),]

  
  ### Graphic 
  color_palette <- c("plum1", "aquamarine", "steelblue4", "deepskyblue", "purple4", "green4", "deeppink2" )
  
  if (i == "0.125") {
    graph_boxplot_tot <- ggplot(data_nbr_tot, aes(x = Dataset_Continent, y = Total, fill = Dataset_Continent)) +
      geom_boxplot(alpha=0.6) +
      scale_fill_manual(name = "Datasets", values=color_palette) +
      labs(x = element_blank(), y = element_blank(), title = "Sum of IBD segments length") +
      theme(axis.text = element_text(face="bold", size=20),
            axis.title = element_text(face="bold", size=40),
            plot.title = element_text(face="bold", size = 38, hjust = 0.5),
            legend.position = "none") + 
      ylim(0,3600) +
      annotate("text", x = 1:7, y = 3600, label = paste0("n = ", number), size = 13) 
    
    graph_boxplot_nbr <- ggplot(data_nbr_tot, aes(x = Dataset_Continent, y = Count, fill = Dataset_Continent)) +
      geom_boxplot(alpha=0.6) +
      scale_fill_manual(name = "Datasets", values=color_palette) +
      labs(x = element_blank(), y = element_blank(), title = "Number of IBD segments") +
      theme(axis.text = element_text(face="bold", size=20),
            axis.title = element_text(face="bold", size=40),
            plot.title = element_text(face="bold", size = 38, hjust = 0.5),
            legend.position = "none") + 
      ylim(0,270) +
      annotate("text", x = 1:7, y = 270, label = paste0("n = ", number), size = 13) 
    
  } else {
    graph_boxplot_tot <- ggplot(data_nbr_tot, aes(x = Dataset_Continent, y = Total, fill = Dataset_Continent)) +
      geom_boxplot(alpha=0.6) +
      scale_fill_manual(name = "Datasets", values=color_palette) +
      labs(x = element_blank(), y = element_blank(), title = element_blank()) +
      theme(axis.text = element_text(face="bold", size=20),
            axis.title = element_text(face="bold", size=40),
            plot.title = element_text(face="bold", size = 38, hjust = 0.5),
            legend.position = "none") + 
      ylim(0,3600) +
      annotate("text", x = 1:7, y = 3600, label = paste0("n = ", number), size = 13) 
    
    graph_boxplot_nbr <- ggplot(data_nbr_tot, aes(x = Dataset_Continent, y = Count, fill = Dataset_Continent)) +
      geom_boxplot(alpha=0.6) +
      scale_fill_manual(name = "Datasets", values=color_palette) +
      labs(x = element_blank(), y = element_blank(), title = element_blank()) +
      theme(axis.text = element_text(face="bold", size=20),
            axis.title = element_text(face="bold", size=40),
            plot.title = element_text(face="bold", size = 38, hjust = 0.5),
            legend.position = "none") + 
      ylim(0,270) +
      annotate("text", x = 1:7, y = 270, label = paste0("n = ", number), size = 13) 
 
    } 
    
  ### Save graphics
  assign(paste0("graph_boxplot_tot_pihat", i),  graph_boxplot_tot)
  assign(paste0("graph_boxplot_nbr_pihat", i),  graph_boxplot_nbr)

}




### Put in one graph ###
plt_all <- ggarrange(graph_boxplot_tot_pihat0.125, graph_boxplot_nbr_pihat0.125, graph_boxplot_tot_pihat0.25, graph_boxplot_nbr_pihat0.25,  graph_boxplot_tot_pihatNO, graph_boxplot_nbr_pihatNO,  ncol=3, nrow=3)

### Save the graphic ###
png(file = "/your/path/graph.png", units="in", width=35, height=36, res=600)
plt_all
dev.off()
