# Sequência sugerida para demonstrar o projeto

## 1. Introdução

“Este é o Flag Game, desenvolvido em Flutter para a terceira atividade de Programação para Dispositivos Móveis. A proposta é identificar países pelas bandeiras em uma partida com tempo limitado. Eu organizei o projeto com o nome visual Atlas.”

Mostre primeiro os três cartões de modo: Qual é o país?, Encontre a bandeira e Bandeira secreta. Depois apresente o nome do jogador, os quatro tempos e as dificuldades. Explique que o nível fácil utiliza 67 países e o difícil utiliza o catálogo completo de 195.

## 2. Jogo aleatório

Selecione Jogo aleatório, 30 segundos e uma dificuldade. Inicie a partida. Mostre que aparece uma bandeira, quatro nomes de países e o cronômetro. Responda algumas perguntas, incluindo uma resposta errada para mostrar a correção automática.

“Cada acerto vale um ponto. O tempo vale para a partida inteira. Quando eu respondo, o aplicativo destaca o resultado e avança sozinho. Durante esse intervalo, ele bloqueia novos toques para não contar a resposta duas vezes.”

Espere o tempo terminar. Mostre perguntas respondidas, acertos, erros e percentual. Mostre o botão para retornar ao menu e a revisão dos erros, se houver.

## 3. Demonstração dos outros desafios

Escolha **Encontre a bandeira** no menu. Mostre que o nome de um país aparece no topo e que as respostas são quatro imagens, sem os nomes dos países. Responda para mostrar a correção e a exibição dos nomes após a escolha.

Depois selecione **Bandeira secreta**. Aguarde alguns segundos para mostrar as peças do mosaico desaparecendo. A imagem começa com três partes visíveis e ganha novas partes a cada 1,5 segundo. Responder revela a bandeira inteira, e a rodada seguinte começa novamente coberta. Explique que cada acerto vale um ponto e que o tempo continua contando durante a revelação.

Esses dois desafios alteram a interação, mantendo os continentes, as alternativas e o tempo do projeto. No resultado e no ranking, mostre a identificação do modo para deixar clara a separação dos recordes.

## 4. Modo por continente

Volte ao menu e selecione um continente, como Oceania ou América. Inicie a partida e mostre que os países exibidos pertencem àquela região. Para voltar sem terminar, use a confirmação de saída e explique que partidas abandonadas não entram no ranking.

## 5. Ranking

Abra o ranking com o mesmo modo, duração, dificuldade e continente da partida concluída.

“As pontuações ficam salvas no próprio aparelho com shared_preferences. Eu separei o ranking por seleção, porque uma partida de trinta segundos precisa ser comparada com outras de trinta segundos. Em um empate de pontos, o aplicativo utiliza o percentual de acertos.”

Se quiser demonstrar persistência, recarregue a página no mesmo endereço e abra o ranking novamente. Não troque de porta ou navegador nessa demonstração.

## 6. Organização do código

Mostre no VS Code:

- `models`: representam os dados de país, configuração e resultado.
- `assets/data/countries.json`: nomes, continentes e referências às bandeiras.
- `services`: leitura do catálogo e armazenamento local.
- `game`: sorteio das alternativas, tempo e validação das respostas.
- `screens`: menu, jogo, resultado, ajuda e ranking.
- `widgets` e `theme`: elementos reutilizados e aparência.
- `test`: verificações das regras e das telas.

“A navegação utiliza Navigator, e as telas atualizam o estado com setState. Eu separei as regras da interface para conferir a lógica sem depender de cliques manuais.”

## Perguntas que podem aparecer

**O app precisa de internet para buscar bandeiras?**  
Não. Os nomes e as imagens estão incluídos nos assets. A instalação de dependências, a compilação e o carregamento inicial da versão Web são etapas que podem precisar de internet ou de um servidor.

**Usa banco de dados?**  
O catálogo é um arquivo JSON. O ranking e as preferências são armazenados com shared_preferences. Não há MySQL, servidor ou login.

**Como são sorteadas as alternativas?**  
O código filtra os países do modo, embaralha o conjunto e escolhe a resposta. Depois escolhe três países diferentes como alternativas incorretas e embaralha as quatro posições.

**O que acontece se o jogador não responder?**  
O tempo acaba e a tela de resultado apresenta zero respostas e zero por cento de acertos, sem divisão por zero.

**O tempo reinicia a cada pergunta?**  
Não. O enunciado define as durações como tempo total da partida. O cronômetro continua entre perguntas e durante o feedback.

**Como evita dois pontos por dois cliques rápidos?**  
Depois de aceitar a resposta, a sessão fica em estado de feedback. Nesse estado, novas respostas são recusadas e os botões ficam bloqueados.

**Como funciona o cronômetro?**  
Um Stopwatch mede o tempo real decorrido. Um Timer periódico atualiza a interface. Ao voltar de outro aplicativo, o jogo verifica novamente o tempo total, em vez de simplesmente descontar um segundo.

**Por que escolher shared_preferences?**  
Foi solicitado na atividade e atende ao armazenamento local pequeno de configurações e pontuações. Os resultados são convertidos em JSON antes de serem salvos como texto.

**Pode instalar no celular?**  
Sim, há projeto Android e iOS. Android exige seu SDK e geração do APK. Para compilar iOS é necessário macOS com Xcode e assinatura Apple. O funcionamento em cada ambiente deve ser validado nele.

**Como os novos modos usam a mesma lógica?**  
A pergunta sempre possui um país correto e quatro países como alternativas. O modo define se os widgets mostram os nomes ou as imagens. No modo secreto, a sessão também fornece quantas partes devem estar visíveis. A escolha continua sendo validada pelo código do país.

**Como o ranking antigo continua funcionando?**  
Configurações antigas não tinham o campo gameMode. Na leitura, esse campo ausente recebe o valor identify, correspondente a Qual é o país?. Os novos resultados incluem o modo no JSON e na chave de comparação.

**O que falta para a entrega da disciplina?**  
Depois de testar no seu computador, publique o código em um repositório seu, grave o vídeo e coloque os links na entrega. O ZIP não faz essas publicações automaticamente.
