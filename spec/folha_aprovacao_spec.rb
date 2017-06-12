# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'open3'

describe 'Folha de Aprovação', :folha_aprovacao do
  
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  let(:tex_file) {Limarka::Conversor.tex_file(t.configuracao)}
  let (:t) {Limarka::Trabalho.new(configuracao: configuracao_padrao.merge(configuracao_especifica), texto: texto)}
  let (:texto) {<<-TEXTO
# Primeiro Capítulo

texto.

TEXTO
    }



  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
  end

  context 'quando geração ativada',  :compilacao, :lento,  :folha_aprovacao => 'ativada'  do
    let (:output_dir) {"tmp/folha_aprovacao/geracao"}
    let (:avalidor1) {"Nome-do-Avaliador1"}
    let (:area_de_concentracao) {"MinhaÁreaDeConcentração"}
    let (:linha_de_pesquisa) {"BoaLinha"}
    let (:configuracao_especifica) {{"folha_de_aprovacao" => true, "avaliador1"=>avalidor1, "area_de_concentracao" => area_de_concentracao, "linha_de_pesquisa" => linha_de_pesquisa}}


    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "é gerada segundo as Normas da ABNT no PDF", :area_de_concentracao, :linha_de_pesquisa do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Monografia aprovada.")
        expect(@cv.txt).to include("#{avalidor1}\nConvidado")
        expect(@cv.txt).to include("Área de concentração: #{area_de_concentracao}")
        expect(@cv.txt).to include("Linha de pesquisa: #{linha_de_pesquisa}")
    end

    context "e propósito personalizado", :proposito do
      let (:output_dir) {"tmp/folha_aprovacao/geracao-proposito-personalizado"}
      let (:proposito) {"Propósito personalizado"}
      let (:configuracao_especifica) {{"folha_de_aprovacao" => true, "proposito" => proposito}}

      it "é gerada com propósito personalizado" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include(proposito)
      end
    end
  end


  
  context 'quando geração desativada',  :compilacao, :lento, :folha_aprovacao => 'desativada' do
    let (:output_dir) {"tmp/folha_aprovacao/desativada"}
    let (:avalidor1) {"Nome-do-Avaliador1"}
    let (:configuracao_especifica) {{"folha_de_aprovacao" => false, "avaliador1"=>avalidor1}}

    before do
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "não é gerada no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).not_to include("Monografia aprovada.")
        expect(@cv.txt).not_to include("#{avalidor1}\nConvidado")
    end
  end

  context 'quando inclusão de escaneada ativada',  :compilacao, :lento, :folha_aprovacao => 'escaneada' do
    let (:output_dir) {"tmp/folha_aprovacao/inclusao"}
    let (:avalidor1) {"Nome-do-Avaliador1"}
    let (:configuracao_especifica) {{"incluir_folha_de_aprovacao" => true}}
    let (:imagens_dir) {"#{output_dir}/imagens"}

    before do
      FileUtils.mkdir_p imagens_dir
      Open3.popen3("pandoc -f markdown -t latex -s -o #{imagens_dir}/folha-de-aprovacao-escaneada.pdf") {|stdin, stdout, stderr, wait_thr|
        stdin.write("#Folha de Aprovação\n\nMinha folha de aprovação personalizada\n")
        stdin.close
        @texto_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      }
      
      @cv = Limarka::Conversor.new(t, options)
      @cv.convert
      @cv.compila
    end
    
    it "imagens/folha-de-aprovacao-escaneada.pdf será incluído no PDF" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Folha de Aprovação")
        expect(@cv.txt).to include("Minha folha de aprovação personalizada")
    end
  end
  
  
end
