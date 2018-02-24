package io.github.crew102.clients;

import io.github.crew102.apimethods.*;
import java.io.IOException;
import com.google.gson.*;

public class APIrequest {
	
	public static void main(String[] args) throws IOException {
		
		Gson gson = new Gson();  
		String json = Utils.readJSONfile("../prototype/client/ex-json.json");
		FindPets findpets = gson.fromJson(json, FindPets.class);
		
	}

}
