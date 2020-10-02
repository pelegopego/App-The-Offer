import 'package:theoffer/models/Produto.dart';

class ProdutoEmpresa {
  final int empresaId;
  final String razaoSocial;
  final String fantasia;
  final String imagem;
  final double horaInicio;
  final double horaFim;
  bool cardVisivel = false;
  final List<Produto> listaProduto;

  ProdutoEmpresa(
      {this.empresaId,
      this.razaoSocial,
      this.fantasia,
      this.imagem,
      this.horaInicio,
      this.horaFim,
      this.listaProduto,
      this.cardVisivel});
}
