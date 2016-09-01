# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Referências', :referencias do


  let (:seed) {Random.new_seed}
  let!(:options) {{output_dir: output_dir, templates_dir: Dir.pwd}}
  
  context 'quando configurada para ler de referencias.bib', :referencias, :referencias_bib do
    let (:configuracao) {{}}
    let (:output_dir) {"tmp/referencias_bib"}

    let (:texto) {s = <<-TEXTO
# Introdução

Citação no texto: \\citeonline{ABNT-citacao}.

> No final da citação direta \\cite{ABNT-citacao}.

Citando o ano: \\citeyear{ABNT-citacao}.

TEXTO
      s + "\nSeed: #{@seed}\n"}
    
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
    let (:trabalho) {Limarka::Trabalho.new(texto: texto, referencias_bib: referencias_bib, configuracao: configuracao)}
    before do
      FileUtils.rm_rf output_dir
      
      @cv = Limarka::Conversor.new(trabalho, options)
      @cv.convert
    end

    it "utiliza pacote abntex2cite para citação no preambulo" do
      expect(@cv.texto_tex).to include("\\usepackage[alf]{abntex2cite}")
    end
    it "cria arquivo tex para compilação" do
      expect(File).to exist(@cv.texto_tex_file)
    end
    it "bibliografia copiada para arquivo temporário xxx-referencias.bib" do
      expect(File).to exist(@cv.referencias_bib_file)
    end
    it "referências será produzida a partir de xxx-referencias.bib" do
      expect(@cv.texto_tex).to include('\\bibliography{xxx-referencias}')
    end
    it "podemos utilizar \\cite para citação", :tecnico , :e1 do
      citacao = <<-CITACAO
\\begin{quote}
No final da citação direta \\cite{ABNT-citacao}.
\\end{quote}
CITACAO
      expect(@cv.texto_tex).to include(citacao)
    end
    it "podemos utilizar \\citeonline para citação", :tecnico do
      expect(@cv.texto_tex).to include("Citação no texto: \\citeonline{ABNT-citacao}.")
    end
    it "podemos utilizar \\citeyear para citação", :tecnico do
      expect(@cv.texto_tex).to include("Citando o ano: \\citeyear{ABNT-citacao}.")
    end

    
    describe 'o pdf', :pdf, :lento do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "é gerado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Referências\n")
        expect(@cpl.txt).to include("Citação no texto: ABNT (2002).")
        expect(@cpl.txt).to include("No final da citação direta (ABNT, 2002).")
        expect(@cpl.txt).to include("Citando o ano: 2002.")
      end
    end
  end

  

end
