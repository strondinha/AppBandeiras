# Conferência dos requisitos do professor

Referência: `PDM_Atividade03.ipynb`, commit `b72b04e164bb1d079e8fa7947b44256684c609d8` do repositório do professor. A cópia anexada foi lida integralmente.

| Requisito | Implementação | Onde conferir |
| --- | --- | --- |
| Aplicativo Flag Game em Flutter | Nome Flag Game · Atlas; implementação Flutter/Dart | `pubspec.yaml`, `lib/main.dart` |
| Menu principal | Seletor de desafios, configuração, início de jogo, continentes e modo aleatório | `home_screen.dart` |
| África, América, Ásia, Europa e Oceania | Cinco seleções com perguntas limitadas à região | `country.dart`, `country_repository.dart` |
| Jogo aleatório | Catálogo completo de 195 países no nível Difícil | `quiz_engine.dart`, `countries.json` |
| Tempos de 30s, 60s, 3min e 5min | Valores 30, 60, 180 e 300 segundos | `game_config.dart` |
| Bandeira no topo da pergunta | Imagem local acima das alternativas | `game_screen.dart`, `FlagImage` |
| Quatro nomes de países | Quatro alternativas distintas, uma correta | `quiz_engine.dart` |
| Temporizador visível | Contagem regressiva e barra de tempo | `game_screen.dart` |
| Feedback de acerto e erro | Mensagem, ícone e cores; mostra a correta | `game_screen.dart` |
| Avanço automático | Próxima pergunta após 850 milissegundos | `game_session.dart` |
| Banco de bandeiras por continente | JSON com nomes, continentes e caminhos de imagem | `assets/data/countries.json` |
| Pontos a cada acerto | Um ponto por resposta correta | `game_session.dart` |
| Fim quando o tempo acabar | Relógio total com rejeição de resposta tardia | `game_session.dart`, `game_screen.dart` |
| Total de respondidas e acertos | Estatísticas no resultado | `result_screen.dart` |
| Percentual de acertos | Cálculo protegido contra divisão por zero | `game_result.dart`, `result_screen.dart` |
| Botão para voltar ao menu | Voltar ao menu principal | `result_screen.dart` |
| Scaffold, Text, Buttons e Images | Widgets Flutter/Material e `Image.asset` | Telas e widgets |
| Navegação por Navigator | Rotas do menu, jogo, resultado, ajuda e ranking | `lib/screens/` |
| Gerenciamento de estado | `StatefulWidget` e `setState` | Telas |
| Arquivo JSON ou pacote de bandeiras | JSON e imagens distribuídos no aplicativo | `assets/`, `pubspec.yaml` |
| shared_preferences para recordes | Persistência, leitura e limpeza do ranking | `local_storage.dart` |
| Código organizado e comentado | Modelos, serviços, regras, telas e widgets separados | `lib/` |
| README com descrição, execução e recursos | Documentação completa | `README.md` |
| Código-fonte completo no GitHub | Projeto organizado para publicação; envio ao GitHub fica a cargo do aluno | `README.md`, `.gitignore`, workflow |
| Vídeo explicativo | Roteiro fornecido; o aluno deve gravar e publicar o vídeo | `APRESENTACAO.md` |

## Modos próprios da versão 1.1

O modo **Qual é o país?** mantém os requisitos de uma bandeira acima de quatro nomes. O seletor permite também **Encontre a bandeira** (nome acima de quatro imagens, com os nomes ocultos até responder) e **Bandeira secreta** (mosaico revelado aos poucos, com quatro nomes para responder). O usuário escolhe o desafio antes de iniciar a partida.

Continente e modo de interação são escolhas independentes: todos os desafios aceitam as cinco regiões ou todos os continentes misturados, os quatro tempos e as duas dificuldades. O ranking acrescentou o filtro de modo e preserva as pontuações antigas no desafio de nomes.

## Extras implementados

| Extra | Comportamento |
| --- | --- |
| Dificuldade | Fácil com 67 países; Difícil com os 195 países |
| Leaderboard | Dez melhores de cada conjunto de modo, continente, tempo e dificuldade |
| Animações | Troca de bandeira, resposta e feedback |
| Revisão dos erros | Bandeira, resposta correta e alternativa escolhida |
| Personalização | Nome ou apelido e última configuração salvos |
| Ajuda | Instruções e regras dentro do aplicativo |
| Funcionamento sem API | Catálogo, bandeiras e fonte locais |

O extra de múltiplos idiomas é opcional e não foi implementado. A interface está em português brasileiro. A seleção de três parâmetros do ranking é um diferencial para comparar partidas sob as mesmas regras.

O enunciado menciona tanto tempo para responder quanto tempo total. A implementação segue a instrução explícita do menu e do controle de tempo: **o tempo escolhido é total, para a partida inteira**.
