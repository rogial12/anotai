import 'package:flutter/material.dart';
import '../../../models/categoria.dart';
import '../../styles/app_theme.dart';
import 'renomear_categoria_dialog.dart';

// Hub de gerenciamento de categorias — aberto pelo chip "+".
// Permite criar, renomear e excluir categorias em um só lugar.
// Todas as operações delegam callbacks ao chamador (HomeView), que persiste e recarrega.
class GerenciarCategoriasDialog extends StatefulWidget {
  final List<Categoria> categorias;
  final Function(String nome) onCriar;
  final Function(Categoria cat, String novoNome) onRenomear;
  final Function(Categoria cat) onExcluir;

  const GerenciarCategoriasDialog({
    super.key,
    required this.categorias,
    required this.onCriar,
    required this.onRenomear,
    required this.onExcluir,
  });

  @override
  State<GerenciarCategoriasDialog> createState() =>
      _GerenciarCategoriasDialogState();
}

class _GerenciarCategoriasDialogState
    extends State<GerenciarCategoriasDialog> {
  final TextEditingController _novaController = TextEditingController();

  // Cópia local editável da lista — reflete exclusões/renomeações imediatamente na UI
  late List<Categoria> _categorias;

  @override
  void initState() {
    super.initState();
    _categorias = List<Categoria>.from(widget.categorias);
  }

  @override
  void dispose() {
    _novaController.dispose();
    super.dispose();
  }

  bool get _podeCriar => _novaController.text.trim().isNotEmpty;

  void _criarCategoria() {
    final nome = _novaController.text.trim();
    if (nome.isEmpty) return;
    widget.onCriar(nome);
    _novaController.clear();
    setState(() {});
  }

  void _abrirRenomear(Categoria cat) {
    showDialog(
      context: context,
      builder: (_) => RenomearCategoriaDialog(
        categoria: cat,
        onRenomear: (novoNome) {
          widget.onRenomear(cat, novoNome);
          // Atualiza a cópia local para refletir o novo nome sem fechar o hub
          setState(() {
            final idx = _categorias.indexWhere((c) => c.id == cat.id);
            if (idx != -1) _categorias[idx].nome = novoNome;
          });
        },
      ),
    );
  }

  void _confirmarExclusao(Categoria cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: Text(
          'A categoria "${cat.nome}" será removida de todas as notas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onExcluir(cat);
              setState(() => _categorias.removeWhere((c) => c.id == cat.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMenu),
          boxShadow: AppTheme.shadowPopover,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categorias', style: AppTheme.sectionTitle),
            const SizedBox(height: 16),

            // Lista de categorias existentes
            if (_categorias.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Nenhuma categoria ainda.\nCrie a primeira abaixo.',
                  style: AppTheme.meta.copyWith(color: AppTheme.muted, height: 1.6),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: _categorias.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.nome,
                                style: AppTheme.notePreview
                                    .copyWith(color: AppTheme.ink),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Botão renomear
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: AppTheme.muted,
                              onPressed: () => _abrirRenomear(cat),
                              tooltip: 'Renomear',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            // Botão excluir
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: AppTheme.danger,
                              onPressed: () => _confirmarExclusao(cat),
                              tooltip: 'Excluir',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const Divider(color: AppTheme.line2, height: 24),

            // Campo para criar nova categoria
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _novaController,
                    maxLength: 20,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) { if (_podeCriar) _criarCategoria(); },
                    style: AppTheme.notePreview.copyWith(color: AppTheme.ink),
                    decoration: InputDecoration(
                      hintText: 'Nova categoria',
                      hintStyle:
                          AppTheme.notePreview.copyWith(color: AppTheme.faint),
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      filled: true,
                      fillColor: AppTheme.paper2,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        borderSide: const BorderSide(color: AppTheme.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        borderSide: const BorderSide(color: AppTheme.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        borderSide: const BorderSide(color: AppTheme.accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão "Criar" inline
                TextButton(
                  onPressed: _podeCriar ? _criarCategoria : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Criar',
                    style: AppTheme.meta.copyWith(
                      color: _podeCriar ? AppTheme.accent : AppTheme.faint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Fechar',
                  style: AppTheme.meta.copyWith(color: AppTheme.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
