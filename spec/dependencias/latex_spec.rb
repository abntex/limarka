# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Compilação Latex', :dependencias, :dependencias_latex do

  let(:output_dir) {input_dir.gsub("spec","test")}
  let(:tex_file) {"xxx-Monografia.tex"}
  
  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp_r input_dir+"/.", output_dir
  end

  context 'de arquivo abntex2 mínimo com latexmk', :latex_minimo do
    let(:input_dir) {"spec/latex/exemplo-minimo"}
    
    before do
      Dir.chdir(output_dir) do
        system "latexmk -quiet -pdflatex=\"xelatex %O %S\" -pdf -dvi- -ps- -f  xxx-Monografia.tex"
        system "pdftotext -enc UTF-8 xxx-Monografia.pdf"
      end
    end
    
    it 'gera o PDF' do
      expect(File).to exist(output_dir+"/xxx-Monografia.pdf")
    end

    it 'o capítulo é prefixado com o número dele' do
      expect(File.read(output_dir+"/xxx-Monografia.txt")).to include("1 Chapter example")
    end

    
  end


  context 'de arquivo abntex2 mínimo com títulos com acentos e latexmk', :latex_minimo do
    let(:input_dir) {"spec/latex/exemplo-minimo-com-acentos"}
    
    before do
      Dir.chdir(output_dir) do
        system "latexmk -quiet -pdflatex=\"xelatex %O %S\" -pdf -dvi- -ps- -f  xxx-Monografia.tex"
        system "pdftotext -enc UTF-8 xxx-Monografia.pdf"
      end
    end
    
    it 'gera o PDF' do
      expect(File).to exist(output_dir+"/xxx-Monografia.pdf")
    end

    it 'o capítulo é prefixado com o número dele' do
      expect(File.read(output_dir+"/xxx-Monografia.txt")).to include("1 Introdução")
    end

    
  end


  context 'compilando um arquivo tex pequeno com latexmk' do
    let(:input_dir) {"spec/latex/exemplo-pequeno-latex"}
   
    it 'gera o PDF' do
      Dir.chdir(output_dir) do
        system "latexmk -quiet -pdflatex=\"xelatex %O %S\" -pdf -dvi- -ps- -f  xxx-Monografia.tex"
        expect(File).to exist("xxx-Monografia.pdf")
      end
    end
  end

  context 'compilando um arquivo tex pequeno com xelatex' do
   
    it 'gera o PDF' do
      Dir.chdir(output_dir) do
        system "xelatex -interaction=batchmode  xxx-Monografia.tex"
        expect(File).to exist("xxx-Monografia.pdf")
      end
    end
  end


end
