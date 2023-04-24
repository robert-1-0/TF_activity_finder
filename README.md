There are three scripts that are called, all other scripts call each other.<br />
The first pipeline creates all clusters and metacells<br />
the second pipeline creates the tranjectory inference<br />
the third pipeline calculates all TFs with the tool DiffTF<br />

1. pipeline<br />
&nbsp;&nbsp;&nbsp;   epi_trajectory.py -> metacell_detection.py -> pipe_metacell.sh
  
   input parameter:<br />
    &nbsp;&nbsp; -m matrix <br />
    &nbsp;&nbsp; -b barcodes <br />
    &nbsp;&nbsp; -p peaks <br />
    &nbsp;&nbsp; -c cells <br />
    
   Application example:<br />
   &nbsp;&nbsp;&nbsp;  python3 epi_trajectory.py -m matrix.mtx -b barcodes.tsv -p peaks.bed -c 30
    
 2. pipeline<br />
 &nbsp;&nbsp;&nbsp;   via_pipe.py
    
    input parameter: <br />
    &nbsp;&nbsp;  -a anndata<br />
    &nbsp;&nbsp;  -c rootcluster<br />
  
    Application example:<br />
    &nbsp;&nbsp;&nbsp;  python3 via_pipe.py -a adata.h5ad -c 6
      
 3. pipeline<br />
 &nbsp;&nbsp;&nbsp;   diffTF_bam_peak.sh -> diffTF_config_data.sh
    
    input parameter:<br />
    &nbsp;&nbsp;  -diff path/of/diffTF<br />
    &nbsp;&nbsp;  -bam bamfile<br />
    &nbsp;&nbsp;  -c1 cluster1<br />
    &nbsp;&nbsp;  -c2 cluster2 <br />
    &nbsp;&nbsp;  -cpath path/of/cluster<br />
    &nbsp;&nbsp;  -ref refgenome (hg38,hg19,mm10)<br />
    &nbsp;&nbsp;  -cores cores<br />
    &nbsp;&nbsp;  -pairedend (true,false)<br />
    &nbsp;&nbsp;  -slurm (true,false)<br />
    &nbsp;&nbsp;  -queue ('sesame_street')<br />
      
    Application example:<br />
    &nbsp;&nbsp;&nbsp;  bash diffTF_bam_pipe.sh -diff /path/to/my/local/diffTF/folder -bam path/to/bam/file -c1 1 -c2 9 -cpath path/to/created/clusters/from/pipe1 -ref hg19 -cores 20 -pairedend true -slurm true -queue sesame_street
