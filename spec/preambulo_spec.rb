# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'open3'

describe 'Preambulo', :projeto do
  
  let!(:options) {{output_dir: output_dir, templates_dir: Dir.pwd}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_especifica), texto: texto)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

texto.

TEXTO
    }


  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
  end

  context 'quando configurado como projeto ',  :pdf, :lento,  :folha_aprovacao => 'ativada'  do
    let (:output_dir) {"tmp/preambulo/projeto"}
    let (:configuracao_especifica) {{"projeto" => true}}


    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "gera o texto de projeto", :area_de_concentracao, :linha_de_pesquisa do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Projeto")
    end

  end


  context 'quando configurado como trabalho final ',  :pdf, :lento,  :folha_aprovacao => 'ativada'  do
    let (:output_dir) {"tmp/preambulo/trabalho-final"}
    let (:configuracao_especifica) {{"projeto" => false}}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "gera o texto de trabalho final", :area_de_concentracao, :linha_de_pesquisa do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).not_to include("Projeto")
    end

  end

  
  
end
