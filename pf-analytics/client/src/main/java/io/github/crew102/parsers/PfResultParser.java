package io.github.crew102.parsers;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import io.github.crew102.rawresponses.PetfinderPetRecord;
import io.github.crew102.rawresponses.PetfinderPetRecords;

public class PfResultParser {
  
  Gson customGson;
  
  public PfResultParser() {
    GsonBuilder gsonBuilder = new GsonBuilder();
    
    JsonDeserializer<PetfinderPetRecords> recordsDeser = new PfResultDeserializer(); 
    gsonBuilder.registerTypeAdapter(PetfinderPetRecords.class, recordsDeser);
    
    JsonDeserializer<PetfinderPetRecord> recordDeser = new PetDeserializer(); 
    gsonBuilder.registerTypeAdapter(PetfinderPetRecord.class, recordDeser);
    
    customGson = gsonBuilder.create();  
  }
  
  public PetfinderPetRecords parse(String json) {
    return customGson.fromJson(json, PetfinderPetRecords.class);   
  }

}
