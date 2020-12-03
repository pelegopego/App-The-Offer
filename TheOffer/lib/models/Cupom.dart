import 'package:theoffer/models/itemCupom.dart';
import 'package:theoffer/models/endereco.dart';

class Cupom {
  int id;
  int usuarioId;
  String dataInclusao;
  String dataConfirmacao;
  int status;
  Endereco endereco;
  int empresa;
  int modalidadeEntrega;
  int formaPagamento;
  String horaPrevista;
  List<ItemCupom> listaItensCupom;

  Cupom(
      {this.id,
      this.usuarioId,
      this.dataInclusao,
      this.dataConfirmacao,
      this.status,
      this.endereco,
      this.empresa,
      this.modalidadeEntrega,
      this.formaPagamento,
      this.horaPrevista,
      this.listaItensCupom});

  double somaValorTotalCupom() {
    double somaValor;
    ItemCupom itemCupom;
    somaValor = 0;
    for (itemCupom in this.listaItensCupom) {
      somaValor =
          somaValor + (itemCupom.produto.valorNumerico * itemCupom.quantidade);
    }
    return somaValor;
  }

  int somaQuantidadeCupom() {
    return this.listaItensCupom.length;
  }
}
