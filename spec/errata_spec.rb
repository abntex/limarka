# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Errata', :anexos do
  
  let!(:options) {{output_dir: output_dir, templates_dir: Dir.pwd}}
  let (:errata) {<<-TEXTO
A aranha arranha a rã. A rã arranha a aranha. **Nem a aranha arranha a rã**. Nem a rã arranha a aranha.

Folha| Linha| Onde se lê     | Leia-se
-----|------|----------------|----------------
10   |12    |aranhaarranha   | aranha arranha

TEXTO
    }

  before do
    FileUtils.rm_rf output_dir
  end

  context 'quando configurada como desativada' do
    let (:output_dir) {"tmp/errata/desativada"}
    let (:t) {Limarka::Trabalho.new(errata: nil)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'não será gerada', :wip do
      expect(@cv.texto_tex).not_to include("\\begin{errata}")
      expect(@cv.texto_tex).not_to include("\\end{errata}")
    end
    it 'apresenta mensagem indicando que a seção está configurada como desativada' do
      expect(@cv.texto_tex).to include("Sem errata")
    end

  end

  context 'quando configurada para ser gerada' do
    let (:output_dir) {"tmp/errata/ativada"}
    let (:t) {Limarka::Trabalho.new(errata: errata)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end
    
    it 'a seção de errata foi criada', :wip do
      expect(@cv.texto_tex).to include("\\begin{errata}")
      expect(@cv.texto_tex).to include("\\end{errata}")
    end
    it 'a errata foi incluída no arquivo', :wip do
      expect(@cv.texto_tex).to include("A aranha arranha a rã.")
      expect(@cv.texto_tex).to include("aranhaarranha")
    end

    describe 'no pdf', :pdf do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Errata\n")
        expect(@cpl.txt).to include("A aranha arranha a rã.")
      end
    end

  end

end
