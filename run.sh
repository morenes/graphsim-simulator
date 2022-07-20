#!/bin/bash

export GRAPHSIM=$PWDexport GRAPHSIM=$PWD
export LD_LIBRARY_PATH=$GRAPHSIM/DRAMSim2/ #:$LD_LIBRARY_PATH
echo $GRAPHSIM

# amazon, twitter, Kron22 (RMAT22), Livejournal (SLICE_COUNT=2), Wikipedia 
rm dramsim.*

apps="0 1 2 3" # 1 2 3"

#Datasets (1:amazon, 2:LJ, 3:wiki, 4:Kron22)
datasets="3"

for d in $datasets
do
    for a in $apps
    do
        #dataset=cora_csr; vertex=2708; edges=10556
        if [[ $d -eq 1 ]]
        then #amazon
            dataset=amazon; vertex=262111 edges=1234878
        elif [[ $d -eq 2 ]]; then #LJ
            dataset=LVW; vertex=4847616; edges=68993773;
        elif [[ $d -eq 3 ]]; then #wiki
            dataset=wikiw; edges=101311613; vertex=4206336;
        elif [[ $d -eq 4 ]]; then #kron22
            dataset=kron22; edges=128311436; vertex=4194303;
        fi

        if [[ $a -eq 0 ]]
        then
            # SSSP, #SLICE_COUNT=2
            param="OUTFILE=bins/sssp_$dataset.bin ABFS=0 FIFO=0 SPATIAL_STRIDE_FACTOR=1024 REAL_MULTICAST=0"
        elif [[ $a -eq 1 ]]; then
            # PR (priority ordering)
            param="OUTFILE=bins/page_$dataset.bin PR=1 FIFO=0 SPATIAL_STRIDE_FACTOR=1024"
        elif [[ $a -eq 2 ]]; then
            # BFS
            param="OUTFILE=bins/bfs_$dataset.bin ABFS=1 FIFO=1 SPATIAL_STRIDE_FACTOR=1024"
        elif [[ $a -eq 3 ]]; then
        # WCC
            param="OUTFILE=bins/wcc_$dataset.bin ACC=1 FIFO=0 SPATIAL_STRIDE_FACTOR=1024"
        fi
        echo "PARAMS: "
        echo $param
        cmd="sim-polygraph csr_file=\\\"$GRAPHSIM/sample_datasets/$dataset.tsv\\\" V=$vertex E=$edges $param"
        echo $cmd
        echo
        bin="2"
        make $cmd > "runs/DATA${bin}_${dataset}_$a.log" &
    done
done

# Cycles = 2M + 0.075M
# total edges = 1.62 * E (68M)
# GTEPS (throughput) = 1.62 * 68M / 2.075M = 
# Real GTEPS = GTEPS / 1.62 = 68M / 2.075M = 33.24
# E=68993773 V=4847571

#V*4 bytes / (16 MB) 

#c 128311436 4194303
# head -n 10 Kronecker_22.tsv 
# sed '1d' Kronecker_22.tsv