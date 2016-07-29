# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'
require 'fileutils'

module Limarka

  class Conversor
    attr_accessor :configuracao
    attr_accessor :options
    attr_accessor :preambulo_tex
    attr_accessor :pretextual_tex
    attr_accessor :postextual_tex
    attr_accessor :texto_tex
    attr_accessor :texto
    attr_accessor :referencias
    attr_accessor :anexos
    attr_accessor :apendices
    attr_accessor :output_dir
    
    def initialize(configuracao: nil, texto: nil, referencias:nil, output_dir: '.', apendices:nil, anexos: nil)
      self.configuracao = configuracao
      self.texto = texto
      self.referencias = referencias
      self.output_dir = output_dir
      self.apendices = apendices
      self.anexos = anexos
    end

    def ler_arquivos
      @configuracao = ler_configuracao
      # transforma os simbolos em string: http://stackoverflow.com/questions/8379596/how-do-i-convert-a-ruby-hash-so-that-all-of-its-keys-are-symbols?noredirect=1&lq=1
      # @configuracao.inject({}){|h,(k,v)| h[k.intern] = v; h} 
      @texto = ler_texto
      @referencias = ler_referencias
      @apendices = ler_apendices
    end


    def ler_apendices
      File.open('apendices.md', 'r') {|f| f.read} if apendices?
    end

    def ler_texto
      File.open('trabalho-academico.md', 'r') {|f| f.read}
    end

    
    def ler_referencias
      return ler_referencias_bib if referencias_bib?
      return ler_referencias_md if referencias_md?
    end
    def ler_configuracao
      File.open('templates/configuracao.yaml', 'r') {|f| YAML.load(f.read)}
    end

    def ler_referencias_bib
      File.open('referencias.bib', 'r') {|f| f.read}
    end

    def ler_referencias_md
      File.open('referencias.md', 'r') {|f| f.read}
    end

    def apendices?
      @configuracao['apendices']
    end

    def referencias_bib?
      @configuracao['referencias_bib']
    end

    def referencias_md?
      @configuracao['referencias_md']
    end

    
    def convert
      FileUtils.mkdir_p(output_dir)
      
      preambulo
      pretextual
      postextual
      textual
    end

    def hash_to_yaml(h)
      s = StringIO.new
      s << h.to_yaml
      s << "---\n\n"
      s.string
    end
    
    PREAMBULO="templates/preambulo.tex"
    def preambulo
      Open3.popen3("pandoc -f markdown --data-dir=. --template=preambulo -t latex") do |stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(@configuracao))
        stdin.close
        @preambulo_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      end
      File.open(preambulo_tex_file, 'w') { |file| file.write(@preambulo_tex) }
    end

    PRETEXTUAL = "templates/pretextual.tex"

    def pretextual
      s = StringIO.new
      necessita_de_arquivo_de_texto = ["errata"]
      ["folha_de_rosto", "errata", "folha_de_aprovacao", "dedicatoria", "agradecimentos", 
      "epigrafe", "resumo", "abstract", "lista_ilustracoes", "lista_tabelas", 
      "lista_siglas", "lista_simbolos", "sumario"].each_with_index do |secao,indice|
        template = "pretextual#{indice+1}-#{secao}"
        Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} -t latex") {|stdin, stdout, stderr, wait_thr|
          stdin.write(hash_to_yaml(@configuracao))
          stdin.write("\n")
          if necessita_de_arquivo_de_texto.include?(secao) then
            arquivo_de_entrada = "#{secao}.md"
            conteudo = File.read(arquivo_de_entrada)
            stdin.write(conteudo)
          end
          stdin.close
          s << stdout.read
          exit_status = wait_thr.value # Process::Status object returned.
          if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
        }
      end
      @pretextual_tex = s.string
      File.open(pretextual_tex_file, 'w') { |file| file.write(pretextual_tex) }
#      puts "#{PRETEXTUAL} criado".green
    end

    POSTEXTUAL = "templates/postextual.tex"
    def postextual
      # Referências (obrigatório)
      # Glossário (opcional)
      # Apêndice (opcional)
      # Anexo (opcional)
      # Índice (opcional)

      s = StringIO.new

      s << secao_referencias
      s << secao_glossario
      s << secao_apendices
      s << secao_anexos
      s << secao_indice
      
      
      ["glossario", "apendices", "anexos", "indice"].each_with_index do |secao,indice|
        template = "postextual#{indice+2}-#{secao}"
        Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} --chapter -t latex") {|stdin, stdout, stderr, wait_thr|
          stdin.write(hash_to_yaml(@configuracao))
          stdin.write("\n")
          escreve_arquivo_externo_se_necessario(stdin, secao)
          stdin.close
          s << stdout.read
          exit_status = wait_thr.value # Process::Status object returned.
          if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
        }
      end

      # arquivo temporário de referencias
      if(referencias_bib?) then
        File.open(referencias_bib_file, 'w') { |file| file.write(@referencias) }
      end
      
      @postextual_tex = s.string
      File.open(postextual_tex_file, 'w') { |file| file.write(postextual_tex) }
    end

    def secao_referencias
      s = StringIO.new
      
      template = "postextual1-referencias"
      Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} --chapter -t latex") {|stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(@configuracao))
        stdin.write("\n")
        if (referencias_md?) then
          stdin.write(@referencias) 
          stdin.write "\n"
        end
        stdin.close
        s << stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      }
      s.string
    end
    
    def secao_glossario
    end
    
    def secao_apendices
    end
    
    def secao_anexos
    end
    
    def secao_indice
    end

    
    
    def escreve_arquivo_externo_se_necessario(stdin, secao)
=begin
        necessita_de_arquivo_de_texto = ["referencias", "apendices","anexos"]
        if necessita_de_arquivo_de_texto.include?(secao) then
          arquivo_de_entradab = "#{secao}.md"
          conteudo = File.read(arquivo_de_entrada)            
          stdin.write(conteudo_externo_para_secao(secao))
        end
=end

      if (secao == 'apendices' and @configuracao['apendices'])
        stdin.write(@apendices)
        stdin.write "\n"
      end

      if (secao == 'anexos' and @configuracao['anexos'])
        stdin.write(@anexos)
        stdin.write "\n"
      end

      
    end

    
    def textual
      valida_yaml
      Open3.popen3("pandoc -f markdown+raw_tex -t latex -s --normalize --chapter --include-in-header=#{preambulo_tex_file} --include-before-body=#{pretextual_tex_file}  --include-after-body=#{postextual_tex_file}") {|stdin, stdout, stderr, wait_thr|
        stdin.write(File.read('templates/configuracao-tecnica.yaml'))
        stdin.write("\n")
        stdin.write(hash_to_yaml(configuracao))
        stdin.write("\n")
        stdin.write(@texto)
        stdin.close
        @texto_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      }
      File.open(texto_tex_file, 'w')  { |f| f.write(@texto_tex)}
    end
    
    def preambulo_tex_file
      "#{output_dir}/xxx-preambulo.tex"
    end
    def pretextual_tex_file
      "#{output_dir}/xxx-pretextual.tex"
    end
    def postextual_tex_file
      "#{output_dir}/xxx-postextual.tex"
    end
    
    def texto_tex_file
      "#{output_dir}/xxx-Monografia.tex"
    end
    def pdf_file
      "#{output_dir}/xxx-Monografia.pdf"
    end

    def referencias_bib_file
      "#{output_dir}/xxx-referencias.bib"
    end
    
    def valida_yaml
      # não faz nada por enquanto
    end

  end
end


