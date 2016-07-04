# abntex2-modelo-trabalho-academico-pandoc

Modelo de trabalho acadêmico para utilizar com pandoc, baseado no abnTeX2.


Dependências:

- abnTeX2
- pandoc

# Instalação de dependências ruby

        gem install rake
        gem install colorize


# Instruções rápidas

Baixe o repositório, depois execute:

        rake
		
Após isso, o arquivo `trabalho-academico.pdf` deve ter sido gerado.


# Filosofia do projeto

- Manter compatibilidade com o template do pandoc
- Customizar com os códigos do abnTeX2

Em vez de criar um template novo, completamente baseado no abnTeX2,
preferi manter o máximo de compatibilidade possível com o
[template original do pandoc](https://github.com/jgm/pandoc-templates/blob/master/default.latex),
dessa forma poderemos nos beneficiar com as alterações realizadas por
eles.

Inserir personalizações baseadas no abnTex2 para inserir no template
do pandoc.

# Detalhes de implementação

- Os arquivos no diretório `templates` são utilizados para gerar código
  Latex para ser inserido no modelo do pandoc. Tudo isso é automatizado através
  de tarefas rake.
