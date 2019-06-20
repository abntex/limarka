
# Instalação do TinyTeX
wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh

# Instalação dos demais pacotes utilizados pelo Limarka e abntex2
tlmgr install abntex2 \
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

# Sobre cache:
# https://tex.stackexchange.com/questions/398830/how-to-build-my-latex-automatically-using-travis-ci

# Keep no backups (not required)
tlmgr option -- autobackup 0
