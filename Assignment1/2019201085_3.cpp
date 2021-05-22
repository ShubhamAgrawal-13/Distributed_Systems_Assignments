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

void dfs(int u, int** graph, int n, int m, int* visited){
    visited[u]=1;
    for(int i=0; i<n; i++){
        int v = graph[u][i];
        if(visited[v]==0)
            dfs(v, graph, n, m, visited);
    }
}

int main( int argc, char **argv ) {
    int rank, numprocs;
    int root_rank=0;
    int n, m;
    int** graph;
    char* input_file = argv[1];
    char* output_file = argv[2];
    int max_degree;

    /* start up MPI */
    MPI_Init( &argc, &argv );

    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &numprocs );

    if(rank == root_rank){
        FILE* input_ptr = fopen(input_file, "r"); 
        fscanf(input_ptr,"%d", &n);
        fscanf(input_ptr,"%d", &m);
        // cout<<n<<endl;
        int *data = (int *)malloc(n*n*sizeof(int));
        graph= (int **)malloc(n*sizeof(int*));
        for (int i=0; i<n; i++)
            graph[i] = &(data[n*i]);

        for(int i=0; i<n; i++){
            for(int j=0; j<n; j++){
                graph[i][j]=0;
            }
        }
        
        for(int i=0; i<m; i++){
            int a, b;
            fscanf(input_ptr,"%d", &a);
            fscanf(input_ptr,"%d", &b);
            a--;
            b--;
            graph[a][b]=1;
            graph[b][a]=1;
        }  
        max_degree=0;
        for(int i=0; i<n; i++){
            int sum=0;
            for(int j=0; j<n; j++){
                sum+=graph[i][j];
            }
            if(max_degree<sum){
                max_degree=sum;
            }
        }

        fclose(input_ptr);
    }

    MPI_Bcast(&n, 1, MPI_INT, root_rank, MPI_COMM_WORLD);
    MPI_Bcast(&m, 1, MPI_INT, root_rank, MPI_COMM_WORLD);
    
    /*synchronize all processes*/
    MPI_Barrier( MPI_COMM_WORLD );
    double tbeg = MPI_Wtime();

    /* write your code here */

    if(rank == root_rank){
        FILE* output_ptr = fopen(output_file, "w"); 
        fprintf(output_ptr, "%d\n", max_degree+1);
        for (int i = 0; i < m; i++)
            fprintf(output_ptr, "%d ", i%(max_degree+1)+1);
        fprintf(output_ptr, "%s\n", "");
        fclose(output_ptr);
    }


    MPI_Barrier( MPI_COMM_WORLD );
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