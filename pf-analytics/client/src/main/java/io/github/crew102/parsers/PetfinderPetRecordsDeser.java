package io.github.crew102.parsers;

import java.lang.reflect.Type;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import io.github.crew102.model2.PetfinderPetRecord;
import io.github.crew102.model2.PetfinderPetRecords;

public class PetfinderPetRecordsDeser implements JsonDeserializer<PetfinderPetRecords> {
	
  @Override
  public PetfinderPetRecords deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) 
      throws JsonParseException {
      
    JsonObject jobj = json.getAsJsonObject().getAsJsonObject("petfinder");
            
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

}
