# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Referências' do

  let (:citacao_numerica) {{'citacao-numerica' => true, 'referencias-manual' => false}}

  context 'quando configurada com citação numérica (NBR 6023:2002, 9.2)' do
    let(:test_dir) {'citacao-numerica'}
    let(:texto) { t = <<-TEXTO
# Introdução

\\citarei{ABNT-citacao}{ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. {\\emph ABNT NBR 6024:2012}: 
  Informação e documentaçãao -- Apresentação de citações em documentos. Rio de Janeiro, 2002.}

> Citações podem ser numéricas \\cita{ABNT-citacao}.

TEXTO
t
}

    let(:configuracao) {configuracao_padrao.merge citacao_numerica}

    before do
      @cv = Limarka::Conversor.new(:texto => texto, :configuracao => configuracao, :output_dir => "tmp/#{test_dir}")
      @cv.convert
    end
    
    it "utiliza pacote natbib para citação no preambulo", :tecnico do
      expect(@cv.preambulo_tex).to include("\\usepackage[numbers,round,comma]{natbib}")
    end

    it "cria arquivo tex para compilação", :tecnico do
      expect(File).to exist(@cv.texto_tex_file)
    end
    
    describe 'no pdf' do
      before do
        Limarka::CompiladorLatex.compila(@cv.texto_tex_file)
      end
      it "a citação mostra o número da referência entre parenteses (NBR 10520:2002, 6.2)", pdf: true do
        expect(pdftext(@cv.pdf_file)).to include("Citações podem ser numéricas (1).")
      end
      it "a seção referências possui apenas o nome Referências", pdf: true do
        expect(pdftext(@cv.pdf_file)).to include("Referências\n")
      end
      it "mostra as referências com numeração sem parênteses ou colchotes", pdf: true do
        expect(pdftext(@cv.pdf_file)).to include("1 ASSOCIAÇÃO BRASILEIRA")
      end

    end
    
    it "cria seção para referencias vazia", :tecnico => true

    
  end
  

end
