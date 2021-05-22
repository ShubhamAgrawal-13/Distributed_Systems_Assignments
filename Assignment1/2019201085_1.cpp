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

int main( int argc, char **argv ) {
    int rank, numprocs;
    int root_rank=0;

    char* input_file = argv[1];
    char* output_file = argv[2];

    FILE* input_ptr = fopen(input_file, "r"); 
    int n;
    fscanf(input_ptr,"%d", &n);
    // cout<<n<<endl;
    fclose(input_ptr);
    /* start up MPI */
    MPI_Init( &argc, &argv );

    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &numprocs );

    double ans = 0;
    double local_sum=0;
    int c=0;
    if(numprocs == 1){
        c=n;
    }
    else{
        c = n/(numprocs-1);
    }

    if(c==0){
        if(rank == root_rank){
            // cout<<"rank="<<rank<<" c="<<c<<endl;
            for(int i=1; i<n+1; i++){
                // cout<<"rank="<<rank<<" "<<i<<endl;
                local_sum += 1.0/(i*(double)i);
            }
            // cout<<"rank="<<rank<<" "<<local_sum<<endl;
        }
    }
    else{
        // cout<<"rank="<<rank<<" c="<<c<<endl;
        for(int i=rank*c+1; i<min(n+1, rank*c+c+1); i++){
            // cout<<"rank="<<rank<<" "<<i<<endl;
            local_sum += 1.0/(i*(double)i);
        }
        // cout<<"rank="<<rank<<" "<<local_sum<<endl;
    }
    
    MPI_Reduce(&local_sum, &ans, 1, MPI_DOUBLE, MPI_SUM, root_rank, MPI_COMM_WORLD);
       
    if(rank == root_rank){
        // cout << fixed << setprecision(6) <<ans << "\n";
        FILE* output_ptr = fopen(output_file, "w"); 
        fprintf(output_ptr, "%0.6f\n", ans);
        fclose(output_ptr);
    }


    /*synchronize all processes*/
    MPI_Barrier( MPI_COMM_WORLD );
    double tbeg = MPI_Wtime();


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