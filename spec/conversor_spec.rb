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
  
  describe "#cria_xxx_referencias" do
    context "quando contém subtítulo e duplas chaves", :i122 do
      let(:referencias_com_duplas_chaves) {<<-BIB
@article{Patton2009,
author = {Patton, George C and Coffey, Carolyn and Sawyer, Susan M and Viner, Russell M and Haller, Dagmar M and Bose, Krishna and Vos, Theo and Ferguson, Jane and Mathers, Colin D},
doi = {10.1016/S0140-6736(09)60741-8},
file = {:home/andresimi/Documentos/Dropbox/Sincronizar/Mendeley Desktop/pdf/Patton et al. - 2009 - Global patterns of mortality in young people a systematic analysis of population health data.pdf:pdf},
journal = {Lancet},
keywords = {infancy,suicide},
mendeley-tags = {infancy,suicide},
number = {9693},
pages = {881--92},
pmid = {19748397},
title = {{Global patterns of mortality in young people: a systematic analysis of population health data}},
url = {http://www.ncbi.nlm.nih.gov/pubmed/19748397},
volume = {374},
year = {2009}
}
BIB
}
      let(:titulo_esperado){"Global patterns of mortality in young people"}
      let(:subtitulo_esperado){"a systematic analysis of population health data"}
      let(:output_dir){"test/referencias/subtitulo-chaves-duplas"}
      let!(:options) {{output_dir: output_dir}}
    
      before do
        FileUtils.rm_rf output_dir
        FileUtils.mkdir_p output_dir

        t = Limarka::Trabalho.new(referencias_bib: referencias_com_duplas_chaves)
        @c = Limarka::Conversor.new(t,options)
      end
      
      it "mantém título e subtítulo consistentes" do
        @c.cria_xxx_referencias
        
        b = BibTeX.open(@c.referencias_bib_file)
        expect(b['Patton2009'].title.to_s).to eq(titulo_esperado)
        expect(b['Patton2009'].subtitle).to eq(subtitulo_esperado)
      end
    end
  end

end
