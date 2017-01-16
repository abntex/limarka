# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

module Limarka

  # Essa classe é responsável por ler os valores salvos em um formulário PDF
  # e gerar um hash compatível com configuração de um {Trabalho}.
  # @see Trabalho#configuracao
  class Pdfconf


    # @return [PdfForms::Pdf]    
    attr_reader :pdf

    # @param pdf [PdfForms::Pdf]
    def initialize(pdf: nil)
      @pdf = pdf
    end

    # Atualiza um campo do formulário. Útil para execução de testes.
    def update(field, value)
      pdf.field(field).instance_variable_set(:@value, value)
    end

    # Exporta um hash que será utilizado como configuração.
    # @return [Hash] que é utilizado como configuração
    # @see {Trabalho#configuracao}
    def exporta(valida=true)
      h = {}
      h.merge! caixas_de_texto
      h.merge! nivel_educacao
      h.merge! ficha_catalografica
      h.merge! folha_de_aprovacao
      h.merge! projeto
      h.merge! apendices
      h.merge! anexos
      h.merge! errata
      h.merge! referencias
      h.merge! lista_ilustracoes
      h.merge! lista_tabelas
      h.merge! lista_siglas

      
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

    def lista_tabelas
      campo = 'lista_tabelas_combo'
      {'lista_tabelas' => pdf.field(campo).value.include?('Gerar')}
    end

    def lista_siglas
      h = {}
      ['siglas','simbolos'].each do |campo|
        str = pdf.field(campo).value
        if (str) then
          sa = [] # sa: s-array
          str.each_line do |linha|
            s,d = linha.split(":")
            sa << { 's' => s.strip, 'd' => d ? d.strip : ""} if s
          end
          h[campo] = sa.empty? ? nil : sa
        end
      end
      h
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

    # Substitui ',' e ';' por '.'  
    def atualiza_palavras_chave(h)    
      ['palavras_chave', 'palabras_clave', 'keywords', 'mots_cles'].each do |p|
        if(h[p])
          h[p] = h[p].gsub(/[;,]/, '.')
        end
      end
    end

    def caixas_de_texto
      h = {}
      pdf.fields.each do |f|
        if (f.type == "Text") then
          h[f.name] = f.value
        end
      end
      atualiza_palavras_chave(h)
      h
    end    
  end

end


