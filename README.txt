**Fine-scale genetic structure and rare variant frequencies**

This repository is for the article : Fine-scale genetic structure and rare variant frequencies.

**Scripts**

- The UMAP are created with : umap.R (figure 1, supplementary figure 1, supplementary figure 2)
- The clustering with DBScan on the UMAP data : clustering_dbscan_from_UMAP_data.R


- The IBD is run with : run_refinedIBD.sh.
- The IBD sharing across the genome is computed with : IBDsharing_byPosition.py and IBD_sharing_across_the_genome.R (supplementary table 1)
- The impact of genetic relatedness cleaning (PLINK pihat) on IBD : distribution_IBD_for_number_tot_mean_for_different_pihat_cleaning.R (supplementary figure 4)


- To compute the frequency of the known disease founder variant : founder_variants_check_freq_per_clusters.sh (table 1, supplementary table 2)


- The heatmap of the genetic relatedness (PLINK pihat) on each cluster : heatmap_pihat_clusters.R (supplementary figure 3)
