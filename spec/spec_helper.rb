# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'limarka'
require 'yaml'
require 'pry-byebug'



@configuracao_padrao = nil
## Para regerar o arquivo de configuração invoke rake configuracao_padrao
def configuracao_padrao
  @configuracao_padrao = @configuracao_padrao or YAML.load_file('spec/configuracao_padrao/configuracao.yaml')
end

# Retorna o texto do pdf
def pdftext(pdf_file)
  <<-PDF
Citações podem ser numéricas (1).

Referências

1 ASSOCIAÇÃO BRASILEIRA"
PDF
end
