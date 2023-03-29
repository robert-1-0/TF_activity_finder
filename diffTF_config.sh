#!/bin/bash

# $1 path diffTF
# $2 bamfile
# $3 cluster1:
# $4 cluster2:
# $5 path cluster
# $6 refgenome hg38 hg19 mm10 hg10_mm10
# $7 cores
# $8 paired end
# $9 random_num

DIR=$1/sc_atac
random_num=$9
slurm=${10}
queue=${11}


arr_c1=($DIR/input_$3"_"$4"_"$random_num/cluster_$3/filtered_*.bam)
arr_c2=($DIR/input_$3"_"$4"_"$random_num/cluster_$4/filtered_*.bam)

header="SampleID\tCondition\tbamReads\tPeaks\tconditionSummary\n" 
printf $header > $DIR/Data_$3_$4_$random_num.tsv

# itereate through replicates of first cluster
for ((i=0; i<${#arr_c1[@]}; i++)); do

        # snipt the path string
        c=${arr_c1[$i]}
        d=$(echo $c | sed 's/.*_//' | cut -f1 -d".")
        
        # write into Data tsv file
        sampleid="cluster_$3_$d\t"
        conditions="cluster_$3\t"
        bamReads="$DIR/input_$3_$4_$random_num/cluster_$3/filtered_$3_$d.bam\t"
        Peaks="$DIR/input_$3_$4_$random_num/cluster_$3/NA_cluster_$3_$d""_peaks.narrowPeak\t"
        conditionSummary="cluster_$3\n"
        input_cluster=$sampleid$conditions$bamReads$Peaks$conditionSummary
        printf $input_cluster >> $DIR/Data_$3_$4_$random_num.tsv

    
done

# itereate through replicates of second cluster
for ((i=0; i<${#arr_c2[@]}; i++)); do
    
        # snip the path string
        c=${arr_c2[$i]}
        d=$(echo $c | sed 's/.*_//' | cut -f1 -d".")
 
        # write into Data tsv file
        sampleid="cluster_$4_$d\t"
        conditions="cluster_$4\t"
        bamReads="$DIR/input_$3_$4_$random_num/cluster_$4/filtered_$4_$d.bam\t"
        Peaks="$DIR/input_$3_$4_$random_num/cluster_$4/NA_cluster_$4_$d""_peaks.narrowPeak\t"
        conditionSummary="cluster_$4\n"
        input_cluster=$sampleid$conditions$bamReads$Peaks$conditionSummary
        printf $input_cluster >> $DIR/Data_$3_$4_$random_num.tsv
    
done

#refGenome_fasta
if [ ! -d "$DIR/refgenome" ]; then
    mkdir $DIR/refgenome
fi

if [ ! -f "$DIR/refgenome/$6.fa" ]; then
    wget -P $DIR/refgenome https://hgdownload.soe.ucsc.edu/goldenPath/$6/bigZips/$6.fa.gz
    gunzip $DIR/refgenome/$6.fa.gz
fi


#HOCOMOCO_mapping
if [ $6 = "hg19" ]; then
    cp -f $1/src/TF_Gene_TranslationTables/HOCOMOCO_v10/translationTable_hg19.csv $1/src/TF_Gene_TranslationTables/translationTable_hg19.csv
elif [ $6 = "mm10" ]; then
    cp -f $1/src/TF_Gene_TranslationTables/HOCOMOCO_v10/translationTable_mm10.csv $1/src/TF_Gene_TranslationTables/translationTable_mm10.csv
elif [ $6 = "hg38" ]; then
    cp -f $1/src/TF_Gene_TranslationTables/HOCOMOCO_v11/translationTable_hg38.csv $1/src/TF_Gene_TranslationTables/translationTable_hg38.csv
fi


#dir_TFBS
if [ ! -d "$DIR/TFBS" ]; then
    mkdir $DIR/TFBS
fi

if [ ! -d "$DIR/TFBS/$6" ] && [ $6 == "hg38" ]; then
#    mkdir $DIR/TFBS/$2
    wget -P $DIR/TFBS https://www.embl.de/download/zaugg/diffTF/TFBS/TFBS_hg38_FIMO_HOCOMOCOv11.tar.gz
    tar -xzf $DIR/TFBS/TFBS_hg38_FIMO_HOCOMOCOv11.tar.gz -C $DIR/TFBS
    mv $DIR/TFBS/FIMO* $DIR/TFBS/hg38
    gunzip $DIR/TFBS/hg38/*_TFBS.bed.gz
    rm -r $DIR/TFBS/TFBS_*
elif [ ! -d "$DIR/TFBS/$6" ] && [ $6 == "hg19" ]; then
#    mkdir $DIR/TFBS/$2
    wget -P $DIR/TFBS https://www.embl.de/download/zaugg/diffTF/TFBS/TFBS_hg19_PWMScan_HOCOMOCOv10.tar.gz
    tar -xzf $DIR/TFBS/TFBS_hg19_PWMScan_HOCOMOCOv10.tar.gz -C $DIR/TFBS
    mv $DIR/TFBS/PWM* $DIR/TFBS/hg19
    gunzip $DIR/TFBS/hg18/*_TFBS.bed.gz
    rm -r $DIR/TFBS/TFBS_*
elif [ ! -d "$DIR/TFBS/$6" ] && [ $6 == "mm10" ]; then
#    mkdir $DIR/TFBS/$2
    wget -P $DIR/TFBS https://www.embl.de/download/zaugg/diffTF/TFBS/TFBS_mm10_PWMScan_HOCOMOCOv10.tar.gz    
    tar -xzf $DIR/TFBS/TFBS_mm10_PWMScan_HOCOMOCOv10.tar.gz -C $DIR/TFBS
    mv $DIR/TFBS/PWM* $DIR/TFBS/mm10
    gunzip $DIR/TFBS/mm10/*_TFBS.bed.gz
    rm -r $DIR/TFBS/TFBS_*
#    tar -xzf $DIR/TFBS/$2/TFBS_mm10_PWMScan_HOCOMOCOv10.tar.gz
fi


# config file
i1="{\n"
i2="  \"par_general\": {\n"
i3="    \"outdir\": \"output_$3_$4_$random_num\",\n"
i4="    \"maxCoresPerRule\": $7,\n"
i5="    \"dir_TFBS_sorted\": false,\n"
i6="    \"regionExtension\": 100,\n"
i7="    \"comparisonType\": \"cluster_$3vscluster_$4.all\",\n"
i8="    \"conditionComparison\": \"cluster_$3,cluster_$4\",\n"
i9="    \"designContrast\": \"~ conditionSummary\",\n"
i10="    \"designVariableTypes\": \"conditionSummary:factor\",\n"
i11="    \"nPermutations\": 100,\n"
i12="    \"nBootstraps\": 0,\n"
i13="    \"nCGBins\": 10,\n"
i14="    \"TFs\": \"all\",\n"
i15="    \"dir_scripts\": \"../src/R\",\n"
i16="    \"RNASeqIntegration\": false,\n"
i17="    \"debugMode\": false\n"
i18="  },\n"
i19="    \"samples\": {\n"
i20="    \"summaryFile\": \"Data_$3_$4_$random_num.tsv\",\n"
i21="    \"pairedEnd\": $8\n"
i22="  },\n"
i23="  \"peaks\":{ \n"
i24="    \"consensusPeaks\": \"\",\n"
i25="    \"peakType\": \"narrow\",\n"
i26="    \"minOverlap\": 2\n"
i27="  },\n"
i28="  \"additionalInputFiles\": {\n"
i29="    \"refGenome_fasta\": \"refgenome/$6.fa\",\n"
i30="    \"dir_TFBS\": \"TFBS/$6\",\n"
i31="    \"RNASeqCounts\": \"\",\n"
i32="    \"HOCOMOCO_mapping\": \"../src/TF_Gene_TranslationTables/translationTable_$6.csv\"\n"
i33="  }\n"
i34="}"

input_config=$i1$i2$i3$i4$i5$i6$i7$i8$i9$i10$i11$i12$i13$i14$i15$i16$i17$i18$i19$i20$i21$i22$i23$i24$i25$i26$i27$i28$i29$i30$i31$i32$i33$i34

echo -e $input_config > $DIR/Config_$3_$4_$random_num.json

cd $DIR

# slurm 
if [ $slurm = "true" ]; then
    k1="{\n"
    k2="  \"__default__\": {\n"
    k3="    \"queue\": \"$queue\",\n"
    k4="    \"nCPUs\": \"{threads}\",\n"
    k5="    \"memory\": 1500,\n"
    k6="    \"maxTime\": \"1:00:00\",\n"
    k7="    \"name\": \"{rule}.{wildcards}\",\n"
    k8="    \"output\": \"{rule}.{wildcards}.out\",\n"
    k9="    \"error\": \"{rule}.{wildcards}.err\"\n"
    k10="  },\n"
    k11="  \"resortBAM\": {\n"
    k12="    \"memory\": 1500,\n"
    k13="    \"maxTime\": \"1:00:00\"\n"
    k14="  },\n"
    k15="  \"intersectPeaksAndPWM\": {\n"
    k16="    \"memory\": 1500,\n"
    k17="    \"maxTime\": \"1:00:00\"\n"
    k18="  },\n"
    k19="  \"intersectPeaksAndBAM\": {\n"
    k20="    \"memory\": 1500,\n"
    k21="    \"maxTime\": \"1:00:00\"\n"
    k22="  },\n"
    k23="  \"intersectTFBSAndBAM\": {\n"
    k24="    \"memory\": 1500,\n"
    k25="    \"maxTime\": \"1:00:00\"\n"
    k26="  },\n"
    k27="  \"DiffPeaks\": {\n"
    k28="    \"memory\": 1500,\n"
    k29="    \"maxTime\": \"1:00:00\"\n"
    k30="  },\n"
    k31="  \"analyzeTF\": {\n"
    k32="    \"memory\": 1500,\n"
    k33="    \"maxTime\": \"1:00:00\"\n"
    k34="  },\n"
    k35="  \"binningTF\": {\n"
    k36="    \"memory\": 1500,\n"
    k37="    \"maxTime\": \"24:00:00\"\n"
    k38="  },\n"
    k39="  \"summaryFinal\": {\n"
    k40="    \"memory\": 1500,\n"
    k41="    \"maxTime\": \"0:30:00\"\n"
    k42="  },\n"
    k43="  \"cleanUpLogFiles\": {\n"
    k44="    \"memory\": 500,\n"
    k45="    \"maxTime\": \"0:30:00\"\n"
    k46="  }\n"
    k47="}"
    input_cluster_config=$k1$k2$k3$k4$k5$k6$k7$k8$k9$k10$k11$k12$k13$k14$k15$k16$k17$k18$k19$k20$k21$k22$k23$k24$k25$k26$k27$k28$k29$k30$k31$k32$k33$k34$k35$k36$k37$k38$k39$k40$k41$k42$k43$k44$k45$k46$k47

    echo -e $input_cluster_config > $DIR/Cluster_Config_$3_$4_$random_num.json

    snakemake -s ../src/Snakefile --configfile Config_$3_$4_$random_num.json --latency-wait 3600 --notemp --rerun-incomplete --reason --keep-going --cores $7 --local-cores $7 --jobs 400 --cluster-config Cluster_Config_$3_$4_$random_num.json --use-singularity --singularity-args "--bind $1" --cluster " sbatch -p {cluster.queue} -J {cluster.name} --cpus-per-task {cluster.nCPUs} --mem {cluster.memory} --time {cluster.maxTime} -o \"{cluster.output}\" -e \"{cluster.error}\"  --mail-type=None --parsable "
    
elif [ $11 = "false" ]; then
    snakemake --snakefile ../src/Snakefile --cores $7 --configfile Config_$3_$4_$random_num.json --use-singularity --singularity-args "--bind $1"
fi
