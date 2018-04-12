package io.github.crew102.rawresponses;

public class Photo {
  
  public enum PhotosizeType {
    x, t, pn, pnt, fpm
  }
  
  PhotosizeType size;
  String url;
  int id;
  
  public Photo(PhotosizeType size, String url, int id) {
    this.size = size;
    this.url = url;
    this.id = id;
  }
  
  public Photo(String size, String url, int id) {
    this.size = PhotosizeType.valueOf(size);
    this.url = url;
    this.id = id;
  }
}
