# Fontes e créditos

## Enunciado

[PDM_Atividade03.ipynb](https://github.com/fgsantosti/programacaodispositivosmoveis/blob/b72b04e164bb1d079e8fa7947b44256684c609d8/PDM_Atividade03.ipynb), do professor. O notebook serve de especificação; não é código do aplicativo.

## Países e continentes

Os nomes em português, códigos ISO e regiões foram derivados de [mledoze/countries](https://github.com/mledoze/countries), versão `6031f5df137c41c76d180c55a0782185ae3ed05b`, consultada em 29/10/2026. Banco derivado distribuído sob **ODbL 1.0**, com texto em `licenses/COUNTRIES_ODbL.txt`. Atribuição: Country database — mledoze/countries and contributors.

O arquivo `assets/data/countries.json` é o banco derivado e legível, incluído com todos os campos utilizados. Alterações: seleção dos 193 membros da ONU mais Palestina e Vaticano, tradução de `region` para os cinco continentes do enunciado, simplificação de nomes em português, inclusão do campo `easy` e do caminho local da bandeira. Nomes ajustados incluem Tchéquia, Essuatíni, Macedônia do Norte, Timor-Leste, Vaticano e as duas repúblicas do Congo.

Os agrupamentos seguem a região da fonte. América do Norte, Central, Caribe e América do Sul formam **América**. Países transcontinentais recebem apenas uma região no jogo; por exemplo, Rússia aparece em Europa e Turquia em Ásia. Não são incluídos territórios dependentes, Kosovo e Taiwan nesta seleção. A seleção do nível Fácil é uma escolha editorial para o jogo, com 67 países e pelo menos quatro em cada continente.

| Continente | Países no nível Difícil |
| --- | ---: |
| África | 54 |
| América | 35 |
| Ásia | 47 |
| Europa | 45 |
| Oceania | 14 |
| **Total** | **195** |

## Bandeiras

As 195 imagens PNG foram obtidas de [FlagCDN](https://flagcdn.com/), serviço da [Flagpedia.net](https://flagpedia.net/), em resolução de 640 pixels de largura. O serviço identifica Wikimedia Commons como origem dos vetores. Cada arquivo foi validado como imagem antes de entrar no projeto. Os arquivos estão em `assets/flags/`, nomeados pelo código ISO em minúsculas. Nenhum download é feito durante a partida.

As bandeiras são símbolos nacionais. Seus direitos e eventuais restrições de uso dependem da imagem e da jurisdição; elas não fazem parte de uma licença geral do código do app. Os links acima mantêm a atribuição à fonte.

## Tipografia, ícones e arte

- **Manrope**, incluída em `assets/fonts/Manrope.ttf`, obtida do repositório [google/fonts](https://github.com/google/fonts/tree/main/ofl/manrope). Licença SIL Open Font License, em `assets/fonts/OFL.txt` e `licenses/MANROPE_OFL.txt`.
- Ícones de interface: Material Icons, distribuídos pelo Flutter.
- Globo decorativo: desenho próprio em `CustomPainter`; é uma ilustração estilizada, não um mapa de referência.
- Ícone do aplicativo: composição própria de globo e bandeira.

## Trabalhos consultados

Os READMEs de [GeoBandeiras](https://github.com/Breno-Guedes/GeoBandeiras) e [QFlags](https://github.com/MauroGutMB/QFlags) foram consultados para contextualizar trabalhos anteriores da disciplina. Não foi reutilizado código, imagem de bandeira, marca ou texto de apresentação desses projetos. O catálogo vem das fontes de dados acima; o código e o visual foram implementados para este projeto.
