# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'

require 'limarka/configuracao'
require 'limarka/conversor'

module Limarka

  class Cli < Thor
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


