# Anotai

## Sobre o projeto

Anotai é um aplicativo de anotações multi-dispositivo (inicialmente web, com plano de expansão para Android), com sincronização entre dispositivos planejada para uma fase futura. É um app de anotações básico: criação rápida de notas em texto, com suporte a imagens e salvamento automático local.

## ⚠️ Contexto pedagógico — LEIA ANTES DE QUALQUER COISA

Este projeto é, antes de tudo, um **exercício de aprendizagem**. O desenvolvedor (Igor) está retomando a prática de programação depois de um tempo afastado, e os objetivos principais deste projeto são:

1. **Reaprender a programar** na prática, com um projeto real e aplicável
2. **Praticar modelagem de projeto e arquitetura de software**
3. **Praticar versionamento com Git** desde o primeiro commit

Por isso, as seguintes regras são **obrigatórias** em qualquer interação:

- **NUNCA aplique mudanças no código sem consentimento explícito do usuário.** Sempre apresente o plano ou o diff e espere aprovação antes de escrever/editar arquivos, mesmo para mudanças pequenas ou "óbvias".
- **Priorize explicações didáticas sobre execução automática.** Ao sugerir uma mudança, explique o raciocínio por trás dela (por que essa abordagem, quais alternativas existem, que conceito está sendo aplicado) — não apenas entregue o código pronto.
- **Não tome decisões de arquitetura sozinho.** Se uma tarefa exigir uma escolha de design (ex: como estruturar uma classe, qual padrão usar), apresente opções com prós/contras e pergunte, em vez de decidir e implementar diretamente.
- **Trate erros como oportunidades de ensino.** Ao corrigir um bug, explique a causa raiz antes de aplicar a correção, para que o usuário entenda o "porquê", não só o "o quê".
- **Vá no ritmo do usuário.** Prefira tarefas menores e incrementais a grandes blocos de código de uma vez, para que o aprendizado acompanhe a implementação.

## Stack

- **Framework**: Flutter (Dart)
- **Plataforma inicial**: Web
- **Plataforma futura**: Android
- **Sincronização entre dispositivos**: planejada para fase posterior (após Web + Android estarem funcionais)

## Arquitetura

Padrão **MVVM (Model-View-ViewModel)**, organizado da seguinte forma dentro de `lib/`:

```
lib/
├── models/        # Classes de dados (ex: Nota)
├── views/         # Telas (UI)
├── viewmodels/    # Lógica de conexão entre Model e View (estado observável)
├── services/      # Funcionalidades como salvamento local, busca, exportação, etc.
└── main.dart
```

## Funcionalidades planejadas (MVP)

- Tela inicial com lista de anotações salvas
- Criação e edição de anotações em texto, com suporte a imagens
- Salvamento automático local
- Lixeira: anotações apagadas ficam disponíveis por até 30 dias antes da exclusão definitiva (ou exclusão manual antecipada)
- Exportação de anotações em formato PDF
- Busca por título ou conteúdo na tela inicial
- Marcação de anotações como favoritas
- Arquivamento de anotações (pasta separada da principal)

## Requisitos não-funcionais relevantes

- **Offline-first**: o app deve funcionar plenamente sem conexão à internet, já que o salvamento é local
- **Performance**: busca deve retornar resultados rapidamente mesmo com muitas notas; salvamento automático não deve travar a digitação
- **Portabilidade**: código estruturado para futura adaptação ao Android sem necessidade de reescrita
- **Manutenibilidade**: estrutura em camadas (MVVM) para facilitar evolução futura (Android, sincronização)

## Padrões de projeto em uso

- **Repository Pattern**: camada de abstração entre a lógica do app e a origem dos dados (local hoje, possivelmente remota no futuro)
- **Soft Delete**: exclusão lógica (marcação de "apagado em [data]") para viabilizar a lixeira de 30 dias
- **Observer / Reactive State**: a View reage automaticamente a mudanças no ViewModel (nativo do Flutter)
- **Sync Queue / Outbox Pattern**: reservado para a fase de sincronização entre dispositivos (ainda não implementado)

## Convenções de nomenclatura

- Nomes de projeto/pastas em `snake_case` (convenção Dart)
- Commits em Git devem ser descritivos e, idealmente, seguir um padrão simples e consistente (a definir/registrar conforme uso)
