# coding: utf-8

require 'spec_helper'
require 'limarka'
require 'limarka/configuracao'
require 'yaml'

describe 'Monografias', :monografia do

  context "proposta ludico: limarka exec -i tmp/monografias/ludico -y --no-compila-tex", :monografia do
    let(:source_dir) {'spec/monografias/ludico'}
    let(:test_dir){'tmp/monografias/ludico'}
    let(:title){'titulo-do-meu-trabalho'}
    let(:author){'Autor-do-trabalho-aqui'}
    let(:proposito_gerado){'Projeto de Monografia apresentado ao Curso de XY da InstituiçãoZ, como requisito parcial para obtenção do grau de Bacharel em algo.'}
    let(:date){'20XX'}
    let(:orientador){'Meu-orientador'}
    let(:resumo){'Resumo do meu trabalho aqui.'}
    let(:folha_de_aprovacao){'% Sem Folha de aprovação'}
    let(:area_de_concentracao){'Minha área de concentração'}
    let(:configuracao) {
      configuracao_padrao.merge({'title' => title, 'author' => author, 'date'=> date,
                                 'instituicao' => 'InstituiçãoZ',
                                 'curso'=>'XY', 'titulacao'=>'Bacharel em algo',
                                 'orientador'=>orientador, 'resumo' => resumo, 'folha_de_aprovacao'=> false, 'area_de_concentracao'=>area_de_concentracao})
    }
    let(:tex_file) {test_dir + '/xxx-Monografia-projeto.tex'}
    let(:tex) {File.open(tex_file, 'r'){|f| f.read}}
    
    before do
      FileUtils.rm_rf test_dir
      FileUtils.mkdir_p test_dir
      FileUtils.cp_r source_dir, test_dir+'/..'
      Limarka::Trabalho.save_yaml(configuracao, test_dir+'/configuracao.yaml')
      system('bundle', 'exec', 'limarka', 'exec', '-i', test_dir, '-y', '--no-compila-tex','-t', File.absolute_path(modelo_dir))
    end
    it "proposta de monografia em latex gerada com sucesso", :proposito_gerado do
      expect(File).to exist(tex_file)
      expect(tex).to include(title)
      expect(tex).to include(author)
      expect(tex).to include(date)
      expect(tex).to include(proposito_gerado)
      expect(tex).to include(orientador)
      expect(tex).to include(resumo)
      expect(tex).to include(folha_de_aprovacao)
      expect(tex).to include(area_de_concentracao)
      
    end    
  end
  
end
