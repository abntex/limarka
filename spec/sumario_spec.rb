# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Sumário', :sumario do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

Texto1

## Seção 1.1

Texto1.1

## Seção 1.2

Texto1.2

# Segundo capítulo

Texto2

TEXTO
    }

  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end

  context 'independente de qualquer configuração' do
    let (:output_dir) {"tmp/sumario/automatico"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao, texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end
    
    it 'sempre é gerado' do
      expect(@cv.texto_tex).to include("% Sumário")
      expect(@cv.texto_tex).to include("\\tableofcontents*")
    end


  end

  context 'quando não for especificado siglas' do
    let (:output_dir) {"tmp/sumario/siglas-nil"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge({'siglas'=>nil}), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end


    it 'nenhuma sigla é incluída' do
      expect(@cv.texto_tex).not_to include("\\begin{siglas}")        
      expect(@cv.texto_tex).not_to include("\\end{siglas}")
    end

    describe 'o sumário no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Sumário\n")
        expect(@cv.txt).to include("Seção 1.1\n")
        expect(@cv.txt).to include("Seção 1.2\n")
      end
    end
  end


  context 'quando não for especificado siglas' do
    let (:output_dir) {"tmp/sumario/sem-siglas"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge({'siglas'=>{}}), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'nenhuma sigla é incluída' do
      expect(@cv.texto_tex).not_to include("\\begin{siglas}")        
      expect(@cv.texto_tex).not_to include("\\end{siglas}")
    end


    describe 'o sumário no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Sumário\n")
        expect(@cv.txt).to include("Seção 1.1\n")
        expect(@cv.txt).to include("Seção 1.2\n")

      end
    end
  end

end
