# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Lista de Simbolos', :simbolos do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

Texto1

TEXTO
    }


  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end
  
  context 'quando simbolos forem especificados', :compilacao, :lento, :simbolos => 'especificado' do
    let (:output_dir) {"tmp/simbolos/especificados"}
    let (:simbolos){{'simbolos' => [{'s'=>"in",'d'=>'Pertence'}, {'s'=>'zeta', 'd'=>'Letra Zeta'}]}}
    let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(simbolos), texto: texto)}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "lista de simbolos é gerada segundo as Normas da ABNT" do
      expect(File).to exist(@cv.pdf_file)
      expect(@cv.txt).to include(<<-TXT)
Lista de símbolos
∈

Pertence

ζ

Letra Zeta
TXT
    end
  end
end
