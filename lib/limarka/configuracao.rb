# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'


module Limarka

  class Configuracao < Thor

    method_option :output_dir, :aliases => '-o', :desc => 'Diretório onde será salvo a exportação', :default => '.'
    desc "exporta", "Exporta configuração para YAML. Ler configuracao.pdf e salva em configuracao.yaml no diretório indicado"
    def exporta
      configuracao_pdf  = "configuracao.pdf"
      configuracao_yaml = "configuracao.yaml"
      
      raise IOError, 'Arquivo não encontrado: ' + configuracao_pdf unless File.exist? (configuracao_pdf)
      pdf = PdfForms::Pdf.new configuracao_pdf, (PdfForms.new 'pdftk'), utf8_fields: true
      pdfconf = Limarka::Pdfconf.new(pdf: pdf)

      # exporta sem validação
      h = pdfconf.exporta(false)

      Limarka::Trabalho.save_yaml(h, options[:output_dir]+'/'+configuracao_yaml)
    end


    method_option :pdf_antigo, :aliases => "-p", :required => true
    desc "upgrade", "Após atualização de versão, atualiza os valores do novo arquivo configuracao.pdf a partir do antigo (que precisa ser especificado)"
    def upgrade
      puts "Ainda falta implementar".red
    end
    

  end
end


