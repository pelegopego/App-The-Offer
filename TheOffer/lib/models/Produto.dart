class Produto {
     final int id;
    final String titulo;
    final String descricao;
    final String imagem;
    final String valor;
    final double quantidade;
  final String dataInicial;
  final String dataFinal;
  final String dataCadastro;
       final int modalidadeRecebimento1;
       final int modalidadeRecebimento2;
       final int usuarioId;

  Produto(
    {this.id,
    this.titulo,
    this.descricao,
    this.imagem,    
    this.valor,
    this.quantidade,
    this.dataInicial,
    this.dataFinal,
    this.dataCadastro,
    this.modalidadeRecebimento1,
    this.modalidadeRecebimento2,
    this.usuarioId});
}