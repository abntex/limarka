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
      h.merge! anexos
      h.merge! errata
      h.merge! referencias
      h.merge! caixas_de_texto
      # TODO: converter para chaves?
      h
    end

    private 
    def apendices
      {'apendices' => !desativado?('apendices_combo')}
    end
    def anexos
      {'anexos' => !desativado?('anexos_combo')}
    end

    def errata
      {'errata' => !desativado?('errata_combo')}
    end

    def referencias
      value = pdf.field('referencias_combo').value
      if value.include?('referencias.bib')  then
        {'referencias_bib' => true, 'referencias_md' => false, 'referencias_numerica_inline' => false}
      elsif value.include?('referencias.md')  then
        {'referencias_bib' => false, 'referencias_md' => true, 'referencias_numerica_inline' => false}
      else
        {'referencias_bib' => false, 'referencias_md' => false, 'referencias_numerica_inline' => true}
      end
    end
    
    def desativado?(campo)
      pdf.field(campo).value.include?('Desativad') # a(o)
    end

    def caixas_de_texto
      h = {}
      pdf.fields.each do |f|
        if (f.type == "Text") then
          h[f.name] = f.value
        end
      end
      h
    end
  end
end


