import 'package:theoffer/models/Produto.dart';

class ItemPedido {
  int produtoId;
  int pedidoId;
  int quantidade;
  final Produto produto;

  ItemPedido(
      {this.produtoId,
      this.pedidoId,
      this.quantidade,
      this.produto});
}
