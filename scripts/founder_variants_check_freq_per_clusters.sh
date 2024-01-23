#! /bin/sh

#SBATCH --account=rrg-girardsi
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=3G
#SBATCH --time=0-00:30


module load StdEnv/2020 gcc/9.3.0
module load vcftools/0.1.16
module load java/17.0.2
module load plink/1.9b_6.21-x86_64


### Work directory ###
wk_dir=/lustre03/project/6033529/laugag/data/imputation/
cd ${wk_dir}


### Example for the Asheknazi Jews data, the same script for the other population ###




### File and variable ###
plink_bfile=your_plink_file ## Here it's the imputated file to check the variants associated with a specific founder effect
POP="Ashkenazi_Jews AshkenaziJews-1 AshkenaziJews-2 AshkenaziJews-3 AshkenaziJews-4 1000GP-EUR"## The different clusters to check the variants 

### Compute freq of the variants for each pop and clusters ###
for i in $POP; do
   echo "${i}"
   
   list_ind=individual_${i}.txt ### Individuals from the good po for clusters only
    
   plink --bfile ${plink_bfile} --allow-extra-chr --keep ${list_ind} --extract mutation_list.txt --freq --out outfile ## Here is the mutation list for the Ashkenazi Jews
   plink --bfile ${plink_bfile} --allow-extra-chr --keep ${list_ind} --extract mutation_list.txt --freq counts --out outfile_counts


done

