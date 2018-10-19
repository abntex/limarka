# Contribuindo com o projeto

No momento, as maiores contribuições são: utilizar a ferramenta, [realizar o experimento]
e [divulgá-la](https://github.com/abntex/limarka/wiki/Imprensa).

[realizar o experimento]: https://github.com/abntex/limarka/wiki/Experimentos

Pull requests são sempre bem vindos. Ao participar desse projeto você está de
acordo com o [código de conduda].

O projeto tem como origem uma pesquisa científica (em andamento) sobre utilização de linguagem de marcação de texto para elaboração de monografias.

- [Realize o experimento de utilização](https://github.com/abntex/limarka/wiki/Experimentos)

Acesse o [chat no gitter](http://gitter.im/abntex/limarka) e fale conosco, independente do seu perfil.

# Professor

Como professor você pode contribuir com o limarka divulgando-o e ofertando o limarka como uma opção para seus alunos realizarem tarefas.

- Ao solicitar relatórios de atividades aos alunos, sugira a utilização do limarka. Embora o limarka tenha o propósito de produzir trabalhos de conclusão de curso, ele pode ser facilmente utilizado para elaboração de relatórios.

- Sugira seus orientandos experimentarem o limarka. O limarka é gratuito e livre, pode ser utilizado no Linux, OS X e Windows. Não recomendamos utilizar o limarka em trabalhos de conclusão que exigam bastante fórmulas, teoremas ou provas. Os editores Latex oferecem melhor suporte para isso.

- Atualize sua página pessoal/institucional adicionando uma [matéria ou link sobre o limarka](https://github.com/abntex/limarka/wiki/Imprensa). Seus alunos e outras pessoas poderão conhecer a ferramenta dessa forma.

- Solicite incluir o limarka como uma alternativa nos materiais de instruções de produção de trabalhos de conclusão, ou nas disciplinas de Metodologia. O momento ideal para apresentar aos alunos a ferramenta são nas aulas de Metodologia. Por enquanto o foco da ferramenta são trabalho de conclusão, mas em breve também será possível realizar artigos.

- Divulgue um notícia sobre o limarka nas listas de professores ou alunos. O público alvo da ferramenta são os estudantes, essas listas propocionam encontrá-los.

- Recomende a veiculação de uma matéria sobre o limarka na agência de noticias de sua instituição. As agências de notícias das instituições são um ótimo meio para divulgação, verifique como contactar agência e recomende uma matéria para ser veiculada.

- Clique na estrela [no repositório do projeto](https://github.com/abntex/limarka) (equivale a um *like*) no github.

# Estudante

- Utilize o limarka para elaboração de relatórios
- Participe do [experimente de uso da ferramenta](https://github.com/abntex/limarka/wiki/Experimentos) - NECESSITA-SE URGENTEMENTE!
- Compartilhe alguma notícia do limarka em suas redes sociais ou lista de alunos ou de laboratórios
- Escreva seu trabalho de conclusão ou sua proposta/projeto com o limarka e compartilhe sua experiência
- Clique na estrela [no repositório do projeto](https://github.com/abntex/limarka) (equivale a um *like*) no github.

# Usuário Latex

Gostaríamos de converter as [customizações conhecidas do abnTeX2](https://github.com/abntex/abntex2/wiki/CustomizacoesConhecidas) para utilização com o limarka.

# Desenvolvedor Ruby

Deseja participar do desenvolvimento do limarka? Considere os [issues marcados com o label help needed](https://github.com/abntex/limarka/labels/help%20wanted) como um convite para contribuir conosco.

Correção de bugs e implementação de novas funcionalidades através de Pull requests são sempre bem vindos.

Ao participar desse projeto você está de acordo com o [código de conduda].

[código de conduda]: https://github.com/abntex/limarka/blob/master/CODE_OF_CONDUCT.md

# Desenvolvedor WEB

Nós desejamos melhorar a experiência de utilização da ferramenta implementando
um site que gere conteúdos dinâmicos.

Suponha que um usuário deseja adicionar uma referência de um artigo, gostaria
que o usuário clicasse em "Artigo" e um formulário fosse apresentado para
preenchimento e acordo com os campos bib desse tipo de entrada. Quando o usuário
vai preenchendo o código bib é gerado automaticamente para inserção no arquivo
de referências.

Para compreender a funcionalidade veja o site [http://shields.io](http://shields.io/) e clique em algum dos badges.


## Implementando uma nova funcionalidade

[Crie um issue](https://github.com/abntex/limarka/issues/new) descrevendo a nova funcionalidade.

Realize um fork no projeto, depois faça o clone do seu fork:

    git clone git@github.com:your-username/limarka.git
    git submodule init
    git submodule update

Configure sua máquina:

    ./bin/setup

Certifique-se que os testes estão passando:

    rake

Crie uma branch a partir da master para sua funcionalidade:

    git checkout -b minha-funcionalidade

Realize as alterações. Adicione testes (opicional, mas desejado) para as suas mudanças. Faça os testes passarem:

    rake
    git add arquivo-modificado1 arquivo-modificado2
    git commit

Se existir um Issue referente a funcionalidade implementada [utilize o número do issue na mensagem de commit](https://help.github.com/articles/closing-issues-via-commit-messages/) para manter rastreabilidade.

Faça um Push para o seu fork:

    git push origin minha-funcionalidade

[Submeta um pull request](https://github.com/abntex/limarka/compare/). Altere o título do issue/PR para o texto que deseja ser adicionado ao [CHANGELOG](https://github.com/abntex/limarka/blob/master/CHANGELOG.md)

## Desenvolvimento

Talvez você deseje consulta a página sobre o [desenvolvimento da ferramenta](https://github.com/abntex/limarka/wiki/Desenvolvimento).
