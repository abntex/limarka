# coding: utf-8

require 'spec_helper'
require 'limarka'
require 'limarka/cli'
require 'yaml'

describe 'Exemplo1', :exemplos do
  

  let(:tex_file){test_dir+'/xxx-Monografia-projeto.tex'}
  let(:texto) {<<-END
# Introdução

Texto da introdução \\cite{ABNT-citacao}.

END
}

    let (:referencias_bib) {<<-REFERENCIAS
@manual{ABNT-citacao,
	Address = {Rio de Janeiro},
	Date-Added = {2012-12-15 21:43:38 +0000},
	Date-Modified = {2013-01-12 22:17:20 +0000},
	Month = {ago.},
	Org-Short = {ABNT},
	Organization = {Associa{\\c c}\\~ao Brasileira de Normas T\\'ecnicas},
	Pages = 7,
	Subtitle = {Informa{\\c c}\\~ao e documenta{\\c c}\\~ao --- Apresenta{\\c c}\\~ao de cita{\\c c}\\~oes em documentos},
	Title = {{NBR} 10520},
	Year = 2002}

REFERENCIAS
    }

  let(:anexos){<<-END
# Primeiro anexo

Texto do anexo
END
  }

  let(:apendices){<<-END
# Primeiro apêndice

Texto do apêndice
END
  }

  let(:errata){<<-END
A aranha arranha a rã. A rã arranha a aranha. **Nem a aranha arranha a rã**. Nem a rã arranha a aranha.

Folha| Linha| Onde se lê     | Leia-se
-----|------|----------------|----------------
10   |12    |aranhaarranha   | aranha arranha
END
  }
  
  
  let!(:templates_dir){modelo_dir}
  let(:t){Limarka::Trabalho.new(configuracao: configuracao_padrao, texto: texto, anexos: anexos, referencias_bib: referencias_bib, apendices: apendices, errata: errata)}

  before do
    FileUtils.rm_rf test_dir
    FileUtils.mkdir_p test_dir
    t.save test_dir # Salva os arquivos que serão lidos
  end

  context "exec -y configuracao.yaml -t templates_dir (invocação)", :compilacao do
    let(:test_dir){'tmp/exemplos/exemplo1'}
    before do
      expect_any_instance_of(Limarka::Cli).to receive(:exec)
    end
    it "invoca Limarka::Cli#exec" do
      Dir.chdir test_dir do
        Limarka::Cli.start(["exec","-y","configuracao.yaml", '-t', templates_dir])
      end
    end
    
  end

  context "exec -y configuracao.yaml -t templates_dir", :compilacao do
    let(:test_dir){'tmp/exemplos/exemplo2'}
    before do
      Dir.chdir test_dir do
        Limarka::Cli.start(["exec","-y", '-t', templates_dir])
      end
      @tex = File.open(tex_file, 'r'){|f| f.read}
    end

    it "gera arquivo latex" do
      expect(File).to exist(tex_file)
      expect(@tex).to include("\\cite{ABNT-citacao}") # Citação
      expect(@tex).to include("Primeiro anexo")
      expect(@tex).to include("Primeiro apêndice")
      expect(@tex).to include("A aranha arranha a rã")
    end
  end

  context "Quando solicita ler de configuracao.pdf e o arquivo não existe", :diretorio_invalido, :configuracao_pdf do
    let(:test_dir){'tmp/exemplos/sem-configuracao-pdf'}
    before do
      FileUtils.rm_rf test_dir
      FileUtils.mkdir_p test_dir
    end

    it "lança erro indicando mensagem sugestiva" do
      Dir.chdir test_dir do
        expect{Limarka::Cli.start(["exec","-y", '-t', templates_dir])}.to raise_error(IOError, "Arquivo configuracao.yaml não foi encontrado, talvez esteja executando dentro de um diretório que não contém um projeto válido?")
      end      
    end
  end
  
end
