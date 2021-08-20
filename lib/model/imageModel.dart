class ImageModel {
  final int id;
  final String photoName;
  final String date;

  ImageModel({this.id, this.photoName, this.date});
  Map<String, dynamic> toMap() {
    return {'id': id, 'photoName': photoName, 'date': date};
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'photoName': photoName, 'date': date};
  }

  @override
  String toString() {
    return 'MstFlagModel: value:$photoName, value:$date';
  }
}
