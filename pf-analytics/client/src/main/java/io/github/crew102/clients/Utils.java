package io.github.crew102.clients;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Paths;
import io.github.crew102.exceptions.SecretNotFoundException;

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
  
  public static void catDir() {
    String dir = Paths.get(".").toAbsolutePath().normalize().toString();
    System.out.println(dir);
  }
  
  public static String getSecret(String secret) throws SecretNotFoundException, IOException {
    
    String envvar = System.getenv(secret);
    String localFile = "../../services/secrets/" + secret;
    String dcFile = "/run/secrets/" + secret.toLowerCase().replaceAll("_", "-");
    
    if (envvar != null) {
      return envvar;
    } else if (new File(localFile).exists()) {
      return readFile(localFile);
    } else if (new File(dcFile).exists()) {
      return readFile(dcFile);
    } else {
      String exp = "Could not find secret: " + secret;
      throw new SecretNotFoundException(exp);
    }
  }
  
}
