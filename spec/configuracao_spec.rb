# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/pdfconf'
require 'open3'

describe 'configuracao.pdf', :integracao do

  def template_mesclado(template, yaml_hash)
    yaml_tempfile = Tempfile.new('yaml')
    result = ''
    begin
      Open3.popen3("pandoc -f markdown --data-dir=#{modelo_dir} --template=#{template} -t latex") {|stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(yaml_hash))
        stdin.close
        result << stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + s).red end
      }
      
    ensure
      yaml_tempfile.close
      yaml_tempfile.unlink
    end

    result
  end
  
  before (:all) do
    # Precisa do libreoffice e ele precisa está fechado!
    Dir.chdir(modelo_dir) do
      system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
    end
  end

  let(:pdf){PdfForms::Pdf.new "#{modelo_dir}/configuracao.pdf", (PdfForms.new 'pdftk'), utf8_fields: true}
  let(:pdfconf){Limarka::Pdfconf.new(pdf: pdf)}
  let(:exportacao){pdfconf.exporta}
  let(:template_output) {template_mesclado(template, exportacao)}

  describe 'Os parâmetros de texto', :campo_texto, :proposito do
    let(:parametros){['avaliador1', 'avaliador2', 'avaliador3', 'linha_de_pesquisa', 'area_de_concentracao', 'proposito']}
    it 'são configurados através de caixas de texto' do
      parametros.each do |campo|
        expect(pdf.field(campo)).not_to be nil
        expect(pdf.field(campo).type).to eq('Text')
      end
    end
    describe 'na exportação para yaml', :pdfconf do
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
    let(:template) {'postextual4-anexos'}
    let(:codigo_latex){'\\begin{anexosenv}'}
    
    it_behaves_like 'um combo desativado por padrão'

    describe 'na exportação para yaml', :pdfconf do
      context 'quando desativada (valor padrão)' do
        let(:configuracao) {{'anexos' => false}}
        it 'exporta a configuração de desativado' do
          expect(pdfconf.exporta).to include(configuracao)
        end
        it 'o template não inclui o anexo', :template, :template_anexo do
          expect(template_mesclado(template, pdfconf.exporta)).not_to include(codigo_latex)
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
        it 'o template inclui o anexo', :template, :template_anexo do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
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
    let(:template) {'pretextual2-errata'}
    let(:codigo_latex){'\\begin{errata}'}
    
    it_behaves_like 'um combo desativado por padrão'

    describe 'na exportação para yaml', :pdfconf do
      context 'quando desativada (valor padrão)' do
        let(:configuracao_exportada) {{'errata' => false}}
        it 'exporta a configuração de desativada' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template não inclui a errata', :template, :template_errata do
          expect(template_mesclado(template, pdfconf.exporta)).not_to include(codigo_latex)
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
        it 'o template inclui a errata', :template, :template_errata do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
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
    let(:template) {'pretextual3-folha_de_aprovacao'}

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

    describe 'na exportação para yaml', :pdfconf, :folha_de_aprovacao do
      context 'quando Não gerar (valor padrão)' do
        let(:configuracao_exportada) {{'folha_de_aprovacao' => false}}
        let(:codigo_latex){<<-CODIGO
% ---
% Sem Folha de aprovação
% ---
CODIGO
        }
        it 'exporta folha_de_aprovacao => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template não inclui ou gera a folha de aprovação escaneada', :template, :template_folha_de_aprovacao do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
        end

      end
      context 'quando Gerar folha de aprovação' do
        let(:valor_configurado) {opcoes[1]}
        let(:configuracao_exportada) {{'folha_de_aprovacao' => true}}
        let(:codigo_latex){<<-CODIGO
% ---
% Folha de aprovação gerada
% ---

% Isto é um exemplo de Folha de aprovação, elemento obrigatório da NBR
% 14724/2011 (seção 4.2.1.3). 
% Este modelo será utilizado antes da aprovação do trabalho.
\\begin{folhadeaprovacao}
CODIGO
        }

        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta folha_de_aprovacao => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template gera uma folha de aprovação', :template, :template_folha_de_aprovacao do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
        end
      end
      context 'quando Incluir folha de aprovação' do
        let(:valor_configurado) {opcoes[2]}
        let(:configuracao_exportada) {{'incluir_folha_de_aprovacao' => true}}
        let(:codigo_latex){<<-CODIGO
\\begin{folhadeaprovacao}
\\includepdf{imagens/folha-de-aprovacao-escaneada.pdf}
\\end{folhadeaprovacao}
CODIGO
        }
        before do
          pdfconf.update(campo, valor_configurado)
        end
        it 'exporta incluir_folha_de_aprovacao => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template inclui a folha de aprovação escaneada', :template, :template_folha_de_aprovacao do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
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
    let(:template) {'trabalho-academico'}

    describe 'na exportação para yaml', :pdfconf do
      context 'quando Referências Alfabética (valor padrão)' do
        let(:configuracao_exportada) {{'referencias_sistema' => 'alf'}}
        let(:codigo_latex){'\\usepackage[alf]{abntex2cite}'}
        it 'exporta referencias_sistema=>alf' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template configura referências com sistema alfabético', :template, :template_referencias do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
        end
      end
      context 'quando Referências Numérica' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'referencias_sistema' => 'num'}}
        let(:codigo_latex){'\\usepackage[num]{abntex2cite}'}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta referencias_sistema=>num' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template configura referências com sistema numérico', :template, :template_referencias do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
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
    let(:template){'pretextual1-folha_de_rosto'}
    let(:codigo_latex){<<-CODIGO
\\begin{fichacatalografica}
    \\includepdf{imagens/ficha-catalografica.pdf}
\\end{fichacatalografica}
CODIGO
    }

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
      context 'quando Sem ficha catalográfica (valor padrão)' do
        let(:configuracao_exportada) {{'incluir_ficha_catalografica' => false}}
        it 'exporta incluir_ficha_catalografica => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template não inclui uma ficha catalográfica', :template, :template_ficha_catalografica do
          expect(template_mesclado(template, pdfconf.exporta)).not_to include(codigo_latex)
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
        it 'o template inclui imagens/ficha-catalografica.pdf', :template, :template_ficha_catalografica do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
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
    let(:template){'pretextual9-lista_ilustracoes'}
    let(:codigo_latex){<<-CODIGO
\\pdfbookmark[0]{\\listfigurename}{lof}
\\listoffigures*
\\cleardoublepage
CODIGO
    }

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
      context 'quando Sem Lista (valor padrão)' do
        let(:configuracao_exportada) {{'lista_ilustracoes' => false}}
        it 'exporta lista_ilustracoes => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template não inclui a lista de ilustrações', :template, :template_lista_ilustracoes do
          expect(template_mesclado(template, pdfconf.exporta)).not_to include(codigo_latex)
        end
      end
      context 'quando Gerar lista de ilustrações' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'lista_ilustracoes' => true}}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta lista_ilustracoes => true' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template inclui a lista de ilustrações', :template, :template_lista_ilustracoes do
          expect(template_mesclado(template, pdfconf.exporta)).to include(codigo_latex)
        end
      end
    end
  end

  describe 'lista_tabelas_combo', :lista_tabelas do
    let(:campo) {'lista_tabelas_combo'}
    let(:tipo) {'Choice'}
    let(:opcoes) {['Dispensar uso de lista de tabelas','Gerar lista de tabelas']}
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
      let(:template){'pretextual10-lista_tabelas'}
      context 'quando Sem Lista (valor padrão)' do
        let(:configuracao_exportada) {{'lista_tabelas' => false}}
        let(:latex_esperado){'% Lista de tabelas (opcional): não utilizando'}
        it 'exporta lista_tabelas => false' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
        it 'o template não inclui a lista de tabelas', :template, :template_lista_tabelas do
          expect(template_mesclado(template, pdfconf.exporta)).to include(latex_esperado)
          expect(template_output).not_to include('\\listoftables*')
        end
      end
      context 'quando Gerar lista de tabelas' do
        let(:sistema_numerico) {opcoes[1]}
        let(:configuracao_exportada) {{'lista_tabelas' => true}}
        before do
          pdfconf.update(campo, sistema_numerico)
        end
        it 'exporta lista_tabelas => true' do
          expect(exportacao).to include(configuracao_exportada)
        end
        it 'o template inclui a lista de tabelas', :template, :template_lista_tabelas do
          expect(template_output).to include(<<-TEX)
\\pdfbookmark[0]{\\listtablename}{lot}
\\listoftables*
\\cleardoublepage
TEX
        end
      end
    end
  end


  describe 'simbolos', :simbolos do
    let(:campo) {'simbolos'}
    let(:tipo) {'Text'}
    let(:valor_padrao) {""}
    let(:field) {pdf.field(campo)}
    let(:template){'pretextual12-lista_simbolos'}

    it 'é um campo do tipo texto' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end

    describe 'seu valor padrão' do
      it "é vazio" do
        expect(field.value).to eq(valor_padrao)
      end
    end

    context 'quando vazio' do
      let(:valor_do_campo){""}
    
      before do
        pdfconf.update(campo, valor_do_campo)
      end 

      describe 'na exportação para yaml', :pdfconf do
        let(:configuracao_exportada) {{'simbolos' => nil}}
        it 'exporta simbolos => nil' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      describe 'na exportação do template', :template => 'lista_siglas' do

        it 'não inclui a lista de siglas', :template, :template_lista_tabelas do
          expect(template_output).not_to include("\\begin{simbolos}")
          expect(template_output).to include(<<-TEX)
% ---
% Lista de símbolos (opcional): AUSENTE
% ---
TEX
        end
      end
    end

    context 'quando preenchido' do
      let(:s1) {"Gamma"}
      let(:s2) {"in"}
      let(:d1) {"Letra grega Gama"}
      let(:d2) {"Pertence"}
      let(:valor_do_campo){"#{s1}: #{d1}\n#{s2}: #{d2}"}
    
      before do
        pdfconf.update(campo, valor_do_campo)
      end 

      describe 'na exportação para yaml', :pdfconf do
        let(:configuracao_exportada) {{'simbolos' => [{'s'=> s1,'d'=> d1},{'s'=> s2,'d'=> d2}]}}
        it 'exporta simbolos como lista de hash: [{"s"=>"Gamma", "d"=>"Letra grega Gama"},...]' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      describe 'na exportação do template', :template => 'simbolos'  do
        it 'inclui o bloco de simbolos', :template, :template_lista_tabelas do
          expect(template_output).to include(<<-TEX)
% ---
% Lista de símbolos (opcional): PRESENTE
% ---
\\begin{simbolos}
  \\item[$ \\Gamma $] Letra grega Gama
  \\item[$ \\in $] Pertence
\\end{simbolos}
TEX
        end
      end
    end    
  end

  
  describe 'siglas', :siglas do
    let(:campo) {'siglas'}
    let(:tipo) {'Text'}
    let(:opcoes) {['ABNT: Associação Brasileira de Normas Técnicas']}
    let(:valor_padrao) {opcoes[0]}
    let(:field) {pdf.field(campo)}
    let(:template){'pretextual11-lista_siglas'}

    it 'é um campo do tipo texto' do
      expect(field).not_to be nil
      expect(field.type).to eq(tipo)
    end

    describe 'seu valor padrão' do
      it "possui duas siglas" do
        expect(field.value).to eq(valor_padrao)
      end
    end

    context 'quando vazia' do
      
      before do
        pdfconf.update(campo, '')
      end

      describe 'na exportação para yaml', :pdfconf do
        let(:configuracao_exportada) {{'siglas' => nil}}
        it 'exporta siglas => nil' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      describe 'na exportação do template', :template => 'lista_siglas' do
        let(:latex_esperado){'% SEM LISTA DE SIGLAS'}
        it 'não inclui a lista de siglas', :template, :template_lista_tabelas do
          expect(template_mesclado(template, pdfconf.exporta)).to include(latex_esperado)
        end
      end
    end

    context 'quando preenchida' do
      before do
        pdfconf.update(campo, "s1: d1\ns2: d2")
      end

      describe 'na exportação para yaml', :pdfconf do
        let(:configuracao_exportada) {{'siglas' => [{'s'=>'s1','d'=>'d1'},{'s'=>'s2','d'=>'d2'}]}}
        it 'exporta siglas como lista de hash: [{"s"=>"s1", "d"=>"d1"},...]' do
          expect(pdfconf.exporta).to include(configuracao_exportada)
        end
      end
      describe 'na exportação do template', :template => 'lista_siglas' do
        let(:latex_esperado){<<-TEX}
\\begin{siglas}
  \\item[s1] d1
  \\item[s2] d2
\\end{siglas}
TEX
        it 'inclui o bloco de siglas', :template, :template_lista_tabelas do
          expect(template_output).to include(latex_esperado)
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
