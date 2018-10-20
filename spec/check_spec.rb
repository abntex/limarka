# coding: utf-8
require 'spec_helper'
require 'limarka'

describe Limarka::Check, :check do
  let (:pandoc_min_version) {'1.19.1'}
  let (:pandoc_max_version) {'2.0.0'}
  let (:pandoc_versao_inferior) {'1.19.0'}
  let (:pandoc_versao_compativel) {'1.19.3'}
  let (:pandoc_versao_superior) {'2.0.0'}

  describe '#check' do


    context 'lendo versões do sistema (real)' do
      let(:c) {Limarka::Check.new()}
      before{ c.check }
      it 'ler a versão do pandoc do sistema' do
        expect(c.pandoc).to eq(`pandoc --version`.split("\n")[0].split(" ")[1])
      end
    end

    context 'configurando versões das dependencias' do
      let(:c) {Limarka::Check.new(pandoc: pandoc_min_version, sistema: false)}
      it 'assume as versões das dependências passadas nos construtor' do
        expect(c.pandoc).to eq(pandoc_min_version)
      end
    end
    context 'configurando versões maiores das dependencias', :maior do
      let(:c) {Limarka::Check.new(pandoc: pandoc_max_version, sistema: false)}
      it 'assume as versões das dependências passadas nos construtor' do
        expect(c.pandoc).to eq(pandoc_max_version)
      end
    end

    context 'utilizando versão do pandoc inferior', :inferior do
      let(:c) {Limarka::Check.new(pandoc: pandoc_versao_inferior, sistema: false)}
      it 'emite erro informando que está utilizando uma versão incompatível' do
        expect { c.check }.to raise_error(Limarka::VersaoIncompativelError)
      end
    end
    context 'utilizando versão do pandoc superior' do
      let(:c) {Limarka::Check.new(pandoc: pandoc_versao_superior, sistema: false)}

      it 'emite erro informando que está utilizando uma versão incompatível' do
        expect { c.check }.to raise_error(Limarka::VersaoIncompativelError)
      end
    end
    context 'utilizando versão compatível do pandoc' do
      let(:c) {Limarka::Check.new(pandoc: pandoc_versao_compativel, sistema: false)}
      it 'emite OK' do
        expect { c.check }.to output("OK.\n").to_stdout
      end
    end

  end




end
