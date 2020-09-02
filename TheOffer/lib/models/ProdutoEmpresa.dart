import 'package:flutter/material.dart';
import 'package:theoffer/models/Produto.dart';

class ProdutoEmpresa {
  final int empresaId;
  final String razaoSocial;
  final String fantasia;
  final String imagem;
  final double horaInicio;
  final double horaFim;
  final List<Produto> listaProduto;

  ProdutoEmpresa(
      {this.empresaId,
      this.razaoSocial,
      this.fantasia,
      this.imagem,
      this.horaInicio,
      this.horaFim,
      this.listaProduto});
}
