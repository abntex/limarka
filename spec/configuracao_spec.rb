# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/pdfconf'

describe 'configuracao.pdf', :integracao do

  before (:all) do
    # Precisa do libreoffice e ele precisa está fechado!
    system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
  end

  let (:pdf){PdfForms::Pdf.new 'configuracao.pdf', (PdfForms.new 'pdftk'), utf8_fields: true}

  shared_examples 'um combo desativado por padrão' do
        
    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui apenas duas opções de configuração' do
      expect(field.options).to eq(opcoes)
    end
    it 'é Desativado por padrão' do
      expect(field.value_default).to eq(valor_padrao)
    end

  end

  
  describe 'apendices_combo', :apendices, :pdf do
    let(:campo) {'apendices_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Apêndices Desativado', 'Utilizar apêndices escrito no arquivo apendices.md']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it_behaves_like 'um combo desativado por padrão'
    
    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando desativada (valor padrão)' do
        let(:configuracao) {{'apendices' => false}}
        it 'exporta a configuração de desativado' do
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

  describe 'anexos_combo', :anexos, :pdf do
    let(:campo) {'anexos_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Anexos Desativado', 'Utilizar anexos, escrito no arquivo anexos.md']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it_behaves_like 'um combo desativado por padrão'

    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando desativada (valor padrão)' do
        let(:configuracao) {{'anexos' => false}}
        it 'exporta a configuração de desativado' do
          expect(pdfconf.exporta).to include(configuracao)
        end
      end
      context 'quando ativado' do
        let(:valor_de_ativacao) {opcoes[1]}
        let(:configuracao) {{'anexos' => true}}
        before do
          pdfconf.update(campo, valor_de_ativacao)
        end
        it 'exporta a configuração de ativado' do
          expect(pdfconf.exporta).to include(configuracao)
        end
      end      
    end
  end

  describe 'errata_combo', :anexos, :pdf do
    let(:campo) {'errata_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Errata Desativada', 'Utilizar errata, escrita no arquivo errata.md']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it_behaves_like 'um combo desativado por padrão'

    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando desativada (valor padrão)' do
        let(:configuracao_exportada) {{'errata' => false}}
        it 'exporta a configuração de desativada' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando ativada' do
        let(:valor_de_ativacao) {opcoes[1]}
        let(:configuracao_exportada) {{'errata' => true}}
        before do
          pdfconf.update(campo, valor_de_ativacao)
        end
        it 'exporta a configuração de ativada' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end      
    end
  end

  describe 'referencias_combo', :referencias, :pdf do
    let(:campo) {'referencias_sistema_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Referências Alfabética (padrão)', 'Referências Numérica']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Referências Alfabética (valor padrão)' do
        let(:configuracao_exportada) {{'referencias_sistema' => 'alf'}}
        it 'exporta referencias_sistema=>alf' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Referências Numérica' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'referencias_sistema' => 'num'}}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta referencias_sistema=>num' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
    end
  end

  describe 'referencias_caminho', :referencias, :pdf do
    let(:campo) {'referencias_caminho'}
    let(:tipo) {'Text'}
    let(:opcoes) {['Referências Alfabética (padrão)', 'Referências Numérica']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo texto' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end

    describe 'seu valor padrão' do
      it "é 'referencias.bib'" do
        expect(field.value).to eq('referencias.bib')
      end
    end


    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando o arquivo de referências NÃO existe' do
        let(:arquivo_nao_existente) {"ARQUIVO_NAO_EXISTENTE.bib"}
        before do
          pdfconf.update(campo, arquivo_nao_existente)
        end
        it 'emite erro durante a exportação' do
          expect {pdfconf.exporta}.to raise_error ArgumentError, "Arquivo de referências configurado não foi encontrado: #{arquivo_nao_existente}"
        end
      end
      context 'quando o arquivo de referências EXISTE' do
        let(:configuracao_exportada) {{'referencias_caminho' => 'referencias.bib'}}
        before do
          allow(File).to receive('exist?').with('referencias.bib') {true}
        end
        it 'exportação contém o valor do campo' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
    end
  end

  
  describe 'Os parâmetros de texto' do
    let(:parametros){['avaliador1', 'avaliador2', 'avaliador3']}
    it 'são configurados através de caixas de texto' do
      parametros.each do |campo|
        expect(pdf.field(campo)).not_to be nil
        expect(pdf.field(campo).type).to eq('Text')
      end
    end
    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      it 'seus valores serão exportados integralmente' do
        configuracao = {}
        parametros.each do |campo|
          expect(pdf.field(campo)).not_to be nil
          configuracao.merge!({"#{campo}" => pdf.field(campo).value})
        end
        expect(pdfconf.exporta).to include(configuracao)
      end
    end
    
  end
end
