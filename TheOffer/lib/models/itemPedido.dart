import 'package:theoffer/models/Produto.dart';

class ItemPedido {
  int produtoId;
  int pedidoId;
  int quantidade;
  String sabores;
  final Produto produto;

  ItemPedido(
      {this.produtoId,
      this.pedidoId,
      this.quantidade,
      this.produto,
      this.sabores});
}
