# language: pt
@extensao
Funcionalidade: Utilizar filtros do pandoc

Como usuário do limarka eu gostaria poder utilizar filtros pandoc
para aprimorar o resultado produzido.

Existem dois tipos de filtros: *executáveis* e *scripts lua*.

Os filtros são executados através das opções `--filtros` e `--filtros-lua`.

Contexto:
  Dado um diretório com o template oficial
  E arquivo configuracao.yaml com configuração padrão

Cenário: chamando filtro executável (que torna os dez primeiros caracteres maiúsculas)
  Dado arquivo "trabalho-academico.md" com o seguinte conteúdo:
  """
  # inicio

  abc def ghi
  """
  Dado existe um filtro executável filtro.rb
  Quando executar limarka "-y --no-compila-tex --filtros filtro.rb"
  Então o arquivo tex gerado contém "ABC DEF GHi"

Cenário: chamando filtro lua (que expande {{mundo}})
  Dado arquivo "trabalho-academico.md" com o seguinte conteúdo:
  """
  # Inicio
  {{mundo}}
  """
  Dado existe um filtro lua filtro.lua
  Quando executar limarka "-y --no-compila-tex --filtros-lua filtro.lua"
  Então o arquivo tex gerado contém "Olá mundo!"
