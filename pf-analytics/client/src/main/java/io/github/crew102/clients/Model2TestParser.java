package io.github.crew102.clients;

import java.io.IOException;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import io.github.crew102.model2.PetfinderPetRecord;
import io.github.crew102.model2.PetfinderPetRecords;
import io.github.crew102.parsers.PetfinderPetRecordDeser;
import io.github.crew102.parsers.PetfinderPetRecordsDeser;

public class Model2TestParser {
  
  public static void main(String[] args) throws IOException {
    
    String json = Utils.readJSONfile("../../prototype/pfproto/inst/dev/ex-json.json");        
    
    GsonBuilder gsonBuilder = new GsonBuilder();
    
    JsonDeserializer<PetfinderPetRecords> recordsDeser = new PetfinderPetRecordsDeser(); 
    gsonBuilder.registerTypeAdapter(PetfinderPetRecords.class, recordsDeser);
    
    JsonDeserializer<PetfinderPetRecord> recordDeser = new PetfinderPetRecordDeser(); 
    gsonBuilder.registerTypeAdapter(PetfinderPetRecord.class, recordDeser);
    
    Gson customGson = gsonBuilder.create();  
    PetfinderPetRecords customObject = customGson.fromJson(json, PetfinderPetRecords.class);         
  }
  
}