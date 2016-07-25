# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'
require 'fileutils'

module Limarka

  class Conversor
    attr_accessor :opcoes
    attr_accessor :preambulo_tex
    def initialize(opcoes)
      self.opcoes = opcoes
    end

    def convert
      #salva_configuracao_yaml
      preambulo
      FileUtils.mkdir_p opcoes[:output_dir]
      FileUtils.touch(texto_tex_file)
    end

    def hash_to_yaml(h)
      s = StringIO.new
      s << h.to_yaml
      s << "---\n\n"
      s.string
    end
    
    PREAMBULO="templates/preambulo.tex"
    def preambulo
      Open3.popen3("pandoc -f markdown --data-dir=. --template=preambulo -t latex") do |stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(opcoes[:configuracao]))
        stdin.close
        @preambulo_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      end
    end
    
    def texto_tex_file
      "#{opcoes[:output_dir]}/xxx-Monografia.tex"
    end
    def pdf_file
    end
    
  end
end


