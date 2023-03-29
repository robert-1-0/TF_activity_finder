There are three scripts that are called, all other scripts call each other.<br />
The first pipeline creates all clusters and metacells<br />
the second pipeline creates the tranjectory inference<br />
the third pipeline calculates all TFs with the tool DiffTF<br />

1. pipeline<br />
   epi_trajectory.py -> metacell_detection.py -> pipe_metacell.sh
  
   input parameter:<br />
         -m matrix <br />
     -b barcodes <br />
     -p peaks <br />
     -c cells <br />
    
   Anwendungsbeispiel:<br />
     python3 epi_trajectory.py -m matrix.mtx -b barcodes.tsv -p peaks.bed -c 30
    
 2. pipeline<br />
    via_pipe.py
    
    input parameter: <br />
      -a anndata<br />
      -c rootcluster<br />
  
    Anwendungsbeispiel:<br />
      python3 via_pipe.py -a adata.h5ad -c 6
      
 3. pipeline<br />
    diffTF_bam_peak.sh -> diffTF_config_data.sh
    
    input parameter:<br />
      -diff path/of/diffTF<br />
      -bam bamfile<br />
      -c1 cluster1<br />
      -c2 cluster2 <br />
      -cpath path/of/cluster<br />
      -ref refgenome (hg38,hg19,mm10)<br />
      -cores cores<br />
      -pairedend (true,false)<br />
      -slurm (true,false)<br />
      -queue ('sesame_street')<br />
      
    Anwendungsbeispiel:<br />
      bash diffTF_bam_pipe.sh -diff /path/to/my/local/diffTF/folder -bam path/to/bam/file -c1 1 -c2 9 -cpath path/to/created/clusters/from/pipe1 -ref hg19 -cores 20 -pairedend true -slurm true -queue sesame_street
