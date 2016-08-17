# coding: utf-8

require 'spec_helper'
require 'limarka'
require 'limarka/cli'
require 'yaml'

describe 'Exemplo1', :exemplos do
  
  let(:test_dir){'tmp/exemplos/exemplo1'}
  let(:tex_file){test_dir+'/xxx-Monografia.tex'}
  let(:texto) {<<-END
# Introdução

Texto da introdução

END
}

  let(:referencias_md) {<<-END
SILVA, Fulano. **Título**. Data.

END
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
  
  
  let!(:templates_dir){Dir.pwd}
  let(:t){Limarka::Trabalho.new(configuracao: configuracao_padrao, texto: texto, anexos: anexos, referencias_md: referencias_md, apendices: apendices, errata: errata)}

  before do
    FileUtils.rm_rf test_dir
    FileUtils.mkdir_p test_dir
    t.save test_dir # Salva os arquivos que serão lidos
  end

  context "exec2 -y configuracao.yaml -t templates_dir (invocação)" do
    before do
      expect_any_instance_of(Limarka::Cli).to receive(:exec2)
    end
    it "invoca Limarka::Cli#exec2" do
      Dir.chdir test_dir do
        Limarka::Cli.start(["exec2","-y","configuracao.yaml", '-t', templates_dir])
      end
    end
    
  end

  context "exec2 -y configuracao.yaml -t templates_dir" do
    before do
      Dir.chdir test_dir do
        byebug
        Limarka::Cli.start(["exec2","-y", '-t', templates_dir])
      end
      @tex = File.open(tex_file, 'r'){|f| f.read}
    end

    it "gera arquivo latex" do
      expect(File).to exist(tex_file)
      expect(@tex).to include("SILVA, Fulano.")
      expect(@tex).to include("Primeiro anexo")
      expect(@tex).to include("Primeiro apêndice")
      expect(@tex).to include("A aranha arranha a rã")
    end
  end

end
