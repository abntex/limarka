#!/usr/bin/env sh
# rodar script usando: 
# ". instalador.sh" ou "bash -i instalador.sh" 
# ver https://askubuntu.com/a/1102119

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
distro=$(lsb_release -i -s)
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
if [ "$distro" = "Ubuntu" -o "$distro" = "ManjaroLinux" ]; then
  if [ "$dependencias" = "dev" ]; then
    echo Instalando dependências de desenvolvimento...
    if [ "$distro" = "Ubuntu" ]; then
      $dry sudo apt-get install -y -qq \
      language-pack-pt \
      libreoffice \
      locales \
      pdfgrep \
      poppler-utils \
      ruby-full \
      unzip \
      xclip
      if [ "$codename" = "xenial" ]; then
        $dry sudo apt-get install pdftk -y
      elif [ "$codename" = "bionic" ]; then
        $dry sudo add-apt-repository ppa:malteworld/ppa -y
        $dry sudo apt-get update
        $dry sudo apt-get install pdftk -y
      else
        # Ubuntu >= 18.10
        $dry sudo apt-get install pdftk-java -y
      fi
    elif [ "$distro" = "ManjaroLinux" ]; then
      $dry sudo pacman -S --noconfirm \
        ruby \
        poppler \
        xclip \
        pacaur
      $dry yes J | pacaur -S pdftk-bin
    fi
  elif [ "$dependencias" = "user" ]; then
    $dry echo Opção ainda não implementada: user
  fi

  if [ "$tex" = "none" ]; then
    echo Ignorando instalação do Latex
  elif [ "$tex" = "system" ]; then
    if [ "$distro" = "ManjaroLinux" ]; then
      $dry sudo pacman -S texlive-core \
        texlive-bin \
        texlive-latexextra
      $dry yes J | pacaur -S abntex2
    elif [ "$distro" = "Ubuntu" ]; then
      $dry sudo apt-get install -y \
        texlive \
        texlive-publishers \
        texlive-lang-portuguese \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-xetex
    fi
  elif [ "$tex" = "tiny" ]; then

    tex_em_cache=0
    if [ $cache -eq 1 ]; then
      if command -v tlmgr > /dev/null; then
        tex_em_cache=1
        echo TinyTeX encontrado no cache.
      fi
    fi

    if [ $tex_em_cache -eq 1 ]; 
    then
      echo TinyTeX não será instalado.
    else
      echo Instalando o tinytex...
      $dry wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | $dry sh
      # Deve ser colocado no Path, se não tlmgr dá comando não encontrado
      $dry echo -e "\n\n# TinyTeX BIN" >> ~/.bashrc
      $dry echo -e "export "PATH"=$"PATH":~/.TinyTeX/bin/x86_64-linux" >> ~/.bashrc
      $dry source ~/.bashrc
      
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
    
    fi #tex
  fi
fi # UbuntuLinux | ManjaroLinux

if [ "$pandoc" -eq 1 ]
then
  echo Ignorando instalação dos Binários do Pandoc
  if [ "$distro" = "ManjaroLinux" ]; then
    $dry yes J | pacaur -S pandoc-bin
  else
    #echo Instalando o pandoc...
    $dry wget -nv https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb \
      && $dry sudo dpkg -i pandoc-*.deb
  fi
fi

if ! $dry gem install limarka
then
    $dry "Não foi possível instalar o limarka"
    $dry exit 1
fi

# Especifico pro Manjaro
if [ "$distro" = "ManjaroLinux" ]; then
  $dry echo -e "\n\n# RUBY GEMS BIN" >> ~/.bashrc
  $dry echo -e "export "PATH"=$"PATH":~/.gem/ruby/2.6.0/bin" >> ~/.bashrc
  $dry source ~/.bashrc
fi