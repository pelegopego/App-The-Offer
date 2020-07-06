class Oferta {
  int id;
  String descricao;
  double valor;
  String datainicial;
  String datafinal;
  String datacadastro;

  Oferta(int id, String descricao, double valor, String datainicial, String datafinal, String datacadastro) {
    this.id = id;    
    this.descricao = descricao;    
    this.valor = valor;
    this.datainicial = datainicial;
    this.datafinal = datafinal;
    this.datacadastro = datacadastro;
  }

  Oferta.fromJson(Map json)
      : id           = int.parse(json['id']),
        descricao    = json['descricao'],
        valor        = double.parse(json['valor']),
        datainicial  = json['datainicial'],
        datafinal    = json['datafinal'],
        datacadastro = json['datacadastro'];
        
  Map toJson() {
    return {'id': id, 'descricao': descricao, 'valor': valor, 'datainicial': datainicial, 'datafinal': datafinal, 'datacadastro': datacadastro};
  }
}