There are three scripts that are called, all other scripts call each other.
The first pipeline creates all clusters and metacells
the second pipeline creates the tranjectory inference
the third pipeline calculates all TFs with the tool DiffTF

1. pipeline
   epi_trajectory.py -> metacell_detection.py -> pipe_metacell.sh
  
   input parameter:
     -m matrix <br />
     -b barcodes <br />
     -p peaks 
     -c cells 
    
   Anwendungsbeispiel:
     python3 epi_trajectory.py -m matrix.mtx -b barcodes.tsv -p peaks.bed -c 30
    
 2. pipeline
    via_pipe.py
    
    input parameter
      -a anndata
      -c rootcluster
  
    Anwendungsbeispiel:
      python3 via_pipe.py -a adata.h5ad -c 6
      
 3. pipeline
    diffTF_bam_peak.sh -> diffTF_config_data.sh
    
    input parameter:
      -diff path diffTF
      -bam bamfile
      -c1 cluster1:
      -c2 cluster2:
      -cpath path cluster
      -ref refgenome (hg38,hg19,mm10)
      -cores cores
      -pairedend (true,false)
      -slurm (true,false)
      -queue ('sesame_street')
      
    Anwendungsbeispiel:
      bash diffTF_bam_pipe.sh -diff /path/to/my/local/diffTF/folder -bam path/to/bam/file -c1 1 -c2 9 -cpath path/to/created/clusters/from/pipe1 -ref hg19 -cores 20 -pairedend true -slurm true -queue sesame_street
