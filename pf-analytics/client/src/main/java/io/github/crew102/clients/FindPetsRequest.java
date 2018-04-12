package io.github.crew102.clients;

import java.util.HashMap;
import io.github.crew102.parsers.PfResultParser;
import io.github.crew102.rawresponses.PetfinderPetRecords;

public class FindPetsRequest {
  
  public static void main(String[] args) throws Exception {
    
    HashMap<String, String> arglist = new HashMap<>();
    arglist.put("animal", "dog");
    arglist.put("count", "100");
    arglist.put("output", "full");
    arglist.put("location", "20008");
    
    HttpRequest apireq = new HttpRequest(arglist);
    String output = apireq.makeRequest();
    
    PfResultParser resparser = new PfResultParser();
    PetfinderPetRecords res = resparser.parse(output);

  }
  
}