import 'package:theoffer/models/itemPedido.dart';
//import 'package:theoffer/models/address.dart';
/*
ID
USUARIO_ID
DATAINCLUSAO
DATACONFIRMACAO
STATUS
*/

class Pedido {
  final int id;
  final int usuarioId;
  final String dataInclusao;
  final String dataConfirmacao;
  final int status;
  final List<ItemPedido> listaItensPedido;
  
  Pedido(
      {this.id,
      this.usuarioId,
      this.dataInclusao,
      this.dataConfirmacao,
      this.status,
      this.listaItensPedido});

  double somaValorTotalPedido() {
    double somaValor;   
    ItemPedido itemPedido;
    somaValor = 0;
    for(itemPedido in this.listaItensPedido) { 
        somaValor = somaValor + itemPedido.produto.valorNumerico; 
    } 
    return somaValor;
  }

  int somaQuantidadePedido() {
    return this.listaItensPedido.length;
  }

}