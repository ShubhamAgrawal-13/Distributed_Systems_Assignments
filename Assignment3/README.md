## Assignment 3 - RMI

# Name: Shubham Agrawal
# Roll No. : 2019201085


In this assigment, we have to use java RMI(Remote Method Invocation) to create a some graph API with the following three functionality on Server side i.e.,

	1. add_graph
	2. add_edge
	3. get_mst (Minimum Spanning Tree)

So for the first two, I have create a HashMap at server side which contains 
` HashMap<key, value> pair as HashMap<String, Graph>`

# Key:- 
	It is a string which will be a graph_identifier.
# Value:- 
	It will contain Graph class Object.

# Graph:- 
	It contains the list of edges for the graph with corresponding graph identifier given as key i.e., ArrayList<Edge>.

# Edge:- 
	It is a user defined class that contains u, v, w as data members.


let,
HashMap<String, Graph> graphs = new HashMap<String, Graph>();

# 1. add_graph(graphId):
		graphs.put(graphId, new Graph(n));

# 2. add_edge(graphId, u, v, w):
		graphs.get(graphId).addEdge(u, v, w);

I have handle the corner cases here, i.e., if key is not present. 

Now about third case,
To represent graph, I have used List of edges not Adjacency list. Since we have to only compute MST of the graph, we don't necessarily need the Adjacency list.

To compute MST for a given graph, I have used Kruskal's Minimum spanning tree algorithm.

For that, I have made a class named Kruskal, which contains the following methods:

1. initialize() -> which initailizes the rank and p arrays.
2. find(i) -> which will find the parent of i
3. union(i, j) -> It will do union of i and j.

Disjoint set union is implemented using this lecture:
http://people.seas.harvard.edu/~cs125/fall16/lec3.pdf


i.e., union by rank + path compression

# Complexity: O((m+n)log∗n)
where,
	m operations for UNION 
	n operations for FIND , 
	log∗n is the number of times you must iterate the log2 function on n before getting a number less than or equal to 1. (So log∗4=2, log∗16=3, log∗65536=4.) 


# Algorithm to find MST:
# 3. get_mst(graphId):
```
sort edges with given identifier by weights

create Kruskal class object (k)
call k.initialize()

cost = 0
edge_count = 0

for each edge=(u, v, w) in G:
	if( k.find(u) != k.find(v) ):
		cost += w
		edge_count +=1
		k.union(u, v)

if edge_count == n-1 :
	return cost
else:
	return -1
```


# printGraph(graphId)
I have also made an additional function i.e., printGraph(graphId) which prints the graph on server side.


# Note:
GraphAPI interface should present on both client and server side if there are on different sytems.

There are 3 files:
1. Client.java
2. Server.java
3. GraphAPI.java

I have made this classes at Server side and also implemented the GraphAPI interface in the Server.java:

1. Edge -> to represent edge
2. Graph -> to represent graph
3. Kruskal -> to apply kruskal's algo
4. CompEdge -> for edge comparison
5. GraphAPIClass -> to implement GraphAPI interface
6. Server -> To create Server.

-----------------------------------------------------------------------------

# How to run code:
-------------------

1. Compile all files

`> javac *.java`

2. First, run rmiregistry in one terminal

`> rmiregistry `

3. Second, Run Server class file by giving port number, It will bind a new registry with the given port number provided. 

`> java Server 9000` 

where, port number = 9000

4. Now, Rum Client class file with ip address and port number given through command line 
arguments. It will connect client to the server.

`> java Client 127.0.1.1 9000 < input.txt`

Here, if you want, you can give the input directly from the terminal also.


# Results:
1. Client is able to execute the methods at the server.
2. Multiple clients are able to connect to the server.
3. Getting correct results for mst with multiple clients. 

# Observations:
1.	If Client and Server run on different machines, first check for firewall settings if you are getting Connection Refused Error.

2.  RMI do implicit multi-threading and stubbing. Also read requests continuously, so don't need to write while(true) on server side.

3. Since, multiple clients are executing the methods in the server, there can be problem of inconsistency at the server. 
Hence, all the methods are synchronised, so it will handle the cases with multiple clients requesting simultaneously, Hence, it is thread safe at server side.

4. Also Cases like n=0, n=1 are handled at Server side.

That's all.  

