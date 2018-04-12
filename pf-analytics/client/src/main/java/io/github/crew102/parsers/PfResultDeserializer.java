package io.github.crew102.parsers;

import java.lang.reflect.Type;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import io.github.crew102.exceptions.PfindHttpRequestException;
import io.github.crew102.rawresponses.PetfinderPetRecord;
import io.github.crew102.rawresponses.PetfinderPetRecords;

public class PfResultDeserializer implements JsonDeserializer<PetfinderPetRecords> {
  
  @Override
  public PetfinderPetRecords deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) 
      throws JsonParseException {
      
    JsonObject jobj = json.getAsJsonObject().getAsJsonObject("petfinder");
    
    // status code is checked within deserializer (and not in FindPetsRequest) b/c need to parse code to check it
    try {
      checkStatusCode(jobj);
    } catch (PfindHttpRequestException e) {
      e.printStackTrace();
    }
    
    // api doesn't wrap "pet" object in "pets" object when just one pet
    if (jobj.has("pets")) {
      JsonElement jel = jobj.getAsJsonObject("pets").get("pet");
      PetfinderPetRecord[] somePets = context.deserialize(jel, PetfinderPetRecord[].class);
      return new PetfinderPetRecords(somePets);
    } else {
      JsonElement jel = jobj.get("pet");
      PetfinderPetRecord somePets = context.deserialize(jel, PetfinderPetRecord.class);
      // PetfinderPetRecords() will create an array of records if passed a single record
      return new PetfinderPetRecords(somePets);
    }
      
  }
  
  private void checkStatusCode(JsonObject pfinderobj) throws PfindHttpRequestException {
    
    JsonObject statusobj = pfinderobj.getAsJsonObject("header").getAsJsonObject("status");
    String statuscode = statusobj.getAsJsonObject("code").get("$t").getAsString();
    
    // petfinder api uses atypical status codes...100 is only code for non-error
    // https://www.petfinder.com/developers/api-docs
    if (!(statuscode.equals("100"))) {
      String message = statusobj.getAsJsonObject("message").get("$t").getAsString();
      throw new PfindHttpRequestException(message);
    }
  }

}
