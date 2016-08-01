require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

module Limarka

  class Pdfconf

    attr_reader :pdf
    
    def initialize(pdf: nil)
      @pdf = pdf
    end

    def update(field, value)
      pdf.field(field).instance_variable_set(:@value, value)
    end

    def exporta
      h = {}
      h.merge! apendices

      h
    end
    
    def apendices
      {'apendices' => !desativado?('apendices_combo')}
    end

    def desativado?(campo)
      pdf.field(campo).value.include?('Desativado')
    end
    
  end
end


