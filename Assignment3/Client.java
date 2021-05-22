import java.rmi.registry.*;
import java.rmi.*;
import java.util.*; 

class Client {  
   private Client() {}  
   public static void main(String[] args) {  
      try{  
            String ip = args[0];
            int port = Integer.valueOf(args[1]);
            Registry registry = LocateRegistry.getRegistry(ip, port); 
            GraphAPI stub = (GraphAPI) registry.lookup("GraphAPI");
            // String connectLocation = "//" + ip + ":" + port + "/GraphAPI";
            // GraphAPI stub = (GraphAPI) Naming.lookup(connectLocation); 
            Scanner sc = new Scanner(System.in);
            int op=1;
            while(sc.hasNextLine()){
               // System.out.print("> ");
               String line = sc.nextLine();
               String[] tokens = line.split(" ");
               if(tokens.length==0){
                  break;
               }
               if(tokens[0].trim().equals("add_graph")){
                  String graphId = tokens[1];
                  int n = Integer.valueOf(tokens[2]);
                  try{
                     String output = stub.createNewGraph(graphId, n);
                     if(output.trim().equals("ok")){
                        //System.out.println("Add graph successfully " + output);
                     }
                     else
                        System.out.println(output);
                  }
                  catch(Exception e){
                     System.err.println("Exception in add_graph: " + e.toString()); 
                     e.printStackTrace(); 
                  }
               }
               else if(tokens[0].trim().equals("add_edge")){
                  String graphId = tokens[1];
                  int u = Integer.valueOf(tokens[2]);
                  int v = Integer.valueOf(tokens[3]);
                  int w = Integer.valueOf(tokens[4]);
                  try{
                     stub.addEdgeInGraph(graphId, u, v, w);
                     // System.out.println("Add edge successfully");
                  }
                  catch(Exception e){
                     System.err.println("Exception in add_edge: " + e.toString()); 
                     e.printStackTrace(); 
                  }
               }
               else if(tokens[0].trim().equals("get_mst")){
                  String graphId = tokens[1];
                  try{
                     long ans = stub.findMinMST(graphId);
                     System.out.println(ans);
                     // System.out.println("Min MST Sum of graphId : " + graphId + " is " + ans);
                  }
                  catch(Exception e){
                     System.err.println("Exception in get_mst: " + e.toString()); 
                     e.printStackTrace(); 
                  }
               }
               else if(tokens[0].trim().equals("print_graph")){
                  String graphId = tokens[1];
                  try{
                     stub.printGraph(graphId);
                     // System.out.println("Printed graph on server with graphId : " + graphId);
                  }
                  catch(Exception e){
                     System.err.println("Exception in print_graph: " + e.toString()); 
                     e.printStackTrace(); 
                  }
               }
               // else if(tokens[0].trim().equals("")){
               //    op=0;
               //    // System.out.println("Exited");
               //    break;
               // }
               // else{
               //    // System.out.println("Entered wrong command");
               // }
            }
      } 
      catch (Exception e) {
            System.err.println("Client exception: " + e.toString()); 
            e.printStackTrace(); 
      } 
   } 
}