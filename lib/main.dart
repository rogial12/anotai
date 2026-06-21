import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'repositories/local_nota_repository.dart';
import 'theme/app_theme.dart';
import 'viewmodels/nota_viewmodel.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notas');
  // Pré-carrega as fontes do Google Fonts para evitar FOUT (flash de fonte incorreta)
  await Future.wait([
    GoogleFonts.pendingFonts([
      GoogleFonts.bricolageGrotesque(),
      GoogleFonts.hankenGrotesk(),
    ]),
  ]);
  runApp(const AnotaiApp());
}

// Widget raiz do app — StatelessWidget porque o app em si não tem estado mutável
class AnotaiApp extends StatelessWidget {
  const AnotaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotaViewModel(LocalNotaRepository())..carregarNotas(),
      child: MaterialApp(
        title: 'Anotai',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeView(),
      ),
    );
  }
}
