# language: pt
@extensao
Funcionalidade: Formato e extensões pandoc

O limarka utiliza [pandoc](https://pandoc.org) para geração do PDF.

Como usuário do limarka eu gostaria poder extender o formato do arquivo
de texto habilitando extensões do pandoc.

Contexto:
  Dado um diretório com o template oficial
  E arquivo "trabalho-academico.md" com o seguinte conteúdo:
  """
  # Links

  - https://github.com/abntex/limarka

  """
  E arquivo configuracao.yaml com configuração padrão

@wip
Cenário: caso normal, utilizando o formato pré-definido do limarka
  O comportamento padrão do limarka não gera links clicáveis no texto, a
  não ser que o usuário utilize a sintaxe apropriada de link.

  Quando executar limarka "-y --no-compila-tex"
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
