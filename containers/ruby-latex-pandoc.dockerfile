FROM ruby:2-slim

LABEL maintainer="eduardo.ufpb@gmail.com"

# Tentamos seguir as melhores práticas:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

RUN apt-get update && apt-get install -y -qq \
	build-essential \
	fontconfig \
	locales \
	pdfgrep \
	poppler-utils \
	unzip \
	wget

# Instala tinytex (/root/.TinyTex)
RUN wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh
ENV PATH="/root/bin:${PATH}"

# instala bibliotecas para o abntex2/limarka
RUN tlmgr install \
	abntex2 \
	babel-portuges \
	enumitem \
	ifetex \
	lastpage \
	lipsum \
	listings \
	memoir \
	microtype \
	pdfpages \
	textcase \
	xcolor

# Configurando o idioma português #175: https://hub.docker.com/_/debian/#locales
RUN rm -rf /var/lib/apt/lists/* \
    && localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
ENV LANG pt_BR.UTF8

# Instalação do pandoc
WORKDIR /tmp
RUN wget https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb \
&& dpkg -i pandoc-*.deb \
&& rm pandoc-*.deb
