require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

module Limarka

  class CompiladorLatex

    attr_accessor :txt
    
    def compila(tex_file, opcoes)

      Dir.chdir(File.dirname(tex_file)) do
        basename = File.basename(tex_file, '.tex')
        system "latexmk --quiet --xelatex -f #{basename}", :out=>"/dev/null", :err=>"/dev/null"
        system "pdftotext -enc UTF-8 #{basename}.pdf"
        File.open("#{basename}.txt", 'r') {|f| @txt = f.read}
      end
                                            
    end
    
  end
end


