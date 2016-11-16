# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

require 'limarka/configuracao'
require 'limarka/conversor'
require 'clipboard'

module Limarka

  class Cli < Thor
    include Thor::Actions
    
    default_command :exec  

    method_option :configuracao_yaml, :aliases => '-y', :type => :boolean, :desc => 'Ler configuração exportada (configuracao.yaml) em vez de configuracao.pdf', :default => false
    method_option :input_dir, :aliases => '-i', :desc => 'Diretório onde será executado a ferramenta', :default => '.'
    method_option :output_dir, :aliases => '-o', :desc => 'Diretório onde serão gerados os arquivos', :default => '.'
    method_option :compila_tex, :aliases => '-c', :desc => 'Compila arquivo tex gerando um PDF', :default => true, :type => :boolean
    method_option :templates_dir, :aliases => '-t', :desc => 'Diretório que contem a pasta templates (pandoc --data-dir)', :default => Dir.pwd
    method_option :verbose, :aliases => '-v', :desc => 'Imprime mais detalhes da execução', :default => false, :type => :boolean
    desc "exec", "Executa o sistema para geração do documento latex e compilação"
    def exec
      #options[:output_dir] = File.absolute_path(options[:output_dir]) 
      Dir.chdir(options[:input_dir]) do
        t = Limarka::Trabalho.new
        t.atualiza_de_arquivos(options)
        cv = Limarka::Conversor.new(t,options)
        cv.convert
        cv.compila if options[:compila_tex]
      end
    end

    
    desc "importa ARQUIVO", "Cria um arquivo trabalho-academico.md com o conteúdo convertido de ARQUIVO"
    long_desc "Converte documento do Word (ou similar) para trabalho-academico.md. O arquivo será criado no mesmo diretório que contém ARQUIVO. Útil quando possuímos um arquivo já digitado no word e desejamos utilizar o limarka. Mantém, por exemplo, as marcações de itálico, negrito e notas de rodapé."
    def importa(arquivo)
      diretorio = File.dirname(arquivo)
      system "pandoc", "-t", "markdown", "-o", "#{diretorio}/trabalho-academico.md", arquivo
    end

    method_option :interativo, :aliases => '-i', :desc => 'Solicita os parâmetros de forma interativa.', :type => :boolean, :default => false
    method_option :clipboard, :aliases => '-c', :desc => 'Utiliza o conteúdo da área de transferência como o nome do arquivo.', :type => :boolean, :default => false

#     method_option :arquivo, :aliases => '-a', :desc => 'Caminho completo ou apenas o nome do arquivo na pasta imagens. Somente arquivos existêntes são válidos. Se não for especificado e o nome do arquivo esteja copiado (na área de transferência), e o arquivo existir, ele será utilizado.'  
    method_option :legenda, :aliases => '-l', :desc => 'Legenda da figura.', :default => "Legenda da figura."
    method_option :fonte, :aliases => '-f', :desc => 'Fonte da imagem.', :default => "Autor."
    method_option :rotulo, :aliases => '-r', :desc => 'Rótulo para ser utilizado na referenciação da figura, caso não especificado um será proposto.'
    method_option :dimensoes, :aliases => '-d', :desc => 'Dimensões percentuais para redimencionar a figura. Se mais de uma dimensão for especificada será apresentado um código para inclusão da imagem para cada dimensão. Útil quando deseja experimentar diversas dimensões para a Figura. Ex: 80 90 100', :default => [100], :type => :array

    long_desc <<-DESC
Esse comando imprime (1) o código para inclusão de uma figura (2) e como referenciá-la no texto. Para as figuras serem apresentadas, em conformidade com as Normas da ABNT, elas precisam serem incluídas como código Latex (abnTeX2).
DESC
    desc "fig ARQUIVO", "Imprime códigos para inclusão de imagens em conformidade com ABNT (em LaTeX)"
    def fig(arquivo=nil)
      
      if (options[:clipboard]) then
        arquivo = Clipboard.paste         # Ler do clipboard, requer xclip: sudo apt-get install xclip
      end

      if (arquivo) then
        if arquivo.start_with?("file://") then
          arquivo = arquivo[7,-1]
        end
      end       

      
      if (options[:interativo]) then
        arquivo =   ask_figura_arquivo(arquivo)
        legenda =   ask_figura_legenda
        fonte =     ask_figura_fonte
        rotulo =    ask_figura_rotulo(rotulo, arquivo)
        dimensoes = ask_figura_dimensoes
      else
        legenda = options[:legenda]
        fonte = options[:fonte]
        rotulo = options[:rotulo]
        if (not arquivo) then
          arquivo = ask_figura_arquivo(nil)
        end       
        rotulo = "fig:" + propoe_rotulo(File.basename arquivo, ".*") if rotulo.nil?
        dimensoes = options[:dimensoes]
      end
      
      valida_figura_arquivo(arquivo)
      valida_figura_rotulo(rotulo)
      
      say "\n<!--\nPara referenciar essa figura no texto utilize: Figura \\ref\{#{rotulo}} \n-->\n"
      dimensoes.each do |dim|

        legenda = options[:legenda]
        escala = (dim.to_f)/100
        
        figura_tex = <<TEX
\\begin{figure}[htbp]
\\caption{\\label{#{rotulo}}#{legenda}}
\\begin{center}
\\includegraphics[width=#{escala}\\textwidth]{#{arquivo}}
\\end{center}
\\legend{Fonte: #{fonte}}
\\end{figure}

TEX

        say figura_tex
      end
    end

    no_commands do
      def valida_figura_rotulo (rotulo)
        if (not rotulo =~ (/^[a-zA-Z][\w\-:]*$/)) then
          raise RuntimeError, "O rótulo não deve conter caracteres especiais. Forneça um rótulo ou remova os caracteres especiais do nome do arquivo. Rótulo atual: #{rotulo}"
        end
      end

      def valida_figura_arquivo(arquivo)
        raise RuntimeError, "Arquivo especificado para a figura não existe: '#{arquivo}'." unless File.file?(arquivo)
      end
    
      def ask_figura_arquivo(arquivo = nil)        
        if arquivo.nil? then
          arquivos = Dir["imagens/*"].select{ |f| File.file? f }.sort
          print_table arquivos.map.with_index{ |a, i| [i+1, *a]}
          selecao = ask("Escolha um arquivo para a Figura:").to_i
          arquivo=arquivos[selecao-1]
        end

        arquivo
      end
      def ask_figura_legenda
        legenda_padrao = "Legenda da figura."
        legenda_lida = ask("Insira o texto da legenda [#{legenda_padrao}]):")
        if legenda_lida == "" then
          legenda = legenda_padrao
        else
          legenda = legenda_lida
        end 
      end
      
      def ask_figura_fonte
        fonte_padrao = "Autor."
        fonte_lida = ask("Insira o texto da fonte [#{fonte_padrao}]):")
        if fonte_lida == "" then
          fonte = fonte_padrao
        else
          fonte = fonte_lida
        end 
      end
      def ask_figura_rotulo(rotulo, arquivo)
        # http://stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
        
        if (not rotulo) then
          rotulo_proposto = "fig:" + propoe_rotulo(File.basename arquivo, ".*")
          rotulo_lido = ask("Rótulo para referenciar a figura [#{rotulo_proposto}]. fig:" )
          if rotulo_lido.empty? then
            rotulo = rotulo_proposto
          else
            rotulo = "fig:"+rotulo_lido
          end
        end      
        rotulo
      end

      def propoe_rotulo(string_base)
        encoding_options = {
          :invalid           => :replace,  # Replace invalid byte sequences
          :undef             => :replace,  # Replace anything not defined in ASCII
          :replace           => '-',        # Use a blank for those replacements
        }

        rotulo_proposto = string_base.gsub(/\s+/, '-').encode(Encoding.find('ASCII'), encoding_options)
      end

      def ask_figura_dimensoes
        dimensoes = ask("Forneça as dimensões separadas por espaço [100]:")
        if dimensoes.empty? then
          [100]
        else
          dimensoes.split(" ")
        end
      end
    end


    
=begin
    method_option :entrada, :default => "configuracao.pdf", :aliases => "-i", :banner => "FILE"
    method_option :saida, :default => "templates/configuracao.yaml", :aliases => "-o", :banner => "FILE"
    desc "pdfconf", "Ler configuração de arquivo pdf"
    def pdfconf
      
      if not (File.exist?(options[:entrada])) then
        raise IOError, "Arquivo não existe: #{options[:entrada]}"
      end
    
      @pdftk = PdfForms.new 'pdftk'
      pdf = PdfForms::Pdf.new options[:entrada], @pdftk, utf8_fields: true
      h = {} # hash

      # Campos do PDF
      pdf.fields.each do |f|
        value = f.value
        if value == "Off" then value = false end
        if value == "" then value = nil end
        h[f.name] = value
      end

      # Substitui ',' e ';' por '.'
      ['palavras_chave', 'palabras_clave', 'keywords', 'mots_cles'].each do |p|
        if(h[p])
          h[p] = h[p].gsub(/[;,]/, '.')   
        end
      end

      h['monografia'] = h["tipo_do_trabalho"] == "Monografia"
      h["ficha_catalografica"] = h["ficha_catalografica"] == "Incluir ficha-catalografica.pdf da pasta imagens"


      # siglas e simbolos
      ['siglas','simbolos'].each do |sigla_ou_simbolo|
        if (h[sigla_ou_simbolo]) then
          sa = [] # sa: s-array
          h[sigla_ou_simbolo].each_line do |linha|
            s,d = linha.split(":")
            sa << { 's' => s.strip, 'd' => d ? d.strip : ""} if s
            end
          h[sigla_ou_simbolo] = sa
        end
      end
      
      # shows
      h["errata"] = pdf.field("errata_combo").value == "Utilizar Errata"
      h["folha_de_aprovacao_gerar"] =   pdf.field("folha_de_aprovacao").value == "Gerar folha de aprovação"
      h["folha_de_aprovacao_incluir"] = pdf.field("folha_de_aprovacao").value == "Utilizar folha de aprovação escaneada"
      h["lista_ilustracoes"] = pdf.field("lista_ilustracoes").value == "Gerar lista de ilustrações"
      h["lista_tabelas"] = pdf.field("lista_tabelas").value == "Gerar lista de tabelas"

      # Referências
      selecao = 'referencias_combo'
      {"referencias_bib" => "Banco de referências Bibtex (referencias.bib) + \\cite",
      'referencias_numerica_inline' => "Inseridas ao longo do texto \\citarei + \\cita",
      'referencias_md' => 'Separadamente, no arquivo referencias.md'}.each do |template_key,valor_para_verdadeiro|
          h[template_key] = pdf.field(selecao).value == valor_para_verdadeiro
      end

      #TESTES

      # Escreve na saída
      s = StringIO.new
      s << h.to_yaml
      s << "---\n\n"
      
      if (options['saida'] == '-')
        puts s.string
      else
        File.open(options['saida'], 'w') { |f| f.write s.string}
        puts "Arquivo criado: #{options['saida']}".green
      end
    end
=end

    desc "configuracao help", "Exporta e atualiza configurações"
    subcommand "configuracao", Limarka::Configuracao

  end
end


