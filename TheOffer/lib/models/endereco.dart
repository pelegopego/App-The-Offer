import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';

class Endereco {
  final int id;
  final String nome;
  final int usuarioId;
  final Cidade cidade;
  final Bairro bairro;
  final String rua;
  final int numero;
  final String complemento;
  final String referencia;
  final DateTime dataCadastro;
  final DateTime dataConfirmacao;
 
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
       this.dataConfirmacao}
  );
}