######
## Laurence Gagnon
## Mars 2023
## Script to do a umap
######


### Library ###
rm(list = ls());
library("umap")
library("plyr")
library("ggplot2")



### Load the dataset ID ###
id <- read.table("/path/to/your/file/ID_file.txt", header = T, sep ="\t") ## File with the fam_id, ind_id and the population




##### Function for UMAP ##### 
### Inspire by : https://github.com/diazale/umap_review/tree/master/code/genizon

### UMAP color ###
XYZ_RGB <-
  function(xyz) {
      
    # Normalize X,Y,Z to convert to RGB
    X <- (xyz[,1] - min(xyz[,1])) /
      (max(xyz[,1]) - min(xyz[,1]))
    Y <- (xyz[,2] - min(xyz[,2])) /
      (max(xyz[,2]) - min(xyz[,2]))
    Z <- (xyz[,3] - min(xyz[,3])) /
      (max(xyz[,3]) - min(xyz[,3]))
    
    # In case there are missing values
    X[is.na(X)] <- 0
    Y[is.na(Y)] <- 0
    Z[is.na(Z)] <- 0
    
    # Convert to RGB
    out <- rgb(unlist(X),
               unlist(Y),
               unlist(Z))
    
    return(out)
  }



## UMAP Function ###
umap2go <- function(pca, val1, val2){
    
  # Run UMAP on PCA
  umap_2D <-umap(pca,
                 n_components = 2,
                 n_neighbors = val1,
                 min_dist = val2) #,
               #  spread = 0.3)
  
  umap_2D <- umap_2D$layout
  colnames(umap_2D) <- c("UMAP1_2D","UMAP2_2D")
  projections <- cbind(umap_2D, pca)
  
  umap_3D <- umap(pca,
                  n_components = 3,
                  n_neighbors = val1,
                  min_dist = val2)
  
  umap_3D <- umap_3D$layout
  colnames(umap_3D) <- c("UMAP1_3D",
                         "UMAP2_3D",
                         "UMAP3_3D")
  projections <- cbind(umap_2D, umap_3D,pca)
}






##### Do the UMAP #####
### Repeat on the dataset of each population and the dataset of merge data
### Changer the number of PCs and the nneighbors according to each popopulation

### Load the PCA data ###
pca <- read.table("/path/to/your/file/pca.eigenvec")
pca.labels <- pca[, c(1,2)]
colnames(pca.labels) <- c("fam_id", "ind_id")



### Variable ###
pc = 4 # Change according to the screeplot 
nneighbors = nrow(pca) # Max number of individual in the population
mindist = 0.01 # Low to favorise clustering



### Get the good number of PCs ###
col = pc + 2
pca.data <- pca[, c(3:col)]
colnames(pca.data) <- paste0("PC", 1:i)



### Do UMAP ###
umap <- umap2go(pca.data, nneighbors, mindist)
umap$RGB <- XYZ_RGB(umap[,c('UMAP1_3D', 'UMAP2_3D', 'UMAP3_3D')])
umap.data.id <- cbind(pca.labels, umap)
umap.data.id <- join(umap.data.id, id, by = c("fam_id", "ind_id"))



### Graph ###
color_palette <- c("hotpink",  "lightseagreen",  "red", "yellow", "darkorchid1", "cyan", "chocolate1","burlywood4", "gray14", "green",  "blue", "gray24")

graph <- ggplot(umap.data.id, aes(x = UMAP1_2D, y = UMAP2_2D, col = Dataset_Continent_QuebecSubpop)) +
      geom_point(alpha = 0.85, size = 0.5) +
      scale_colour_manual(values=color_palette, "Datasets") +
      labs(x = "UMAP 1",
           y = "UMAP 2",) +
      guides(color=guide_legend(override.aes = list(size=3))) +
      theme(axis.ticks = element_blank(),
            axis.text = element_blank(),
            plot.title = element_text(hjust = 0.5),
            text=element_text(face="bold", size=9))
    graph

### Save graphic ###
graph_out_tiff <- "/path/to/your/out_file/ID_file.txt/graph.tiff"

tiff(file = graph_out_tiff , units="cm", width = 18, height = 12, res=750)
print(graph)
dev.off()




### Once the clustering is done with : clustering_dbscan_from_UMAP_data.R, you can redo the UMAP with the color according to the clustering 
### Also, I redo the UMAP with the color accorded to the real region/country of origin of the individual from Quebec and Ashkenazi Jews and shaped with the clustering



