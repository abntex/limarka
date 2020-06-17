FROM alpine:3.7

LABEL maintainer="eduardo.ufpb@gmail.com"

# Tentamos seguir as melhores práticas:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

RUN apk update \
  && apk upgrade \
  && apk add --no-cache --update \
  alpine-sdk \
  build-base \
  fontconfig \
  pdfgrep \
  perl \
  poppler-utils \
  ruby-dev \
  ruby \
  unzip \
  wget

# Instala tinytex (/root/.TinyTex)
RUN wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh
ENV PATH="/root/bin:${PATH}"

# instala bibliotecas para o abntex2/limarka
RUN tlmgr install \
  abntex2 \
  babel-portuges \
  bookmark \
  enumitem \
  epstopdf-pkg \
  iftex \
  lastpage \
  lipsum \
  listings \
  caption \
  memoir \
  microtype \
  pdflscape \
  pdfpages \
  textcase \
  xcolor

# Configurando o idioma português
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl

RUN apk add --no-cache \
  $MUSL_LOCALE_DEPS \
  && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
  && unzip musl-locales-master.zip \
  && cd musl-locales-master \
  && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
  && cd .. && rm -r musl-locales-master

ENV LANG pt_BR.UTF8

# Instalação do pandoc
RUN wget -O pandoc.tar.gz https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-linux-amd64.tar.gz \
  && tar xvzf pandoc.tar.gz --strip-components 1 -C /usr/local/ && rm pandoc.tar.gz

RUN gem install limarka; exit 0

RUN apk del ruby-dev build-base wget alpine-sdk unzip cmake make musl-dev gcc

VOLUME ["/trabalho"]
WORKDIR /trabalho

CMD ["--help"]
ENTRYPOINT ["/usr/local/bundle/bin/limarka"]
