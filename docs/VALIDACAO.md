# Registro de validação

## Versão 1.1 — seleção de modos

Revisão em **29/10/2026**, com **Flutter 3.47.7 / Dart 3.13.5**.

- Análise estática sem problemas.
- **60 testes automatizados aprovados** na suíte completa.
- Compilação de release Web concluída, com recursos do renderizador incluídos localmente.
- Modos conferidos no Chromium Headless **151.0.7922.34**, em 1440 × 1120 e 390 × 844 pixels.

Os novos testes cobrem configuração e JSON dos três modos, pontuação e tempo total, bloqueio de resposta duplicada, evolução do mosaico, nomes ocultos no desafio inverso, feedback, filtro de ranking e leitura dos recordes da versão anterior. O menu também foi conferido em 360, 768, 832 e 1440 pixels, incluindo texto ampliado.

No navegador foram executados: escolha dos três cartões; partida de 30 segundos em **Encontre a bandeira**, com quatro imagens sem nomes antes da resposta; feedback e nomes após a escolha; resultado e ranking recuperados após recarregar; **Bandeira secreta** com 3 partes iniciais, 5 após a espera, 12 ao responder e 3 ao iniciar a rodada seguinte; abandono sem gravar pontuação; modo clássico; modo inverso no celular; tela de ajuda atualizada. Não foram capturados erros de execução nem requisições externas.

A conferência visual abrangeu o novo menu, os cartões de bandeiras e o mosaico. As capturas são apenas de validação e não estão no ZIP.

O código-fonte, as instruções iniciais, a matriz de requisitos e o roteiro de apresentação foram atualizados. Permanecem os limites de validação nativa descritos no histórico.

## Histórico das versões anteriores

Validação realizada em **29/10/2026**, com Flutter **3.47.9** e Dart **3.13.7**, em ambiente Linux de desenvolvimento.

### Revisão de compatibilidade com Flutter 3.47.7

A exigência mínima em `pubspec.yaml` foi reduzida de `>=3.47.9` para `>=3.47.7`, permitindo manter a versão já instalada no computador do aluno. O README, as instruções iniciais e o workflow do GitHub foram atualizados. A lógica do jogo não foi alterada.

Verificações repetidas com **Flutter 3.47.7 / Dart 3.13.5**:

- `flutter pub get`: dependências instaladas com sucesso.
- `flutter analyze --no-pub`: nenhum problema encontrado.
- `flutter test --no-pub`: os **46 testes aprovados**.
- `flutter build web --no-pub --no-web-resources-cdn --no-wasm-dry-run`: compilação Web concluída.

As verificações iniciais descritas abaixo continuam registradas com as versões em que foram executadas.

### Análise e testes automatizados

- `flutter analyze`: análise sem problemas.
- `flutter test`: **46 testes aprovados**.
- Formatação dos arquivos em `lib/` e `test/` conferida com `dart format`.
- Compilação de release para Web concluída com `flutter build web --no-web-resources-cdn`.

Foram conferidos:

1. Os 195 países, códigos e nomes únicos, cinco continentes e imagens locais.
2. Perguntas e alternativas de cada continente nas duas dificuldades.
3. Quatro alternativas distintas e uma única resposta correta.
4. Ciclos sem repetição e sem repetir a bandeira na mudança de ciclo.
5. Acerto, erro, sequência e bloqueio de resposta duplicada.
6. Avanço após 850ms sem reiniciar o tempo total.
7. Encerramento no limite exato dos quatro tempos e recusa de resposta tardia.
8. Último acerto aceito antes do prazo, mesmo com feedback interrompido.
9. Salto de tempo após interrupção e tempo restante que nunca aumenta.
10. Resultado sem respostas, sem divisão por zero.
11. Preferências e ranking recuperados após reconstruir o serviço.
12. Limite de dez registros por seleção e separação de tempo, dificuldade e continente.
13. Desempates, prevenção de duplicatas e recuperação de dados corrompidos.
14. Limpeza do ranking sem apagar as preferências.
15. Menu em larguras de 360, 768 e 1440 pixels, inclusive com texto ampliado.
16. Navegação da configuração até o jogo, quatro botões de resposta e resultado.

### Conferência no navegador

A versão Web compilada foi executada no **Chromium/Chrome Headless 151.0.7922.34**, com os arquivos de `build/web` fornecidos localmente ao navegador. Requisições externas foram bloqueadas durante a conferência: o jogo não precisou de nenhuma.

Fluxo executado:

- Menu em 1440 × 1000 pixels.
- Nome de teste, duração de 30 segundos, dificuldade Difícil e continente Oceania.
- Resposta correta e feedback de acerto.
- Resposta errada e exibição do nome correto.
- Quatro alternativas pertencentes à Oceania.
- Fim automático da partida pelo relógio real.
- Resultado conferido: **2 respostas, 1 acerto, 1 erro e 50%**.
- Retorno ao menu, abertura do ranking e recuperação do resultado após recarregar a página.
- Início do modo aleatório, cancelamento da saída e confirmação de abandono.
- Menu em 390 × 844 pixels e abertura da tela de ajuda.
- Nenhum erro de execução capturado no fluxo.

As telas de menu, jogo e resultado foram inspecionadas visualmente. As capturas utilizadas para essa conferência não fazem parte da entrega.

### Limites da validação

As pastas Android, iOS e Windows acompanham o código, mas **as compilações e a instalação nativas não foram executadas neste ambiente**. APK exige Android SDK; iOS exige macOS, Xcode e assinatura Apple; Windows nativo exige as ferramentas C++ do Visual Studio. A compilação Web e os testes Flutter não substituem a validação de instalação nessas plataformas.

A gravação do vídeo, a publicação do repositório do aluno e a publicação em lojas não foram feitas automaticamente. O README explica essas etapas.
