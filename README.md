# O que é o limarka?

O limarka é uma ferramenta que possibilita o usuário escrever o seu trabalho de conclusão de curso (monografia, dissertação ou teste) em Markdown e produzir PDFs em conformidade com as normas da ABNT.

# Qual a relação do limarka com o abnTeX?

O limarka é um projeto pertencente ao grupo do [abnTeX](https://github.com/abntex), que provém  uma suíte para LaTeX que atende os requisitos das normas da ABNT (Associação Brasileira de Normas Técnicas) para elaboração de trabalhos acadêmicos como teses, dissertações, projetos de pesquisa e outros documentos do gênero.

O limarka converte os textos produzidos em Markdown para LaTeX, utilizando os modelos do abnTeX2 que são extensivamente utilizados, testados e incrementados pela comunidade nacional.
 
# Por que escrever em Markdown ao invés de Latex?

O LaTeX é ótimo e bastante útil para quem deseja percorrer uma carreira de Pesquisador. Muitos *journals* disponibilizam modelos somente em LaTeX para produção de artigos, aprender LaTeX irá ser útil nessa carreira.

Mas se você não pretende utilizar LaTeX após a conclusão do seu curso, por que investir na longa curva de aprendizado do LaTeX se não pretende utilizar depois? 

> Uma reposta seria: *Com o Latex e abnTeX eu serei capaz de produzir um trabalho em conformidade com as normas da ABNT, isso por si só já compensaria o investimento*.


## Markdown como alternativa de aprendizado

Com o limarka você agora possui outra escolha de investimento para elaborar um trabalho de conclusão do curso em conformidade com as Normas da ABNT: Aprender Markdown.

O [Markdown](https://pt.wikipedia.org/wiki/Markdown) é uma linguagem simples de marcação. Os princípios das linguagem simples de marcação estão sendo popularizados em diversas ferramentas de interação social, veja alguns exemplos: [Github](https://help.github.com/articles/basic-writing-and-formatting-syntax/), [Moodle](https://docs.moodle.org/23/en/Markdown), [WhatsApp](https://www.whatsapp.com/faq/en/general/26000002), [Facebook](http://wersm.com/facebook-is-testing-rich-text-formatting-with-markdown/) [Google Plus](https://plus.google.com/+SarahHill/posts/TWYwPctEpJp), [Jekyll](http://jekyllrb.com), etc.

Após ou durante conclusão do seu curso, você pretende:

- Interagir através da escrita em redes sociais ou fóruns de discussão?
- Editar Wikis ou formatar mensagens?
- Participar em projetos no Github?
- Escrever documentações de softwares?
- Gerar código HTML a partir de texto?
- Elaborar *ebooks*?

Se você respondeu afirmativamente a algumas dessas perguntas, aprender uma linguagem simples de marcação (como o Markdown) é um investimento que provavelmente agilizará as realizações destas ações.

**OBS:** A implementação atual do limarka ainda exige conhecimentos mínimos do Latex.


# Informações técnicas

- Escreva o texto utilizando a linguagem Markdown;
- Configure diversos aspectos do trabalho através de um formulário PDF;
- O texto será convertido em Latex, através da ferramenta [pandoc](http://pandoc.org), templates baseados no [abntex2](http://www.abntex.net.br) e as configurações do formulário;
- Um PDF em conformidade com as normas mais recentes da ABNT é gerado através da compilação do código Latex.

# Documentação

A documentação do limarka será mantida no [wiki do projeto](https://github.com/abntex/limarka/wiki).

# Origem do projeto

O projeto tem como origem uma pesquisa científica sobre utilização de linguagem de marcação de texto para elaboração de monografias (em andamento).

# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abntex/limarka. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
