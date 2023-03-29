from pyVIA.core import *
import matplotlib.pyplot as plt
import sys, getopt 
import anndata as ad

# -a adata
# -c rootcluster

adata = ''
cluster = ''
def main(argv):
    try:
        opts, args = getopt.getopt(argv,"ha:c:",["adata=","cluster="])
    except getopt.GetoptError:
        print('via_pipe.py -a <adata.h5ad> -c <clusternumber>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('via_pipe.py -a <adata.h5ad> -c <clusternumber>')
            sys.exit()
        elif opt in ("-a", "--adata"):
            global adata
            adata = arg
        elif opt in ("-c", "--cluster"):
            global cluster
            cluster = arg

if __name__ == "__main__":
    main(sys.argv[1:])   
            
adata = ad.read(adata)
true_label = adata.obs.louvain.tolist()
embedding = adata.obsm['X_umap']
ncomps, knn, random_seed, dataset, root_user  =30,20, 41,'', [cluster]
v0 = VIA(adata.obsm['X_umap'][:, 0:ncomps], true_label, jac_std_global=0.15, dist_std_local=1, knn=knn, cluster_graph_pruning_std=1, too_big_factor=0.3, root_user=root_user, preserve_disconnected=True, dataset='group', random_seed=random_seed)
v0.run_VIA()
fig, ax, ax1 = draw_piechart_graph(via0=v0)

fig.set_size_inches(12,5)
plt.savefig('via_trajecotry_graph.png')
fig, ax, ax1 = draw_trajectory_gams(via_coarse=v0, via_fine=v0, embedding=embedding)
fig.set_size_inches(12,5)
plt.savefig('via_trajecotry_umap.png')
