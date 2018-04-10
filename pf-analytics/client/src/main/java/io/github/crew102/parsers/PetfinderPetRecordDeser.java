package io.github.crew102.parsers;

import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.util.ArrayList;
import com.google.gson.JsonArray;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import io.github.crew102.model2.PetfinderPetRecord;
import io.github.crew102.model2.Photo;
import io.github.crew102.model2.PetTypes.AgeType;
import io.github.crew102.model2.PetTypes.MixType;
import io.github.crew102.model2.PetTypes.OptionType;
import io.github.crew102.model2.PetTypes.SexType;
import io.github.crew102.model2.PetTypes.SizeType;
import io.github.crew102.model2.PetTypes.StatusType;

public class PetfinderPetRecordDeser implements JsonDeserializer<PetfinderPetRecord> {
  
  private JsonObject mainJsonObject;

  @Override
  public PetfinderPetRecord deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) 
      throws JsonParseException {

    mainJsonObject = json.getAsJsonObject();
    
    // AI = always exists
    
    int pet_id = getT("id").getAsInt(); // pet_id (AI)
    String shelter_id = getT("shelterId").getAsString(); // sheter_id (AI)
    String name = getT("name").getAsString(); // name (AI)
    String description = getT("description").getAsString(); // description (AI)
    
    LocalDateTime last_update = parseDateTime(getT("lastUpdate").getAsString()); // last_update (AI)

    StatusType status = StatusType.valueOf(getT("status").getAsString()); // status (AI)
    AgeType age = AgeType.valueOf(getT("age").getAsString()); // age (AI)
    SizeType size = SizeType.valueOf(getT("size").getAsString()); // size (AI)
    SexType sex = SexType.valueOf(getT("sex").getAsString()); // sex (AI)
    MixType mix = MixType.valueOf(getT("mix").getAsString()); // mix (AI)
        
    String[] breed = parseBreed(); // breed (AI)
    OptionType[] option = parseOption(); // option ("options" = AI, "option" != AI)
    Photo[] photo = parsePhoto();
    
    // contact != AI, but if it does then all children should be AI...though $t inside these children may not exist
    // maybe should create single contact class?
    JsonElement contactEl = mainJsonObject.get("contact");
    String city, state, zip;
    if (contactEl == null) {
      city = (String) null;
      state = (String) null;
      zip = (String) null;
    } else {
      JsonObject contactJobj = contactEl.getAsJsonObject();
      city = parseContactField(contactJobj, "city");
      state = parseContactField(contactJobj, "state");
      zip = parseContactField(contactJobj, "zip");
    }
    
    return new PetfinderPetRecord(pet_id, shelter_id, name, status, age, size, sex, mix, description, 
        option, breed, photo, last_update, city, state, zip);
  }
  
  private JsonElement getT(String field) {
    // we have to call getAsJsonObject here b/c we can't call get("t") on JsonElement, so
    // basically we have to cast Json back to JsonObject before we can parse it further
    return mainJsonObject.getAsJsonObject(field).get("$t");
  }
  
  private LocalDateTime parseDateTime(String dt) {
    String cleanedString = dt.replaceAll("Z$", "");;    
    return LocalDateTime.parse(cleanedString);
  }
  
  private String[] parseBreed() {
    // note that we don't know breed object exists, so although we can use getAsJsonObject on breeds object
    // b/c it will always exist, have to use get() on resulting obj in case object is null...null el's get
    // taken care of in parseOptionOrBreed()
    JsonElement el = mainJsonObject.getAsJsonObject("breeds").get("breed");
    return elToArray(el); 
  }
  
  private OptionType[] parseOption() {
    JsonElement el = mainJsonObject.getAsJsonObject("options").get("option");
    String[] optstring = elToArray(el);
    return stringToOptionType(optstring);
  }
  
  private String[] elToArray(JsonElement el) throws JsonParseException {
    
    ArrayList<String> resArL = new ArrayList<String>();
    if (el == null) {
      return new String[0];
    }
    
    if (el.isJsonArray()) {
      JsonArray jarray = el.getAsJsonArray();
      for (int i = 0; i < jarray.size(); i++) {
        JsonObject jobj = jarray.get(i).getAsJsonObject();
        String val = jobj.get("$t").getAsString();
        resArL.add(val);
      }
    } else if (el.isJsonObject()) {
      String val = el.getAsJsonObject().get("$t").getAsString();
      resArL.add(val);
    } else {
      throw new JsonParseException("Unexpected element type");
    }
    
    String[] resAr = new String[resArL.size()];
    return resArL.toArray(resAr);
  }
  
  private OptionType[] stringToOptionType(String[] vals) {
    OptionType[] optarray = new OptionType[vals.length];
    
    for (int i = 0; i < optarray.length; i++) {
      optarray[i] = OptionType.valueOf(vals[i]);
    }
    return optarray;
  }
 
  private Photo[] parsePhoto() {
    
    JsonObject jobj = mainJsonObject.getAsJsonObject("media"); // media = AI, photos = NAI, photo = NAI
    JsonElement jel = jobj.get("photos");
    
    if (jel == null) {
      return new Photo[0];
    }
    
    // we know at this point that media has photos element, which means it must have photo el...only question is 
    // if photo is an array...either way we will put photo(s) in arraylist then convert to array
    ArrayList<Photo> resArL = new ArrayList<Photo>();
    JsonElement photoel =  jel.getAsJsonObject().get("photo");
    
    if (photoel.isJsonArray()) {
      JsonArray jAr = photoel.getAsJsonArray();
      for (int i = 0; i < jAr.size(); i++) {
        JsonObject jobj2 = jAr.get(i).getAsJsonObject();
        Photo onephoto = parseOnePhoto(jobj2);
        resArL.add(onephoto);
      }
    } else if (photoel.isJsonObject()) {
      Photo onephoto = parseOnePhoto(photoel.getAsJsonObject());
      resArL.add(onephoto);
    } else {
      throw new JsonParseException("Unexpected element type");
    }
    
    Photo[] result = new Photo[resArL.size()];
    return resArL.toArray(result);
  }
  
  private Photo parseOnePhoto(JsonObject jobj) {
    String stringsize = jobj.get("@size").getAsString();
    Photo.PhotosizeType size = Photo.PhotosizeType.valueOf(stringsize);
    
    String url = jobj.get("$t").getAsString();
    
    String idstring = jobj.get("@id").getAsString();
    int id = Integer.valueOf(idstring);
    
    return new Photo(size, url, id);
  }
  
  private String parseContactField(JsonObject jobj, String field) {
    
    JsonElement jel = jobj.get(field);
    if (jel == null) {
      return (String) null;
    }
    
    JsonElement jel2 = jel.getAsJsonObject().get("$t");
    if (jel2 == null) {
      return (String) null;
    } else {
      return jel2.getAsString();
    }
  }
  
}
