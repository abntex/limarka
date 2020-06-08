#!/usr/bin/env sh

dependencias=
pandoc=
tex=
codename=$(lsb_release -c -s)
pacotes=
dry=
cache=

# Documentação de ajuda:
# https://wiki.bash-hackers.org/howto/getopts_tutorial
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
# http://robertmuth.blogspot.com/2012/08/better-bash-scripting-in-15-minutes.html
# https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html

while getopts "Dcdtpn" opt; do
  case $opt in
    p)
      pandoc=1
      ;;
    D)
      # Dry-run: não executa os comandos
      # https://unix.stackexchange.com/questions/433801/add-some-dry-run-option-to-script
      dry="echo "
      ;;
    c)
      # Não instala o TinyTeX se existir no cache
      cache=1
      ;;
    d)
      dependencias=1
      ;;
    t)
      tex=1
      ;;
    n)
      codename="$OPTARG"
      ;;
    \?)
      echo "Opção inválida: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Opção -$OPTARG requer argumento." >&2
      exit 1
      ;;
  esac
done

# ler distribuição: lsb_release -c -s
if [ "$codename" = "bionic" ]; then

  if [ -n "$dependencias" ]; then
    $dry sudo apt-get install -y -qq \
      language-pack-pt \
      locales \
      pdfgrep \
      poppler-utils \
      ruby-full \
      unzip \
      xclip
  fi

  if [ -n "$tex" ]; then
    tex_em_cache=0
    if [ -n "$cache" ]; then
      if command -v tlmgr > /dev/null; then
        tex_em_cache=1
        echo TinyTeX não será instalado pois foi encontrado no cache.
      fi
    fi

    if [ $tex_em_cache -eq 1 ]; then
      : #echo TinyTeX não será instalado.
    else
      if [ -z "$dry" ]; then
        wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh
        tlmgr install \
          abntex2 \
          babel-portuges \
          bookmark \
          enumitem \
          epstopdf-pkg \
          ifetex \
          lastpage \
          lipsum \
          listings \
          ltcaption \
          memoir \
          microtype \
          pdflscape \
          pdfpages \
          textcase \
          xcolor

          tlmgr option -- autobackup 0
      else
        $dry wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" \| sh
        $dry tlmgr install abntex2 \
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
          $dry tlmgr option -- autobackup 0
      fi

    fi


  fi #tex

fi #

if [ -n "$pandoc" ];
then
  $dry wget -nv https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-1-amd64.deb
  $dry sudo dpkg -i pandoc-*.deb && $dry rm pandoc-*.deb
fi
