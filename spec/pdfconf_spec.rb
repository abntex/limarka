# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/pdfconf'

describe 'Configuração' do

  before (:all) do
    # Precisa do libreoffice e ele precisa está fechado!
    system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
  end

  let (:pdf){PdfForms::Pdf.new 'configuracao.pdf', (PdfForms.new 'pdftk'), utf8_fields: true}
  
  describe 'dos Apendices', :apendices, :pdf do
    let(:campo) {'apendices_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Apêndices Desativado', 'Utilizar apêndices escrito no arquivo apendices.md']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}
    
    describe 'no pdf' do
      it 'é realizada através de um combo' do
        expect(field.type).to eq(tipo)
      end
      it 'possui apenas duas opções' do
        expect(field.options).to eq(opcoes)
      end
      it 'é Desativado por padrão' do
        expect(field.value_default).to eq(valor_padrao)
      end
    end

    describe 'na exportação do pdf', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando desativada (valor padrão)' do
        let(:configuracao) {{'apendices' => false}}
        it 'exporta a configuração de desativada' do
          expect(pdfconf.exporta).to include(configuracao)
        end
      end
      context 'quando ativada' do
        let(:valor_de_ativacao) {opcoes[1]}
        let(:configuracao) {{'apendices' => true}}
        before do
          pdfconf.update(campo, valor_de_ativacao)
        end
        it 'exporta a configuração de ativada' do
          expect(pdfconf.exporta).to include(configuracao)
        end
      end      
    end
    
  end

  
end
