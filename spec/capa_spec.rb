# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Capa', :capa do


  let!(:configuracao) {configuracao_padrao.merge(configuracao_especifica)}
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let (:t) {Limarka::Trabalho.new(configuracao: configuracao, texto: texto)}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:texto) {<<-TEXTO
  # Primeiro Capítulo

  Texto qualquer

  TEXTO
    }
  let (:texto_gerado_para_capa){<<-TEXTO
Nome do autor

Título do trabalho

Cidade - UF
2019
    TEXTO
    }

  before do
    cria_copia_do_modelo(output_dir)
    @cv = Limarka::Conversor.new(t, options)
    @cv.convert
  end

  context 'quando fornece pdf personalizado' do
    let (:output_dir) {"tmp/capa/capa-pdf-personalizada"}
    let (:configuracao_especifica) {{'capa_pdf_caminho'=> 'imagens/capa.pdf'}}

    it 'capa não será gerada' do
      expect(@cv.texto_tex).not_to include("% Gerando capa abnTeX2")
      expect(@cv.texto_tex).not_to include("\\imprimircapa")
    end
    it 'o pdf da capa é utilizado' do
      expect(@cv.texto_tex).to include("% Incluindo capa personalizada de pdf")
      expect(@cv.texto_tex).to include("\\includepdf{imagens/capa.pdf}")
    end

    describe 'no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "a capa foi incluída apropriadamente" do
        expect(@cv.txt).to include("Capa personalizada")
        expect(@cv.txt).not_to include(texto_gerado_para_capa)
      end
    end
  end

  context 'quando NÃO fornece pdf personalizado' do
    let (:output_dir) {"tmp/capa/sem-capa-personalizada"}
    let (:configuracao_especifica) {{'capa_pdf_caminho'=> ''}}

    it 'nenhuma capa é incluída' do
      expect(@cv.texto_tex).not_to include("\\includepdf")
      expect(@cv.texto_tex).not_to include("% Incluindo capa personalizada de pdf")
    end
    it 'capa será gerada' do
      expect(@cv.texto_tex).to include("\\imprimircapa")
      expect(@cv.texto_tex).to include("% Gerando capa abnTeX2")
    end

    describe 'no pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "a capa foi gerada apropriadamente" do
        expect(@cv.txt).to include(texto_gerado_para_capa)
        expect(@cv.txt).not_to include("Capa personalizada")
      end
    end
  end


end
