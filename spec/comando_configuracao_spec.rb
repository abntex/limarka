# coding: utf-8

require 'spec_helper'
require 'limarka'
require 'limarka/configuracao'
require 'yaml'

describe 'Comando configuracao' do
    
  context "quando invoca: limarka configuracao exporta -o tmp/configuracao/exporta-configuracao-pdf-para-yaml", :exporta_yaml, :configuracao do
    let(:test_dir){'tmp/configuracao/exporta-configuracao-pdf-para-yaml'}
    let(:arquivo_de_saida) {"#{test_dir}/configuracao.yaml"}
    before do
      FileUtils.rm_rf test_dir
      FileUtils.mkdir_p test_dir
      FileUtils.cp "configuracao.pdf", test_dir
    end
    it "exporta a configuração do PDF para o diretório indicado" do
      system('bundle', 'exec', 'limarka', 'configuracao', 'exporta', '-o', test_dir)
      expect(File).to exist(arquivo_de_saida)
      file = IO.read(arquivo_de_saida)
      expect(file).to include('resumo')
      expect(file).to include('title: Título do trabalho')
    end    
  end
  
end
