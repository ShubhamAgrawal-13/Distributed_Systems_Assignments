import java.rmi.*; 

interface GraphAPI extends Remote {  
   void printGraph(String graphId) throws RemoteException;
   void addEdgeInGraph(String graphId, int u, int v, int w) throws RemoteException;  
   String createNewGraph(String graphId, int n) throws RemoteException;  
   long findMinMST(String graphId) throws RemoteException;    
}