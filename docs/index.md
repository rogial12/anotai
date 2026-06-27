# Anotai: um app de notas feito por quem nunca programou de verdade

Publicado originalmente em 27/06/2026

A programação nunca foi meu forte, mas minha jornada acadêmica nunca se distanciou tanto desse tema. As várias tentativas de aprender a codificar foram frustradas, exceto pelas provas em que fui obrigado a decorar código em Java para transformar diagramas de classes prontos em código rudimentar escrito em papel. Provavelmente, não foi o melhor método de ensino – e, por isso, o trauma.

Apesar disso, a gestão de processos, o design de sistemas e o gerenciamento de produtos sempre estiveram no meu radar. O assunto parece unir aquilo que sei fazer de melhor – comunicar, interpretar e vislumbrar projetos – com aquilo que estudo todos os dias na faculdade. Porém, todas as tentativas de pisar nisso pareciam empacadas na etapa de documentação – diagramas de classe, fluxogramas, BPMNs e mais. Nunca consegui ir para além disso.

Até que conheci o Claude Code.

Percebi no chatbot da Anthropic a oportunidade de levar minhas decisões de alto nível para um bot codificador responsável pela sintaxe e pela troca de ideias. Então, surgiu a ideia: e se eu colocar meu conhecimento universitário em prática usando o Claude Code para codificar meu projeto?

Daí, nasceu o Anotai.

---

O Anotai não é um projeto exótico, tampouco inédito: é um aplicativo de notas e nada mais. Nele, o usuário final pode criar, salvar e editar anotações – e só. Era a oportunidade perfeita de colocar parte do meu conhecimento de arquitetura de software em algo palpável.

## O que é o Anotai?

Anotai é um exercício pedagógico: um app real sendo desenvolvido do zero com foco em arquitetura de software, boas práticas e versionamento com Git.

O projeto foi concebido para ser usado na web e no mobile (Android). Portanto, foram escolhidos Flutter e Dart como framework e linguagem principal do aplicativo, garantindo compatibilidade com diferentes plataformas com uma única base de código. Neste primeiro momento, a persistência foi atribuída ao Hive, banco de dados NoSQL leve com boa performance e nativo do Dart.

Para a arquitetura, embora eu fosse mais familiarizado com o MVC (Model-View-Controller), optei por desenhar o Anotai em MVVM (Model-View-ViewModel), aparentemente mais moderno e adaptável para as necessidades de um aplicativo em Flutter. O Claude endossou essa ideia, confirmando que seria suficiente para o MVP.

O desenvolvimento está dividido em quatro fases:

- **Fase 1 (concluída):** criação e edição de notas com título e conteúdo em texto, salvamento automático com debounce de 5 segundos, tela principal com três abas (Anotações, Arquivo, Lixeira), possibilidade de marcar notas como favoritas, possibilidade de arquivar notas para melhor organização, e soft-delete com deleção permanente em 30 dias.
- **Fase 2 (em andamento):** UI/UX mais refinada e com linguagem de design consistente, chips de categorias (Favoritas, categorias customizadas), diálogo de confirmação com Undo de exclusão, testes automatizados e modo escuro.
- **Fase 3:** exportação em PDF, exportação e backup manual, suporte a imagens nas anotações, histórico de versões, lock/unlock de notas e anotações criptografadas.
- **Fase 4:** autenticação biométrica para acesso ao app, sincronização entre dispositivos (Android + Web) e resolução de conflitos de sincronização.

---

Em vez de entregar toda a responsabilidade ao Claude Code, optei por acompanhar o processo cuidadosamente. Para isso, determinei que ele não fizesse mudanças drásticas sem autorização e que deixasse observações em todas as linhas de código do projeto. Naturalmente, o Anotai fica com aspecto de software universitário, mas essa é realmente a proposta. Além disso, ordenei que o Claude não tomasse decisões de arquitetura sem me consultar e sempre fiz perguntas antes de cada alteração, sobre cada aspecto do projeto, e pedi para ele me explicar como construiu cada método.

Isso deixou o fluxo de desenvolvimento bem mais lento, mas sempre sob meu controle – afinal, estou estudando. Eu não queria me tornar refém do chatbot ou acabar caindo no vibe coding em termos de ausência de controle. Quero ser arquiteto do projeto, e por isso o Claude precisa ser acompanhado de perto.

Além disso, o Anotai serviu como oportunidade para treinar o fluxo do Git, importante ferramenta de controle de versões. Cada mudança no código foi acompanhada por commits bem descritos, embora com padrão pouco consistente.

## O "alpha" do Anotai

A primeira versão do Anotai era rudimentar. O primeiro objetivo era ver o aplicativo rodando. Para tanto, foi desenvolvida uma estrutura básica para o Anotai: duas classes para UI – EditorView e HomeView –, uma única ViewModel NotaViewModel, a Nota e uma interface NotaRepository para efetivação do Repository Pattern, necessário para garantir a troca do banco de dados escolhido sem alterações em outras partes da estrutura.

O aplicativo executa bem, mas é feio. Os objetivos iniciais, porém, foram bem atendidos: é possível criar, editar e salvar uma nota com bastante facilidade. Os fluxos de criação/edição seguem convenções da categoria de apps de notas, mas a UX é significativamente menos polida do que alternativas mais populares.

## O deslize da UI

A construção da UI foi feita pela recente ferramenta Claude Design. Na primeira iteração, ele criou uma interface de um app de notas voltado para a exibição web, mas com fácil adaptabilidade para o mobile.

De primeira, não imaginei que a implementação de uma UI fosse ser trabalhosa, portanto demandei um arquivo de handoff ao Claude Design e o entreguei para análise do Claude Code. Sem pensar muito, pedi para que todas as alterações fossem implementadas de uma vez, e aí aconteceu o primeiro deslize grave: toda a UI foi implementada com defeitos.

Nos primeiros momentos após o erro, pedi para que o Claude corrigisse pontos específicos da interface gráfica, mas sem sucesso. O Claude parecia se perder com o emaranhado de código e não conseguia chegar a uma correção satisfatória visualmente. Havia muitos recursos na interface que não estavam previstos naquela etapa do Anotai, e a implementação desordenada fez o chatbot se perder em um código pouco legível.

Então, aproveitei o bom histórico de commits e reverti o projeto para uma versão anterior à tentativa de implantação da UI. Encontrei alguns obstáculos no processo, mas a reversão foi bem feita posteriormente.

Nesta segunda tentativa, decidi ser mais cuidadoso. Percebi que vários elementos da interface eram consistentes por toda a UI, portanto poderiam ser programados uma única vez e só serem chamados pelas respectivas Views. Então, foi implementada uma estrutura mais desacoplada, encapsulada e manutenível da View, agora segmentada em diferentes diretórios: components, styles e utils, cada um deles com atribuições específicas, enquanto as views seriam como orquestradores destes recursos.

Para evitar uma outra tragédia, a implementação aconteceu em etapas tão cuidadosas quanto no começo – senão, ainda mais cuidadosas. Primeiro, foi feito o scaffolding, depois, a implementação de cada parte da UI – da mais simples, a AppTheme, à mais complexa, a Components. Desta vez, após inúmeros commits, deu tudo certo.

## Mudança de direção

Durante o processo de desenvolvimento, descobri que o debugging do aplicativo no mobile podia ser feito com bastante facilidade. O celular Android oferece um recurso para isso via USB ou Wi-Fi, e isso foi a oportunidade perfeita para redirecionar o foco para o mobile, onde há apelo visual bem maior do que na web.

Ver o aplicativo rodando no celular foi uma conquista pessoal importante. Até então, nunca havia implementado nada que fosse visível numa telinha além de um terminal ou navegador. Interagir com o Anotai por toque, poder debugar rapidamente e ver as alterações acontecendo em tempo real foi uma experiência diferente de tudo que havia feito antes no desenvolvimento.

A partir disso, várias mudanças foram necessárias: a UI precisou ser repensada para se enquadrar em telas menores e com convenções de uso diferentes, como interações por toque; o design Material tem padrões e convenções específicas que o design inicial desrespeitava; e a exibição na tela mobile revelou problemas de redimensionamento e usabilidade que a versão web não revelava, tornando necessário refatorar parte da UI para adaptá-la.

Esse aperfeiçoamento aconteceu sem surpresas, já que o processo de desenvolvimento continuou cuidadoso e iterativo como antes. As mudanças chegaram em etapas bem documentadas e commitadas, contando com minha participação durante todo o desenvolvimento.

## Versão 1.0 e o fim da Fase 2

A construção da Fase 2 é, até o momento, a mais lenta. As features previstas para essa etapa foram de complexidade significativa e demandaram mudanças estruturais grandes sobre a estrutura. Uma das alterações mais notáveis está na arquitetura MVVM, agora complementada pela Service Layer para garantir melhor legibilidade no código e reduzir a dependência da ViewModel.

A Service Layer também se mostrou útil para garantir escalabilidade ao projeto. Com ela, toda a lógica acerca de features novas ficam bem segmentadas. Possivelmente é um over-engineering para um projeto universitário, mas uma vez que a proposta é preservar boas práticas, estudar arquitetura e fazer um programa com bases robustas, a adição da camada parece apropriada.

Com a Service Layer, foi possível implementar features diferentes e mais refinadas e melhorar a sensação de fluidez no aplicativo. Qualquer ajuste passou a ser feito exclusivamente nas classes de serviço, sem depender de alterações na ViewModel. Então, alterações no debounce, nos estados de edição/salvamento, na exclusão automática da lixeira e no arquivamento de notas passaram a acontecer em classes menores, sem chance de interferir com outras partes do programa.

Consequentemente, percebi que o Claude passou a interpretar melhor o código. As conversas com o chatbot pareciam mais claras e as interações com ele foram mais rápidas e aparentemente econômicas em tokens. Em vez de olhar para uma classe gigante para encontrar um método, ele sabia exatamente onde procurar métodos de uma determinada feature e, com classes menores, a leitura e refatoração aconteciam com mais agilidade.

Dada a consistência do código atual, bem como a implementação de features que complementam à experiência do usuário (separação por tags, exclusão automática e mais), percebi a necessidade de iniciar os testes no aplicativo. Nessa parte, não tive experiência anterior, então prevejo que será um longo caminho até a conclusão.

## Volto todos os dias

Minha jornada acadêmica está longe de acabar e não é nada tranquila, mas o processo de desenvolvimento do Anotai, de alguma forma, me fisgou. Todos os dias volto para o VS Code para conferir o backlog e gerenciar o débito técnico do aplicativo – embora pequenos, significativos para mim. Conheço meu aplicativo de cabo a rabo, apesar de o Claude ser o principal responsável pelo código.

Se sintaxe e a programação crua eram um problema quase emocional, a intermediação do projeto com uma IA generativa parece ser um remédio válido. O trauma ainda existe, mas não ao ponto de tremer ao ver um diagrama de classes. Além disso, o tom aparentemente elogioso do Claude e às intervenções do meu terapeuta me fazem acreditar, ao menos um pouco, que estou cada vez mais preparado para encarar uma carreira como Product Manager.

Posso não ser um bom programador, mas eu ainda sei das coisas!

Observação do autor:

Retornarei a este artigo para adicionar atualizações acerca do andamento do projeto no futuro. Portanto, adicionarei a data da publicação original e a data das modificações posteriores.

Não deixe de conferir o repositório do GitHub do Anotai com a documentação completa e uma versão mais recente do projeto.
