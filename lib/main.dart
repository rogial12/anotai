import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'repositories/local_nota_repository.dart';
import 'viewmodels/nota_viewmodel.dart';
import 'views/home_view.dart';

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
      create: (_) => NotaViewModel(LocalNotaRepository())..carregarNotas(),
      child: MaterialApp(
        title: 'Anotai',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: const HomeView(),
      ),
    );
  }
}
