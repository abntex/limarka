# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Anexos', :anexos do
  
  let!(:options) {{output_dir: output_dir, templates_dir: Dir.pwd}}
  let (:anexos) {<<-ANEXO
# Primeiro anexo

Texto do anexo.

# Segundo anexo

Texto do segundo anexo.

ANEXO
    }

  before do
    FileUtils.rm_rf output_dir
  end

  context 'quando configurado como desativado' do
    let (:output_dir) {"tmp/anexos/desativado"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao, anexos: nil)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'não serao gerados', :wip do
      expect(@cv.texto_tex).to include("% Anexos desativados")
      expect(@cv.texto_tex).not_to include("\\begin{anexosenv}")
      expect(@cv.texto_tex).not_to include("\\partanexos")
      expect(@cv.texto_tex).not_to include("\\end{anexosenv}")
    end
    it 'apresenta mensagem indicando que a seção está configurada como desativada' do
      expect(@cv.texto_tex).to include("Seção de anexos configurada como desativada")
    end

  end

  context 'quando configurado para serem gerados' do
    let (:output_dir) {"tmp/anexos/ativado"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao, anexos: anexos)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end
    
    it 'a seção de anexos foi criada', :wip do
      expect(@cv.texto_tex).to include("\\begin{anexosenv}")
      expect(@cv.texto_tex).to include("\\partanexos")
      expect(@cv.texto_tex).to include("\\end{anexosenv}")
    end
    it 'os anexos foram incluído no arquivo', :wip do
      expect(@cv.texto_tex).to include("\\chapter{Primeiro anexo}")
      expect(@cv.texto_tex).to include("\\chapter{Segundo anexo}")
    end

    describe 'no pdf', :pdf, :lento do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Anexos\n")
        expect(@cpl.txt).to include("ANEXO A – Primeiro anexo")
        expect(@cpl.txt).to include("ANEXO B – Segundo anexo")
      end
    end

  end

end
