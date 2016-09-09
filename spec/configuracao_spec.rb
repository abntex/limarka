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

  describe 'Os parâmetros de texto', :campo_texto, :proposito do
    let(:parametros){['avaliador1', 'avaliador2', 'avaliador3', 'linha_de_pesquisa', 'area_de_concentracao', 'proposito']}
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

  describe 'nivel_educacao_combo', :nivel_educacao do
    let(:campo) {'nivel_educacao_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Graduação', 'Especialização', 'Mestrado', 'Doutorado']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui 4 opções de configuração' do
      expect(field.options).to include(opcoes[0])
      expect(field.options).to include(opcoes[1])
      expect(field.options).to include(opcoes[2])
      expect(field.options).to include(opcoes[3])
    end
    
    it 'seu valor padrão é Graduação' do
      expect(field.value_default).to eq(valor_padrao)
    end

    describe 'na exportação para yaml', :pdfconf, :nivel_educacao, :tipo_do_trabalho do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Graduação (valor padrão)' do
        let(:configuracao_exportada) {{'graduacao' => true, 'especializacao' => false, 'mestrado' => false, 'doutorado' => false, 'tipo_do_trabalho'=>'Monografia'}}
        it 'exporta graduacao => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Especialização' do
        let(:valor_configurado) {opcoes[1]}
        let(:configuracao_exportada) {{'graduacao' => false, 'especializacao' => true, 'mestrado' => false, 'doutorado' => false, 'tipo_do_trabalho'=>'Trabalho de final de curso'}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta especializacao => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Mestrado' do
        let(:valor_configurado) {opcoes[2]}
        let(:configuracao_exportada) {{'graduacao' => false, 'especializacao' => false, 'mestrado' => true, 'doutorado' => false, 'tipo_do_trabalho'=>'Dissertação'}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta mestrado => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end      
      context 'quando Doutorado' do
        let(:valor_configurado) {opcoes[3]}
        let(:configuracao_exportada) {{'graduacao' => false, 'especializacao' => false, 'mestrado' => false, 'doutorado' => true, 'tipo_do_trabalho'=>'Tese'}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta doutorado => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end      

    end
  end

  describe 'projeto_combo', :projeto, :pdf do
    let(:campo) {'projeto_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Projeto ou Proposta para Qualificação/Avaliação', 'Trabalho final (em produção ou finalizado)']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui 2 opções de configuração' do
      expect(field.options).to eq(opcoes)
    end
    
    it 'seu valor padrão é Proposta ou Projeto' do
      expect(field.value_default).to eq(valor_padrao)
    end

    describe 'na exportação para yaml', :pdfconf, :nivel_educacao do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Proposta ou Projeto (valor padrão)' do
        let(:configuracao_exportada) {{'projeto' => true}}
        it 'exporta projeto => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Trabalho Final ou Completo' do
        let(:valor_configurado) {opcoes[1]}
        let(:configuracao_exportada) {{'projeto' => false}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta projeto => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
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

  describe 'errata_combo', :errata, :pdf do
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

  describe 'folha_de_aprovacao_combo', :folha_de_aprovacao do
    let(:campo) {'folha_de_aprovacao_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Não gerar folha de aprovação', 'Gerar folha de aprovação', 'Utilizar folha de aprovação escaneada']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui 3 opções de configuração' do
      expect(field.options).to include(opcoes[0])
      expect(field.options).to include(opcoes[1])
      expect(field.options).to include(opcoes[2])
    end
    
    it 'seu valor padrão é Não Gerar' do
      expect(field.value_default).to eq(valor_padrao)
    end

    describe 'na exportação para yaml', :pdfconf, :nivel_educacao do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Não gerar (valor padrão)' do
        let(:configuracao_exportada) {{'folha_de_aprovacao' => false}}
        it 'exporta folha_de_aprovacao => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Gerar folha de aprovação' do
        let(:valor_configurado) {opcoes[1]}
        let(:configuracao_exportada) {{'folha_de_aprovacao' => true}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta folha_de_aprovacao => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Incluir folha de aprovação' do
        let(:valor_configurado) {opcoes[2]}
        let(:configuracao_exportada) {{'incluir_folha_de_aprovacao' => true}}
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta incluir_folha_de_aprovacao => true' do
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

  describe 'ficha_catalografica_combo', :ficha_catalografica do
    let(:campo) {'ficha_catalografica_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Sem ficha catalográfica','Incluir ficha-catalografica.pdf da pasta imagens']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui 2 opções de configuração' do
      expect(field.options).to include(opcoes[0])
      expect(field.options).to include(opcoes[1])
    end
    
    it 'seu valor padrão é Sem ficha' do
      expect(field.value_default).to eq(valor_padrao)
    end
    
    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Sem ficha catalográfica (valor padrão)' do
        let(:configuracao_exportada) {{'incluir_ficha_catalografica' => false}}
        it 'exporta incluir_ficha_catalografica => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Incluir ficha catalográfica' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'incluir_ficha_catalografica' => true}}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta incluir_ficha_catalografica => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
    end
  end

  describe 'lista_ilustracoes_combo', :lista_ilustracoes do
    let(:campo) {'lista_ilustracoes_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Dispensar uso de lista de ilustrações','Gerar lista de ilustrações']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}

    it 'é um campo do tipo combo' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end
    it 'possui 2 opções de configuração' do
      expect(field.options).to include(opcoes[0])
      expect(field.options).to include(opcoes[1])
    end
    
    it 'seu valor padrão é Sem Lista' do
      expect(field.value_default).to eq(valor_padrao)
    end
    
    describe 'na exportação para yaml', :pdfconf do
      let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
      context 'quando Sem Lista (valor padrão)' do
        let(:configuracao_exportada) {{'lista_ilustracoes' => false}}
        it 'exporta lista_ilustracoes => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      context 'quando Incluir lista de ilustrações' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'lista_ilustracoes' => true}}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta lista_ilustracoes => true' do
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


  
end
