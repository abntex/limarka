# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Apendices', :apendices do

  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}  
  let (:configuracao) {configuracao_padrao}
  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end

  context 'quando configurado como oculto' do
    let (:output_dir) {"tmp/apendices/desativado"}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao, anexos: nil)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'não serao gerados' do
      expect(@cv.texto_tex).not_to include("\\begin{apendicesenv}")
      expect(@cv.texto_tex).not_to include("\\partapendices")
      expect(@cv.texto_tex).not_to include("\\end{apendicesenv}")
    end
    it 'apresenta mensagem indicando que a seção está configurada como desativada' do
      expect(@cv.texto_tex).to include("Seção de apendices configurada como desativada")
    end

  end

  context 'quando configurado para serem gerados' do
    let (:output_dir) {"tmp/apendices/ativado"}
    let (:apendice_texto) {<<-APENDICE
# Primeiro apêndice

Texto do apêndice.

# Segundo apêndice

Texto do segundo apêndice

APENDICE
    }
    let (:t) {Limarka::Trabalho.new(apendices: apendice_texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
    end

    it 'a seção de apêndices foi criada' do
      expect(@cv.texto_tex).to include("\\begin{apendicesenv}")
      expect(@cv.texto_tex).to include("\\partapendices")
      expect(@cv.texto_tex).to include("\\end{apendicesenv}")
    end
    it 'o texto do apêndice foi incluído no arquivo' do
      expect(@cv.texto_tex).to include("\\chapter{Primeiro apêndice}")
      expect(@cv.texto_tex).to include("\\chapter{Segundo apêndice}")
    end

    describe 'no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerado segundo as Normas da ABNT" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Apêndices\n")
        expect(@cv.txt).to include("APÊNDICE A – Primeiro apêndice\nTexto do apêndice.")
        expect(@cv.txt).to include("APÊNDICE B – Segundo apêndice\nTexto do segundo apêndice")
      end
    end

  end

end
