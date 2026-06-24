import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'repositories/local_nota_repository.dart';
import 'services/archive_service.dart';
import 'services/favorite_service.dart';
import 'services/note_editor_service.dart';
import 'services/trash_service.dart';
import 'viewmodels/nota_viewmodel.dart';
import 'ui/views/home_view.dart';
import 'ui/styles/app_theme.dart';

// Ponto de entrada do app — equivalente ao main() em Java
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notas');
  runApp(const AnotaiApp());
}

// Widget raiz do app — StatelessWidget porque o app em si não tem estado mutável
class AnotaiApp extends StatelessWidget {
  const AnotaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        // Cria o repositório uma vez e o compartilha entre ViewModel e serviços
        final repo = LocalNotaRepository();
        return NotaViewModel(
          repo,
          noteEditorService: NoteEditorService(repo),
          archiveService: ArchiveService(repo),
          trashService: TrashService(repo),
          favoriteService: FavoriteService(repo),
        )..carregarNotas();
      },
      child: MaterialApp(
        title: 'Anotai',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.paper,
          colorScheme: ColorScheme.light(
            primary: AppTheme.accent,
            onPrimary: AppTheme.accentFg,
            surface: AppTheme.card,
            onSurface: AppTheme.ink,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.card,
            foregroundColor: AppTheme.ink,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          dividerColor: AppTheme.line,
          cardColor: AppTheme.card,
        ),
        home: const HomeView(),
      ),
    );
  }
}
