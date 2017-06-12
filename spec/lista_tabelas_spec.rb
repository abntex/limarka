# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Lista de Tabelas', :lista_tabelas do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

Texto1

|AA|BB|
---|---
|CC|DD|

: Título da tabela

TEXTO
    }



  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end

  context 'quando ativada',  :compilacao, :lento do
    let (:output_dir) {"tmp/lista_tabelas/ativada"}
    let (:configuracao_da_tabela) {{'lista_tabelas' => true}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_da_tabela), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "é gerada segundo as Normas da ABNT no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Lista de tabelas\nTabela 1 – Título da tabela")
    end
  end

  context 'quando desativada',  :compilacao, :lento do
    let (:output_dir) {"tmp/lista_tabelas/ativada"}
    let (:configuracao_da_tabela) {{'lista_tabelas' => false}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_da_tabela), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "nao é gerada no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).not_to include("Lista de tabelas\nTabela 1 – Título da tabela")
    end
  end

  
end
