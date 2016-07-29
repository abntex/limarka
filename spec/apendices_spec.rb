# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Apendices', :apendices do
  

  let (:texto) {""}

  before do
    FileUtils.rm_rf output_dir
  end

  context 'quando configurado como oculto' do
    let (:output_dir) {"tmp/apendices/desativado"}
    let (:configuracao) {configuracao_padrao.merge({'apendices' => false})}

    before do
      @cv = Limarka::Conversor.new(output_dir: output_dir, configuracao: configuracao, texto: texto)
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
    let (:configuracao) {configuracao_padrao.merge({'apendices' => true})}
    let (:apendice_texto) {<<-APENDICE
# Primeiro apêndice

Texto do apêndice.

# Segundo apêndice

Texto do segundo apêndice

APENDICE
    }

    before do
      @cv = Limarka::Conversor.new(output_dir: output_dir, configuracao: configuracao, texto: texto, apendices: apendice_texto)
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

    describe 'o pdf', :pdf do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "é gerado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Apêndices\n")
        expect(@cpl.txt).to include("APÊNDICE A – Primeiro apêndice\nTexto do apêndice.")
        expect(@cpl.txt).to include("APÊNDICE B – Segundo apêndice\nTexto do segundo apêndice")
      end
    end

  end

end
