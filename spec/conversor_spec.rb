# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe Limarka::Conversor do


  describe ".tex_file", :tipo_trabalho, :nivel_educacao do
    context "Quando configurado como Projeto de Graduação", :projeto, :graduacao, :monografia do
      let (:configuracao_exportada) {{'graduacao' => true, 'projeto' => true}}
      it "retorna xxx-Monografia-projeto.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Monografia-projeto.tex')
      end
    end
    context "Quando configurado como Trabalho final de Graduação", :monografia, :graduacao do
      let (:configuracao_exportada) {{'graduacao' => true, 'projeto' => false}}
      it "retorna xxx-Monografia.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Monografia.tex')
      end
    end
    context "Quando configurado como Projeto de Especialização", :projeto, :especializacao, :tfc do
      let (:configuracao_exportada) {{'especializacao' => true, 'projeto' => true}}
      it "retorna xxx-TCC-projeto.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-TFC-projeto.tex')
      end
    end
    context "Quando configurado como Trabalho final de especialização", :especializacao, :tfc do
      let (:configuracao_exportada) {{'especializacao' => true, 'projeto' => false}}
      it "retorna xxx-TCC.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-TFC.tex')
      end
    end
    context "Quando configurado como Projeto de Mestrado", :projeto, :mestrado, :dissertacao do
      let (:configuracao_exportada) {{'mestrado' => true, 'projeto' => true}}
      it "retorna xxx-Dissertacao-projeto.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Dissertacao-projeto.tex')
      end
    end
    context "Quando configurado como Trabalho final de Mestrado", :mestrado, :dissertacao do
      let (:configuracao_exportada) {{'mestrado' => true, 'projeto' => false}}
      it "retorna xxx-Dissertacao.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Dissertacao.tex')
      end
    end
    context "Quando configurado como Projeto de Doutorado", :projeto, :doutorado, :tese do
      let (:configuracao_exportada) {{'doutorado' => true, 'projeto' => true}}
      it "retorna xxx-Tese-projeto.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Tese-projeto.tex')
      end
    end
    context "Quando configurado como Trabalho final de Doutorado", :doutorado, :tese do
      let (:configuracao_exportada) {{'doutorado' => true, 'projeto' => false}}
      it "retorna xxx-Tese.tex" do
        expect(Limarka::Conversor.tex_file(configuracao_exportada)).to eq('xxx-Tese.tex')
      end
    end

  end

end
