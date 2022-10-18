class ImageConstants {
  static const String emptyString = "";
  static const String newId = "0";
  static const String firestore = "image";
}

class ImageEntity{
  String id = ImageConstants.newId;
  String url = ImageConstants.emptyString;

  ImageEntity(this.id, this.url);

  ImageEntity.newImage(String url) : this(ImageConstants.newId ,url);

  ImageEntity.empty();

  static ImageEntity fromJson(String docId, Map<String, dynamic> json){
    return ImageEntity(docId, json['url']);
  }

  Map<String, dynamic> getHash(){
    return <String, dynamic>{
      'url':url
    };
  }
}

