import 'package:theoffer/models/itemPedido.dart';
import 'package:theoffer/models/endereco.dart';

class Pedido {
  final int id;
  final int usuarioId;
  final String dataInclusao;
  final String dataConfirmacao;
  final int status;
   Endereco endereco;
  final List<ItemPedido> listaItensPedido;
  
  Pedido(
      {this.id,
      this.usuarioId,
      this.dataInclusao,
      this.dataConfirmacao,
      this.status,
      this.endereco,
      this.listaItensPedido});

  double somaValorTotalPedido() {
    double somaValor;   
    ItemPedido itemPedido;
    somaValor = 0;
    for(itemPedido in this.listaItensPedido) { 
        somaValor = somaValor + (itemPedido.produto.valorNumerico * itemPedido.quantidade); 
    } 
    return somaValor;
  }

  int somaQuantidadePedido() {
    return this.listaItensPedido.length;
  }

}