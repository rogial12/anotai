import 'package:flutter/material.dart';
import '../../../models/categoria.dart';
import '../../styles/app_theme.dart';

// Dialog para renomear uma categoria existente.
// Igual ao NovaCategoriaDialog, mas com o nome atual pré-preenchido.
class RenomearCategoriaDialog extends StatefulWidget {
  final Categoria categoria;
  final Function(String novoNome) onRenomear;

  const RenomearCategoriaDialog({
    super.key,
    required this.categoria,
    required this.onRenomear,
  });

  @override
  State<RenomearCategoriaDialog> createState() =>
      _RenomearCategoriaDialogState();
}

class _RenomearCategoriaDialogState extends State<RenomearCategoriaDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.categoria.nome);
    // Posiciona o cursor no final do texto pré-preenchido
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _podeConfirmar {
    final novo = _controller.text.trim();
    return novo.isNotEmpty && novo != widget.categoria.nome;
  }

  void _confirmar() {
    final novoNome = _controller.text.trim();
    if (novoNome.isEmpty || novoNome == widget.categoria.nome) return;
    widget.onRenomear(novoNome);
    Navigator.of(context).pop();
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
            Text('Renomear categoria', style: AppTheme.sectionTitle),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 20,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) { if (_podeConfirmar) _confirmar(); },
              style: AppTheme.notePreview.copyWith(color: AppTheme.ink),
              decoration: InputDecoration(
                hintText: 'Nome da categoria',
                hintStyle: AppTheme.notePreview.copyWith(color: AppTheme.faint),
                counterStyle: AppTheme.meta,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: AppTheme.paper2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  onPressed: _podeConfirmar ? _confirmar : null,
                  child: Text(
                    'Salvar',
                    style: AppTheme.meta.copyWith(
                      color: _podeConfirmar ? AppTheme.accent : AppTheme.faint,
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
