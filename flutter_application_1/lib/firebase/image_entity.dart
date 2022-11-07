class ImageConstants {
  static const String emptyString = "";
  static const String newId = "0";
  static const String firestore = "image";
  static const String location = "Internet";
}

class ImageEntity{
  String id = ImageConstants.newId;
  String url = ImageConstants.emptyString;
  String location = ImageConstants.emptyString;

  ImageEntity(this.id, this.url, this.location);

  ImageEntity.newImage(String url, String location) : this(ImageConstants.newId ,url, location);

  ImageEntity.empty();

  static ImageEntity fromJson(String docId, Map<String, dynamic> json){
    return ImageEntity(docId, json['url'], json['location']);
  }

  Map<String, dynamic> getHash(){
    return <String, dynamic>{
      'url':url,
      'location': location
    };
  }
}

