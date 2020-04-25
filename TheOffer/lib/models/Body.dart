class Body {
  final int usuario;
  final int produto;
  final int quantidade;
  final int status;
 
  Body({this.usuario, this.produto, this.quantidade, this.status});

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["usuario"]    = usuario.toString();
    map["produto"]    = produto.toString();
    map["status"]     = status.toString();
    map["quantidade"] = quantidade.toString();
    return map;
  }
}
               