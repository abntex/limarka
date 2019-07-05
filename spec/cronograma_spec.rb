# coding: utf-8
require 'spec_helper'
require 'limarka'

describe Limarka::Cronograma, :cronograma do
  let (:legenda) {'Cronograma'}
  let (:fonte) {'Autor.'}
  let (:rotulo) { 'tab:cronograma' }
  let (:tabela) {[[]]}

  describe '#new' do
    context 'com argumentos' do
      let(:c) {Limarka::Cronograma.new(tabela: tabela, legenda: legenda, fonte: fonte, rotulo: rotulo)}
      it 'cria um cronograma com as propriedades passadas' do
        expect(c.tabela).to equal(tabela)
        expect(c.legenda).to equal(legenda)
        expect(c.fonte).to equal(fonte)
        expect(c.rotulo).to equal(rotulo)
      end
    end
  end

  describe '.cria_atividades' do
    context "qtde_atividades válida E meses válido" do
      let (:qtde_atividades) {5}
      let (:meses) {[3,4,5,6,7]}
      let (:c) {Limarka::Cronograma.cria_atividades(qtde_atividades, meses, legenda, fonte, rotulo)}

      it "tabela possui qtde_atividades +1 linhas" do
        expect(c.tabela.length).to eq(qtde_atividades+1)
      end
      it "tabela possui qtde_meses +1 colunas" do
        expect(c.tabela[0].length).to eq(meses.length+1)
      end
    end
  end

end
