import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Dialog para criação de uma nova categoria.
// Recebe onCriar — quem chama decide o que fazer com o nome (persistir, recarregar, etc).
class NovaCategoriaDialog extends StatefulWidget {
  final Function(String nome) onCriar;

  const NovaCategoriaDialog({super.key, required this.onCriar});

  @override
  State<NovaCategoriaDialog> createState() => _NovaCategoriaDialogState();
}

class _NovaCategoriaDialogState extends State<NovaCategoriaDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _podeConfirmar => _controller.text.trim().isNotEmpty;

  void _confirmar() {
    final nome = _controller.text.trim();
    if (nome.isEmpty) return;
    widget.onCriar(nome);
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
            Text('Nova categoria', style: AppTheme.sectionTitle),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true, // teclado abre automaticamente ao exibir o dialog
              maxLength: 20,
              onChanged: (_) => setState(() {}), // rebuild para atualizar estado do botão
              onSubmitted: (_) { if (_podeConfirmar) _confirmar(); },
              style: AppTheme.notePreview.copyWith(color: AppTheme.ink),
              decoration: InputDecoration(
                hintText: 'Nome da categoria',
                hintStyle: AppTheme.notePreview.copyWith(color: AppTheme.faint),
                counterStyle: AppTheme.meta,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                    'Criar',
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
