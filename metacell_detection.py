#!/usr/bin/python

# §1 anndata
# $2 number of seacells

import os
import numpy as np
import pandas as pd
import scanpy as sc
import SEACells
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import subprocess
import sys
import logging

# blocks error msg of missing font
logging.getLogger('matplotlib.font_manager').setLevel(logging.ERROR)

ad = sc.read(sys.argv[1])
n_SEACells = sys.argv[2]
build_kernel_on = 'X_umap'
n_waypoint_eigs = 10
# calculate model and seacells
model = SEACells.core.SEACells(ad, 
                  build_kernel_on=build_kernel_on, 
                  n_SEACells=n_SEACells, 
                  n_waypoint_eigs=n_waypoint_eigs,
                  convergence_epsilon = 1e-5)
model.construct_kernel_matrix()
M = model.kernel_matrix
model.initialize_archetypes()
SEACells.plot.plot_initialization(ad, model)
model.fit(min_iter=10, max_iter=50)

# export seacells and louvain results
ad.obs['SEACell'].to_csv('meta_cells.tsv',sep="\t")
ad.obs['louvain'].to_csv('louvain_meta.tsv',sep="\t")
sc.pl.umap(ad, color=['SEACell','louvain'], legend_loc=None, wspace=0.4)
plt.savefig('pipe_metacell_adata.png')

print('\nMetacells created with tool Seacells\n')

# call bash script
command = ["bash pipe_metacell.sh"]
p = subprocess.Popen(command, universal_newlines=True, shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
text = p.stdout.read()
retcode = p.wait()
print(text)
