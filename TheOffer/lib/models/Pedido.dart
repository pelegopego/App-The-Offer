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
    int contador;   
    
    somaValor = 0;
    for(contador = 0 ; contador >= this.listaItensPedido.length; contador++) { 
        somaValor = somaValor + this.listaItensPedido[contador].produto.valorNumerico; 
    } 
    return somaValor;
  }

  int somaQuantidadePedido() {
    return this.listaItensPedido.length;
  }

}