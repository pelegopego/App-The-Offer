class Cupom {
  final int id;
  final String usuario;
  final String message;
 
  Cupom({this.id, this.usuario, this.message});
 
  factory Cupom.fromJson(Map<String, dynamic> json) {
    return Cupom(
      id: json['id'],
      usuario: '1',
      message: json['message']
    );
  }
 
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id.toString();
    map["usuario"] = usuario;
 
    return map;
  }
}