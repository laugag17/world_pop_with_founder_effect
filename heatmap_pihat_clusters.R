######
## Laurence Gagnon
## November 2023
## Genetic relatedness (PLINK pihat) between clustering 
######


### Packages ###
rm(list = ls());
library("plyr")
library("ggplot2")
library("ggpubr")


### Example for the Asheknazi Jews data, the same script for the other population ###


### Load the file ###
pihat <- read.table("your/path/PLINK_pihat_data.genome", header = T) ## From PLINK --genome flag
pihat <- pihat[, c(2, 4, 10)]
colnames(pihat) <- c("ind_id_1", "ind_id_2", "pihat")


### Re-add the data on the reverse side so the heatmap can be miror (do not impact the real mean)
pihat2 <- pihat
colnames(pihat2) <- c("ind_id_2", "ind_id_1", "pihat")
pihat <- rbind(pihat, pihat2)


### Load cluster file ###
## Clusters from : clustering_dbscan_from_UMAP_data.R
clusters <- read.delim("your/path/clustering_DBScan.txt")


### Do a matrix ###
clusters1 <- clusters[, c(1, 3, 4)]
colnames(clusters1) <- c("ind_id_1", "Dataset_Continent1", "Cluster_pop1")

clusters2 <- clusters[, c(2, 3, 4)]
colnames(clusters2) <- c("ind_id_2", "Dataset_Continent2", "Cluster_pop2")


pihat_pop <- join(pihat, clusters1, by = c("ind_id_1"))
pihat_pop <- join(pihat_pop, clusters2, by = c("ind_id_2"))


pihat_pop_aj <- pihat_pop[pihat_pop$Dataset_Continent1 == "Ashkenazi_Jews", ]
pihat_pop_aj <- pihat_pop_aj[pihat_pop_aj$Dataset_Continent2 == "Ashkenazi_Jews", ]
pihat_pop_aj <- pihat_pop_aj[!(is.na(pihat_pop_aj$ind_id_1)), ]

table <- as.data.frame(xtabs(pihat~Cluster_pop1+Cluster_pop2,aggregate(pihat~Cluster_pop1+Cluster_pop2,pihat_pop_aj,mean))) ## The miror matrix is created here


### Do the graphic ###
ggraph <- ggplot(table, aes(Cluster_pop1, Cluster_pop2, fill= Freq)) + 
  geom_tile(aes(fill= Freq)) +
  scale_fill_gradient(low = "white", high = "red", limits=c(0, 0.06))+
  geom_text(aes(label=round(Freq, 4)), cex=3) +
  labs(x = " ", y = " ", fill = "Pihat") +
  theme(text=element_text(face="bold", size=11)) 

### Save graphic ###
graph_out_tiff <- paste0("/your/path/outfile.tiff")
tiff(file = graph_out_tiff , units="cm", width = 20, height = 14, res=750)
print(ggraph)
dev.off()









