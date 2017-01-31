# coding: utf-8

require 'spec_helper'
require 'limarka/pdfconf'
require 'pdf_forms'

describe Limarka::Pdfconf do

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

  before(:suite) do
    system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
  end

  describe "#exporta" do
    context "quando PDF configurado para gerar folha de aprovação", :i128 do
      let(:dir){"formulario-pdf/fdf"}
      let(:fdf_file){"gerar-folha-de-aprovacao.fdf"}
      let(:pdf_file){"gerar-folha-de-aprovacao.pdf"}
      before do
        FileUtils.mkdir_p "test/#{dir}"
        system "pdftk configuracao.pdf fill_form #{fdf_file} output test/#{dir}/#{pdf_file}"
        pdf = PdfForms::Pdf.new "test/#{dir}/#{pdf_file}", (PdfForms.new 'pdftk'), utf8_fields: true
        @pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      end
      it "exporta mês de aprovação" do
        expect(@pdfconf.exporta).to include("aprovacao_mes" => "Maio")
      end
    end
  end

end
