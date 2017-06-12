# coding: utf-8
require 'spec_helper'
require 'limarka'

describe Limarka::Trabalho do
  let (:texto) {'# Texto'}
  let (:anexos) {'# Anexo1\nTexto'}
  let (:configuracao) { {'title' => 'algo'} }
  let (:apendices) {'# Apendice1'}
  let (:referencias_bib) {'@book {}'}
  let (:errata) {'Errata1'}
  let(:test_dir) {'tmp/trabalho'}
  
  describe '#new' do
    context 'com argumentos' do
      let(:t) {Limarka::Trabalho.new(configuracao: configuracao, texto: texto, anexos: anexos, apendices: apendices, referencias_bib: referencias_bib)}
      it 'cria trabalho com as propriedades' do
        expect(t.texto).to eq(texto)
        expect(t.anexos).to eq(anexos)
        expect(t.apendices).to eq(apendices)
        expect(t.referencias).to eq(referencias_bib)
        expect(t.configuracao).to include(configuracao)
      end
    end
  end

  describe '.default_texto_file' do
    it 'returna trabalho-academico.md' do
      expect(Limarka::Trabalho.default_texto_file).to eq('trabalho-academico.md')
    end
  end
  describe '.default_anexos_file' do
    it 'returna anexos.md' do
      expect(Limarka::Trabalho.default_anexos_file).to eq('anexos.md')
    end
  end
  describe '.default_apendices_file' do
    it 'returna apendices.md' do
      expect(Limarka::Trabalho.default_apendices_file).to eq('apendices.md')
    end
  end

  describe '.default_apendices_file' do
    subject {Limarka::Trabalho.default_apendices_file}
    it { is_expected.to eq('apendices.md') }
  end

  describe '.default_referencias_bib_file' do
    it 'returna referencias.bib' do
      expect(Limarka::Trabalho.default_referencias_bib_file).to eq('referencias.bib')
    end
  end

  describe '#referencias_bib=' , :erro do
    let (:t) {Limarka::Trabalho.new(referencias_bib: referencias_bib)}
    it 'atualiza referencias' do
      expect(t.referencias).to eq(referencias_bib)
    end
  end

  describe '#anexos=' do
    let (:t) {Limarka::Trabalho.new()}
    before do
      t.anexos=anexos
    end
    it 'atualiza valor de anexos' do
      expect(t.anexos).to eq(anexos)
    end
    it 'habilita anexos na configuração' do
      expect(t.configuracao).to include('anexos' => true)
    end
    context 'quando anexos for nil' do
      before do
        t.anexos = nil
      end
      it 'atualiza anexos' do
        expect(t.anexos).to be nil
      end
      it 'desabilita anexos na configuração' do
        expect(t.configuracao).to include('anexos' => false)
      end
    end
  end

  describe '#apendices=' do
    let (:t) {Limarka::Trabalho.new()}
    before do
      t.apendices=apendices
    end
    it 'atualiza valor de apendices' do
      expect(t.apendices).to eq(apendices)
    end
    it 'habilita apêndices na configuração' do
      expect(t.configuracao).to include('apendices' => true)
    end
    context 'quando apendices for nil' do
      before do
        t.apendices = nil
      end
      it 'atualiza apendices' do
        expect(t.apendices).to be nil
      end
      it 'desabilita apêndices na configuração' do
        expect(t.configuracao).to include('apendices' => false)
      end
    end
  end

  describe '#configuracao=' do
    let (:t) {Limarka::Trabalho.new}
    let (:configuracao) {{'title' => 'meu título', 'date' => 'yyyy'}}
    before do
      t.configuracao = configuracao
    end
    it 'atualiza configuração' do
      expect(t.configuracao).to include('title' => 'meu título')
    end
  end
  
  describe '#save', :save do
    let(:t) {Limarka::Trabalho.new(configuracao: {'title' => 'meu título'}, texto: texto, anexos: anexos, apendices: apendices)}
    before do
      FileUtils.rm_rf test_dir
      FileUtils.mkdir_p test_dir
    end

    context 'quando há apêndice' do
      let(:t) {Limarka::Trabalho.new(apendices: apendices)}
      it 'salva arquivo de apêndices' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_apendices_file)
      end
    end

    context 'quando não há apêndice' do
      let(:t) {Limarka::Trabalho.new(apendices: nil)}
      it 'NÃO salva arquivo de apêndice' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_apendices_file)
      end
    end

    context 'quando há anexos' do
      let(:t) {Limarka::Trabalho.new(anexos: anexos)}
      it 'salva arquivo de anexos' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_anexos_file)
      end
    end

    context 'quando não há anexos' do
      let(:t) {Limarka::Trabalho.new(anexos: nil)}
      it 'NÃO salva arquivo de anexos' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_anexos_file)
      end
    end

    context 'quando há texto' do
      it 'salva arquivo de texto' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_texto_file)
      end
    end

    context 'quando não há texto' do
      let (:t) {Limarka::Trabalho.new}
      it 'não salva arquivo de texto' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_texto_file)
      end
    end
    context 'quando há configuração' do
      before do
        t.save test_dir
      end
      it 'salva arquivo de configuração' do
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_configuracao_file)
      end
    end
    context 'quando há referencias_bib', :referencias, :save  do
      let(:arquivo_de_referencias) {'meu-arquivo-de-referencias.bib'}
      let(:t) {Limarka::Trabalho.new(referencias_bib: referencias_bib, configuracao: {'referencias_caminho' => arquivo_de_referencias})}
      it 'salva referencias_bib' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + arquivo_de_referencias)
      end
    end
    context 'quando há errata' do
      let(:t) {Limarka::Trabalho.new(errata: errata)}
      let(:arquivo) {test_dir + '/' + Limarka::Trabalho.default_errata_file}
      let(:conteudo_do_arquivo) {File.open(arquivo, 'r') {|f| f.read}}
      it 'salva arquivo de errata' do
        t.save test_dir
        expect(File).to exist(arquivo)
      end
      it 'conteúdo do arquivo correspondeu a @errata' do
        t.save test_dir
        expect(conteudo_do_arquivo).to eq(errata)
      end

    end

    context 'quando não há errata' do
      let(:t) {Limarka::Trabalho.new(errata: nil)}
      it 'NÃO salva arquivo de errata' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_errata_file)
      end
    end
        
  end

  describe '#ler_configuracao', :ler_configuracao do
    let (:arquivo_de_configuracao) {'configuracao.yaml'}
    let (:options) {{configuracao_yaml: true}}
    let (:configuracao_yaml) {<<-CONF
---
qualquer-chave: valor da chave
---
CONF
}
    let (:t) {Limarka::Trabalho.new}
    context 'quando solicitado ler de configuracao.yaml e arquivo existe' do
      before do
        expect(File).to receive('exist?').with('configuracao.yaml') {true}
        expect(File).to receive(:open).with(arquivo_de_configuracao,'r').and_yield(
                          StringIO.new(configuracao_yaml))
      end
      it 'ler configuracao do arquivo' do
        expect(t.ler_configuracao(options)).to include('qualquer-chave' => 'valor da chave')
      end
    end
    context 'quando arquivo de configuração YAML especificado NÃO existe'  do
      before do
        expect(File).to receive('exist?').with('configuracao.yaml') {false}
      end
      it 'erro com mensagem apropriada será lançado' do
        expect { t.ler_configuracao(options) }.to raise_error(IOError, "Arquivo configuracao.yaml não foi encontrado, talvez esteja executando dentro de um diretório que não contém um projeto válido?")
      end
    end
    
    context 'quando optado por ler configuração de configuracao.pdf existente', :lento, :libreoffice, :configuracao do
      let (:arquivo_de_configuracao) {'configuracao.pdf'}
      let (:options) {{configuracao_yaml: false}}
      let (:configuracao_esperada) {{"title" => "Título do trabalho"}}
      before do
        # Precisa do libreoffice e ele precisa está fechado!
        Dir.chdir(modelo_dir) do
          system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
        end
        # expect(t).to receive(:ler_configuracao_pdf) {configuracao}
      end
      it 'ler configuracao do arquivo' do
        Dir.chdir(modelo_dir) do
          expect(t.ler_configuracao(options)).to include(configuracao_esperada)
        end
      end
    end

    context 'quando optado por ler configuração de PDF inexistente', :configuracao do
      let (:arquivo_de_configuracao) {'configuracao.pdf'}
      let (:options) {{configuracao_yaml: false}}
      before do
        allow(File).to receive(:exist?).with(arquivo_de_configuracao).and_return(false)
      end
      it 'emite error informando que não encontrou o arquivo' do
        expect {t.ler_configuracao(options)}.to raise_error(IOError, "Arquivo configuracao.pdf não foi encontrado, talvez esteja executando dentro de um diretório que não contém um projeto válido?")
      end
    end
  end

  describe '#ler_referencias' do
    let (:t) {Limarka::Trabalho.new}
    context 'quando configurado para ler do arquivo referencias.bib', :referencias do
      let (:configuracao) {{'referencias_caminho' => 'referencias.bib'}}
      it 'ler o arquivo e retorna seu conteúdo' do
        expect(t).to receive(:ler_referencias)
        t.ler_referencias(configuracao)
      end
    end
    context 'quando configurado para ler do arquivo jabref.bib', :referencias, :referencias_caminho do
      let (:configuracao) {{'referencias_caminho' => 'jabref.bib'}}
      let (:conteudo) {"@book{mybook}"}
      before do
        expect(File).to receive(:open).with('jabref.bib', 'r').and_yield(StringIO.new(conteudo))
      end
      it 'ler o arquivo e retorna seu conteúdo' do
        expect(t.ler_referencias(configuracao)).to eq(conteudo)
      end
    end
    
  end

  describe '#ler_apendices' do
    let (:arquivo) {'apendices.md'}
    context 'quando EXISTE apendices.md', :apendices do
      let (:configuracao) {{'apendices' => true}}
      let (:t) {Limarka::Trabalho.new}
      let (:conteudo) {apendices}
      before do
        expect(File).to receive(:open).with(arquivo,'r').and_yield(
                         StringIO.new(conteudo))
      end
      it 'ler o arquivo e retorna seu conteúdo' do
        t.configuracao = configuracao
        expect(t.ler_apendices).to eq(conteudo)
      end
    end
  end

end
