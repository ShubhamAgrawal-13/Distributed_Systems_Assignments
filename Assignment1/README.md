
# Name : Shubham Agrawal
# Roll No: 2019201085

-----------------------------
# Problem 1:
In problem 1, we have to find sum of series, so in this question I have made chunks of size (n/p) and every process computes sum and then I reduced the local sum to global sum using MPI_Reduce.

where, n = number of terms in the series.
and    p = number of processes

so, if n = 100 and p = 4

then, each process will have 25 size chunk (n/p) and computes the local sum.

At last, Combine all sum to global sum using MPI_Reduce. 
----------------------------------


# Problem 2:
In problem 2, we have to implement parallel quicksort, for this, First I read the input using any one process and then broadcast value of n and assigned a chunk of size ceil(n/p) to each process using MPI_Scatter Function.

After All chunk are parallely sorted using quicksort. Then, I merged all the chunks to using parallelize merge function which merges in log p iterations.

Hence, it is very fast then the sequential quicksort. 


-------------------------------------------
# Problem 3:
In problem 3, we have to find edge coloring.
First, I read the input using one of the process and broad cast it to every process.

Then computed the maximum degree vertex.
We know, chromatic index <= max degree  + 1

so, then for each process, I ran the dfs and after assigned colors. Since, There will be some critical sections, so used mutex for it.

and found the edge coloring.




