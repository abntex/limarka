# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Compilação Latex', :dependencias, :dependencias_latex do
  
  before do
    # Cria cópia de input_dir em output_dir
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp_r input_dir+"/.", output_dir
  end

  context 'de arquivo abntex2 mínimo com latexmk', :latex_minimo do
    let(:input_dir) {"spec/latex/exemplo-minimo"}
    let(:output_dir) {input_dir.gsub("spec","test")}
    
    it 'O pdf é gerado e o capítulo é prefixado com o número dele' do
      Dir.chdir(output_dir) do
        system "latexmk --quiet --xelatex -f xxx-Monografia.tex", :out=>"/dev/null"
        expect(File).to exist("xxx-Monografia.pdf")
        system "pdftotext -enc UTF-8 xxx-Monografia.pdf"
        expect(File).to exist("xxx-Monografia.txt")
        expect(File.read("xxx-Monografia.txt")).to include("1 Chapter example")
      end    
    end    
  end


  context 'de arquivo abntex2 mínimo com títulos com acentos e latexmk', :latex_minimo do
    let(:input_dir) {"spec/latex/exemplo-minimo-com-acentos"}
    let(:output_dir) {input_dir.gsub("spec","test")}
    
    it 'O pdf é gerado e o capítulo é prefixado com o número dele' do
      Dir.chdir(output_dir) do
        system "latexmk --quiet --xelatex -f xxx-Monografia.tex", :out=>"/dev/null"
        expect(File).to exist("xxx-Monografia.pdf")
        system "pdftotext -enc UTF-8 xxx-Monografia.pdf"
        expect(File).to exist("xxx-Monografia.txt")
        expect(File.read("xxx-Monografia.txt")).to include("1 Introdução")
      end    
    end   
  end


  context 'compilando um arquivo tex pequeno com latexmk' do
    let(:input_dir) {"spec/latex/exemplo-pequeno-latex"}
    let(:output_dir) {input_dir.gsub("spec","test")}
   
    it 'O pdf é gerado segundo as normas da ABNT' do
      Dir.chdir(output_dir) do
        system "latexmk --quiet --xelatex -f xxx-Monografia.tex", :out=>"/dev/null"
        expect(File).to exist("xxx-Monografia.pdf")
        system "pdftotext -enc UTF-8 xxx-Monografia.pdf"
        expect(File).to exist("xxx-Monografia.txt")
        expect(File.read("xxx-Monografia.txt")).to include("1 Introdução")
      end    
    end   
  end


end
