# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Lista de Ilustrações', :lista_ilustracoes do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

![Minha figura](arquivo.png)

TEXTO
    }



  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end

  context 'quando ativada',  :compilacao, :lento do
    let (:output_dir) {"tmp/lista_ilustracoes/ativada"}
    let (:configuracao_especifica) {{'lista_ilustracoes' => true}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_especifica), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "é gerada segundo as Normas da ABNT no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Lista de ilustrações\nFigura 1 – Minha figura")
    end
  end

  context 'quando desativada',  :compilacao, :lento do
    let (:output_dir) {"tmp/lista_tabelas/desativada"}
    let (:configuracao_da_tabela) {{'lista_tabelas' => false}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_da_tabela), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "nao é gerada no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).not_to include("Lista de ilustrações")
    end
  end
  
end
