#Distributed Assignment2:
-------------------------
Shubham Agrawal
2019201085

#Question 1: Ring Topology
----------------------------
To implement this, first I have created N process and connect them via a link in ring like fashion.
and while creating the link between processes, I also passed the next process id. Now, Processs can communicate to its next process. After link creation, I have a token from main to process 0, and after process 0 will send it to process 1, After that each process sends a token to its next process, and so on. After reaching to (N-1)th process, Nth process will send the token to process 0 (i.e., root process). In recursion, I have passed Root process id(process 0) so that last process know to whom the token is to be sent.

Since in erlang there is no loops so I used recursion for all tasks.

New process is created using spawn function.

This is the code for Link creation.
`
create_process(N, N, T, Root, OFile) ->
	Current = spawn(fun() -> process_handle(N, self(), OFile) end),
	Current ! {link, 0, Root, T},
 	Current;
create_process(I, N, T, Root, OFile) ->
	Current = spawn(fun() -> process_handle(I, self(), OFile) end),
	Next = create_process(I+1, N, T, Root, OFile),
	Current ! {link, I+1, Next, T},
	Current.`

#Number of Messages = N (for link creation) + N (token passing) + 1 (additional token pass from main) = 2.N + 1

---------------------------------------------------------------------------------------------------------------
#Question 2: Single Source Shortest Path
----------------------------------------

To implement this, I have used Parallel Dijkstra’s Algorithm. There were many difficulties I have faced while implementing it. Since, values can be assigned to a variable only time, updation was really difficult, Hence, To overcome this problem, I have used Recursion and map.

1. Read input
2. Created Graph
3. Split the Graph between the processes
4. Then, Run the below algorithm
5. Saved the output in the file.


#Parallel Dijkstra’s algorithm Approach:−
-----------------------------------------

1. Each process identifies its closest vertex to the source vertex and send it to main process.
2. Main process find the min src and update the visited list.
3. Then, it broadcasts the min vertex to all the processes.
4. Each process will update its visited list.
5. After that combine all the distance vector.

`dijkstra(I, N, Pids, S, D, Ans) ->
	send_each_process(Pids, S, D), 
	Len = length(Pids),
	List1 = collect(1, Len),
	Min = min(List1),
	Ans1 = maps:put(element(2, Min), element(1, Min), Ans),
	dijkstra(I+1, N, Pids, element(2, Min), element(1, Min), Ans1).`

Here, We start with (S, D) = (S, 0), where S is source vertex, then send it to all process, Now, collect the local min vertex, Now, compute global min vertex, and then recur. 

for command line argument:
`main(Args) ->
	Input=lists:nth(1,Args),
	Output=lists:nth(2,Args).`

#Time Complexitiy: O((N^2)/P+N.(log P))

where, N = number of vertices and P = number of processes.
The thing I have learnt from this assignment is that almost everyhting is possible using recursion :) .  
---------------------------------------------------------------------------------------------------------- 





