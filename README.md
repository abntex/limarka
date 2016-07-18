# Limarka

Gere o PDF do seu trabalho de conclusão de curso (monografia, dissertação ou teste),
formatado automaticamente com as normas da ABNT, escrevendo-o de forma bem simples.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'limarka'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install limarka

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/limarka. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

# Informações técnicas

- Escreva o texto utilizando a linguagem Markdown
- O texto será convertido em Latex, através da ferramenta pandoc e templates 
baseados no abntex2
- O código Latex é compilado e gerado o PDF

# Estado do projeto: em desenvolvimento

Este projeto ainda está em fase embrionária, muito pode ser mudado.

# ATENÇÃO: Instruções desatualizadas

As instruções abaixo provavelmente estarão desatualizadas.


# Dependências

- abnTeX2
- pandoc
- ruby
- gems: rake, colorize, pdf-forms
- gems de desenvolvimento:  `github_changelog_generator`

# Instalação dos gems

        gem install rake colorize pdf-forms

OBS: No momento o gem `pdf-forms` apresenta um problema, ver #6.

# Instruções rápidas 

Baixe o repositório, depois execute:

        rake
		
Após isso, o arquivo `trabalho-academico.pdf` deve ter sido gerado.

# Detalhes de implementação

- O arquivo [trabalho-academico.md](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/trabalho-academico.md) contém o texto do trabalho.
- Os arquivos no diretório [templates](https://github.com/abntex/trabalho-academico-pandoc-abntex2/tree/master/templates) são utilizados para gerar código  Latex para ser inserido no modelo do pandoc. 
- Diversas informações são redigidas no arquivo [metadados.yaml](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/metadados.yaml)
- Algumas seções do trabalho são redigidas em arquivos separados: [anexos.md](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/anexos.md), [apendices.md](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/apendices.md) e [referencias.md](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/referencias.md).
- Tudo isso é automatizado através de tarefas `rake`, definidas no arquivo [Rakefile](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/Rakefile).
- Os diversos arquivos `.md` são utilizados na geração do PDF.

# Filosofia do projeto

- Manter compatibilidade com o template do pandoc
- Customizar com os códigos do abnTeX2
- Utilização simples

Em vez de criar um template novo, completamente baseado no abnTeX2,
preferi manter o máximo de compatibilidade possível com o
[template original do pandoc](https://github.com/jgm/pandoc-templates/blob/master/default.latex),
dessa forma poderemos nos beneficiar com as alterações realizadas por
eles.

Inserir personalizações baseadas no abnTex2 para inserir no template
do pandoc.

# Origem do projeto

O projeto tem como origem uma pesquisa científica sobre utilização de linguagem
de marcação de texto para elaboração de monografias (em andamento).

- Busca realizar e publicar experimentos de utilização
- Experimentar estratégias para facilitar utilização por usuários leigos

