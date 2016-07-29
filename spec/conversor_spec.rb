# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe Limarka::Conversor do


  describe '#ler_configuracao' do
    let (:arquivo_de_configuracao) {'templates/configuracao.yaml'}
    let (:configuracao_yaml) {<<-CONF
---
qualquer-chave: valor da chave
---
CONF
}
    let (:cv) {Limarka::Conversor.new}
    it 'ler configuracao do arquivo templates/configuracao.yaml' do
      expect(File).to receive(:open).with(arquivo_de_configuracao,'r').and_yield(
                        StringIO.new(configuracao_yaml))
      cv.ler_configuracao
    end
  end

  describe '#ler_texto' do
    let (:arquivo) {'trabalho-academico.md'}
    let (:conteudo) {'# Conteúdo do arquivo'}
    let (:cv) {Limarka::Conversor.new}
    it 'ler texto do arquivo trabalho-academico.md' do
      expect(File).to receive(:open).with(arquivo,'r').and_yield(
                        StringIO.new(conteudo))
      expect(cv.ler_texto).to eq(conteudo)
    end
  end

  
  describe '#ler_referencias' do
    let (:conteudo) {'QUALQUER CONTEÚDO'}
    let (:cv) {Limarka::Conversor.new(configuracao: configuracao)}
    context 'quando configurado para ler do arquivo referencias.md', :referencias do
      let (:configuracao) {{'referencias_md' => true}}
      let (:arquivo) {'referencias.md'}
      it 'ler o arquivo e retorna seu conteúdo' do
        expect(File).to receive(:open).with(arquivo,'r').and_yield(
                         StringIO.new(conteudo))
        expect(cv.ler_referencias).to eq(conteudo)
      end
    end
    context 'quando configurado para ler do arquivo referencias.bib', :referencias do
      let (:configuracao) {{'referencias_bib' => true}}
      let (:arquivo) {'referencias.bib'}
       it 'ler o arquivo e retorna seu conteúdo' do
        expect(File).to receive(:open).with(arquivo,'r').and_yield(
                         StringIO.new(conteudo))
        expect(cv.ler_referencias).to eq(conteudo)
      end
    end
  end

  describe '#ler_apendices' do
    let (:conteudo) {'QUALQUER CONTEÚDO'}
    let (:cv) {Limarka::Conversor.new(configuracao: configuracao)}
    let (:arquivo) {'apendices.md'}
    context 'quando apêndice desativado', :apendices do
      let (:configuracao) {{'apendices' => false}}
      it 'não ler o arquivo apendices.md' do
        expect(File).not_to receive(:open).with(arquivo,'r')
        expect(cv.ler_apendices).to be nil
      end
    end
    context 'quando apêndice ativado e EXISTE o arquivo apendices.md', :apendices do
      let (:configuracao) {{'apendices' => true}}
      before do
        allow(File).to receive(:exist?).with(arquivo){true}
      end
      it 'ler o arquivo apendices.md e retorna seu conteúdo' do
        expect(File).to receive(:open).with(arquivo,'r').and_yield(
                         StringIO.new(conteudo))

        expect(cv.ler_apendices).to eq(conteudo)
      end
    end
    context 'quando apêndice ativado e NÃO existe o arquivo apendices.md', :apendices do
      it 'informa que o arquivo é necessário'
    end

  end
  
  describe '#ler_arquivos' do
    let (:configuracao) {double}
    let (:referencias) {double}
    let (:apendices) {double}
    let (:texto) {double}
    let (:cv) {Limarka::Conversor.new}

    before do
    end

    it 'invoca os métodos para leitura dos arquivos e atualizar estado do objeto' do
      expect(cv).to receive(:ler_configuracao) {configuracao}
      expect(cv).to receive(:ler_texto) {texto}
      expect(cv).to receive(:ler_referencias) {referencias}
      expect(cv).to receive(:ler_apendices) {apendices}

      cv.ler_arquivos
      expect(cv.configuracao).to equal(configuracao)
      expect(cv.texto).to equal(texto)
      expect(cv.referencias).to equal(referencias)
      expect(cv.apendices).to equal(apendices)
    end
  end


end
