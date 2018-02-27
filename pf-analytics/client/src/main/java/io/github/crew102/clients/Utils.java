package io.github.crew102.clients;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public final class Utils {
	
	public static String readJSONfile(String file) throws IOException {
		
		File myFile = new File(file);
		FileReader filereader = new FileReader(myFile);
		BufferedReader reader = new BufferedReader(filereader);
		
		StringBuilder builder = new StringBuilder();
		
		String line = null;
	    while ((line = reader.readLine()) != null) {
	    		builder.append(line);
	    }
	    
	    reader.close();
	    return builder.toString();
	}

}
