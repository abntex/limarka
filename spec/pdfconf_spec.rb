# coding: utf-8

require 'spec_helper'
require 'limarka/pdfconf'
require 'pdf_forms'

describe Limarka::Pdfconf do

  let!(:root_dir){Dir.pwd}

  describe "#ler_campo" do
    
    context "quando campo multi-linhas salvo pelo evince", :pdf_evince, :i124 do
      let(:form_file){"spec/formulario-pdf/campo-multi-linhas-preenchido-com-evince.pdf"}
      let(:valor_experado){"ABNT: Associação Brasileira de Normas Técnicas
ES: Engenharia de Software"}
      let(:campo){"siglas"}
      before do
        pdf = PdfForms::Pdf.new form_file, (PdfForms.new 'pdftk'), utf8_fields: true
        @pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      end
      it "ler o valor do campo normalmente" do
        expect(@pdfconf.ler_campo(campo)).to eq(valor_experado)
      end
    end

    context "quando campo multi-linhas salvo pelo pdf-xchange", :pdf_xchange, :i124 do
      let(:form_file){"spec/formulario-pdf/campo-multi-linhas-preenchido-com-pdf-xchange.pdf"}
      let(:valor_experado){"ABNT: Associação Brasileira de Normas Técnicas
ES: Engenharia de Software"}
      let(:campo){"siglas"}
      before do
        pdf = PdfForms::Pdf.new form_file, (PdfForms.new 'pdftk'), utf8_fields: true
        @pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      end

      it "ler o valor do campo e utiliza fim de linha universal" do
        expect(@pdfconf.ler_campo(campo)).to eq(valor_experado)
      end
    end
  end


  describe "#exporta" do

    context "quando PDF configurado para gerar folha de aprovação", :i128 do
      let(:fdf_file){"spec/formulario-pdf/fdf/gerar-folha-de-aprovacao.fdf"}
      let(:pdf_file){"test/formulario-pdf/fdf/gerar-folha-de-aprovacao.pdf"}
      let(:test_dir){"test/formulario-pdf/fdf"}
      before(:context) do
        Dir.chdir(modelo_dir) do
          system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
        end
      end

      before do
        FileUtils.mkdir_p test_dir
        system "pdftk #{modelo_dir}/configuracao.pdf fill_form #{fdf_file} output #{pdf_file}"
        pdf = PdfForms::Pdf.new pdf_file, (PdfForms.new 'pdftk'), utf8_fields: true
        @pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      end
      it "exporta 'folha_de_aprovacao' => true" do
        expect(@pdfconf.exporta).to include('folha_de_aprovacao' => true)
      end

      it "exporta o mês de aprovação selecionado" do
        expect(@pdfconf.exporta).to include("aprovacao_mes" => "Maio")
      end
      
      it "exporta o avaliador1 preenchido" do
        expect(@pdfconf.exporta).to include("avaliador1" => "Fulano")
      end

      it "exporta o avaliador2 preenchido" do
        expect(@pdfconf.exporta).to include("avaliador2" => "Beltrano")
      end

      it "exporta o avaliador3 preenchido" do
        expect(@pdfconf.exporta).to include("avaliador3" => "Cicrano")
      end

    end
  end

end
