// ignore_for_file: unused_import, unused_local_variable, must_be_immutable

import 'dart:convert';

import 'package:crtech/appBar.dart';
import 'package:crtech/barra_inferior.dart';
import 'package:crtech/detalhes_produto.dart';
import 'package:crtech/produtos/meus_produtos.dart';
import 'package:crtech/produtos/produtos.dart';
import 'package:crtech/tela/carrrossel.dart';
import 'package:crtech/tela/tela_carrinho.dart';
import 'package:crtech/tela/tela_favoritos.dart';
import 'package:crtech/favoritos_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class PaginaPrincipal extends StatefulWidget {
  final List<Produtos> carrinho;
  List favoritos;
  List listaDeProdutos = MeusProdutos.todosProdutos;

  PaginaPrincipal({Key? key, required this.carrinho, required this.favoritos})
      : super(key: key);

  @override
  _EstadoPaginaPrincipal createState() => _EstadoPaginaPrincipal();
}

class _EstadoPaginaPrincipal extends State<PaginaPrincipal> {
  int isSelected = 0;
  String searchText = "";
  List<Produtos> carrinho = [];

  @override
  void initState() {
    super.initState();
    getProdutosByIndex()
        .then((value) => setState(() => widget.listaDeProdutos = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        flexibleSpace: Column(
          children: [
            Image.asset(
              'assets/logo/logo.jpg', // Caminho da imagem
              width: 90.0,
              height: 90.0,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Carrossel
          Carrossel(),

          // AppBar
          CustomAppBar(
            onCartPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaCarrinho(carrinho: carrinho),
                ),
              );
            },
            onSearchChanged: (text) {
              setState(() {
                searchText = text;
              });
            },
          ),

          // Conteúdo principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
              child: Column(
                children: [
                  construirCategoriasDeProdutos(),
                  Expanded(
                    child: construirProdutosExibidos(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onTabSelected: (index) {
          setState(() {
            isSelected = index;
            getProdutosByIndex().then(
              (value) {
                setState(() {
                  widget.listaDeProdutos = value;
                  searchText = "";
                });
              },
            );
          });
        },
        selectedIndex: isSelected,
        favoritos: widget.favoritos,
      ),
      backgroundColor: Color.fromARGB(239, 238, 237, 237),
    );
  }

  Future<List<Produtos>> getProdutosByIndex() async {
    String url;

    if (isSelected == 1) {
      url = 'http://localhost:8000/api/produtos?categoria=gamer';
    } else if (isSelected == 2) {
      url = 'http://localhost:8000/api/produtos?categoria=network';
    } else if (isSelected == 3) {
      url = 'http://localhost:8000/api/produtos?categoria=hardware';
    } else {
      url = 'http://localhost:8000/api/produtos';
    }

    try {
      var retorno = await http.get(Uri.parse(url));

      if (retorno.statusCode == 200) {
        var dados = await jsonDecode(retorno.body);

        // Lista de produtos
        List<Produtos> produtos = [];

        // Laço de repetição
        for (var obj in dados) {
          Produtos p = Produtos(
            descricao: obj["descricao"] ?? "",
            id: obj["id"] ?? "",
            nome: obj["nome"] ?? "",
            imagem: obj["imagem"] ?? "",
            preco: obj["preco"] ?? 0.0,
            quantidade: obj["quantidade"] ?? 0,
          );
          produtos.add(p);
        }

        // Retorno
        return produtos;
      } else {
        throw Exception('Erro ao obter dados do servidor');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }

  Widget construirCardDeProdutos(Produtos produtos, int index, int id) {
    double _rating = 0.0;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícone de coração para favoritar
              IconButton(
                iconSize: 18.5, // Tamanho do ícone
                icon: Icon(
                  widget.favoritos.contains(produtos)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Color.fromARGB(255, 231, 130, 164),
                ),
                onPressed: () {
                  setState(() {
                    if (widget.favoritos.contains(produtos)) {
                      widget.favoritos.remove(produtos);
                    } else {
                      setState(() {
                        widget.favoritos.add(produtos);
                      });
                    }
                  });
                },
              ),
              // Ícone de carrinho para adicionar ao carrinho
              IconButton(
                iconSize: 18.5, // Tamanho do ícone
                icon: Icon(
                  Icons.add_shopping_cart_sharp,
                  color: Colors.black, // Cor do ícone de carrinho
                ),
                onPressed: () {
                  setState(() {
                    carrinho.add(produtos);
                  });
                  mostrarModalConfirmacao(context);
                },
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesProdutoMaior(
                      produto: produtos,
                    ),
                  ),
                );
              },
              child: Container(
                height: 100,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: produtos.imagem,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    // Handle error loading image
                    print('Error loading image: $error');
                    return Icon(Icons.error);
                  },
                ),
              ),
            ),
          ),
          Text(
            produtos.descricao,
            style: TextStyle(
              fontFamily: GoogleFonts.lato().fontFamily,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(produtos.preco)}',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void mostrarModalConfirmacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Produto adicionado ao carrinho.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.pink, // Define a cor de fundo como rosa
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                    color: Colors.white), // Define a cor do texto como branco
              ),
            ),
          ],
        );
      },
    );
  }

  Widget construirCategoriasDeProdutos() {
    return Container(
      color: Color.fromARGB(239, 238, 237, 237),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            construirCategoriaDeProdutos(index: 0, nome: "Ver tudo"),
            construirCategoriaDeProdutos(index: 1, nome: "Gamer"),
            construirCategoriaDeProdutos(index: 2, nome: "Rede"),
            construirCategoriaDeProdutos(index: 3, nome: "Hardware"),
          ],
        ),
      ),
    );
  }

  Widget construirCategoriaDeProdutos({
    required int index,
    required String nome,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = index;
          getProdutosByIndex()
              .then((value) => setState(() => widget.listaDeProdutos = value));
          searchText = "";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected == index
              ? Colors.pink
              : Color.fromARGB(
                  239, 238, 237, 237), // Use Colors.pink quando selecionado
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          nome,
          style: TextStyle(
            color: isSelected == index
                ? Colors.white
                : Color.fromARGB(255, 25, 26, 25),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget construirProdutosExibidos() {
    List produtosExibidos = [];

    if (searchText.isNotEmpty) {
      produtosExibidos = widget.listaDeProdutos.where((item) {
        return item.descricao
            .toLowerCase() // Converter para minúsculas
            .contains(searchText.toLowerCase().trim());
      }).toList();
    } else {
      produtosExibidos = List.from(widget.listaDeProdutos);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 3 / 3,
      ),
      itemCount: produtosExibidos.length, // Usar a lista filtrada
      itemBuilder: (context, index) {
        final produto = produtosExibidos[index]; // Usar a lista filtrada
        return construirCardDeProdutos(produto, index, produto.id);
      },
    );
  }
}
