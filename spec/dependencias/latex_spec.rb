# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Latex dependências', :dependencias do
  
  let(:input_dir) {"spec/latex/exemplo-pequeno-latex"}
  let(:output_dir) {"test/latex/exemplo-pequeno-latex"}
  let(:tex_file) {"xxx-Monografia.tex"}

  before do
    FileUtils.rm_rf output_dir
    FileUtils.mkdir_p output_dir
    FileUtils.cp_r input_dir+"/.", output_dir
  end

  context 'compilando um arquivo tex pequeno com latexmk' do
   
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
