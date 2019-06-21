#!/usr/bin/env sh

#quiet
#dependencias=dev,user
#pandoc
#tex=tiny,live,system
#codename=xenial
#grupo=limarka,limarka-extras
#pacote
#Dry run
quiet=0
dependencias=dev
pandoc=0
tex=tiny
codename=$(lsb_release -c -s)
grupo=basico
pacotes=
dry=
cache=0

# Documentação de ajuda:
# https://wiki.bash-hackers.org/howto/getopts_tutorial
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html

while getopts "DPCd:t:c:g:p:" opt; do
  case $opt in
    P)
      pandoc=1
      ;;
    D)
      # Dry-run: não executa os comandos
      dry="echo "
      ;;
    C)
      # Não instala o TinyTeX se existir no cache
      cache=1
      ;;
    d)
      dependencias="$OPTARG"
      ;;
    t)
      tex="$OPTARG"
      ;;
    c)
      codename="$OPTARG"
      ;;
    g)
      grupo="$OPTARG"
      ;;
    p)
      pacotes="$pacotes $OPTARG "
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
if [ "$codename" = "xenial" ]; then

  if [ "$dependencias" = "dev" ]; then
    echo Instalando dependências de desenvolvimento...
    $dry sudo apt-get install -y -qq \
      language-pack-pt \
      libreoffice \
      locales \
      pdfgrep \
      pdftk \
      poppler-utils \
      ruby-full \
      unzip \
      xclip
  elif [ "$dependencias" = "user" ]; then
    $dry echo Opção ainda não implementada: user
  fi

  if [ "$tex" = "none" ]; then
    echo Ignorando instalação do Latex
  elif [ "$tex" = "tiny" ]; then

    tex_em_cache=0
    if [ $cache -eq 1 ]; then
      if command -v tlmgr > /dev/null; then
        tex_em_cache=1
        echo TinyTeX encontrado no cache.
      fi
    fi

    if [ $tex_em_cache -eq 1 ]; then
      : #echo TinyTeX não será instalado.
    else
      echo Instalando o tinytex...
      $dry wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | $dry sh

      if [ "$grupo" = "basico" ]; then
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
      elif [ "$grupo" = "extras" ]; then
          $dry Opção ainda não implementada: extras
      fi

      if [ -n "$pacotes" ] ; then
        $dry tlmgr install $pacotes
      fi

      $dry tlmgr option -- autobackup 0
    fi


  fi #tex

fi # xenial

if [ "$pandoc" -eq 1 ]
then
  #echo Instalando o pandoc...
  $dry wget -nv https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb \
    && $dry sudo dpkg -i pandoc-*.deb
fi
