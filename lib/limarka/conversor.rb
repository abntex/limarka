# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'
require 'fileutils'

module Limarka

  class Conversor
    # trabalho
    attr_accessor :t
    attr_accessor :options
    attr_accessor :preambulo_tex
    attr_accessor :pretextual_tex
    attr_accessor :postextual_tex
    attr_accessor :texto_tex
    
    def initialize(trabalho, options)
      self.t = trabalho
      self.options = options
    end

    
    def convert()
      FileUtils.mkdir_p(options[:output_dir])

      # A invocação de pandoc passando parâmetro como --before-body necessita
      # de ser realizado através de arquivos, portanto, serão criados arquivos
      # temporários para sua execução
      preambulo_tempfile =  Tempfile.new('preambulo')
      pretextual_tempfile = Tempfile.new('pretextual')
      postextual_tempfile = Tempfile.new('postextual')
      begin
        preambulo(preambulo_tempfile)
        pretextual(pretextual_tempfile)
        postextual(postextual_tempfile)
        textual(preambulo_tempfile, pretextual_tempfile,postextual_tempfile)
        
        ensure
          preambulo_tempfile.close
          preambulo_tempfile.unlink
          pretextual_tempfile.close
          pretextual_tempfile.unlink
          postextual_tempfile.close
          postextual_tempfile.unlink
      end
    end

    def hash_to_yaml(h)
      s = StringIO.new
      s << h.to_yaml
      s << "---\n\n"
      s.string
    end
    
    PREAMBULO="templates/preambulo.tex"
    def preambulo(tempfile)
      Open3.popen3("pandoc -f markdown --data-dir=#{options[:templates_dir]} --template=preambulo -t latex") do |stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(t.configuracao))
        stdin.close
        @preambulo_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      end
      File.open(tempfile, 'w') { |file| file.write(@preambulo_tex) }
    end

    PRETEXTUAL = "templates/pretextual.tex"

    def pretextual(tempfile)
      s = StringIO.new
      necessita_de_arquivo_de_texto = ["errata"]
      ["folha_de_rosto", "errata", "folha_de_aprovacao", "dedicatoria", "agradecimentos", 
      "epigrafe", "resumo", "abstract", "lista_ilustracoes", "lista_tabelas", 
      "lista_siglas", "lista_simbolos", "sumario"].each_with_index do |secao,indice|
        template = "pretextual#{indice+1}-#{secao}"
        Open3.popen3("pandoc -f markdown --data-dir=#{options[:templates_dir]} --template=#{template} -t latex") {|stdin, stdout, stderr, wait_thr|
          stdin.write(hash_to_yaml(t.configuracao))
          stdin.write("\n")
          if t.errata? and necessita_de_arquivo_de_texto.include?(secao) then
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
      File.open(tempfile, 'w') { |file| file.write(pretextual_tex) }
#      puts "#{PRETEXTUAL} criado".green
    end

    POSTEXTUAL = "templates/postextual.tex"
    def postextual(tempfile)
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
      
      # arquivo temporário de referencias
      if(t.referencias_bib?) then
        File.open(referencias_bib_file, 'w') { |file| file.write(@referencias) }
      end
      
      @postextual_tex = s.string
      File.open(tempfile, 'w') { |file| file.write(postextual_tex) }
    end

    def secao(template, condicao_para_conteudo, conteudo_externo)
      s = StringIO.new
      
      Open3.popen3("pandoc -f markdown --data-dir=#{options[:templates_dir]} --template=#{template} --chapter -t latex") {|stdin, stdout, stderr, wait_thr|
        stdin.write(hash_to_yaml(t.configuracao))
        stdin.write("\n")
        if (condicao_para_conteudo) then
          stdin.write(conteudo_externo)
          stdin.write("\n")
        end
        stdin.close
        s << stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      }
      s.string
    end

    
    def secao_referencias
      secao("postextual1-referencias", t.referencias_md?, t.referencias)
    end

    def secao_apendices
      secao("postextual3-apendices", t.apendices?, t.apendices)
    end

    def secao_anexos
      secao("postextual4-anexos", t.anexos?, t.anexos)
    end
    
    def secao_glossario
    end

    def secao_indice
    end
    
    def textual(preambulo_tempfile, pretextual_tempfile, postextual_tempfile)
      valida_yaml
      Open3.popen3("pandoc -f markdown+raw_tex -t latex -s --normalize --chapter --include-in-header=#{preambulo_tempfile.path} --include-before-body=#{pretextual_tempfile.path}  --include-after-body=#{postextual_tempfile.path}") {|stdin, stdout, stderr, wait_thr|
        stdin.write(File.read(options[:templates_dir] + '/templates/configuracao-tecnica.yaml'))
        stdin.write("\n")
        stdin.write(hash_to_yaml(t.configuracao))
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
      "#{options[:output_dir]}/xxx-preambulo.tex"
    end
    def pretextual_tex_file
      "#{options[:output_dir]}/xxx-pretextual.tex"
    end
    def postextual_tex_file
      "#{options[:output_dir]}/xxx-postextual.tex"
    end
    
    def texto_tex_file
      "#{options[:output_dir]}/xxx-Monografia.tex"
    end
    def pdf_file
      "#{options[:output_dir]}/xxx-Monografia.pdf"
    end

    def referencias_bib_file
      "#{options[:output_dir]}/xxx-referencias.bib"
    end
    
    def valida_yaml
      # não faz nada por enquanto
    end

  end
end


