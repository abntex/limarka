# language: pt
@extensao
Funcionalidade: Habilitando extensões pandoc

O limarka utiliza [pandoc](https://pandoc.org) para geração do PDF.

Como usuário do limarka eu gostaria poder escolher quais extensões do
pandoc eu poderia utilizar no meu trabalho, extendendo qual o formato do
arquivo que limarka irá interpretar.

Contexto:
  Dado um diretório com o template oficial
  E arquivo "trabalho-academico.md" com o seguinte conteúdo:
  """
  # Links

  - https://github.com/abntex/limarka

  """
  E arquivo configuracao.yaml com configuração padrão

@wip
Cenário: caso normal
  Neste caso, o texto normal não será convertido em link.

  Quando executar limarka "-y"
  Então o arquivo tex gerado contém "https://github.com/abntex/limarka"
  Mas o arquivo tex gerado não contém "\\url{https://github.com/abntex/limarka}"

Cenário: habilitando uma extensão pandoc
  Neste cenário iremos habilitar a extensão 'autolink_bare_uris'
  (ver em https://pandoc.org/MANUAL.html#non-pandoc-extensions)
  que converte automaticamente todos os endereços web no texto em links
  clicáveis no PDF.

  Dado adiciona-se em configuracao.yaml:
  """
  formato: "+autolink_bare_uris"
  """
  Quando executar limarka "-y --no-compila-tex"
  Então o arquivo tex gerado contém "\\url{https://github.com/abntex/limarka}"
