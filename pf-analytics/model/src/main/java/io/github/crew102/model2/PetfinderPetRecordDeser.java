package io.github.crew102.model2;

import java.lang.reflect.Type;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import io.github.crew102.model2.PetTypes.StatusType;

public class PetfinderPetRecordDeser implements JsonDeserializer<PetfinderPetRecord> {
    @Override
  public PetfinderPetRecord deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) 
      throws JsonParseException {
      
    JsonObject jsonObject = json.getAsJsonObject();
    
    // minimal example
    int pet_id = jsonObject.get("id").getAsJsonObject().get("$t").getAsInt();
    String status = jsonObject.get("status").getAsJsonObject().get("$t").getAsString();
    StatusType hi = StatusType.valueOf(status);
    return new PetfinderPetRecord(pet_id, hi);
      
  }
}
