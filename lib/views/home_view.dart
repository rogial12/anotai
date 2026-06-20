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
          if (viewModel.notas.isEmpty) {
            return const Center(
              child: Text('Nenhuma nota ainda.'),
            );
          }
          return ListView.builder(
            itemCount: viewModel.notas.length,
            itemBuilder: (context, index) {
              final nota = viewModel.notas[index];
              return ListTile(
                title: Text(nota.titulo),
                subtitle: Text(nota.conteudo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
