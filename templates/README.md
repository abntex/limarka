# templates pandoc

Os arquivos neste diretório são templates pandoc utilizados para gerar código 
Latex. Tudo isso é automatizado através de tarefas rake.

- Os templates utilizam código Latex, baseados no arquivo [abntex2-modelo-trabalho-academico.tex](https://github.com/abntex/abntex2/blob/master/doc/latex/abntex2/examples/abntex2-modelo-trabalho-academico.tex).
- Utilizam a [sintaxe de templates do pandoc](http://pandoc.org/README.html#templates)
- As variáveis são configuradas no arquivo [metadados.yaml](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/metadados.yaml)
- A regra de como os templates serão gerados é implementada no arquivo [Rakefile](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/Rakefile)

Para maiores informações consulte:

- [Manual do AbnTeX2](ftp://ftp.dante.de/tex-archive/macros/latex/contrib/abntex2/doc/abntex2.pdf) ou digite `texdoc abntex2`
- [Documentação do Pandoc](http://pandoc.org/README.html)
- [pandoc-templates/default.latex](https://github.com/jgm/pandoc-templates/blob/master/default.latex)
- [Rakefile](https://github.com/abntex/trabalho-academico-pandoc-abntex2/blob/master/Rakefile)

