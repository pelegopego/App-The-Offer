import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theoffer/models/endereco.dart';
import 'package:theoffer/models/cidade.dart';
import 'package:theoffer/models/bairro.dart';
import 'package:theoffer/models/itemPedido.dart';
import 'package:theoffer/models/Pedido.dart';
import 'package:theoffer/models/payment_methods.dart';
import 'package:theoffer/models/Produto.dart';
import 'package:theoffer/screens/autenticacao.dart';
import 'package:theoffer/screens/produtoDetalhado.dart';
import 'package:theoffer/utils/constants.dart';
import 'package:theoffer/utils/headers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

mixin CarrinhoModel on Model {
  bool hi = false;

  List<ItemPedido> _listaItensPedido = [];
  Pedido _pedido;
  bool _isLoading = false;
  List<PaymentMethod> _paymentMethods = [];

  Map<dynamic, dynamic> objetoItemPedido = Map();

  List<ItemPedido> get listaItensPedido {
    return List.from(listaItensPedido);
  }

  Pedido get pedido {
    return _pedido;
  }

  List<PaymentMethod> get paymentMethods {
    return List.from(_paymentMethods);
  }

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void getProdutoDetalhe(int id, BuildContext context,
      [bool isSimilarListing = false]) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody;
    Produto produtoDetalhado = Produto();
    _isLoading = true;
    notifyListeners();
    // setLoading(true);
    print(
        "DETALHAMENTO DE PRODUTO ------> ${Configuracoes.BASE_URL + 'produto/$id'}");
    http.Response response = await http.get(Configuracoes.BASE_URL + 'produto/$id/', headers: headers);
    responseBody = json.decode(response.body);
    responseBody['empresas'].forEach((empresaJson) {
      empresaJson['produtos'].forEach((produtoJson) {
        produtoDetalhado = Produto(
            id                    : int.parse(produtoJson['id']),
            titulo                : produtoJson['titulo'],
            descricao             : produtoJson['descricao'],
            imagem                : produtoJson['imagem'],
            valor                 : produtoJson['valor'],
            valorNumerico         : double.parse(produtoJson['valorNumerico']),
            quantidade            : int.parse(produtoJson['quantidade']),
            quantidadeRestante    : int.parse(produtoJson['quantidadeRestante']),
            dataInicial           : produtoJson['dataInicial'],
            dataFinal             : produtoJson['dataFinal'],
            dataCadastro          : produtoJson['dataCadastro'],
            modalidadeRecebimento1: int.parse(produtoJson['modalidadeRecebimento1']),
            modalidadeRecebimento2: int.parse(produtoJson['modalidadeRecebimento2']),
            usuarioId             : int.parse(produtoJson['usuario_id'])
          );
          });
      });

    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => TelaProdutoDetalhado(produtoDetalhado));
    if (isSimilarListing) Navigator.pop(context);
    Navigator.push(context, route);
    _isLoading = false;
    notifyListeners();
  }

  void adicionarProduto({int usuarioId, int produtoId, int quantidade, int somar}) async {
    print("QUANTIDADE ADICIONADA AO CARRINHO $quantidade");
    _listaItensPedido.clear();
    _isLoading = true;
    notifyListeners();
    adicionarItemCarrinho(usuarioId, produtoId, quantidade, somar);
    _isLoading = false;
    notifyListeners(); 
  }

  void comprarProduto({int usuarioId, int produtoId, int quantidade})  {
    _isLoading = true;
    pedido.id = null;
    notifyListeners();
    print("QUANTIDADE COMPRADA $quantidade");
    _listaItensPedido.clear();
    adquirirProduto(usuarioId, produtoId, quantidade);
    _isLoading = false;
    notifyListeners(); 
  }

  void removerProdutoCarrinho(int pedidoId, int usuarioId, int produtoId) async {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = await getHeaders();
    print("REMOVENDO ITEM DO CARRINHO");
        objetoItemPedido = {
          "pedido": pedidoId.toString(), "produto": produtoId.toString()
        };
    http
        .post(
            Configuracoes.BASE_URL + 'pedido/removerProdutoCarrinho/',
            headers: headers,
            body: objetoItemPedido)
        .then((response) {
      print("REMOVENDO PRODUTO DO CARRINHO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(null, usuarioId);
      return responseBody['message'];  
    });
  }

  void adicionarItemCarrinho(int usuarioId, int produtoId, int quantidade, int somar) async {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = await getHeaders();
    print("ADICIONANDO ITEM AO CARRINHO");
        objetoItemPedido = {
          "usuario": usuarioId.toString(), "produto": produtoId.toString(), "quantidade": quantidade.toString(), "somar": somar.toString()
        };
    http
        .post(
            Configuracoes.BASE_URL + 'pedido/adicionarProdutoCarrinho/',
            headers: headers,
            body: objetoItemPedido)
        .then((response) {
      print("ADICIONANDO PRODUTO AO CARRINHO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarCarrinho(null, usuarioId);
      return responseBody['message'];  
    });
  }

  void adquirirProduto(int usuarioId, int produtoId, int quantidade) async {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = await getHeaders();
    print("ADQUIRINDO PRODUTO");
        objetoItemPedido = {
          "usuario": usuarioId.toString(), "produto": produtoId.toString(), "quantidade": quantidade.toString()
        };
    http
        .post(
            Configuracoes.BASE_URL + 'pedido/comprarproduto/',
            headers: headers,
            body: objetoItemPedido)
        .then((response) {
      print("ADQUIRINDO PRODUTO _______");
      print(json.decode(response.body).toString());
      responseBody = json.decode(response.body);
      localizarPedido(int.parse(responseBody['id']), Autenticacao.CodigoUsuario, 2);  
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
    Map<String, String> headers = await getHeaders();
    try {
      _listaItensPedido.clear();
      objetoItemPedido = {
        "usuario": usuarioId.toString(), "pedido": pedidoId.toString(), "status": 1.toString()
      };
      http.Response response =
          await http.post(Configuracoes.BASE_URL + 'pedido/localizar', headers: headers,
          body: objetoItemPedido);
          
      responseBody = json.decode(response.body);
      responseBody['pedidos'].forEach((pedidosJson) {
             produto = Produto(
              id                    : int.parse(pedidosJson['produto_id']),
              titulo                : pedidosJson['titulo'],
              descricao             : pedidosJson['descricao'],
              imagem                : pedidosJson['imagem'],
              valor                 : pedidosJson['valor'],
              valorNumerico         : double.parse(pedidosJson['valorNumerico']),
              quantidade            : int.parse(pedidosJson['quantidade']), 
              quantidadeRestante    : int.parse(pedidosJson['quantidadeRestante']),
              dataInicial           : pedidosJson['dataInicial'],
              dataFinal             : pedidosJson['dataFinal'],
              dataCadastro          : pedidosJson['DataCadastro'],
              modalidadeRecebimento1: int.parse(pedidosJson['modalidadeRecebimento1']),
              modalidadeRecebimento2: int.parse(pedidosJson['modalidadeRecebimento2']),
              usuarioId             : int.parse(pedidosJson['usuario_id'])
              );
          
            itemPedido = ItemPedido(
                pedidoId  : int.parse(pedidosJson['pedido_id']),
                produtoId : int.parse(pedidosJson['produto_id']),
                quantidade: int.parse(pedidosJson['quantidade_item']),
                produto: produto);
            _listaItensPedido.add(itemPedido);
        notifyListeners();
       });   

      if (responseBody['pedidos'][0]['endereco_id'] != null) { 
          bairro  = Bairro(
            id  : int.parse(responseBody['pedidos'][0]['bairro_id']),
            nome: responseBody['pedidos'][0]['nomeBairro']
          );      
          
          cidade  = Cidade(
            id  : int.parse(responseBody['pedidos'][0]['cidade_id']),
            nome: responseBody['pedidos'][0]['nomeCidade']
          );

          endereco = Endereco(
              id             : int.parse(responseBody['pedidos'][0]['endereco_id']),
              nome           : responseBody['pedidos'][0]['nomeEndereco'],
              cidade         : cidade,
              bairro         : bairro,
              rua            : responseBody['pedidos'][0]['rua'],
              numero         : int.parse(responseBody['pedidos'][0]['numero']),
              complemento    : responseBody['pedidos'][0]['complemento'], 
              referencia     : responseBody['pedidos'][0]['referencia'],
              dataCadastro   : DateTime.parse(responseBody['pedidos'][0]['dataCadastroEndereco']),
              dataConfirmacao: DateTime.parse(responseBody['pedidos'][0]['dataConfirmacaoEndereco'])
          );
      }
      _pedido = Pedido(
          id              : int.parse(responseBody['pedidos'][0]['pedido_id']),
          usuarioId       : int.parse(responseBody['pedidos'][0]['usuario_id']),
          dataInclusao    : responseBody['pedidos'][0]['dataInclusao'],
          dataConfirmacao : responseBody['pedidos'][0]['dataConfirmacao'],
          status          : int.parse(responseBody['pedidos'][0]['status']),
          endereco        : endereco,
          listaItensPedido: _listaItensPedido);

      _isLoading = false;
      prefs.setString('numeroItens', _listaItensPedido.length.toString());
      prefs.setString('orderToken', responseBody['token']);
      prefs.setString('orderNumber', responseBody['number']);
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
    Map<String, String> headers = await getHeaders();
    try {
      _listaItensPedido.clear();
      objetoItemPedido = {
        "usuario": usuarioId.toString(), "pedido": pedidoId.toString(), "status": status.toString()
      };
      http.Response response =
          await http.post(Configuracoes.BASE_URL + 'pedido/localizar', headers: headers,
          body: objetoItemPedido);
          
      responseBody = json.decode(response.body);
      responseBody['pedidos'].forEach((pedidosJson) {
             produto = Produto(
              id                    : int.parse(pedidosJson['produto_id']),
              titulo                : pedidosJson['titulo'],
              descricao             : pedidosJson['descricao'],
              imagem                : pedidosJson['imagem'],
              valor                 : pedidosJson['valor'],
              valorNumerico         : double.parse(pedidosJson['valorNumerico']),
              quantidade            : int.parse(pedidosJson['quantidade']), 
              quantidadeRestante    : int.parse(pedidosJson['quantidadeRestante']),
              dataInicial           : pedidosJson['dataInicial'],
              dataFinal             : pedidosJson['dataFinal'],
              dataCadastro          : pedidosJson['DataCadastro'],
              modalidadeRecebimento1: int.parse(pedidosJson['modalidadeRecebimento1']),
              modalidadeRecebimento2: int.parse(pedidosJson['modalidadeRecebimento2']),
              usuarioId             : int.parse(pedidosJson['usuario_id'])
              );
          
            itemPedido = ItemPedido(
                pedidoId  : int.parse(pedidosJson['pedido_id']),
                produtoId : int.parse(pedidosJson['produto_id']),
                quantidade: int.parse(pedidosJson['quantidade_item']),
                produto: produto);
            _listaItensPedido.add(itemPedido);
        notifyListeners();
       });   

      if (responseBody['pedidos'][0]['endereco_id'] != null) { 
          bairro  = Bairro(
            id  : int.parse(responseBody['pedidos'][0]['bairro_id']),
            nome: responseBody['pedidos'][0]['nomeBairro']
          );      
          
          cidade  = Cidade(
            id  : int.parse(responseBody['pedidos'][0]['cidade_id']),
            nome: responseBody['pedidos'][0]['nomeCidade']
          );

          endereco = Endereco(
              id             : int.parse(responseBody['pedidos'][0]['endereco_id']),
              nome           : responseBody['pedidos'][0]['nomeEndereco'],
              cidade         : cidade,
              bairro         : bairro,
              rua            : responseBody['pedidos'][0]['rua'],
              numero         : int.parse(responseBody['pedidos'][0]['numero']),
              complemento    : responseBody['pedidos'][0]['complemento'], 
              referencia     : responseBody['pedidos'][0]['referencia'],
              dataCadastro   : DateTime.parse(responseBody['pedidos'][0]['dataCadastroEndereco']),
              dataConfirmacao: DateTime.parse(responseBody['pedidos'][0]['dataConfirmacaoEndereco'])
          );
      }
      _pedido = Pedido(
          id              : int.parse(responseBody['pedidos'][0]['pedido_id']),
          usuarioId       : int.parse(responseBody['pedidos'][0]['usuario_id']),
          dataInclusao    : responseBody['pedidos'][0]['dataInclusao'],
          dataConfirmacao : responseBody['pedidos'][0]['dataConfirmacao'],
          status          : int.parse(responseBody['pedidos'][0]['status']),
          endereco        : endereco,
          listaItensPedido: _listaItensPedido);

      _isLoading = false;
      prefs.setString('numeroItens', _listaItensPedido.length.toString());
      prefs.setString('orderToken', responseBody['token']);
      prefs.setString('orderNumber', responseBody['number']);
      notifyListeners();
    return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
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
