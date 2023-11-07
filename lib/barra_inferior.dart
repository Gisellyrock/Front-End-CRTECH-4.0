// ignore_for_file: unused_import

import 'package:crtech/avaliacao_cliente.dart';
import 'package:crtech/produtos/produtos.dart';
import 'package:crtech/tela/tela_perfil.dart';
import 'package:crtech/tela/tela_favoritos.dart';
import 'package:flutter/material.dart';
import 'package:crtech/produtos/cadastro_produtos.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;
  List favoritos;

  CustomBottomAppBar({
    required this.onTabSelected,
    required this.selectedIndex,
    required this.favoritos,
  });

  // Método para abrir a página de favoritos
  void _openFavoritesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaFavoritos(favoritos: favoritos),
      ),
    );
  }

// Método para abrir a página de perfil
  void _openProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPerfil(),
      ),
    );
  }

  // Método para abrir a página de perfil
  void _openCadastroProdutos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaginaCadastroProdutos(),
      ),
    );
  }

  // Método para abrir a página de avaliação do cliente
  // void _openAvaliacaoClientePage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AvaliacaoClientePage(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color.fromARGB(239, 238, 237, 237),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => onTabSelected(0),
              color: Colors.pink),
          IconButton(
              icon: const Icon(Icons.favorite), // Ícone de coração
              onPressed: () =>
                  _openFavoritesPage(context), // Abre a página de favoritos
              color: Colors.pink),
          IconButton(
              icon: const Icon(Icons.person), // Ícone de perfil do usuário
              onPressed: () =>
                  _openProfilePage(context), // Abre a página de perfil
              color: Colors
                  .pink // Altere o ícone ativo/inativo conforme necessário
              ),
          IconButton(
              icon: const Icon(Icons.settings), // Ícone de perfil do usuário
              onPressed: () => _openCadastroProdutos(
                  context), // Abre a página de cadastro de produtos
              color: Colors
                  .pink // Altere o ícone ativo/inativo conforme necessário
              ),
        ],
      ),
    );
  }
}
