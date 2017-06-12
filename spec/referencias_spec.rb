# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'

describe 'Referências', :referencias do


  let (:seed) {Random.new_seed}
  let!(:options) {{output_dir: output_dir, templates_dir: modelo_dir}}
  
  context 'quando configurada para ler de referencias.bib', :referencias, :referencias_bib do
    let (:configuracao) {configuracao_padrao.merge({'referencias_caminho' => 'referencias.bib', 'referencias_sistema'=>'alf'})}
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
	Title = {{NBR} 10520: meu subtitulo},
	Year = 2002}

REFERENCIAS
    }
    let (:trabalho) {Limarka::Trabalho.new(texto: texto, referencias_bib: referencias_bib, configuracao: configuracao)}
    before do
      FileUtils.rm_rf output_dir
      FileUtils.mkdir_p output_dir
      FileUtils.cp "#{modelo_dir}/latexcustomizacao.sty",output_dir
      
      @cv = Limarka::Conversor.new(trabalho, options)
      @cv.convert
    end

    it "utiliza pacote abntex2cite para citação no preambulo" do
      expect(@cv.texto_tex).to include("\\usepackage[alf]{abntex2cite}")
    end
    it "cria arquivo tex para compilação" do
      expect(File).to exist(@cv.texto_tex_file)
    end
    it "bibliografia é criada em xxx-referencias.bib", :xxx_referencias do
      expect(File).to exist(@cv.referencias_bib_file)
    end
    it "title é dividido em title e subtitle se tittle contém :" , :titulo, :subtitulo do
      expect(File).to exist(@cv.referencias_bib_file)
      expect(File.open(@cv.referencias_bib_file, 'r'){|f| f.read}).to include("title = {{NBR} 10520}")
      expect(File.open(@cv.referencias_bib_file, 'r'){|f| f.read}).to include("subtitle = {meu subtitulo}")
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
    
    describe 'o pdf', :compilacao, :lento do
      before do
        @cv.compila
      end
      it "é gerado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cv.txt).to include("Referências\n")
        expect(@cv.txt).to include("Citação no texto: ABNT (2002).")
        expect(@cv.txt).to include("No final da citação direta (ABNT, 2002).")
        expect(@cv.txt).to include("Citando o ano: 2002.")
      end
    end
  end

  

end
