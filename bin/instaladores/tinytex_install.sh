#!/usr/bin/env sh

if [ "$IGNORE_CACHE" != "1" ] && command -v tlmgr > /dev/null; then
  tex_em_cache=1
  echo TinyTeX não será instalado pois foi encontrado no cache.
else
    wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh
    ~/bin/tlmgr --no-verify-downloads install \
      abntex2 \
      babel-portuges \
      biber \
      biblatex \
      biblatex-abnt \
      bookmark \
      caption \
      enumitem \
      epstopdf-pkg \
      lastpage \
      lipsum \
      listings \
      memoir \
      microtype \
      pdflscape \
      pdfpages \
      psnfss \
      shipunov \
      texliveonfly \
      textcase \
      xcolor
      ~/bin/tlmgr option -- autobackup 0
fi
