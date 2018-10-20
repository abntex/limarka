# coding: utf-8
require 'spec_helper'
require 'limarka'

describe Limarka::Check, :check do
  let (:pandoc_min_version) {'1.19.1'}
  let (:pandoc_max_version) {'1.19.2'}

  describe '#check' do
    context 'lendo versão do sistema (real)' do
      let(:c) {Limarka::Check.new()}
      before{ c.check }
      it 'ler a versão do pandoc do sistema' do
        expect(c.pandoc).to eq(`pandoc --version`.split("\n")[0].split(" ")[1])
      end
    end

    context 'configurando versões das dependencias' do
      let(:c) {Limarka::Check.new(pandoc: pandoc_min_version, sistema: false)}
      before{ c.check }
      it 'assume as versões das dependências passadas nos construtor' do
        expect(c.pandoc).to eq(pandoc_min_version)
      end
    end

  end



end
