# coding: utf-8

require 'spec_helper'
require 'limarka/conversor'
require 'limarka/compilador_latex'

describe 'Referências' do


  context 'quando configurada para ler de referencias.bib' do
    before (:context)  do
      referencias_configuracao = {'referencias_numerica_inline' => false, 'referencias_abnt2cite' => true, 'referencias_md' => false}
      test_dir = 'referencias_abnt2cite'
      @seed  = Random.new_seed 
      texto = <<-TEXTO
# Introdução

Citação no texto: \\citeonline{ABNT-citacao}.

> No final da citação direta \\cite{ABNT-citacao}.

Citando o ano: \\citeyear{ABNT-citacao}.

TEXTO

      texto = texto + "\nSeed: #{@seed}\n" 
      @referencias_bib = <<-REFERENCIAS
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
      configuracao = configuracao_padrao.merge referencias_configuracao
      FileUtils.rm_rf "tmp/#{test_dir}"
      @cv = Limarka::Conversor.new(:texto => texto, :referencias_bib => @referencias_bib, :configuracao => configuracao, :output_dir => "tmp/#{test_dir}")
      @cv.convert
    end

    it "utiliza pacote abntex2cite para citação no preambulo", :tecnico do
      expect(@cv.texto_tex).to include("\\usepackage[alf]{abntex2cite}")
    end
    it "cria arquivo tex para compilação", :tecnico do
      expect(File).to exist(@cv.texto_tex_file)
    end
    it "bibliografia copiada para arquivo temporário xxx-referencias.bib", :tecnico do
      expect(File).to exist(@cv.referencias_bib_file)
    end
    it "referências será produzida a partir de xxx-referencias.bib", :tecnico do
      expect(@cv.texto_tex).to include('\\bibliography{xxx-referencias}')
    end
    it "códigos de citações estão presentes no arquivo latex", :tecnico do
      citacao = <<-CITACAO
Citação no texto: \\citeonline{ABNT-citacao}.

\\begin{quote}
No final da citação direta \\cite{ABNT-citacao}.
\\end{quote}

Citando o ano: \\citeyear{ABNT-citacao}.
CITACAO
      expect(@cv.texto_tex).to include(citacao)
    end

    
    context 'no pdf', :pdf do
      before (:context) do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "não possui erros de compilação" do
        expect(File).to exist(@cv.pdf_file)
      end
      it "a seção referências possui apenas o nome Referências" do
        expect(@cpl.txt).to include("Referências\n")
      end
      it "citação no texto apresentada apropriadamente" do
        expect(@cpl.txt).to include("Citação no texto: ABNT (2002).")
      end
      it "citação direta apresentada apropriadamente" do
        expect(@cpl.txt).to include("No final da citação direta (ABNT, 2002).")
      end
      it "citação do ano apresentada apropriadamente" do
        expect(@cpl.txt).to include("Citando o ano: 2002.")
      end
    end
  end


  context 'quando configurada para ler de referencias.md' do
    before (:context)  do
      referencias_configuracao = {'referencias_numerica_inline' => false, 'referencias_abnt2cite' => false, 'referencias_md' => true}
      test_dir = 'referencias_md'
      @seed  = Random.new_seed 
      texto = <<-TEXTO
# Introdução

Citação manual no texto: ABNT (2002).

> No final da citação direta (ABNT, 2011).

TEXTO

      texto = texto + "\nSeed: #{@seed}\n" 
      @referencias_md = <<-REFERENCIAS

ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. **NBR 10520**: Informação e
documentação — apresentação de citações em documentos. Rio de Janeiro, 2002.
Disponível em <https://www.abntcatalogo.com.br/norma.aspx?ID=2074#>.

ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. **NBR 14724**: Informação e
documentação — Trabalhos acadêmicos — Apresentação. Rio de Janeiro, 2011.

REFERENCIAS
      configuracao = configuracao_padrao.merge referencias_configuracao
      FileUtils.rm_rf "tmp/#{test_dir}"
      @cv = Limarka::Conversor.new(:texto => texto, :referencias_md => @referencias_md, :configuracao => configuracao, :output_dir => "tmp/#{test_dir}")
      @cv.convert
    end

    it "cria arquivo tex para compilação", :tecnico do
      expect(File).to exist(@cv.texto_tex_file)
    end

    it "referências foram incluídas no arquivo tex", :tecnico do
      expect(@cv.texto_tex).to include('ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. \textbf{NBR 10520}')
    end

    context 'no pdf', :pdf do
      before (:context) do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "não possui erros de compilação" do
        expect(File).to exist(@cv.pdf_file)
      end
      it "a seção referências possui apenas o nome Referências" do
        expect(@cpl.txt).to include("Referências\n")
      end
      it "as referências estão presentes no pdf" do
        expect(@cpl.txt).to include("ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. NBR 14724: Informação e")
      end

    end
  end


  
  context 'quando configurada com citação numérica (NBR 6023:2002, 9.2)' do

    before (:context)  do
      referencias_configuracao = {'referencias_numerica_inline' => true, 'referencias_abnt2cite' => false, 'referencias_md' => false}
      test_dir = 'citacao-numerica'
      @seed  = Random.new_seed 
      texto = <<-TEXTO
# Introdução

\\citarei{ABNT-citacao}{ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. {\\emph ABNT NBR 6024:2012}: 
  Informação e documentaçãao -- Apresentação de citações em documentos. Rio de Janeiro, 2002.}

> Citações podem ser numéricas \\cita{ABNT-citacao}.

TEXTO
      texto = texto + "\nSeed: #{@seed}\n" 
      configuracao = configuracao_padrao.merge referencias_configuracao
      FileUtils.rm_rf "tmp/#{test_dir}"
      @cv = Limarka::Conversor.new(:texto => texto, :configuracao => configuracao, :output_dir => "tmp/#{test_dir}")
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

    
    context 'no pdf', :pdf do
      before (:context) do
        @cpl = Limarka::CompiladorLatex.new()
        @cpl.compila(@cv.texto_tex_file, :salva_txt => true)
      end
      it "não possui erros de compilação" do
        expect(File).to exist(@cv.pdf_file)
      end
      it "pode ser convertido para txt" do
        expect(File).to exist(@cv.pdf_file)
      end
      it "a citação mostra o número da referência entre parenteses (NBR 10520:2002, 6.2)", pdf: true do
        expect(@cpl.txt).to include("Citações podem ser numéricas (1).")
      end
      it "a seção referências possui apenas o nome Referências" do
        expect(@cpl.txt).to include("Referências\n")
      end
      it "mostra as referências com numeração sem parênteses ou colchotes" do
        expect(@cpl.txt).to include("1 ASSOCIAÇÃO BRASILEIRA")
      end

    end
    
  end
  

end
