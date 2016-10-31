# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Lista de Siglas', :siglas do
  
  let!(:options) {{output_dir: output_dir, templates_dir: Dir.pwd}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

Texto1

TEXTO
    }



  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
  end

  context 'quando siglas forem especificadas' do
    let (:output_dir) {"tmp/siglas/especificadas"}
    let (:siglas){{'siglas' => [{'s'=>"SQN",'d'=>'Só que não.'}, {'s'=>'OMG', 'd'=>'Oh My God!'}]}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(siglas), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end
    
    it 'seu código é gerado' do
      expect(@cv.texto_tex).to include("\\begin{siglas}")
      expect(@cv.texto_tex).to include("\\end{siglas}")
      expect(@cv.texto_tex).to include("\\item[OMG] Oh My God!")
      expect(@cv.texto_tex).to include("\\item[SQN] Só que não.")
    end

    describe 'no pdf', :pdf, :lento do
      before do
        @cv.compila
      end
      it "são geradas segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Lista de abreviaturas e siglas")
        expect(@cv.txt).to include("SQN")
        expect(@cv.txt).to include("OMG")
        expect(@cv.txt).to include(<<-TXT)
Lista de abreviaturas e siglas
SQN

Só que não.

OMG

Oh My God!
TXT
      end
    end
  end

  context 'quando siglas for nil' do
    let (:output_dir) {"tmp/siglas/siglas-nil"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge({'siglas'=>nil}), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'nenhuma sigla é incluída' do
      expect(@cv.texto_tex).not_to include("\\begin{siglas}")
      expect(@cv.texto_tex).not_to include("\\end{siglas}")
    end
  end


  context 'quando não for especificado siglas' do
    let (:output_dir) {"tmp/siglas/siglas-vazio"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge({'siglas'=>{}}), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'nenhuma sigla é incluída' do
      expect(@cv.texto_tex).not_to include("\\begin{siglas}")        
      expect(@cv.texto_tex).not_to include("\\end{siglas}")
    end
  end

end
