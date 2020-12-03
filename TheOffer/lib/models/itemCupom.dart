import 'package:theoffer/models/Produto.dart';

class ItemCupom {
  int produtoId;
  int cupomId;
  int quantidade;
  String sabores;
  final Produto produto;

  ItemCupom(
      {this.produtoId,
      this.cupomId,
      this.quantidade,
      this.produto,
      this.sabores});
}
