# coding: utf-8
require "thor"
require 'open3'
require 'bibtex'
require 'clipboard'

module Limarka

  class Ref < Thor
    include Thor::Actions
    
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
      begin
        entry = BibTeX.parse(referencia)
        error = entry.length.zero?
        if not error then
          append_to_file options[:bibfile], referencia
          
          puts <<MSG
A seguinte referência foi adicionado ao arquivo '#{options[:bibfile]}':
#{referencia}
ABNT NBR 10520:2002(5.1): As citações diretas devem indicar a página.
Como citar no texto: \\cite{#{entry[0].key}}    \\cite[p. XXX]{#{entry[0].key}}    \\citeonline{#{entry[0].key}}
MSG
        end
      rescue BibTeX::ParseError
        error = true
      end
      if (error) then
        puts "Entrada não apresenta uma referência válida:\n#{referencia}"
        return 1
      end
    end
  end
end


