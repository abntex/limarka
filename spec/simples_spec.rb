# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Teste simples', :simpls do

  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir, verbose:true}}
  let(:tex_file) {Limarka::Conversor.tex_file}
  let (:texto) {<<-TEXTO
# Primeiro capítulo

Primeiro parágrafo.

TEXTO
    }


  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
  end

  context 'em um arquivo de texto simples com verbose ativado' do
    let (:output_dir) {"tmp/simples"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao, texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'gera arquivo tex corretamente' do
      expect(File).to exist(@cv.tex_file)
      expect(@cv.texto_tex).to include("\\chapter{Primeiro capítulo}")
      expect(@cv.texto_tex).to include("Primeiro parágrafo.")
    end

    describe 'no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Primeiro capítulo\n")
        expect(@cv.txt).to include("Primeiro parágrafo.")
      end
    end


  end

end
