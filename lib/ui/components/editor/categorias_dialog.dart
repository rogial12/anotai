import 'package:flutter/material.dart';
import '../../../models/categoria.dart';
import '../../../models/nota.dart';
import '../../styles/app_theme.dart';

// Dialog de associação de categorias a uma nota.
// Exibe a lista de categorias criadas pelo usuário com checkboxes.
// Mudanças só são salvas ao confirmar — cancelar descarta tudo.
class CategoriasDialog extends StatefulWidget {
  final Nota nota;
  final List<Categoria> categorias;
  final Function(List<String> ids) onSalvar;

  const CategoriasDialog({
    super.key,
    required this.nota,
    required this.categorias,
    required this.onSalvar,
  });

  @override
  State<CategoriasDialog> createState() => _CategoriasDialogState();
}

class _CategoriasDialogState extends State<CategoriasDialog> {
  // Cópia local das categorias selecionadas — só atualiza a nota ao confirmar
  late Set<String> _selecionadas;

  @override
  void initState() {
    super.initState();
    _selecionadas = Set<String>.from(widget.nota.categoriaIds);
  }

  void _toggle(String id) {
    setState(() {
      if (_selecionadas.contains(id)) {
        _selecionadas.remove(id);
      } else {
        _selecionadas.add(id);
      }
    });
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

            if (widget.categorias.isEmpty)
              // Estado vazio — nenhuma categoria criada ainda
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhuma categoria criada ainda.\nToque em + na tela inicial para criar uma.',
                  style: AppTheme.meta.copyWith(color: AppTheme.muted, height: 1.6),
                ),
              )
            else
              // Lista de categorias com checkbox
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.categorias.map((cat) {
                      return CheckboxListTile(
                        value: _selecionadas.contains(cat.id),
                        onChanged: (_) => _toggle(cat.id),
                        title: Text(
                          cat.nome,
                          style: AppTheme.notePreview.copyWith(color: AppTheme.ink),
                        ),
                        activeColor: AppTheme.accent,
                        checkColor: AppTheme.accentFg,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTheme.meta.copyWith(color: AppTheme.muted),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    widget.onSalvar(_selecionadas.toList());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Salvar',
                    style: AppTheme.meta.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
