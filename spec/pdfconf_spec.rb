# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Configuração' do

  before (:all) do
    # Precisa do libreoffice e ele precisa está fechado!
    system "libreoffice --headless --convert-to pdf configuracao.odt"
  end

  let (:pdf){PdfForms::Pdf.new 'configuracao.pdf', (PdfForms.new 'pdftk'), utf8_fields: true}
  
  describe 'dos Apendices', :apendices do
    let(:campo) {'apendices_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Apêndices Desativado', 'Utilizar apêndices escrito no arquivo apendices.md']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}
    
    describe 'no pdf', :wip do
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

    describe 'na exportação do pdf' do
      let(:valor_padrao) {{'apendices': false}}
      context 'quando desativada (valor padrão)' do
        let(:configuracao) {valor_padrao}
        it 'exporta a configuração de desativada'
      end
      context 'quando ativada' do
        let(:configuracao) {{'apendices': true}}
        it 'exporta a configuração de ativada'
      end      
    end
    
  end

  
end
