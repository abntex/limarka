# Contribuindo com o projeto

No momento, as maiores contribuições são: utilizar a ferramenta, [realizar o experimento]
e [divulgá-la](https://github.com/abntex/limarka/wiki/Imprensa).

[realizar o experimento]: https://github.com/abntex/limarka/wiki/Experimentos

Pull requests são sempre bem vindos. Ao participar desse projeto você está de 
acordo com o [código de conduda].

[código de conduda]: https://github.com/abntex/limarka/blob/master/CONTRIBUTING.md

Realize um fork no projeto, depois faça o clone do seu fork:

    git clone git@github.com:your-username/limarka.git

Configure sua máquina:

    ./bin/setup

Certifique-se que os testes estão passando:

    rake

Crie uma branch a partir da master para sua funcionalidade:

    git checkout -b minha-funcionalidade

Realize as alterações. Adicione testes para as suas mudanças. Faça os testes passarem:

    rake

Se existir um Issue referente a funcionalidade implementada:

- [Utilizar o número do issue na mensagem de commit](https://help.github.com/articles/closing-issues-via-commit-messages/).
- Altere o título do issue para o texto que deseja ser adicionado ao [CHANGELOG](https://github.com/abntex/limarka/blob/master/CHANGELOG.md)

Faça um Push para o seu fork e [submeta um pull request][pr].

[pr]: https://github.com/abntex/limarka/compare/
