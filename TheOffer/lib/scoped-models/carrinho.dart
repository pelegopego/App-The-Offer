import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';
import 'package:theoffer/models/itemPedido.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/screens/produtoDetalhado.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:theoffer/screens/finalizarPedido.dart';

mixin CarrinhoModel on Model {
  bool hi = false;

  List<ItemPedido> _listaItensPedido = [];
  Pedido _pedido;
  bool _isLoading = false;

  Map<dynamic, dynamic> objetoItemPedido = Map();

  List<ItemPedido> get listaItensPedido {
    return List.from(listaItensPedido);
  }

  Pedido get pedido {
    return _pedido;
  }

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void limparPedido() {
    if (_pedido != null) {
      _pedido.id = 0;
      _pedido.usuarioId = 0;
      _pedido.dataInclusao = null;
      _pedido.status = 0;
      _pedido.endereco = null;
      _pedido.empresa = 0;
      _pedido.modalidadeEntrega = null;
      _pedido.formaPagamento = null;
      _pedido.horaPrevista = null;
      _pedido.listaItensPedido.clear();
    }
    notifyListeners();
  }

  void getProdutoDetalhe(int id, BuildContext context,
      [bool isSimilarListing = false]) async {
    Map<String, String> headers = getHeaders();
    Map<String, dynamic> responseBody;
    Produto produtoDetalhado = Produto();
    _isLoading = true;
    notifyListeners();
    // setLoading(true);
    print(
        "DETALHAMENTO DE PRODUTO ------> ${Configuracoes.BASE_URL + 'produto/$id'}");
    http.Response response = await http
        .get(Configuracoes.BASE_URL + 'produto/$id/', headers: headers);
    responseBody = json.decode(response.body);
    responseBody['empresas'].forEach((empresaJson) {
      empresaJson['produtos'].forEach((produtoJson) {
        produtoDetalhado = Produto(
            empresa: int.parse(produtoJson['empresa_id']),
            id: int.parse(produtoJson['id']),
            titulo: produtoJson['titulo'],
            descricao: produtoJson['descricao'],
            imagem: produtoJson['imagem'],
            valor: produtoJson['valor'],
            valorNumerico: double.parse(produtoJson['valorNumerico']),
            quantidade: int.parse(produtoJson['quantidade']),
            quantidadeRestante: int.parse(produtoJson['quantidadeRestante']),
            dataInicial: produtoJson['dataInicial'],
            dataFinal: produtoJson['dataFinal'],
            dataCadastro: produtoJson['dataCadastro'],
            usuarioId: int.parse(produtoJson['usuario_id']),
            empresaSegundaInicio: double.parse(empresaJson['segundaInicio']),
            empresaSegundaFim: double.parse(empresaJson['segundaFim']),
            empresaTercaInicio: double.parse(empresaJson['tercaInicio']),
            empresaTercaFim: double.parse(empresaJson['tercaFim']),
            empresaQuartaInicio: double.parse(empresaJson['quartaInicio']),
            empresaQuartaFim: double.parse(empresaJson['quartaFim']),
            empresaQuintaInicio: double.parse(empresaJson['quintaInicio']),
            empresaQuintaFim: double.parse(empresaJson['quintaFim']),
            empresaSextaInicio: double.parse(empresaJson['sextaInicio']),
            empresaSextaFim: double.parse(empresaJson['sextaFim']),
            empresaSabadoInicio: double.parse(empresaJson['sabadoInicio']),
            empresaSabadoFim: double.parse(empresaJson['sabadoFim']),
            empresaDomingoInicio: double.parse(empresaJson['domingoInicio']),
            empresaDomingoFim: double.parse(empresaJson['domingoFim']),
            possuiSabores: int.parse(produtoJson['possuiSabores']) > 0,
            categoria: int.parse(produtoJson['categoria_id']));
      });
    });

    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => TelaProdutoDetalhado(produtoDetalhado));
    if (isSimilarListing) Navigator.pop(context);
    Navigator.push(context, route);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarProduto(
      {int usuarioId, int produtoId, int quantidade, int somar}) async {
    print("QUANTIDADE ADICIONADA AO CARRINHO $quantidade");
    _listaItensPedido.clear();
    _isLoading = true;
    notifyListeners();
    adicionarItemCarrinho(usuarioId, produtoId, quantidade, somar);
    _isLoading = false;
    notifyListeners();
  }

  void comprarProduto(
      {int usuarioId, int produtoId, int quantidade, BuildContext context}) {
    _isLoading = true;
    notifyListeners();
    print("QUANTIDADE COMPRADA $quantidade");
    _listaItensPedido.clear();
    adquirirProduto(usuarioId, produtoId, quantidade, context);
    _isLoading = false;
    notifyListeners();
  }

  void alterarStatus(int pedidoId, int status) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    Map<dynamic, dynamic> objetoCarrinho = Map();
    print("ALTERANDO STATUS DO PEDIDO {$pedidoId, $status}");
    objetoCarrinho = {
      "pedido": pedidoId.toString(),
      "status": status.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/alterarStatus/',
            headers: headers, body: objetoCarrinho)
        .then((response) {
      print("DELETANDO PEDIDO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(pedidoId, Autenticacao.codigoUsuario);
      return responseBody['message'];
    });
  }

  void deletarPedido(int pedidoId, int status) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    Map<dynamic, dynamic> objetoCarrinho = Map();
    print("DELETANDO PEDIDO {$pedidoId, $status}");
    objetoCarrinho = {
      "pedido": pedidoId.toString(),
      "status": status.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/deletarPedido/',
            headers: headers, body: objetoCarrinho)
        .then((response) {
      print("DELETANDO PEDIDO _______");
      if (response.body != '') {
        print(json.decode(response.body).toString());
        responseBody = json.decode(response.body);
        localizarCarrinho(pedidoId, Autenticacao.codigoUsuario);
        return responseBody['message'];
      } else {
        localizarCarrinho(null, Autenticacao.codigoUsuario);
      }
    });
  }

  void removerProdutoPedido(int pedidoId, int usuarioId, int produtoId) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    print("REMOVENDO ITEM DO PEDIDO");
    objetoItemPedido = {
      "pedido": pedidoId.toString(),
      "produto": produtoId.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/removerProdutoPedido/',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      print("REMOVENDO PRODUTO DO PEDIDO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(pedidoId, usuarioId);
      return responseBody['message'];
    });
  }

  void removerProdutoCarrinho(int pedidoId, int usuarioId, int produtoId) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    print("REMOVENDO ITEM DO CARRINHO");
    objetoItemPedido = {
      "pedido": pedidoId.toString(),
      "produto": produtoId.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/removerProdutoCarrinho/',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      print("REMOVENDO PRODUTO DO CARRINHO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(null, usuarioId);
      return responseBody['message'];
    });
  }

  void adicionarItemCarrinho(
      int usuarioId, int produtoId, int quantidade, int somar) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    print("ADICIONANDO ITEM AO CARRINHO");
    objetoItemPedido = {
      "usuario": usuarioId.toString(),
      "produto": produtoId.toString(),
      "quantidade": quantidade.toString(),
      "somar": somar.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/adicionarProdutoCarrinho/',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      print("ADICIONANDO PRODUTO AO CARRINHO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(null, usuarioId);
      return responseBody['message'];
    });
  }

  void adquirirProduto(
      int usuarioId, int produtoId, int quantidade, BuildContext context) {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = getHeaders();
    print("COMPRANDO PRODUTO");
    objetoItemPedido = {
      "usuario": usuarioId.toString(),
      "produto": produtoId.toString(),
      "quantidade": quantidade.toString()
    };
    http
        .post(Configuracoes.BASE_URL + 'pedido/comprarproduto/',
            headers: headers, body: objetoItemPedido)
        .then((response) {
      print("PRODUTO COMPRADO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      if (responseBody['id'] == 0) {
        final snackBar = SnackBar(
            content: Text(responseBody['message']),
            duration: Duration(seconds: 5));
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
            content: Text(responseBody['message']),
            duration: Duration(seconds: 5));
        Scaffold.of(context).showSnackBar(snackBar);
        localizarPedido(
            int.parse(responseBody['id']), Autenticacao.codigoUsuario, 2);
      }
    });
    _isLoading = false;
  }

  Future<bool> localizarCarrinho(int pedidoId, int usuarioId) async {
    print("LOCALIZANDO CARRINHO");
    _isLoading = true;
    notifyListeners();
    Map<dynamic, dynamic> responseBody;
    Produto produto;
    Endereco endereco;
    Bairro bairro;
    Cidade cidade;
    ItemPedido itemPedido;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = getHeaders();
    try {
      _listaItensPedido.clear();
      objetoItemPedido = {
        "usuario": usuarioId.toString(),
        "pedido": pedidoId.toString(),
        "status": 1.toString()
      };
      http.Response response = await http.post(
          Configuracoes.BASE_URL + 'pedido/localizar',
          headers: headers,
          body: objetoItemPedido);

      responseBody = json.decode(response.body);
      if (responseBody['possuiPedidos'] == true) {
        responseBody['pedidos'].forEach((pedidosJson) {
          produto = Produto(
              id: int.parse(pedidosJson['produto_id']),
              titulo: pedidosJson['titulo'],
              descricao: pedidosJson['descricao'],
              imagem: pedidosJson['imagem'],
              valor: pedidosJson['valor'],
              valorNumerico: double.parse(pedidosJson['valorNumerico']),
              quantidade: int.parse(pedidosJson['quantidade']),
              quantidadeRestante: int.parse(pedidosJson['quantidadeRestante']),
              dataInicial: pedidosJson['dataInicial'],
              dataFinal: pedidosJson['dataFinal'],
              dataCadastro: pedidosJson['DataCadastro'],
              usuarioId: int.parse(pedidosJson['usuario_id']));

          itemPedido = ItemPedido(
              pedidoId: int.parse(pedidosJson['pedido_id']),
              produtoId: int.parse(pedidosJson['produto_id']),
              quantidade: int.parse(pedidosJson['quantidade_item']),
              sabores: pedidosJson['sabores_item'],
              produto: produto);
          _listaItensPedido.add(itemPedido);
          notifyListeners();
        });

        if (responseBody['pedidos'][0]['endereco_id'] != null) {
          bairro = Bairro(
              id: int.parse(responseBody['pedidos'][0]['bairro_id']),
              nome: responseBody['pedidos'][0]['nomeBairro']);

          cidade = Cidade(
              id: int.parse(responseBody['pedidos'][0]['cidade_id']),
              nome: responseBody['pedidos'][0]['nomeCidade']);

          endereco = Endereco(
              id: int.parse(responseBody['pedidos'][0]['endereco_id']),
              nome: responseBody['pedidos'][0]['nomeEndereco'],
              cidade: cidade,
              bairro: bairro,
              rua: responseBody['pedidos'][0]['rua'],
              numero: int.parse(responseBody['pedidos'][0]['numero']),
              complemento: responseBody['pedidos'][0]['complemento'],
              referencia: responseBody['pedidos'][0]['referencia'],
              dataCadastro: responseBody['pedidos'][0]['dataCadastroEndereco'],
              dataConfirmacao: responseBody['pedidos'][0]
                  ['dataConfirmacaoEndereco']);
        }
        _pedido = Pedido(
            id: int.parse(responseBody['pedidos'][0]['pedido_id']),
            usuarioId: int.parse(responseBody['pedidos'][0]['usuario_id']),
            empresa: int.parse(responseBody['pedidos'][0]['produto_empresa']),
            dataInclusao: responseBody['pedidos'][0]['dataInclusao'],
            dataConfirmacao: responseBody['pedidos'][0]['dataConfirmacao'],
            status: int.parse(responseBody['pedidos'][0]['status']),
            endereco: endereco,
            listaItensPedido: _listaItensPedido);
      }
      _isLoading = false;
      prefs.setString('numeroItens', _listaItensPedido.length.toString());
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> localizarPedido(int pedidoId, int usuarioId, int status) async {
    print("LOCALIZANDO CARRINHO");
    _isLoading = true;
    notifyListeners();
    Map<dynamic, dynamic> responseBody;
    Produto produto;
    Endereco endereco;
    Bairro bairro;
    Cidade cidade;
    ItemPedido itemPedido;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = getHeaders();
    limparPedido();
    try {
      _listaItensPedido.clear();
      objetoItemPedido = {
        "usuario": usuarioId.toString(),
        "pedido": pedidoId.toString(),
        "status": status.toString()
      };
      http.Response response = await http.post(
          Configuracoes.BASE_URL + 'pedido/localizar',
          headers: headers,
          body: objetoItemPedido);

      responseBody = json.decode(response.body);
      if (responseBody['possuiPedidos'] == true) {
        responseBody['pedidos'].forEach((pedidosJson) {
          produto = Produto(
              id: int.parse(pedidosJson['produto_id']),
              titulo: pedidosJson['titulo'],
              descricao: pedidosJson['descricao'],
              imagem: pedidosJson['imagem'],
              valor: pedidosJson['valor'],
              valorNumerico: double.parse(pedidosJson['valorNumerico']),
              quantidade: int.parse(pedidosJson['quantidade']),
              quantidadeRestante: int.parse(pedidosJson['quantidadeRestante']),
              dataInicial: pedidosJson['dataInicial'],
              dataFinal: pedidosJson['dataFinal'],
              dataCadastro: pedidosJson['DataCadastro'],
              usuarioId: int.parse(pedidosJson['usuario_id']));

          itemPedido = ItemPedido(
              pedidoId: int.parse(pedidosJson['pedido_id']),
              produtoId: int.parse(pedidosJson['produto_id']),
              quantidade: int.parse(pedidosJson['quantidade_item']),
              sabores: pedidosJson['sabores_item'],
              produto: produto);
          _listaItensPedido.add(itemPedido);
          notifyListeners();
        });

        if (responseBody['pedidos'][0]['endereco_id'] != null) {
          bairro = Bairro(
              id: int.parse(responseBody['pedidos'][0]['bairro_id']),
              nome: responseBody['pedidos'][0]['nomeBairro']);

          cidade = Cidade(
              id: int.parse(responseBody['pedidos'][0]['cidade_id']),
              nome: responseBody['pedidos'][0]['nomeCidade']);

          endereco = Endereco(
              id: int.parse(responseBody['pedidos'][0]['endereco_id']),
              nome: responseBody['pedidos'][0]['nomeEndereco'],
              cidade: cidade,
              bairro: bairro,
              rua: responseBody['pedidos'][0]['rua'],
              numero: int.parse(responseBody['pedidos'][0]['numero']),
              complemento: responseBody['pedidos'][0]['complemento'],
              referencia: responseBody['pedidos'][0]['referencia'],
              dataCadastro: responseBody['pedidos'][0]['dataCadastroEndereco'],
              dataConfirmacao: responseBody['pedidos'][0]
                  ['dataConfirmacaoEndereco']);
        }
        _pedido = Pedido(
            id: int.parse(responseBody['pedidos'][0]['pedido_id']),
            usuarioId: int.parse(responseBody['pedidos'][0]['usuario_id']),
            empresa: int.parse(responseBody['pedidos'][0]['produto_empresa']),
            dataInclusao: responseBody['pedidos'][0]['dataInclusao'],
            dataConfirmacao: responseBody['pedidos'][0]['dataConfirmacao'],
            status: int.parse(responseBody['pedidos'][0]['status']),
            endereco: endereco,
            listaItensPedido: _listaItensPedido);
      }

      _isLoading = false;
      prefs.setString('numeroItens', _listaItensPedido.length.toString());
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> localizarPedidoPendente(
      int pedidoId, int usuarioId, int status) async {
    print("LOCALIZANDO CARRINHO");
    _isLoading = true;
    notifyListeners();
    Map<dynamic, dynamic> responseBody;
    Produto produto;
    Endereco endereco;
    Bairro bairro;
    Cidade cidade;
    ItemPedido itemPedido;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = getHeaders();
    limparPedido();
    try {
      _listaItensPedido.clear();
      objetoItemPedido = {
        "usuario": usuarioId.toString(),
        "pedido": pedidoId.toString(),
        "status": status.toString()
      };
      http.Response response = await http.post(
          Configuracoes.BASE_URL + 'pedido/verificarPedidoPendente',
          headers: headers,
          body: objetoItemPedido);

      responseBody = json.decode(response.body);
      if (responseBody['possuiPedidos'] == true) {
        responseBody['pedidos'].forEach((pedidosJson) {
          produto = Produto(
              id: int.parse(pedidosJson['produto_id']),
              titulo: pedidosJson['titulo'],
              descricao: pedidosJson['descricao'],
              imagem: pedidosJson['imagem'],
              valor: pedidosJson['valor'],
              valorNumerico: double.parse(pedidosJson['valorNumerico']),
              quantidade: int.parse(pedidosJson['quantidade']),
              quantidadeRestante: int.parse(pedidosJson['quantidadeRestante']),
              dataInicial: pedidosJson['dataInicial'],
              dataFinal: pedidosJson['dataFinal'],
              dataCadastro: pedidosJson['DataCadastro'],
              usuarioId: int.parse(pedidosJson['usuario_id']));

          itemPedido = ItemPedido(
              pedidoId: int.parse(pedidosJson['pedido_id']),
              produtoId: int.parse(pedidosJson['produto_id']),
              quantidade: int.parse(pedidosJson['quantidade_item']),
              sabores: pedidosJson['sabores_item'],
              produto: produto);
          _listaItensPedido.add(itemPedido);
          notifyListeners();
        });

        if (responseBody['pedidos'][0]['endereco_id'] != null) {
          bairro = Bairro(
              id: int.parse(responseBody['pedidos'][0]['bairro_id']),
              nome: responseBody['pedidos'][0]['nomeBairro']);

          cidade = Cidade(
              id: int.parse(responseBody['pedidos'][0]['cidade_id']),
              nome: responseBody['pedidos'][0]['nomeCidade']);

          endereco = Endereco(
              id: int.parse(responseBody['pedidos'][0]['endereco_id']),
              nome: responseBody['pedidos'][0]['nomeEndereco'],
              cidade: cidade,
              bairro: bairro,
              rua: responseBody['pedidos'][0]['rua'],
              numero: int.parse(responseBody['pedidos'][0]['numero']),
              complemento: responseBody['pedidos'][0]['complemento'],
              referencia: responseBody['pedidos'][0]['referencia'],
              dataCadastro: responseBody['pedidos'][0]['dataCadastroEndereco'],
              dataConfirmacao: responseBody['pedidos'][0]
                  ['dataConfirmacaoEndereco']);
        }
        _pedido = Pedido(
            id: int.parse(responseBody['pedidos'][0]['pedido_id']),
            usuarioId: int.parse(responseBody['pedidos'][0]['usuario_id']),
            empresa: int.parse(responseBody['pedidos'][0]['produto_empresa']),
            dataInclusao: responseBody['pedidos'][0]['dataInclusao'],
            dataConfirmacao: responseBody['pedidos'][0]['dataConfirmacao'],
            status: int.parse(responseBody['pedidos'][0]['status']),
            endereco: endereco,
            listaItensPedido: _listaItensPedido);
      }

      _isLoading = false;
      prefs.setString('numeroItens', _listaItensPedido.length.toString());
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future verificarPedidoPendente(
    int pedidoId,
    int usuarioId,
    BuildContext context,
  ) async {
    print("VERIFICANDO PENDENCIAS");
    limparPedido();
    await localizarPedidoPendente(pedidoId, usuarioId, 2);
    if (pedido != null && pedido.id > 0) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Existe um pedido não finalizado.",
                style: TextStyle(
                    color: Colors.secundariaTheOffer,
                    fontWeight: FontWeight.bold),
              ),
              content: new Text(
                "Você deseja?",
                style: TextStyle(color: Colors.secundariaTheOffer),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: Text(
                    "Visualizar",
                    style: TextStyle(
                        color: Colors.secundariaTheOffer,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    MaterialPageRoute finalizarPedidoRoute = MaterialPageRoute(
                        builder: (context) => TelaFinalizarPedido());
                    Navigator.push(context, finalizarPedidoRoute);
                  },
                ),
                new FlatButton(
                  child: Text(
                    "Excluir",
                    style: TextStyle(
                        color: Colors.secundariaTheOffer,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    deletarPedido(pedido.id, 2);
                  },
                )
              ],
            );
          });
    }
  }

  clearData() async {
    print("CLEAR DATA");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('orderToken', null);
    prefs.setString('orderNumber', null);
    _listaItensPedido.clear();
    _pedido = null;
    notifyListeners();
  }
}
