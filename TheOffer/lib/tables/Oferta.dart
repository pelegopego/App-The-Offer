class Oferta {
  int id;
  String imagem;
  String descricao;
  double valororiginal;
  double valordesconto;
  double quantidadecupons;
  double percentualdesconto;
  String datainicial;
  String datafinal;
  String datacadastro;  
  

  Oferta(int id, String descricao, double valororiginal, String datainicial, String datafinal, String datacadastro, String imagem) {
    this.id = id;    
    this.imagem = imagem;
    this.descricao = descricao;    
    this.valororiginal = valororiginal;
    this.datainicial = datainicial;
    this.datafinal = datafinal;
    this.datacadastro = datacadastro;
  }

  Oferta.fromJson(Map json)
      : id             = int.parse(json['id']),
        descricao      = json['descricao'],
        valororiginal  = double.parse(json['valororiginal']),
        valordesconto  = double.parse(json['valordesconto']),
        quantidadecupons  = double.parse(json['quantidadecupons']),
        percentualdesconto  = double.parse(json['percentualdesconto']),        
        datainicial  = json['datainicial'],
        datafinal    = json['datafinal'],
        datacadastro  = json['datacadastro'],
        imagem  = json['imagem'];        
        
  Map toJson() {
    return {'id': id, 'descricao': descricao, 'valor': valororiginal, 'datainicial': datainicial, 'datafinal': datafinal, 'datacadastro': datacadastro, 'imagem': imagem};
  }
}