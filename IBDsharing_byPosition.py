######
## Created by Claudia Moreau
#
## Edit by : 
## Laurence Gagnon
## August 2023
## Check the IBD sharing across the genome
######


## Load packages
import pandas as pd
import numpy as np
import sys
from sys import argv


##### Data #####
### Arguments: path and file names ###
datafilename = sys.argv[1] ### IBD file .merged.ibd from refinedIBD (run_refinedIBD.sh)
print (datafilename)

### .bim file ###
bim_file = (sys.argv[2]) ### .bim file from PLINK. The same that was use to compute IBD with refinedIBD
print (bim_file)

### Outfile ###
pop = (sys.argv[3]) ### Population identification (if needed) -> if you need to run the script for different dataset
print (pop)



##### Def function ######
### Load refinedIBD file ###
def loadfile (datafile, chromosome):
    df = pd.read_csv(datafile, sep = '\t', header=None)
    new_df = df[df[4] == chromosome]
    return [new_df[5].to_numpy(), new_df[6].to_numpy()]
  
    
### Load .bim file for map ####
def loadmapfile (mapfile):
    positions = []
    f=open(mapfile,'r')
    for line in f:
        ichr=int(line.rstrip('\n\r').split()[0])
        if ichr == mychr:
            pos=int(line.rstrip('\n\r').split()[3])
            positions.append(pos)
    return positions


### Write output ####
def writefile (outputfilename,dict,pos):
    outputfile = open(outputfilename, "w")
    for i in range(len(pos)): 
        if dict[pos[i]] > 0:
            outputfile.write(str(mychr) + "\t" + str(pos[i])+ "\t" + str(dict[pos[i]]) + "\n")       
    outputfile.close()


    
### Run the code to check IBD segments ###
for mychr in range(1, 23): 
    print (mychr)

    ## Load refinedIBD file
    print ('loading data file...')
    data = loadfile(datafilename, mychr)

    ## Load .bim file 
    positions=loadmapfile(bim_file)
    print (len(positions))
    print (positions[1:10])

    ## Do dict for the position
    pos_dict = dict(zip(positions, [0]*len(positions)))

    ## Looping through IBD segments 
    for i in range(len(data[0])):
        for j in range(positions.index(data[0][i]),(positions.index(data[1][i])+1),1):
            pos_dict[positions[j]]+=1
            
    ## Output
    outputfilename = '/your/path/' + pop + '_file_name.sharing.by.pos'
    writefile(outputfilename,pos_dict,positions)

    
