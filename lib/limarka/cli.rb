# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

require 'limarka/configuracao'
require 'limarka/ref'
require 'limarka/conversor'
require 'clipboard'
require 'terminal-table'

module Limarka

  # Essa classe é responsável por interpretar e executar os comandos de linha
  # da ferramenta. Para compreender sua utilização recomendo consultar a
  # documentação do [thor](http://whatisthor.com).
  #
  # @author Eduardo de Santana Medeiros Alexandre
  #
  class Cli < Thor
    include Thor::Actions

    default_command :exec

    desc "check", "Verifica se o sistema está utilizando as dependências compatíveis"
    def check
      c = Limarka::Check.new()
      c.check()
    end


    method_option :configuracao_yaml, :aliases => '-y', :type => :boolean, :desc => 'Ler configuração exportada (configuracao.yaml) em vez de configuracao.pdf', :default => false
    method_option :input_dir, :aliases => '-i', :desc => 'Diretório onde será executado a ferramenta', :default => '.'
    method_option :output_dir, :aliases => '-o', :desc => 'Diretório onde serão gerados os arquivos', :default => '.'
    method_option :compila_tex, :aliases => '-c', :desc => 'Compila arquivo tex gerando um PDF', :default => true, :type => :boolean
    method_option :templates_dir, :aliases => '-t', :desc => 'Diretório que contem a pasta templates (pandoc --data-dir)', :default => Dir.pwd
    method_option :rascunho, :aliases => '-r', :desc => 'Ler de um arquivo de rascunho em vez de "trabalho-academico.md"', :banner => "RASCUNHO_FILE"
    method_option :verbose, :aliases => '-v', :desc => 'Imprime mais detalhes da execução', :default => false, :type => :boolean
    method_option :version, :desc => 'Imprime a versão do limarka', :default => false, :type => :boolean

    desc "exec", "Executa o sistema para geração do documento latex e compilação"
    def exec

      if (options[:version]) then
        puts "limarka "+Limarka::VERSION
        s = `pandoc --version`
        s << `ruby --version`
        s << `pdftk --version`
        s <<`latexmk --version`
        s << `xelatex --version `
        puts s
        return
      end

      #options[:output_dir] = File.absolute_path(options[:output_dir])
      Dir.chdir(options[:input_dir]) do
        t = Limarka::Trabalho.new
        t.atualiza_de_arquivos(options)
        cv = Limarka::Conversor.new(t,options)
        cv.convert
        cv.usa_pdftotext = false
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
    method_option :dimensoes, :aliases => '-d', :desc => 'Dimensões percentuais para redimensionar a figura. Se mais de uma dimensão for especificada será apresentado um código para inclusão da imagem para cada dimensão. Útil quando deseja experimentar diversas dimensões para a Figura. Ex: 80 90 100', :default => [100], :type => :array

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
        valida_figura_arquivo(arquivo) # antecipando validação issue #78
        legenda =   ask_figura_legenda
        fonte =     ask_figura_fonte
        rotulo =    ask_figura_rotulo(rotulo, arquivo)
        valida_figura_rotulo(rotulo)   # antecipando validação issue #78
        dimensoes = ask_figura_dimensoes
      else
        legenda = options[:legenda]
        fonte = options[:fonte]
        rotulo = options[:rotulo]
        if (not arquivo) then
          arquivo = ask_figura_arquivo(nil)
        end
        valida_figura_arquivo(arquivo) # antecipando validação issue #78
        rotulo = "fig:" + propoe_rotulo(File.basename arquivo, ".*") if rotulo.nil?
        valida_figura_rotulo(rotulo)   # antecipando validação issue #78
        dimensoes = options[:dimensoes]
      end




      dimensoes.each do |dim|

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
      say "\n<!--Para referenciar a figura acima no texto utilize: Figura \\ref\{#{rotulo}} \n-->\n"
    end

    method_option :legenda, :aliases => '-l', :desc => 'Legenda da tabela.', :default => "Legenda da tabela."
    method_option :fonte, :aliases => '-f', :desc => 'Fonte da tabela.', :default => "Autor."
    method_option :rotulo, :aliases => '-r', :desc => 'Rótulo para ser utilizado na referenciação da tabela, caso não especificado um será proposto.'
    method_option :nota, :aliases => '-n', :desc => 'Texto de nota adicional. (opcional)'

    long_desc <<-DESC
Esse comando imprime duas tabela para facilitar a criação de tabelas.
DESC
    desc "tab", "Imprime códigos para inclusão de tabelas em conformidade com ABNT (em LaTeX)"
    def tab
      legenda = options[:legenda]
      fonte = options[:fonte]
      rotulo_lido = options[:rotulo]
      if rotulo_lido then
        rotulo = rotulo_lido
      else
        rotulo = "tab:"+(Time.now.to_i % 100000).to_s
      end

      nota = options[:nota]
      if nota then
        nota_linha = "  \\nota{#{nota}}%\n"
      else
        nota_linha = ""
      end

      valida_tabela_rotulo(rotulo)

      say <<TEX

\\begin{table}[htb]
\\ABNTEXfontereduzida
\\caption{#{legenda}}
\\label{#{rotulo}}
\\begin{tabular}{p{2.6cm}|p{6.0cm}|p{2.25cm}|p{3.40cm}}
  %\\hline
   \\textbf{Nível de Investigação} & \\textbf{Insumos}  & \\textbf{Sistemas de Investigação}  & \\textbf{Produtos}  \\\\
    \\hline
    Meta-nível & Filosofia\\index{filosofia} da Ciência  & Epistemologia &
    Paradigma  \\\\
    \\hline
    Nível do objeto & Paradigmas do metanível e evidências do nível inferior &
    Ciência  & Teorias e modelos \\\\
    \\hline
    Nível inferior & Modelos e métodos do nível do objeto e problemas do nível inferior & Prática & Solução de problemas  \\\\
   % \\hline
\\end{tabular}
\\legend{Fonte: #{fonte}}
\\end{table}

\\begin{table}[htb]
\\IBGEtab{%
  \\caption{#{legenda}}%
  \\label{#{rotulo}}
}{%
  \\begin{tabular}{ccc}
  \\toprule
   Nome & Nascimento & Documento \\\\
  \\midrule \\midrule
   Maria da Silva & 11/11/1111 & 111.111.111-11 \\\\
  \\midrule
   João Souza & 11/11/2111 & 211.111.111-11 \\\\
  \\midrule
   Laura Vicuña & 05/04/1891 & 3111.111.111-11 \\\\
  \\bottomrule
\\end{tabular}%
}{%
  \\fonte{#{fonte}}%
#{nota_linha}}
\\end{table}

<!--
Para referenciar a tabela acima no texto utilize: Tabela \\ref\{#{rotulo}}
-->
TEX

#        say tabela_tex


    end

    desc "cronograma", "Imprime código para facilitar elaboração de Cronograma"
    def cronograma
    # https://github.com/abntex/limarka/issues/90
    tex = <<TEX
\\begin{table}[htbp]
  \\centering
  \\caption{Cronograma de atividades}
  \\label{tab:cronograma}
  \\begin{tabular}{|c|c|c|c|c|c|}
    \\hline
    Fase & Março & Abril & Maio & Junho & Julho \\\\
    \\hline
    1 & \\textbullet & & & & \\\\
    2 & & \\textbullet & & & \\\\
    3 & & & \\textbullet & & \\\\
    4 & & & & \\textbullet & \\\\
    5 & & & & & \\textbullet \\\\
    \\hline
  \\end{tabular}
  \\legend{Fonte: Autor.}
\\end{table}

\\begin{table}[htbp]
  \\centering
  \\caption{Cronograma de atividades}
  \\label{tab:cronograma}
  \\begin{tabular}{|l|c|c|c|c|c|}
    \\hline
    Atividade & Março & Abril & Maio & Junho & Julho \\\\
    \\hline
    XXXXXXXXXXXXXXXX & \\textbullet & & & & \\\\
    XXXXXXXXXXXXXXXX & & \\textbullet & & & \\\\
    XXXXXXXX & & & \\textbullet & & \\\\
    XXXXXXXX & & & & \\textbullet & \\\\
    XXXXXXXX & & & & & \\textbullet \\\\
    \\hline
  \\end{tabular}
  \\legend{Fonte: Autor.}
\\end{table}
TEX
      puts tex
    end

    desc "menu", "Inicia um menu interativo, aceita TAB para autocompletar."
    def menu
      table = Terminal::Table.new :title => "Menu interativo - limarka v#{Limarka::VERSION}\n#{Dir.pwd}", :headings => ['Comando', 'Descrição'] do |t|
        t << ["exec", "Executa o limarka."]
        t << ["figura","Imprime código para adição de Figura."]
        t << ["tabela","Imprime código para adição de Tabela."]
        t << ["cronograma","Imprime código para inclusão de Cronograma."]
        t << ["rascunho","Executa o limarka lendo de rascunho.md"]
        t << ["web","Imprime o endereço da documentação online."]
        t << ["menu","Imprime esse menu."]
        t << ["sair","Termina o menu interativo."]
      end
      puts table
      puts "Pressione TAB para completar o comando ao digitar: 'sa'+TAB completa para 'sair'"
      sair = false
      until sair do
        cmd = ask("Qual comando deseja executar?", :limited_to => ["exec", "figura", "tabela", "cronograma","rascunho","web","menu","sair"])
        case cmd
        when "sair"
          sair = true
        when "menu"
          puts table
        when "exec"
          system "limarka","exec"
        when "web"
          puts "https://github.com/abntex/limarka/wiki"
          puts ""
        when "figura"
          system "limarka", "fig","-i"
        when "tabela"
          system "limarka", "tab"
        when "cronograma"
          system "limarka", "cronograma"
        when "rascunho"
          system "limarka", "exec", "--rascunho=rascunho.md"
        else
          "Você digitou a opção #{cmd} -- esta não é uma opção válida, apresentando o menu.\n"
          puts table
        end
      end


    end


    no_commands do
      def valida_figura_rotulo (rotulo)
        if (not rotulo =~ (/^[a-zA-Z][\w\-:]*$/)) then
          raise RuntimeError, "O rótulo não deve conter caracteres especiais. Forneça um rótulo ou remova os caracteres especiais do nome do arquivo. Rótulo atual: '#{rotulo}'"
        end
      end
      def valida_tabela_rotulo (rotulo)
        if (not rotulo =~ (/^[a-zA-Z][\w\-:]*$/)) then
          raise RuntimeError, "O rótulo não deve conter caracteres especiais, rótulo atual: #{rotulo}"
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




    desc "configuracao help", "Exporta e atualiza configurações"
    subcommand "configuracao", Limarka::Configuracao

    desc "ref", "Adiciona ou referencia bibliografia"
    subcommand "ref", Limarka::Ref

  end
end
