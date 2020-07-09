import 'package:theoffer/models/Produto.dart';

class CategoriaDetalhada {
   int    id;
   String nome;
   String imagem;
   List<Produto> listaProduto;

  CategoriaDetalhada(
    {this.id,
    this.nome,
    this.imagem,
    this.listaProduto});
}

class EmpresaDetalhada {
   int    id;
   String razaoSocial;
   String fantasia;
   String imagem;
   List<CategoriaDetalhada> listaCategoria;

  EmpresaDetalhada(
    {this.id,
    this.razaoSocial,
    this.fantasia,
    this.imagem,
    this.listaCategoria});
}