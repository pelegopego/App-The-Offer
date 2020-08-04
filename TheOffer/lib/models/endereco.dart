import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';

class Endereco {
  int id;
  String nome;
  int usuarioId;
  Cidade cidade;
  Bairro bairro;
  String rua;
  int numero;
  String complemento;
  String referencia;
  bool favorito;
  String dataCadastro;
  String dataConfirmacao;

  Endereco(
      {this.id,
      this.nome,
      this.usuarioId,
      this.cidade,
      this.bairro,
      this.rua,
      this.numero,
      this.complemento,
      this.referencia,
      this.dataCadastro,
      this.favorito,
      this.dataConfirmacao});
}
