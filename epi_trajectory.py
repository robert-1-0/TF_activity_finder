#!/usr/bin/python3

# seacellsenv
# $1 matrix
# $2 barcodes
# $3 peaks
# $4 cells

import scanpy as sc
import anndata as ad
import numpy as np
import pandas as pd
import episcanpy.api as epi
import sys
import matplotlib.pyplot as plt
import sys, getopt, os

matrix = ''
barcodes = ''
peaks = ''
cells = ''

def main(argv):
    try:
        opts, args = getopt.getopt(argv,"hm:b:p:c:",["matrix=","barcodes=","peaks=","cells="])
    except getopt.GetoptError:
        print('epi_trajectory.py -m <matrix.mtx> -b <barcodes.tsv> -p <peaks.bed> -c <number of metacells>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('epi_trajectory.py -m <matrix.mtx> -b <barcodes.tsv> -p <peaks.bed> -c <number of metacells>')
            sys.exit()
        elif opt in ("-m", "--matrix"):
            global matrix
            matrix = arg
        elif opt in ("-b", "--barcodes"):
            global barcodes
            barcodes = arg
        elif opt in ("-p", "--peaks"):
            global peaks 
            peaks = arg  
        elif opt in ("-c", "--cells"):
            global cells 
            cells = arg              

if __name__ == "__main__":
    main(sys.argv[1:])   
    
adata = epi.pp.read_ATAC_10x(matrix, cell_names=barcodes, var_names=peaks)
# filter
epi.pp.filter_cells(adata, min_features=1)
epi.pp.filter_features(adata, min_cells=1)
epi.pp.lazy(adata)

# cluster
epi.tl.louvain(adata)
#save
epi.pl.umap(adata, color=['louvain'], legend_loc='on data' ,wspace=0.4)
plt.savefig('pipe_louvain_adata.png')
adata.obs.louvain.to_csv('louvain_cluster.tsv',sep="\t")
adata.write('adata_save.h5ad')

# call next script
input_os = "python3 metacell_detection.py adata_save.h5ad "+str(cells)
os.system(input_os)

