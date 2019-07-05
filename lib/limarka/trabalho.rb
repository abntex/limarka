# coding: utf-8

module Limarka

  # Esta classe representa o seu trabalho acadêmico.
  # @author Eduardo de Sanana Medeiros Alexandre
  class Trabalho
    # Todas as chaves de configuração devem ser string (não utilizar simbolos!)
    # @return [Hash] a configuração desse trabalho.
    attr_accessor :configuracao
    attr_accessor :texto, :anexos, :apendices, :errata
    attr_reader :referencias

    def initialize(configuracao: {}, texto: nil, anexos: nil, apendices: nil, referencias_bib: nil, errata: nil)
      self.configuracao = configuracao
      self.texto = texto
      self.anexos = anexos
      self.apendices = apendices
      self.referencias_bib = referencias_bib
      self.errata = errata
    end

#    def configuracao=(c)
#      # http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
#      @configuracao = c.inject({}){|h,(k,v)| h[k.to_s] = v; h} # convert to strings
#    end


    # Atualiza a configuração do trabalho.
    # @param configuracao [Hash]
    def configuracao=(configuracao)
      @configuracao = configuracao or {}
      siglas = @configuracao['siglas']
      if siglas and siglas.empty? then
        @configuracao['siglas'] = nil
      end
    end



    def anexos=(a)
      @anexos = a
      if (a) then
        @configuracao.merge!('anexos' => true)
      else
        @configuracao.merge!('anexos' => false)
      end
    end

    # @return o valor de `anexos` na configuração.
    def anexos?
      @configuracao['anexos']
    end

    # @return o valor de `errata` na configuração.
    def errata?
      @configuracao['errata']
    end

    # Atualiza errata na configuração
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

    def referencias_bib?
      @referencias
    end

    def referencias_bib=(ref)
      @referencias = ref
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

    def self.default_configuracao_file
      'configuracao.yaml'
    end

    # Ler os arquivos e atualiza a configuração, texto, referências, apendices e anexos.
    # @param options opção criada em {Cli}
    def atualiza_de_arquivos(options)
      self.configuracao = ler_configuracao(options)
      puts "Configuração lida: #{configuracao}" if options[:verbose]
      # transforma os simbolos em string: http://stackoverflow.com/questions/8379596/how-do-i-convert-a-ruby-hash-so-that-all-of-its-keys-are-symbols?noredirect=1&lq=1
      # @configuracao.inject({}){|h,(k,v)| h[k.intern] = v; h}
      self.texto = ler_texto(options[:rascunho_file])
      self.referencias_bib = ler_referencias(self.configuracao)
      self.apendices = ler_apendices if apendices?
      self.anexos = ler_anexos if anexos?
    end

    # Ler a configuração. A origem da configuração é determinada pelo valor de `options[:configuracao_yaml]`.
    # Se contém valor verdadeiro, ler do arquivo `configuracao.yaml`, caso contrário ler de `configuracao.pdf`.
    # @param options [Hash] criado na classe {Cli}
    # @return configuracao
    # @see {Cli}
    def ler_configuracao(options)
      if options and options[:configuracao_yaml] then
        raise IOError, "Arquivo configuracao.yaml não foi encontrado, talvez esteja executando dentro de um diretório que não contém um projeto válido?" unless File.exist?('configuracao.yaml')
        File.open('configuracao.yaml', 'r') {|f| YAML.load(f.read)}
      else
        raise IOError, "Arquivo configuracao.pdf não foi encontrado, talvez esteja executando dentro de um diretório que não contém um projeto válido?" unless File.exist?('configuracao.pdf')
        ler_configuracao_pdf 'configuracao.pdf'
      end
    end

    # Ler configuração do arquivo pdf
    # @param file arquivo pdf
    # @return [Hash] configuração exportada a partir da leitura do arquivo pdf
    # @see Pdfconf#exporta
    def ler_configuracao_pdf(file)
      raise IOError, 'Arquivo não encontrado: ' + file unless File.exist? (file)
      pdf = PdfForms::Pdf.new file, (PdfForms.new 'pdftk'), utf8_fields: true
      pdfconf = Limarka::Pdfconf.new(pdf: pdf)
      pdfconf.exporta
    end

    def ler_apendices
      File.open('apendices.md', 'r') {|f| f.read} if apendices?
    end

    def ler_anexos
      File.open('anexos.md', 'r') {|f| f.read} if anexos?
    end

    def ler_texto(rascunho_file)
      # Ficou estranho esse código, merece um refactory.
      if (rascunho_file) then
        File.open(rascunho_file, 'r') {|f| f.read}
      else
        File.open('trabalho-academico.md', 'r') {|f| f.read}
      end
    end

    # Ler referências do arquivo de referências.
    # @return [String] conteúdo do arquivo de referências
    def ler_referencias(configuracao)
      arquivo_de_referencias = configuracao['referencias_caminho']
      if File.exist?(arquivo_de_referencias)
        return File.open(arquivo_de_referencias, 'r') {|f| f.read}
      else
        return ""
      end
    end

    # Salva o hash no formato yaml no caminho especificado. Adiciona o `\n---\n`
    # para manter compatível com o leitor pandoc.
    # @param hash que será exportado.
    # @param caminho [String] aonde será salvo o arquivo
    def self.save_yaml(hash, caminho)
      File.open(caminho, 'w') do |f|
        f.write YAML.dump(hash)
        f.write "\n---\n"
      end
    end

    # Salva os conteúdos do trabalho em arquivos no diretórios especificado.
    def save(dir)
      Dir.chdir(dir) do
        File.open(Trabalho.default_texto_file, 'w'){|f| f.write texto} if texto
        File.open(configuracao['referencias_caminho'], 'w'){|f| f.write referencias} if referencias_bib?
        File.open(Trabalho.default_anexos_file, 'w'){|f| f.write anexos} if anexos?
        File.open(Trabalho.default_apendices_file, 'w'){|f| f.write apendices} if apendices?
        File.open(Trabalho.default_errata_file, 'w'){|f| f.write errata} if errata?
        Limarka::Trabalho.save_yaml(configuracao, Trabalho.default_configuracao_file)
      end

    end
  end
end
