# coding: utf-8

module Limarka

  # Tentativa para criar um modelo de cronograma. Não é utilizado ainda.
  # Ver https://github.com/abntex/limarka/issues/90
  # @see Cli
  class Check
    attr_accessor :pandoc
    attr_accessor :sistema

    def initialize(pandoc: nil, sistema: true)
      self.pandoc = pandoc
      self.sistema = sistema
    end

    def check
      if sistema
        ler_pandoc
      end
    end

    private

    def ler_pandoc
      self.pandoc = `pandoc --version`.split("\n")[0].split(" ")[1]
    end

  end


end
