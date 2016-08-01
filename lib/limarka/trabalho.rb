# coding: utf-8

module Limarka
  class Trabalho
    attr_accessor :configuracao, :texto, :anexos, :apendices
    attr_reader :referencias
    
    def initialize(configuracao: {}, texto: nil, anexos: nil, apendices: nil, referencias_md: nil, referencias_bib: nil)
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
      
    end

    def configuracao=(c)
      # http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
      @configuracao = c.inject({}){|h,(k,v)| h[k.to_sym] = v; h} # convert to symbols
    end

    
    def anexos=(a)
      @anexos = a
      if (a) then
        @configuracao.merge!(anexos: true)
      else
        @configuracao.merge!(anexos: false)
      end
    end

    def apendices=(a)
      @apendices = a
      if (a) then
        @configuracao.merge!(apendices: true)
      else
        @configuracao.merge!(apendices: false)
      end
    end

    
    def referencias_md=(ref)
      @referencias = ref
      @configuracao.merge!({:referencias_md => true, :referencias_bib => false, :referencias_numerica_inline => false})
    end
    def referencias_bib?
      @configuracao[:referencias_bib]
    end
    def referencias_md?
      @configuracao[:referencias_md]
    end
    def referencias_inline?
      @configuracao[:referencias_numerica_inline]
    end
    
    def referencias_bib=(ref)
      @referencias = ref
      @configuracao.merge!({:referencias_md => false, :referencias_bib => true, :referencias_numerica_inline => false})
    end
    def referencias_inline!
      @referencias = nil
      @configuracao.merge!({:referencias_md => false, :referencias_bib => false, :referencias_numerica_inline => true})
    end
    
    def self.default_texto_file
      "trabalho-academico.md"
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

    def save
      File.open(Trabalho.default_texto_file, 'w'){|f| f.write texto}
      #File.open(self.default"#{test_dir}/#{arquivo_referencias}", 'w'){|f| f.write referencias}
      File.open(Trabalho.default_anexos_file, 'w'){|f| f.write anexos}
      File.open(Trabalho.default_apendices_file, 'w'){|f| f.write anexos}
      File.open(Trabalho.default_referencias_md_file, 'w'){|f| f.write referencias} if referencias_md?
      File.open(Trabalho.default_referencias_bib_file, 'w'){|f| f.write referencias} if referencias_bib?
      File.open(Trabalho.default_configuracao_file, 'w') do |f|
        f.write YAML.dump(configuracao)
        f.write "\n---\n"
      end
      
      
    end
  end
end
