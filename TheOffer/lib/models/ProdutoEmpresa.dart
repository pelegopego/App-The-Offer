import 'package:theoffer/models/Produto.dart';

class ProdutoEmpresa {
  final int    empresaId;
  final String razaoSocial;
  final String fantasia;
  final List<Produto> listaProduto;

  ProdutoEmpresa(
    {this.empresaId,
    this.razaoSocial,
    this.fantasia,
    this.listaProduto});
}