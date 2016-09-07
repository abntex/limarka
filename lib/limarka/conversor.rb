# coding: utf-8
require "thor"
require 'pdf_forms'
require 'yaml'
require 'colorize'
require 'open3'
require 'fileutils'
require 'bibtex'


module Limarka

  class Conversor
    # trabalho
    attr_accessor :t
    attr_accessor :options
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
      pretextual_tempfile = Tempfile.new('pretextual')
      postextual_tempfile = Tempfile.new('postextual')
      begin
        pretextual(pretextual_tempfile)
        postextual(postextual_tempfile)
        textual(pretextual_tempfile,postextual_tempfile)
        
        ensure
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

      cria_xxx_referencias
      
      @postextual_tex = s.string
      File.open(tempfile, 'w') { |file| file.write(postextual_tex) }
    end

    ## arquivo temporário de referencias
    def cria_xxx_referencias
      referencias_tempfile = Tempfile.new('referencias')
      File.open(referencias_tempfile, 'w') {|file| file.write(t.referencias)}
      b = BibTeX.open(referencias_tempfile.path)
      b.each do |entry|
        if entry.title.include?(':') then
          s = entry.title.split(':')
          entry['title'] = s[0].strip
          entry['subtitle'] = s[1].strip
        end
      end
      
      b.save_to referencias_bib_file
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
      secao("postextual1-referencias", false, t.referencias)
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
    
    def textual(pretextual_tempfile, postextual_tempfile)
      valida_yaml
      Open3.popen3("pandoc -f markdown+raw_tex -t latex -s --data-dir=#{options[:templates_dir]} --template=trabalho-academico --normalize --chapter --include-before-body=#{pretextual_tempfile.path}  --include-after-body=#{postextual_tempfile.path}") {|stdin, stdout, stderr, wait_thr|
        stdin.write(File.read(options[:templates_dir] + '/templates/configuracao-tecnica.yaml'))
        stdin.write("\n")
        stdin.write(hash_to_yaml(t.configuracao))
        stdin.write("\n")
        stdin.write(t.texto)
        stdin.close
        @texto_tex = stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
        if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
      }
      File.open(texto_tex_file, 'w')  { |f| f.write(@texto_tex)}
    end
    
    def pretextual_tex_file
      "#{options[:output_dir]}/xxx-pretextual.tex"
    end
    def postextual_tex_file
      "#{options[:output_dir]}/xxx-postextual.tex"
    end
    
    def texto_tex_file
      Conversor.tex_file(t.configuracao)
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

    def self.tex_file(configuracao)
      if (configuracao['graduacao'] and configuracao['projeto']) then
        'xxx-Monografia-projeto.tex'
      elsif (configuracao['graduacao'] and not configuracao['projeto']) then
        'xxx-Monografia.tex'
      elsif (configuracao['especializacao'] and configuracao['projeto']) then
        'xxx-TFC-projeto.tex'
      elsif (configuracao['especializacao'] and not configuracao['projeto']) then
        'xxx-TFC.tex'
      elsif (configuracao['mestrado'] and configuracao['projeto']) then
        'xxx-Dissertacao-projeto.tex'
      elsif (configuracao['mestrado'] and not configuracao['projeto']) then
        'xxx-Dissertacao.tex'
      elsif (configuracao['doutorado'] and configuracao['projeto']) then
        'xxx-Tese-projeto.tex'
      elsif (configuracao['doutorado'] and not configuracao['projeto']) then
        'xxx-Tese.tex'
      else
        "xxx.tex"
      end

    end

  end
end


