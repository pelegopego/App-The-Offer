class Produto {
  final int id;
  final String titulo;
  final String descricao;
  final String imagem;
  final String valor;
  final double valorNumerico;
  final int quantidade;
  final int quantidadeRestante;
  final String dataInicial;
  final String dataFinal;
  final String dataCadastro;
  final int usuarioId;
  final int categoria;
  final int empresa;

  Produto(
      {this.id,
      this.titulo,
      this.descricao,
      this.imagem,
      this.valor,
      this.valorNumerico,
      this.quantidade,
      this.quantidadeRestante,
      this.dataInicial,
      this.dataFinal,
      this.dataCadastro,
      this.usuarioId,
      this.categoria,
      this.empresa});
}
