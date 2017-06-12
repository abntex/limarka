# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Errata', :anexos do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let (:errata) {<<-TEXTO
A aranha arranha a rã. A rã arranha a aranha. **Nem a aranha arranha a rã**. Nem a rã arranha a aranha.

Folha| Linha| Onde se lê     | Leia-se
-----|------|----------------|----------------
10   |12    |aranhaarranha   | aranha arranha

TEXTO
    }

  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp_r "#{modelo_dir}/.",output_dir
  end

  context 'quando configurada como desativada' do
    let (:output_dir) {File.absolute_path "tmp/errata/desativada"}
    let (:t) {Limarka::Trabalho.new(errata: nil)}

    before do
      Dir.chdir output_dir do
        @cv = Limarka::Conversor.new(t, options)
        @cv.convert
      end
    end

    it 'não será gerada' do
      expect(@cv.texto_tex).not_to include("\\begin{errata}")
      expect(@cv.texto_tex).not_to include("\\end{errata}")
    end
    it 'apresenta mensagem indicando que a seção está configurada como desativada' do
      expect(@cv.texto_tex).to include("Sem errata")
    end

  end

  context 'quando configurada para ser gerada' do
    let (:output_dir) {File.absolute_path "tmp/errata/ativada"}
    let (:t) {Limarka::Trabalho.new(errata: errata)}

    before do
      Dir.chdir output_dir do
        @cv = Limarka::Conversor.new(t, options)
        @cv.convert
      end
    end
    
    it 'a seção de errata foi criada' do
      Dir.chdir output_dir do
        expect(@cv.texto_tex).to include("\\begin{errata}")
        expect(@cv.texto_tex).to include("\\end{errata}")
      end
    end
    it 'a errata foi incluída no arquivo' do
      expect(@cv.texto_tex).to include("A aranha arranha a rã.")
      expect(@cv.texto_tex).to include("aranhaarranha")
    end

    describe 'no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerada segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Errata\n")
        expect(@cv.txt).to include("A aranha arranha a rã.")
      end
    end

  end

end
