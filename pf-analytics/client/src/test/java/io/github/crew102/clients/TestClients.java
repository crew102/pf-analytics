package io.github.crew102.clients;

import io.github.crew102.parsers.PfResultParser;
import io.github.crew102.rawresponses.PetfinderPetRecords;
import java.util.HashMap;
import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class TestClients {
  
  @Test
  public void testPetFindMethod() throws Exception {
    
    HashMap<String, String> arglist = new HashMap<>();
    arglist.put("animal", "dog");
    arglist.put("count", "1000");
    arglist.put("output", "full");
    arglist.put("location", "20008");
    
    HttpRequest apireq = new HttpRequest("pet.find", arglist);
    String output = apireq.makeRequest();
    
    PfResultParser resparser = new PfResultParser();
    PetfinderPetRecords res = resparser.parse(output);
    
    assertEquals(1000, res.getPetList().size());

  }

}
