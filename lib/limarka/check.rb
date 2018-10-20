# coding: utf-8

module Limarka

  # Possibilita checar dependencias: pandoc
  # Ver https://github.com/abntex/limarka/issues/165
  # @see Cli
  class Check
    attr_accessor :pandoc
    attr_accessor :sistema
    PANDOC_VERSAO_MINIMA = '1.19.1'
    PANDOC_VERSAO_MAXIMA = '2.0.0'

    def initialize(pandoc: nil, sistema: true)
      self.pandoc = pandoc
      self.sistema = sistema
    end

    def check
      if sistema
        ler_pandoc_version
      end
      verifica_compatibilidade
      puts "OK."
    end

    def ler_pandoc_version
      self.pandoc = `pandoc --version`.split("\n")[0].split(" ")[1]
    end

    private

    def verifica_compatibilidade
      #byebug
      if Gem::Version.new(pandoc) < Gem::Version.new(Check::PANDOC_VERSAO_MINIMA) || Gem::Version.new(pandoc) >= Gem::Version.new(Check::PANDOC_VERSAO_MAXIMA)
        raise VersaoIncompativelError, "Versão incompatível do pandoc. Versão compatível: #{Check::PANDOC_VERSAO_MINIMA} <= Versão < #{Check::PANDOC_VERSAO_MAXIMA}"
      end
    end

  end

  class VersaoIncompativelError < StandardError
  end

end
