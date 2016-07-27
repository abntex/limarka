# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe Limarka::Conversor do

  describe '#ler_arquivos' do
    let (:cli_options) {{}}
    let (:cv) {Limarka::Conversor.new(cli_options)}
    let (:conteudo) {"Conteúdo do arquivo"}
    let (:configuracao) {configuracao_padrao}
    let (:arquivo_de_configuracao) {'templates/configuracao.yaml'}
    
    before do
      allow(cv).to receive(:ler_texto)
      allow(File).to receive(:open).with(arquivo_de_configuracao,'r').and_yield(
                       StringIO.new(YAML.dump(configuracao)))
    end

    it 'ler configuracao de "templates/configuracao.yaml" e atualiza @configuracao', :wipo do
      allow(cv).to receive(:ler_referencias)
      cv.ler_arquivos
      expect(cv.configuracao).to eq(configuracao)
    end

    describe "ler as referencias", :wip do
      
      context 'quando configurado para ler do arquivo referencias.md' do
        let (:configuracao) {{'referencias_md' => true}}
        let (:arquivo) {'referencias.md'}

        it 'e atualiza @referencias com o conteúdo do arquivo' do
          allow(File).to receive(:open).with(arquivo,'r').and_yield(
                           StringIO.new(conteudo))

          cv.ler_arquivos
          expect(cv.referencias).to eq(conteudo)
        end
      end
      context 'quando configurado para ler do arquivo referencias.bib' do
        let (:configuracao) {{'referencias_bib' => true}}
        let (:arquivo) {'referencias.bib'}

        it 'e atualiza @referencias com o conteúdo do arquivo' do
          allow(File).to receive(:open).with(arquivo,'r').and_yield(
                           StringIO.new(conteudo))

          cv.ler_arquivos
          expect(cv.referencias).to eq(conteudo)
        end
      end

    end
    
  end


end
