package io.github.crew102.model2;

import java.lang.reflect.Type;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;

public class PetfinderPetRecordsDeser implements JsonDeserializer<PetfinderPetRecords> {
	
    @Override
    public PetfinderPetRecords deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) 
    		throws JsonParseException {
        
        JsonObject jobj = json.getAsJsonObject();
        JsonElement jel = jobj.getAsJsonObject("petfinder").getAsJsonObject("pets").get("pet");
                
        if (jel.isJsonArray()) {
        		PetfinderPetRecord[] somePets = context.deserialize(jel, PetfinderPetRecord[].class);
            return new PetfinderPetRecords(somePets);
        } else {
        		PetfinderPetRecord somePets = context.deserialize(jel, PetfinderPetRecord.class);
            return new PetfinderPetRecords(somePets);
        }
        
    }
	

}
