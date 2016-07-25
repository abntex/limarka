require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

module Limarka

  class Conversor
    attr_accessor :opcoes
    def initialize(opcoes)
      self.opcoes = opcoes
    end

    def convert
    end

    def preambulo_tex
      "\\usepackage[numbers,round,comma]{natbib}"
    end
    def texto_tex_file
      
    end
    def pdf_file
    end
  end
end


