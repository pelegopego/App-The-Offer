import 'package:theoffer/models/Produto.dart';

class ProdutoEmpresa {
  final int empresaId;
  final String razaoSocial;
  final String fantasia;
  final String imagem;
  double segundaInicio;
  double segundaFim;
  double tercaInicio;
  double tercaFim;
  double quartaInicio;
  double quartaFim;
  double quintaInicio;
  double quintaFim;
  double sextaInicio;
  double sextaFim;
  double sabadoInicio;
  double sabadoFim;
  double domingoInicio;
  double domingoFim;
  bool cardVisivel = false;
  final List<Produto> listaProduto;

  ProdutoEmpresa(
      {this.empresaId,
      this.razaoSocial,
      this.fantasia,
      this.imagem,
      this.segundaInicio,
      this.segundaFim,
      this.tercaInicio,
      this.tercaFim,
      this.quartaInicio,
      this.quartaFim,
      this.quintaInicio,
      this.quintaFim,
      this.sextaInicio,
      this.sextaFim,
      this.sabadoInicio,
      this.sabadoFim,
      this.domingoInicio,
      this.domingoFim,
      this.listaProduto,
      this.cardVisivel});
}
