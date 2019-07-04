# coding: utf-8

require 'spec_helper'
require 'limarka/cli'

describe Limarka::Cli, :cli do

  describe "#exec", :filtros do

    context "--filtros-lua filtro.lua", :filtro => 'lua' do
      let (:output_dir) {"tmp/cli/filtros/lua"}
      let (:texto) {%Q(
# Início

{{mundo}}
)}

      before do
        FileUtils.rm_rf output_dir
        FileUtils.mkdir_p output_dir
        IO.write(File.join(output_dir,'trabalho-academico.md'), texto)
        IO.write(File.join(output_dir,'configuracao.yaml'), JSON.pretty_generate(configuracao_padrao))
        FileUtils.cp_r "modelo-oficial/referencias.bib",output_dir
        FileUtils.cp_r "test/filtros/lua/filtro.lua",output_dir
      end


      it "o filtro é executado durante conversão" do
        Limarka::Cli.start(["exec","-y", "--filtros-lua", "filtro.lua", "--no-compila-tex", "--input-dir", output_dir, "-t", modelo_dir])
        expect(Limarka::Cli.cv.texto_tex).to include("Olá mundo!")
      end
    end

    context "--filtros filtro.rb", :filtro => 'ruby' do
      let (:output_dir) {"tmp/cli/filtros/ruby"}
      let (:texto) {%Q(
# inicio

abc def ghi
)}

      before do
        FileUtils.rm_rf output_dir
        FileUtils.mkdir_p output_dir
        IO.write(File.join(output_dir,'trabalho-academico.md'), texto)
        IO.write(File.join(output_dir,'configuracao.yaml'), JSON.pretty_generate(configuracao_padrao))
        FileUtils.cp_r "modelo-oficial/referencias.bib",output_dir
        FileUtils.cp_r "test/filtros/ruby/filtro.rb",output_dir
      end


      it "o filtro é executado durante conversão" do
        Limarka::Cli.start(["exec","-y", "--filtros", "filtro.rb", "--no-compila-tex", "--input-dir", output_dir, "-t", modelo_dir])
        expect(Limarka::Cli.cv.texto_tex).to include("ABC DEF GHi")
      end
    end


  end


end
