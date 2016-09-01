# coding: utf-8
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
      valida_campos(h)
      h
    end

    private

    def valida_campos(h)
      arquivo_de_referencias = h['referencias_caminho']
      raise ArgumentError, "Arquivo de referências configurado não foi encontrado: #{arquivo_de_referencias}" unless File.exist?(arquivo_de_referencias)
      
    end
    
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
      value = pdf.field('referencias_sistema_combo').value
      if value.include?('Numérica')  then
        {'referencias_sistema' => 'num'}
      elsif value.include?('Alfabética')  then
        {'referencias_sistema' => 'alf'}
      else
        raise ArgumentError, "Caixa referencias_sistema_combo com valor inválido"
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


