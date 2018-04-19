package io.github.crew102.clients;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Map;
import io.github.crew102.exceptions.SecretNotFoundException;

public class HttpRequest {
  
  String method;
  Map<String, String> arglist;
  
  public HttpRequest(String method, Map<String, String> arglist) {
   this.method = method;
   this.arglist = arglist;
  }
  
 // should i specify that makeRequest can throw any of these, or just use Exception?
 // IOException, MalformedURLException, UnsupportedEncodingException, SecretNotFoundException
  public String makeRequest() throws Exception {
    
    URL aurl = new URL(genURL());
    HttpURLConnection con = (HttpURLConnection) aurl.openConnection();
    
    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
    String inputLine;
    StringBuffer content = new StringBuffer();
    while ((inputLine = in.readLine()) != null) {
        content.append(inputLine);
    }
    in.close();
    return content.toString();
  }
  
  private String genURL() throws UnsupportedEncodingException, SecretNotFoundException, IOException {
    
    StringBuilder temp = new StringBuilder("http://api.petfinder.com/" + method + "?key=" + Utils.getSecret("PF_KEY") + 
        "&format=json");
    
    for (Map.Entry<String, String> entry : arglist.entrySet()) {
      String value = URLEncoder.encode(entry.getValue(), "UTF-8");
      temp.append("&").append(entry.getKey()).append("=").append(value);
    }
    return temp.toString();
    
  }
  

}
