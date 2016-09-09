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

    def exporta(valida=true)
      h = {}
      h.merge! nivel_educacao
      h.merge! ficha_catalografica
      h.merge! folha_de_aprovacao
      h.merge! projeto
      h.merge! apendices
      h.merge! anexos
      h.merge! errata
      h.merge! referencias
      h.merge! lista_ilustracoes
      h.merge! caixas_de_texto
      
      # TODO: converter para chaves?
      valida_campos(h) if valida
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

    def lista_ilustracoes
      campo = 'lista_ilustracoes_combo'
      {'lista_ilustracoes' => pdf.field(campo).value.include?('Gerar')}
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

    def projeto
      campo = 'projeto_combo'
      value = pdf.field(campo).value

      if value.include?('Projeto')  then
        {'projeto' => true}
      elsif value.include?('final')  then
        {'projeto' => false}
      else
        raise ArgumentError, "Caixa #{campo} com valor inválido"
      end
    end

    def ficha_catalografica
      campo = 'ficha_catalografica_combo'
      value = pdf.field(campo).value

      if value.include?('Sem ficha')  then
        {'incluir_ficha_catalografica' => false}
      elsif value.include?('Incluir ficha')  then
        {'incluir_ficha_catalografica' => true}
      else
        raise ArgumentError, "Caixa #{campo} com valor inválido"
      end
    end

    
    def nivel_educacao
      campo = 'nivel_educacao_combo'
      value = pdf.field(campo).value

      if value.include?('Graduação')  then
        {'graduacao' => true, 'especializacao' => false, 'mestrado' => false, 'doutorado' => false, 'tipo_do_trabalho'=>'Monografia'}
      elsif value.include?('Especialização')  then
        {'graduacao' => false, 'especializacao' => true, 'mestrado' => false, 'doutorado' => false, 'tipo_do_trabalho'=>'Trabalho de final de curso'}
      elsif value.include?('Mestrado')  then
        {'graduacao' => false, 'especializacao' => false, 'mestrado' => true, 'doutorado' => false, 'tipo_do_trabalho'=>'Dissertação'}
      elsif value.include?('Doutorado')  then
        {'graduacao' => false, 'especializacao' => false, 'mestrado' => false, 'doutorado' => true, 'tipo_do_trabalho'=>'Tese'}
      else
        raise ArgumentError, "Caixa #{campo} com valor inválido"
      end
    end

    def folha_de_aprovacao
      campo = 'folha_de_aprovacao_combo'
      value = pdf.field(campo).value

      if value.include?('Não gerar')  then
        {'folha_de_aprovacao' => false}
      elsif value.include?('Gerar folha')  then
        {'folha_de_aprovacao' => true}
      elsif value.include?('escaneada')  then
        {'incluir_folha_de_aprovacao' => true}
      else
        raise ArgumentError, "Caixa #{campo} com valor inválido"
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


