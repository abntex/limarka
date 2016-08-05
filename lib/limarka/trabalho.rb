# coding: utf-8

module Limarka
  class Trabalho
    # Todas as chaves de configuração devem ser string (e não utilizar simbolos!)
    attr_accessor :configuracao
    attr_accessor :texto, :anexos, :apendices, :errata
    attr_reader :referencias
    
    def initialize(configuracao: {}, texto: nil, anexos: nil, apendices: nil, referencias_md: nil, referencias_bib: nil, errata: nil)
      self.configuracao = configuracao
      self.texto = texto
      self.anexos = anexos
      self.apendices = apendices
      if referencias_md then
        self.referencias_md = referencias_md
      elsif (referencias_bib) then
        self.referencias_bib = referencias_bib
      else
        referencias_inline!
      end
      self.errata = errata
      
    end

#    def configuracao=(c)
#      # http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
#      @configuracao = c.inject({}){|h,(k,v)| h[k.to_s] = v; h} # convert to strings
#    end

    def anexos=(a)
      @anexos = a
      if (a) then
        @configuracao.merge!('anexos' => true)
      else
        @configuracao.merge!('anexos' => false)
      end
    end

    def anexos?
      @configuracao['anexos']
    end

    def errata?
      @configuracao['errata']
    end

    def errata=(e)
      @errata = e
      if (e) then
        @configuracao.merge!('errata' => true)
      else
        @configuracao.merge!('errata' => false)
      end
    end

    
    def apendices=(a)
      @apendices = a
      if (a) then
        @configuracao.merge!('apendices' => true)
      else
        @configuracao.merge!('apendices' => false)
      end
    end

    def apendices?
      @configuracao['apendices']
    end

    def anexos?
      @configuracao['anexos']
    end
    
    def referencias_md=(ref)
      @referencias = ref
      @configuracao.merge!({'referencias_md' => true, 'referencias_bib' => false, 'referencias_numerica_inline' => false})
    end
    def referencias_bib?
      @configuracao['referencias_bib']
    end
    def referencias_md?
      @configuracao['referencias_md']
    end
    def referencias_inline?
      @configuracao['referencias_numerica_inline']
    end
    
    def referencias_bib=(ref)
      @referencias = ref
      @configuracao.merge!({'referencias_md' => false, 'referencias_bib' => true, 'referencias_numerica_inline' => false})
    end
    def referencias_inline!
      @referencias = nil
      @configuracao.merge!({'referencias_md' => false, 'referencias_bib' => false, 'referencias_numerica_inline' => true})
    end
    
    def self.default_texto_file
      "trabalho-academico.md"
    end
    def self.default_errata_file
      "errata.md"
    end
    def self.default_anexos_file
      "anexos.md"
    end
    def self.default_apendices_file
      "apendices.md"
    end

    def self.default_referencias_bib_file
      "referencias.bib"
    end

    def self.default_referencias_md_file
      "referencias.md"
    end

    def self.default_configuracao_file
      'configuracao.yaml'
    end

    def atualiza_de_arquivos(options)
      self.configuracao = ler_configuracao(options)
      # transforma os simbolos em string: http://stackoverflow.com/questions/8379596/how-do-i-convert-a-ruby-hash-so-that-all-of-its-keys-are-symbols?noredirect=1&lq=1
      # @configuracao.inject({}){|h,(k,v)| h[k.intern] = v; h} 
      self.texto = ler_texto
      self.referencias_bib = ler_referencias_bib if referencias_bib?
      self.referencias_md = ler_referencias_md if referencias_md?
      self.apendices = ler_apendices if apendices?
      self.anexos = ler_anexos if anexos?
    end

    def ler_configuracao(options)
      File.open(options[:configuracao_yaml], 'r') {|f| YAML.load(f.read)}
    end

    def ler_apendices
      File.open('apendices.md', 'r') {|f| f.read} if apendices?
    end

    def ler_anexos
      File.open('anexos.md', 'r') {|f| f.read} if anexos?
    end
    
    def ler_texto
      File.open('trabalho-academico.md', 'r') {|f| f.read}
    end
    
    def ler_referencias(configuracao)
      return ler_referencias_bib if configuracao['referencias_bib']
      return ler_referencias_md if configuracao['referencias_md']
    end

    def ler_referencias_bib
      File.open('referencias.bib', 'r') {|f| f.read}
    end

    def ler_referencias_md
      File.open('referencias.md', 'r') {|f| f.read}
    end
    
    def save(dir)
      Dir.chdir(dir) do
        File.open(Trabalho.default_texto_file, 'w'){|f| f.write texto} if texto
        #File.open(self.default"#{test_dir}/#{arquivo_referencias}", 'w'){|f| f.write referencias}
        File.open(Trabalho.default_anexos_file, 'w'){|f| f.write anexos} if anexos?
        File.open(Trabalho.default_apendices_file, 'w'){|f| f.write apendices} if apendices?
        File.open(Trabalho.default_referencias_md_file, 'w'){|f| f.write referencias} if referencias_md?
        File.open(Trabalho.default_referencias_bib_file, 'w'){|f| f.write referencias} if referencias_bib?
        File.open(Trabalho.default_errata_file, 'w'){|f| f.write errata} if errata?
        File.open(Trabalho.default_configuracao_file, 'w') do |f|
          f.write YAML.dump(configuracao)
          f.write "\n---\n"
        end
      end
    end
  end
end
