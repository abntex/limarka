# coding: utf-8

require 'spec_helper'
require 'limarka/cli'

describe Limarka::Cli, :cli do

  describe "#command_line_options_file" do
    it "retorna .limarka" do
      expect(Limarka::Cli.command_line_options_file).to eq('.limarka')
    end
  end


  describe "#inicia" do
    context "Quando existe arquivo .limarka" do
      let(:execution_dir){"tmp/cli/aquivo_de_parametros_existente"}
      let(:conteudo_do_arquivo){"""
--input_dir
.
"""}
      before do
        FileUtils.rm_rf execution_dir
        FileUtils.mkdir_p execution_dir
      end
      it "adiciona seu conteúdo como parâmetros para invocar o start" do
        expect(Limarka::Cli).to receive(:start).with(["exec","--input_dir", "."], {})
        Dir.chdir execution_dir do
          IO.write(Limarka::Cli.command_line_options_file, conteudo_do_arquivo)
          Limarka::Cli.inicia(["exec"])
        end
      end
    end

    context "Quando não existe arquivo .limarka" do
      let(:execution_dir){"tmp/cli/aquivo_de_parametros_inexistente"}
      before do
        FileUtils.rm_rf execution_dir
        FileUtils.mkdir_p execution_dir
      end
      it "start é iniciado com os parâmetros passados" do
        expect(Limarka::Cli).to receive(:start).with(["exec"], {})
        Dir.chdir execution_dir do
          Limarka::Cli.inicia(["exec"])
        end
      end
    end


  end

end
