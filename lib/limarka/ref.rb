# coding: utf-8
require "thor"
require 'open3'
require 'bibtex'
require 'clipboard'

module Limarka

  class Ref < Thor

    method_option :clipboard, :aliases => '-c', :desc => 'Incluir referência bibtex do clipboard (área de transferência)', :default => false, :type => :boolean
    method_option :bibfile, :aliases => '-f', :desc => 'Arquivo de referências bibtex onde será incluído a referência', :default => "referencias.bib", :type => :string
    desc "add", "Adiciona referência ao arquivo de bibliografia."
    long_desc <<-DESC
Quando você estiver navegando poderá copiar a referência bibtex (do google acadêmico, Zotero, etc.) e incluir ao arquivo de gerência de bibliografia (geralmente referencias.bib) utilizando esse comando. A inclusão do texto ocorrerá da entrada padrão, a não ser que a leitura do clipboard seja acionada (opção `-c`).
DESC
    def add
      if (options[:clipboard]) then
        referencia = Clipboard.paste 
      else 
        referencia = $stdin.read
      end
      entry = BibTeX.parse(referencia)
      if (entry.length.zero?) then
        puts "Entrada não apresenta uma referência válida: #{referencia}"
        return
      else
        referencias = BibTeX.open(options[:bibfile], :include => [:meta_content])
        referencias << entry.entries
        if (referencias.duplicates?) then
          puts "Referência duplicada. Nada foi feito."
        else
          referencias.save
        end
        puts <<MSG

#{entry[0]}

Para citar utilize: \\cite{#{entry[0].key}}  ou  \\citeonline{#{entry[0].key}}
As citações diretas devem indicar a página (NBR 10520:2002, item 5.1): \\cite[p. XXX]{#{entry[0].key}}

MSG
      end
    end
  end
end


