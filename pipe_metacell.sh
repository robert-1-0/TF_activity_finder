#!/bin/bash

# combine two files and delete not needed columns
paste meta_cells.tsv louvain_meta.tsv | awk '{print $1 "\t" $2 "\t" $4}' > meta_louvain_merge.tsv
awk -F"\t" 'NR>1{print $1 "\t" $2 > "cluster_"$3".tsv"}' meta_louvain_merge.tsv


# use nullglob in case there are no matching files
shopt -s nullglob

# create an array with all the filer/dir inside ~/myDir
arr=(cluster_*.tsv)

# iterate through clusters using a counter
for ((i=0; i<${#arr[@]}; i++)); do

    mkdir cluster_$i
    cd cluster_$i

    awk -F"\t" 'NR>1{print $1 > "cluster__"$2".tsv"}' ../cluster_$i".tsv"

    arr2=(cluster__*-1.tsv)
    
    # iterate through replicates of clusters
    for((k=0; k<${#arr2[@]}; k++)); do
    
        while read line
            do printf $line"\tcluster_"$i"_"$k"\n" >> cluster_$i"_"$k.tsv
        done < "${arr2[$k]}"

        rm -r "${arr2[$k]}"
        
    done

    echo "${arr[$i]}"
done

echo "Metacells for Cluster created"

rm -r cluster_*.tsv
rm -r louvain_meta.tsv 
rm -r meta_louvain_merge.tsv 
rm -r meta_cells.tsv 
