#! /bin/sh

#SBATCH --account=rrg-girardsi
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6 
#SBATCH --mem-per-cpu=3G
#SBATCH --time=0-15:00 


module load StdEnv/2020
module load nixpkgs/16.09
module load java/1.8.0_121
module load plink/2.00-10252019-avx2


### Add working dir ###
mydir=/your/working/path
cd ${mydir}



### PLINK bfile ###
plink_file=your_plink_file ## to change



### Variable ###
length=1
lod=3



### Compute IBD and HBD segments ###
for ichr in {1..22}
do

	echo "${ichr}"

	## Make vcf
	plink2 --bfile ${plink_file} --recode vcf --chr ${ichr}  --out ${plink_file}_length${length}_lod${lod}_chr${ichr}

	## Phase with Beagle
	java -Xmx29127m -jar /the/good/path/SOFT/beagle.18May20.d20.jar gt=${plink_file}_length${length}_lod${lod}_chr${ichr}.vcf out=${plink_file}_length${length}_lod${lod}_chr${ichr}

	## IBD
	java -Xmx29127m -jar /the/good/path/SOFT/refined-ibd.17Jan20.102.jar gt=${plink_file}_length${length}_lod${lod}_chr${ichr}.vcf.gz length=${length} lod=${lod} out=${plink_file}_length${length}_lod${lod}_chr${ichr}

    ## Info
	ibd_file=${plink_file}_length${length}_lod${lod}_chr${ichr}.ibd.gz
	hbd_file==${plink_file}_length${length}_lod${lod}_chr${ichr}.hbd.gz
	vcf_file=${plink_file}_length${length}_lod${lod}_chr${ichr}.vcf.gz
	map_file=/the/good/path/plink.chr${ichr}.GRCh37.map
	gap=0.6
	discord=1
	outfile_merged==${plink_file}_length${length}_lod${lod}_chr${ichr}.merged.ibd
	outfile_merged_hbd==${plink_file}_length${length}_lod${lod}_chr${ichr}.merged.hbd
    

	## Merge IBD segments..
	zcat ${ibd_file} | java -jar /the/good/path/SOFT/merge-ibd-segments.17Jan20.102.jar ${vcf_file} ${map_file} ${gap} ${discord} | sed 's/,/\./g' > ${outfile_merged}
 
	## Merge HBD segments..
	zcat ${hbd_file} | java -jar /the/good/path/SOFT/merge-ibd-segments.17Jan20.102.jar ${vcf_file} ${map_file} ${gap} ${discord} | sed 's/,/\./g' > ${outfile_merged_hbd}


done



