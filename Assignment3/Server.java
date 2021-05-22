import java.rmi.registry.Registry; 
import java.rmi.registry.LocateRegistry; 
import java.rmi.*;
import java.util.*;
import java.io.*;
import java.net.*;
import java.rmi.server.UnicastRemoteObject; 

class Edge implements Serializable{
   int u;
   int v;
   int w;
   Edge(){

   }
   Edge(int u, int v, int w){
      this.u = u;
      this.v = v;
      this.w = w;
   }
}

class CompEdge implements Comparator<Edge>
{
    public int compare(Edge a, Edge b)
    {
        return a.w - b.w;
    }
}

class Kruskal{
   int n;
   int[] p, rank;

   Kruskal(){

   }

   Kruskal(int n){
       initialize(n);
   }

   void initialize(int n){
      p = new int[n+1];
      rank = new int[n+1];
      for(int i=0; i<p.length; i++){
         p[i] = i;
         rank[i] = 0;
      }
   }

   int find(int x){
      if(x!=p[x]){
         p[x] = find(p[x]);
      }
      return p[x];
   }

   void union(int x, int y){
      x = find(x);
      y = find(y);

      if(rank[x] > rank[y]){
         int temp = rank[x];
         rank[x] = rank[y];
         rank[y] = temp;
      }

      if(rank[x] == rank[y]){
         rank[y] = rank[y] + 1;
      }

      p[x] = y;
   }
}

class Graph implements Serializable{
   int n;
   ArrayList<Edge> graph;

   Graph(){

   }

   Graph(int n){
      this.n = n;
      graph = new ArrayList<Edge>();
   }

   synchronized void addEdge(int u, int v, int w){
      graph.add(new Edge(u, v, w));
   }

   void printGraph(){
      System.out.println("Graph with n = " + n + " : {");
      for(int i=0; i<graph.size(); i++){
          Edge edge = graph.get(i);
         System.out.println((i+1) + " : (" + edge.u + ", " + edge.v + ", " + edge.w + ")");
      }
       System.out.println("}\n");
   }

   synchronized long applyKruskal(){
      long ans = 0;
      if(n==0){
         return 0;
      }
      Collections.sort(graph, new CompEdge());
      int edge_count = 0;
      Kruskal k = new Kruskal(n);
      for(Edge edge : graph){
         int u = edge.u;
         int v = edge.v;
         int w = edge.w;
         if(k.find(u) != k.find(v)){
            ans += w;
            edge_count += 1;
            k.union(u, v);
         }
      }

      //Disconnected graph
      if(edge_count!=n-1)
         return -1;

      return ans;
   }

}

// Implementing the remote interface 
class GraphAPIClass extends UnicastRemoteObject implements GraphAPI, Serializable{
   HashMap<String, Graph> graphs;

   GraphAPIClass() throws java.rmi.RemoteException 
   { 
      super();
      graphs = new HashMap<String, Graph>();
   }

   public synchronized String createNewGraph(String graphId, int n){
      if(graphs.containsKey(graphId)){
         System.out.println("Graph already exists with id : " + graphId);
         return "Graph already exists with the given identifier";
      }
      graphs.put(graphId, new Graph(n));
      System.out.println("Created new Graph with id : " + graphId);
      return "ok";
   }

   public void printGraph(String graphId){
      System.out.println("Graph with id : " + graphId);
      if(!graphs.containsKey(graphId)){
         System.out.println("Graph doesn\'t exist with id : " + graphId);
         return;
      }
      graphs.get(graphId).printGraph();
   }

   public void addEdgeInGraph(String graphId, int u, int v, int w){
      if(!graphs.containsKey(graphId)){
         System.out.println("Graph doesn't exist with id : " + graphId);
         return;
      }
      System.out.println("Created a new edge for id : " + graphId + ", edge : " + u + " " + v + " " + w);
      graphs.get(graphId).addEdge(u, v, w);
   }

   public long findMinMST(String graphId){
      if(!graphs.containsKey(graphId)){
         System.out.println("Graph doesn't exist with id : " + graphId);
         return -1;
      }
      long ans = graphs.get(graphId).applyKruskal();
      System.out.println("findMinMST for " + graphId + " : " + ans);
      return ans;
   }
}

public class Server extends GraphAPIClass { 
   public Server() throws java.rmi.RemoteException {
      super();
   } 
   public static void main(String args[]) { 
      try { 
         int port = Integer.valueOf(args[0]);
         GraphAPIClass graphAPIObj = new GraphAPIClass();
         String address=""; 
           try{  
            address = (InetAddress.getLocalHost()).toString();
           }
           catch(Exception e){
            System.out.println("can't get inet address.");
           }

         Registry registry  = LocateRegistry.createRegistry(port);
         registry.rebind("GraphAPI", graphAPIObj);   
         // LocateRegistry.createRegistry(port);
         // String hostname = "0.0.0.0";
         // String bindLocation = "//" + hostname + ":" + port + "/GraphAPI";
         // Naming.bind(bindLocation, graphAPIObj);

         // GraphAPI stub = (GraphAPI) UnicastRemoteObject.exportObject(graphAPIObj, 0);
         // Registry registry  = LocateRegistry.createRegistry(port);
         // registry.bind("GraphAPI", stub);  
         // Naming.rebind("rmi://localhost:" + port, graphAPIObj);
         // GraphAPI stub = (GraphAPI) UnicastRemoteObject.exportObject(graphAPIObj, 0);
         // Registry registry = LocateRegistry.getRegistry(); 
         // registry.bind("GraphAPI", stub);  
         System.err.println("Server ready " + address + " " + port); 

      } catch (Exception e) { 
         System.err.println("Server exception: " + e.toString()); 
         e.printStackTrace(); 
      }
   } 
} 