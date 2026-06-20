# Anotai

Um app de anotações offline-first construído com Flutter como projeto de aprendizado prático.

## Sobre

Anotai é um exercício pedagógico: um app real sendo desenvolvido do zero com foco em
arquitetura de software, boas práticas e versionamento com Git.

## Status

Em desenvolvimento — construção do MVP.

## Funcionalidades

**MVP (em desenvolvimento)**
- Escrita, edição e salvamento de anotações em texto
- Suporte a imagens nas anotações
- Arquivamento de anotações em pasta dedicada
- Lixeira com exclusão permanente após 30 dias
- Marcação de favoritas
- Busca por título ou conteúdo

**Planejado para o futuro**
- Plataforma Android
- Sincronização entre dispositivos

## Tech Stack

- **Flutter / Dart**
- **Hive** — armazenamento local
- **Provider** — gerenciamento de estado

## Arquitetura

Padrão **MVVM**, organizado em:

```
lib/
├── models/         # Classes de dados
├── views/          # Telas (UI)
├── viewmodels/     # Lógica de estado (ChangeNotifier)
├── repositories/   # Acesso a dados (Repository Pattern)
└── services/       # Serviços futuros (busca, exportação, etc.)
```

## Como rodar localmente

**Pré-requisitos**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Google Chrome

**Instalação**
```bash
git clone https://github.com/rogial12/anotai.git
cd anotai
flutter pub get
flutter run -d chrome
```
