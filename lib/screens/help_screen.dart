import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/game_config.dart';
import '../widgets/common.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Como jogar')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Pequenas viagens, grandes descobertas'),
              const SizedBox(height: 12),
              Text(
                'Escolha o desafio.\nMude sua forma de jogar.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 26),
              for (final mode in GameMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.lime,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mode.description,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        if (mode == GameMode.reveal)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Começa com 3 de 12 partes visíveis. A cada 1,5 segundo, aparecem mais duas; após 7,5 segundos, a imagem está completa. Ao responder, a bandeira inteira é mostrada. O tempo total continua contando.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              for (final item in const [
                (
                  '01',
                  'Prepare a partida',
                  'Escolha 30 segundos, 1, 3 ou 5 minutos. Esse é o tempo total da partida, incluindo o intervalo de resposta.',
                ),
                (
                  '02',
                  'Escolha o mapa',
                  'Jogue com todos os continentes no Jogo aleatório ou selecione África, América, Ásia, Europa ou Oceania.',
                ),
                (
                  '03',
                  'Observe e responda',
                  'No desafio de nomes, toque no país. No desafio inverso, toque na bandeira. No mosaico, tente reconhecer a imagem antes de ela aparecer inteira. Sempre são quatro alternativas, com uma correta.',
                ),
                (
                  '04',
                  'Aprenda a cada rodada',
                  'Cada acerto vale um ponto. O jogo destaca a resposta correta e avança automaticamente após 0,85 segundo. Erros não retiram pontos.',
                ),
                (
                  '05',
                  'Confira seu resultado',
                  'Quando o tempo acaba, veja perguntas respondidas, acertos, erros e percentual de acertos. Uma pergunta sem resposta não entra no total.',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.$3,
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const Text(
                'Dificuldade e recordes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fácil utiliza uma seleção de 67 países. Difícil utiliza os 195 países do catálogo. As alternativas sempre pertencem ao continente e à dificuldade selecionados. Nenhuma bandeira se repete antes de terminar o ciclo da seleção.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              const Text(
                'O ranking guarda os dez melhores resultados de cada combinação de modo, continente, dificuldade e duração. Mais acertos ficam à frente; em caso de empate, vale a precisão e depois a partida mais recente.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              const Text(
                'O cronômetro continua se você trocar de aplicativo ou abrir a confirmação de saída. Sair antes do fim descarta a partida. No navegador, o ranking fica salvo neste navegador e pode ser apagado ao limpar os dados do site.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              const Tag(
                text: 'Bandeiras e nomes incluídos no app',
                icon: Icons.offline_bolt_outlined,
              ),
              const SizedBox(height: 22),
              const Text(
                'Flag Game · Atlas\nAtividade 03 · Programação para Dispositivos Móveis\nIFPI — Campus Corrente\nCaio Vieira Vila Nova',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
