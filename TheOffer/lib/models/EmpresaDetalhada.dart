import 'package:theoffer/models/Produto.dart';

class CategoriaDetalhada {
  int id;
  String nome;
  String imagem;
  List<Produto> listaProduto;

  CategoriaDetalhada({this.id, this.nome, this.imagem, this.listaProduto});
}

class EmpresaDetalhada {
  int id;
  String razaoSocial;
  String fantasia;
  String imagem;
  num telefone;
  double segundaInicio;
  double segundaFim;
  double tercaInicio;
  double tercaFim;
  double quartaInicio;
  double quartaFim;
  double quintaInicio;
  double quintaFim;
  double sextaInicio;
  double sextaFim;
  double sabadoInicio;
  double sabadoFim;
  double domingoInicio;
  double domingoFim;
  List<CategoriaDetalhada> listaCategoria;

  EmpresaDetalhada(
      {this.id,
      this.razaoSocial,
      this.fantasia,
      this.imagem,
      this.telefone,
      this.segundaInicio,
      this.segundaFim,
      this.tercaInicio,
      this.tercaFim,
      this.quartaInicio,
      this.quartaFim,
      this.quintaInicio,
      this.quintaFim,
      this.sextaInicio,
      this.sextaFim,
      this.sabadoInicio,
      this.sabadoFim,
      this.domingoInicio,
      this.domingoFim,
      this.listaCategoria});

  String maskTelefone() {
    String aux;
    String telefone = this.telefone.toString();
    if (telefone.length >= 6) {
      aux = telefone.substring(telefone.length - 4, telefone.length);
      telefone = telefone.substring(0, telefone.length - 4) + '-' + aux;

      aux = telefone.substring(telefone.indexOf('-') - 4, telefone.length);
      if ((telefone.substring(0, telefone.indexOf('-') - 4)).length == 2) {
        //sem o 9
        telefone =
            '(' + telefone.substring(0, telefone.indexOf('-') - 4) + ') ' + aux;
      } else if ((telefone.substring(0, telefone.indexOf('-') - 4)).length == 3) {
        //com o 9
        telefone = '(' +
            telefone.substring(0, telefone.indexOf('-') - 5) +
            ') ' +
            telefone.substring(
                telefone.indexOf('-') - 5, telefone.indexOf('-') - 4) +
            ' ' +
            aux;
      } else {
        //não informou ddd
        telefone = telefone.substring(0, telefone.indexOf('-') - 4) + ' ' + aux;
      }
    }
    return telefone;
  }
}
