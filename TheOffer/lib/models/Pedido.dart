import 'package:theoffer/models/itemPedido.dart';
import 'package:theoffer/models/endereco.dart';

class Pedido {
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
  List<ItemPedido> listaItensPedido;

  Pedido(
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
      this.listaItensPedido});

  double somaValorTotalPedido() {
    double somaValor;
    ItemPedido itemPedido;
    somaValor = 0;
    for (itemPedido in this.listaItensPedido) {
      somaValor = somaValor +
          (itemPedido.produto.valorNumerico * itemPedido.quantidade);
    }
    return somaValor;
  }

  int somaQuantidadePedido() {
    return this.listaItensPedido.length;
  }
}
