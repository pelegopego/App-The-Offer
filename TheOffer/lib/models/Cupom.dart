class Cupom {
  final int id;
  final String message;
 
  Cupom({this.id, this.message});
 
  factory Cupom.fromJson(Map<String, dynamic> json) {
    return Cupom(
      id: json['id'],
      message: json['message']
    );
  }
 
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id.toString();
    map["message"] = message;
 
    return map;
  }
}