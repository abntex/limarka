# coding: utf-8

require 'spec_helper'
require 'limarka/cli'
require 'yaml'

describe 'Exemplo1', :exemplos do
  
  let(:test_dir){'tmp/exemplos/exemplo1'}
  let(:tex_file){test_dir+'/xxx-Monografia.tex'}
  let (:texto) {<<-END
# Introdução

Texto da introdução

END
}

  let(:referencias) {<<-END
SILVA, Fulano. **Título**. Data.

END
  }

  let(:anexos){<<-END
# Primeiro anexo

Texto do anexo
END
  }
  let(:templates_dir){Dir.pwd}
  let(:t){Limarka::Trabalho.new(configuracao: configuracao_padrao, texto: texto, anexo: anexo, referencias_md: referencias}

  before do
    FileUtils.rm_rf test_dir
    FileUtils.mkdir_p test_dir

    puts "temp: #{templates_dir}"
    
    
    File.open("#{test_dir}/#{arquivo_texto}", 'w'){|f| f.write texto}
    File.open("#{test_dir}/#{arquivo_referencias}", 'w'){|f| f.write referencias}
    File.open("#{test_dir}/#{arquivo_anexos}", 'w'){|f| f.write anexos}
    File.open("#{test_dir}/#{arquivo_configuracao}", 'w') do |f|
      configuracao = configuracao_padrao.merge(conf_referencias_md).merge(conf_anexos_ativado)
      f.write YAML.dump(configuracao)
      f.write "\n---\n"
    end
    Dir.chdir test_dir do
      t.save
    end
  end

  context "Quando invocado limarka" do
    before do
      Dir.chdir test_dir do 
        Limarka::Cli.start(["exec2","-y","configuracao.yaml", '-t', templates_dir])
      end
      @tex = File.open(tex_file, 'r'){|f| f.read}
    end

    it "gera arquivo latex" do
      expect(File).to exist(tex_file)
      expect(@tex).to include("Primeiro anexo")
    end
 
    
    
  end

end
