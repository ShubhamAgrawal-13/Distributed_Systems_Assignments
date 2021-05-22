/* MPI Program Template */

/**
 * Shubham Agrawal
 * 2019201085
 */

#include <stdio.h>
#include <string.h>
#include "mpi.h"
#include <fstream>
#include <bits/stdc++.h>
using namespace std;
typedef long long int ll;

int findpivot(int* arr, int l, int h){
    int pivot, p, q;
    p = l+1;
    q=h;
    pivot=arr[l];
    while(p<=q){
        while(arr[p]<=pivot){
            p++;
        }
        while(arr[q]>pivot){
            q--;
        }
        if(p<q){
            int temp = arr[p];
            arr[p]=arr[q];
            arr[q]=temp;
        }
    }
    int temp = arr[l];
    arr[l]=arr[q];
    arr[q]=temp;

    return q;
}

void quicksort(int* arr, int l, int h){
    if(l>=h)
        return;
    int pivot_index = findpivot(arr, l, h);
    quicksort(arr, l, pivot_index - 1);
    quicksort(arr, pivot_index + 1, h);
}

int* merge(int *a, int na, int *b,int nb)
{
    int *res = (int *)malloc((na + nb) * sizeof(int));

    int i=0;
    int j=0;
    int k=0;

    while(i<na && j<nb)
    {
        if(a[i]>b[j])
        {
            res[k++]=b[j++];
        }
        else
        {
            res[k++]=a[i++];
        }
    }

    while(i<na)
    {
        res[k++]=a[i++];
    }

    while(j<nb)
    {
        res[k++]=b[j++];
    }

    return res;
}

int main( int argc, char **argv ) {
    int rank, numprocs;
    MPI_Status status;
    int* partition;
    int psize; // partition size
    int* a; //for data
    int n;
    int root_rank=0;
    int size;

    char* input_file = argv[1];
    char* output_file = argv[2];

    /* start up MPI */
    MPI_Init( &argc, &argv );

    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &numprocs );

    if(rank == root_rank){
        FILE* input_ptr = fopen(input_file, "r"); 
        fscanf(input_ptr,"%d", &n);
        // cout<<n<<endl;

        psize = (int)ceil(1.0*n/numprocs);

        a = (int*)malloc(psize*numprocs*sizeof(int));
        for(int i=0; i<n; i++){
            fscanf(input_ptr,"%d", &a[i]);
        }   
        for(int i=n; i<psize*numprocs; i++){
            a[i]=0;
        }

        fclose(input_ptr);
    }

    MPI_Bcast(&n, 1, MPI_INT, root_rank, MPI_COMM_WORLD);
    MPI_Bcast(&psize, 1, MPI_INT, root_rank, MPI_COMM_WORLD);

    /*synchronize all processes*/
    MPI_Barrier( MPI_COMM_WORLD );
    double tbeg = MPI_Wtime();

    partition = (int*) malloc(psize*sizeof(int));
    MPI_Scatter(a, psize, MPI_INT, partition, psize, MPI_INT, root_rank, MPI_COMM_WORLD);
    if((n >= psize * (rank+1))){
        size = psize;
    }
    else{
        size = n - psize * rank;
    }    
    // cout << rank << " " << size << endl;
    if(size<0)
        size=0;
    quicksort(partition, 0, size-1);
    // sort(partition, partition+size);
    // for(int i=0; i<size; i++)
    //     cout<< partition[i]<<" ";
    // cout<<endl;
    // cout << rank << " " << size << endl;
    MPI_Barrier( MPI_COMM_WORLD );
    // Merging partitions
    int level=1;
    while(level < numprocs){
        int diff = 2*level;
        int send_or_recv = rank % diff;
        
        if(send_or_recv != 0){
            // cout<<rank <<" send" <<endl;
            MPI_Send(partition, size, MPI_INT, rank-level, 0, MPI_COMM_WORLD);
            break;
        }

        if((rank+level) < numprocs){
            // cout<<rank <<" recv" <<endl;
            int rsize;
            if(n >= psize * (rank+diff)){
                rsize = psize * level;
            }
            else{
                rsize = n - psize * (rank + level);
            }
            if(rsize<0)
                rsize=0;
            // cout<<"deb="<<o<<endl;
            int* received = (int *)malloc(rsize * sizeof(int));
            MPI_Recv(received, rsize, MPI_INT, rank + level, 0, MPI_COMM_WORLD, &status);
            // cout<<"debugged"<<endl;
            int* temp = merge(partition, size, received, rsize);
            // cout<<"debuggedkk"<<endl;
            free(partition);
            free(received);
            size = size + rsize;
            partition = temp;
        }

        level = 2*level;
    }


    // MPI_Barrier( MPI_COMM_WORLD );
    // free(a);
    if(rank == root_rank){
        FILE* output_ptr = fopen(output_file, "w"); 
        for (int i = 0; i < size; i++)
            fprintf(output_ptr, "%d ", partition[i]);
        fprintf(output_ptr, "%s\n", "");
        fclose(output_ptr);
    }

    free(partition);
    double elapsedTime = MPI_Wtime() - tbeg;
    double maxTime;
    MPI_Reduce( &elapsedTime, &maxTime, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD );
    if ( rank == 0 ) {
        printf( "Total time (s): %f\n", maxTime );
    }

    /* shut down MPI */
    MPI_Finalize();
    return 0;
}