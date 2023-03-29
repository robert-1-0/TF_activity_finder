#!/bin/bash

# $1 path diffTF
# $2 bamfile
# $3 cluster1:
# $4 cluster2:
# $5 path cluster
# $6 refgenome hg38 hg19 mm10
# $7 cores -> 20
# $8 paired end -> true, false

# $9 random_num
# $10 slurm (true or false)
# $11 queue (sesame_street)

#arguments
while [[ "$#" -gt 0 ]]
do case $1 in
    #necessary
    -diff) diff="$2"
    shift;;
    -bam) bam="$2"
    shift;;
    -c1) c1="$2"
    shift;;
    -c2) c2="$2"
    shift;;
    -cpath) cpath="$2"
    shift;;
    -ref) ref="$2"
    shift;;

    # default
    -cores) cores="$2"
    shift;;  
    -pairedend) pairedend="$2"
    shift;;  
    -slurm) slurm="$2"
    shift;;  
    -queue) queue="$2"
    shift;;  
    
    *) echo "Unknown parameter passed: $1"
    exit 1;;
esac
shift
done

#necessary
[ -z "$diff" ] && { echo "!Error diffTF Path is necessary"; exit $ERRCODE; }
[ -z "$bam" ] && { echo "!Error Path for bam file is necessary"; exit $ERRCODE; }
[ -z "$c1" ] && { echo "!Eroor Choice of cluster 1 is necessary"; exit $ERRCODE; }
[ -z "$c2" ] && { echo "!Error Choice of cluster 2 is necessary"; exit $ERRCODE; }
[ -z "$cpath" ] && { echo "!Error Path of the clusters is necessary"; exit $ERRCODE; }
[ -z "$ref" ] && { echo "!Error Choice between hg38, hg19 or mm10 must be made"; exit $ERRCODE; }
#defaults
[ -z "$cores" ] && cores=20
[ -z "$pairedend" ] && pairedend=true
[ -z "$slurm" ] && slurm=true
[ -z "$queue" ] && queue=sesame_street

#directory for difftf input files
DIR=$diff/sc_atac
random_num=$RANDOM
mkdir -p $DIR
mkdir -p $DIR/input_$c1"_"$c2"_"$random_num
cp -f -r $cpath/cluster_$c1 $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c1
cp -f -r $cpath/cluster_$c2 $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c2
path_cluster=$DIR/input_$c1"_"$c2"_"$random_num

arr=($path_cluster/cluster_$c1/cluster_*.tsv)
arr2=($path_cluster/cluster_$c2/cluster_*.tsv)

# paired end or not for macs2
input_f=""
if [ "$pairedend" = "true" ]; then
    input_f="BAMPE"
else
    input_f="BAM"
fi

# iterate through replicates of first cluster using a counter
for ((i=0; i<${#arr[@]}; i++)); do

    # create subbam
    sinto filterbarcodes -b $bam -c $path_cluster/cluster_$c1/cluster_$c1"_"$i.tsv -p $cores --outdir $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c1
    
    mv $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c1/cluster_$c1"_"$i.bam $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c1/filtered_$c1"_"$i.bam


    echo "filtered_"$c1"_"$i".bam created"

    # create peakfile
    macs2 callpeak -t $path_cluster/cluster_$c1/filtered_$c1"_"$i.bam --nomodel --shift 100 --ext 200 -f $input_f --qvalue 0.01 --SPMR --outdir $path_cluster/cluster_$c1 -n NA_cluster_$c1"_"$i

    # delete empty peakfiles
    if [ ! -s $path_cluster/cluster_$c1/NA_cluster_$c1"_"$i"_peaks.narrowPeak" ] ; then
        rm -r $path_cluster/cluster_$c1/NA_cluster_$c1"_"$i"_peaks.narrowPeak"
        rm -r $path_cluster/cluster_$c1/filtered_$c1"_"$i.bam
        echo cluster_$c1_$i" deleted because no peaks were detected"
    fi 


    echo "peakfile NA_cluster_"$c1"_"$i"_peaks.narrowPeak created"


done

rm -f -r $path_cluster/cluster_$c1/NA_*.xls
rm -f -r $path_cluster/cluster_$c1/NA_*.bed


# iterate through replicates of second cluster using a counter
for ((i=0; i<${#arr2[@]}; i++)); do

    # create subbam
    sinto filterbarcodes -b $bam -c $path_cluster/cluster_$c2/cluster_$c2"_"$i.tsv -p $cores --outdir $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c2
    
    
    mv $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c2/cluster_$c2"_"$i.bam $DIR/input_$c1"_"$c2"_"$random_num/cluster_$c2/filtered_$c2"_"$i.bam


    echo "filtered_"$c1"_"$i".bam created"

    # create peakfile
    macs2 callpeak -t $path_cluster/cluster_$c2/filtered_$c2"_"$i.bam --nomodel --shift 100 --ext 200 -f $input_f --qvalue 0.01 --SPMR --outdir $path_cluster/cluster_$c2 -n NA_cluster_$c2"_"$i

    # delete if empty peakfile
    if [ ! -s $path_cluster/cluster_$c2/NA_cluster_$c2"_"$i"_peaks.narrowPeak" ] ; then
        rm -r $path_cluster/cluster_$c2/NA_cluster_$c2"_"$i"_peaks.narrowPeak"
        rm -f -r $path_cluster/cluster_$c2/filtered_$c2"_"$i.bam
        echo cluster_$c2"_"$i" deleted because no peaks were detected"
    fi 
    
    echo "peakfile NA_cluster_"$c2"_"$i"_peaks.narrowPeak created"

done

# delete unnecessary peakfiles of MACS2
rm -r -f $path_cluster/cluster_$c2/NA_*.xls
rm -r -f $path_cluster/cluster_$c2/NA_*.bed

bash diffTF_config_data.sh $diff $bam $c1 $c2 $cpath $ref $cores $pairedend $random_num $slurm $queue

# $1 path diffTF
# $2 bamfile
# $3 cluster1:
# $4 cluster2:
# $5 path cluster
# $6 refgenome hg38 hg19 mm10
# $7 cores
# $8 paired end
# $9 random_num
# $10 slurm
# $11 queue
