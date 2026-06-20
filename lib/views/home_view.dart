import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nota_viewmodel.dart';
import 'editor_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotai'),
      ),
      body: Consumer<NotaViewModel>(
        builder: (context, viewModel, _) {
          // Se não há notas, exibe mensagem vazia
          if (viewModel.notas.isEmpty) {
            return const Center(
              child: Text('Nenhuma nota ainda.'),
            );
          }
          // Lista todas as notas ativas (não arquivadas, não deletadas)
          return ListView.builder(
            itemCount: viewModel.notas.length,
            itemBuilder: (context, index) {
              final nota = viewModel.notas[index];
              // Cada nota é um ListTile clicável que leva para a EditorView
              return ListTile(
                title: Text(nota.titulo),
                subtitle: Text(nota.conteudo),
                onTap: () {
                  // Define qual nota está sendo editada no ViewModel
                  viewModel.setNotaEmEdicao(nota);
                  // Navega para a EditorView (modo edição)
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditorView()),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Limpa a nota em edição (null = modo criação)
          Provider.of<NotaViewModel>(context, listen: false)
              .setNotaEmEdicao(null);
          // Navega para a EditorView (modo criação)
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorView()),
          );
        },
        tooltip: 'Nova nota',
        child: const Icon(Icons.add),
      ),
    );
  }
}
