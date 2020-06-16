FROM ruby:2-slim

LABEL maintainer="eduardo.ufpb@gmail.com"

# Tentamos seguir as melhores práticas:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

WORKDIR /tmp
COPY bin/instaladores/dependencias_execucao_install.sh \
	bin/instaladores/pandoc_install.sh \
	bin/instaladores/tinytex_install.sh \
	.

RUN apt-get update && dependencias_execucao_install.sh

# Instala tinytex (/root/.TinyTex)
# e bibliotecas para o abntex2/limarka
RUN bin/instaladores/tinytex_install.sh
ENV PATH="/root/bin:~/.TinyTeX/bin/x86_64-linux:${PATH}"

# Configurando o idioma português #175: https://hub.docker.com/_/debian/#locales
RUN rm -rf /var/lib/apt/lists/* \
    && localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
ENV LANG pt_BR.UTF8

# Instalação do pandoc
RUN pandoc_install.sh
