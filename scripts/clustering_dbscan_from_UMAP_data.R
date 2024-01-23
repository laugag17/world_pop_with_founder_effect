######
## Laurence Gagnon
## June 2023
## Script to do cluster from UMAP with DBScan
######


### Library ###
rm(list = ls());
library("ggplot2")
library("dplyr")
library("ggpubr")
library("dbscan")


##### The DBScan methods #####
### Repeat on the dataset of each population 
### Changer the eps_value according to each population


### Open UMAP data ###
umap_data <- read.delim("/path/to/your/file/UMAP_file.txt")


### Variable ###
minPts_value = 4 # Suggested to take take minPts = 4 for 2D data
eps_value = 0.30 # Change according to each population


### Plot to choose eps_value ###
kNNdistplot(as.matrix(umap_data[, c(3, 4)]), minPts = minPts_value)
abline(h = eps_value, col="red")


### Do DBScan ###
Dbscan_cl <- dbscan(umap_data[, c(3,4)], eps = eps_value, minPts = minPts_value, borderPoints = T)


### Add cluster with UMAP data ###
umap_data$Cluster <- factor(Dbscan_cl$cluster)


### Graphic ###
graph <- ggscatter(umap_data, x = "UMAP1_2D", y = "UMAP2_2D", color = "Cluster", ellipse = TRUE, ellipse.type = "convex",
                   size = 1.5,  legend = "right", ggtheme = theme_bw(),
                   xlab = "UMAP1",
                   ylab = "UMAP2",
                   mean.point.size = 30) +
                   stat_mean(aes(color = Cluster), size = 4)




### Save graphic ####
graph_out_tiff <- "/path/to/your/out_file/ID_file.txt/graph.tiff"
tiff(file = graph_out_tiff , units="cm", width = 14, height = 12, res=750)
print(graph)
dev.off()


### Save the data ###
write.table(umap_data, "/path/to/your/file/UMAP_file_with_clusters.txt", quote = F, row.names = F, sep = "\t")
 
 
 
 