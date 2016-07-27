# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Referências' do

  let (:seed) {Random.new_seed}
  
  context 'quando configurada para ler de referencias.bib' do
    let (:configuracao) {configuracao_padrao.merge({'referencias_numerica_inline' => false, 'referencias_abnt2cite' => true, 'referencias_md' => false})}
    let (:test_dir) {"tmp/referencias_abnt2cite"}
    let (:cli_options) {{:output_dir => test_dir}}
    let (:texto) {texto = <<-TEXTO
# Introdução

Citação no texto: \\citeonline{ABNT-citacao}.

> No final da citação direta \\cite{ABNT-citacao}.

Citando o ano: \\citeyear{ABNT-citacao}.

TEXTO
      texto = texto + "\nSeed: #{@seed}\n"}
    
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
    before do
      
      FileUtils.rm_rf test_dir
      @cv = Limarka::Conversor.new(cli_options)
      allow(@cv).to receive(:ler_texto) {texto}
      allow(@cv).to receive(:ler_referencias_bib) {referencias_bib}
      allow(@cv).to receive(:ler_configuracao_yaml) {configuracao}
      @cv.ler_arquivos
      @cv.convert
    end

    it "utiliza pacote abntex2cite para citação no preambulo", :tecnico do
      expect(@cv.texto_tex).to include("\\usepackage[alf]{abntex2cite}")
    end
    it "cria arquivo tex para compilação" do
      expect(File).to exist(@cv.texto_tex_file)
    end
    it "bibliografia copiada para arquivo temporário xxx-referencias.bib" do
      expect(File).to exist(@cv.referencias_bib_file)
    end
    it "referências será produzida a partir de xxx-referencias.bib", :tecnico do
      expect(@cv.texto_tex).to include('\\bibliography{xxx-referencias}')
    end
    it "podemos utilizar \\cite para citação", :tecnico do
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

    
    context 'o pdf', :pdf do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "foi gerado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Referências\n")
        expect(@cpl.txt).to include("Citação no texto: ABNT (2002).")
        expect(@cpl.txt).to include("No final da citação direta (ABNT, 2002).")
        expect(@cpl.txt).to include("Citando o ano: 2002.")
      end
    end
  end

  context 'quando configurada para ler de referencias.md' do
    let (:configuracao) {configuracao_padrao.merge({'referencias_numerica_inline' => false, 'referencias_abnt2cite' => false, 'referencias_md' => true})}
    let (:test_dir) {"tmp/referencias_md"}
    let (:cli_options) {{:output_dir => test_dir}}
    let (:texto) {texto = <<-TEXTO
# Introdução

Citação manual no texto: ABNT (2002).

> No final da citação direta (ABNT, 2011).

TEXTO

      texto = texto + "\nSeed: #{@seed}\n" 
    }
    let (:referencias_md) {<<-REFERENCIAS
ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. **NBR 10520**: Informação e
documentação — apresentação de citações em documentos. Rio de Janeiro, 2002.
Disponível em <https://www.abntcatalogo.com.br/norma.aspx?ID=2074#>.

ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. **NBR 14724**: Informação e
documentação — Trabalhos acadêmicos — Apresentação. Rio de Janeiro, 2011.

REFERENCIAS
}
    before do
      FileUtils.rm_rf test_dir
      @cv = Limarka::Conversor.new(cli_options)
      allow(@cv).to receive(:ler_texto) {texto}
      allow(@cv).to receive(:ler_referencias_md) {referencias_md}
      allow(@cv).to receive(:ler_configuracao_yaml) {configuracao}
      @cv.ler_arquivos
      @cv.convert
    end

    it "cria arquivo tex para compilação" do
      expect(File).to exist(@cv.texto_tex_file)
    end

    it "referências foram incluídas no arquivo tex" do
      expect(@cv.texto_tex).to include('ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. \textbf{NBR 10520}')
    end

    context 'o pdf', :pdf do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "foi criado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Referências\n")
        expect(@cpl.txt).to include("ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. NBR 14724: Informação")
      end
    end
  end


  
  context 'quando configurada com citação numérica (NBR 6023:2002, 9.2)', :wip do
    let (:configuracao) {configuracao_padrao.merge({'referencias_numerica_inline' => true, 'referencias_abnt2cite' => false, 'referencias_md' => false})}
    let (:test_dir) {"tmp/referencias_numerica_inline"}
    let (:cli_options) {{:output_dir => test_dir}}
    let (:texto) {texto = <<-TEXTO
# Introdução

\\citarei{ABNT-citacao}{ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. {\\emph ABNT NBR 6024:2012}: 
  Informação e documentaçãao -- Apresentação de citações em documentos. Rio de Janeiro, 2002.}

> Citações podem ser numéricas \\cita{ABNT-citacao}.

TEXTO

texto = texto + "\nSeed: #{seed}\n"}
    
    before do
      FileUtils.rm_rf test_dir
      @cv = Limarka::Conversor.new(cli_options)
      allow(@cv).to receive(:ler_texto) {texto}
      allow(@cv).to receive(:ler_configuracao_yaml) {configuracao}
      @cv.ler_arquivos
      @cv.convert
    end
    
    it "utiliza pacote natbib para citação no preambulo", :tecnico do
      expect(@cv.texto_tex).to include("\\usepackage[numbers,round,comma]{natbib}")
    end

    it "cria arquivo tex para compilação", :tecnico do
      expect(File).to exist(@cv.texto_tex_file)
    end

    it "converte o conteúdo do texto inteiro" do
      expect(@cv.texto_tex).to include("#{@seed}")
    end
    
    context 'o pdf', :pdf do
      before do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "foi gerado apropriadamente" do
        expect(File).to exist(@cv.pdf_file)
        expect(@cpl.txt).to include("Citações podem ser numéricas (1).")
        expect(@cpl.txt).to include("Referências\n")
        expect(@cpl.txt).to include("1 ASSOCIAÇÃO BRASILEIRA")
      end
    end
    
  end
  

end
