# coding: utf-8

module Limarka

  # Ver https://github.com/abntex/limarka/issues/90
  class Cronograma
    attr_accessor :tabela, :legenda, :fonte, :rotulo
    
    def initialize(tabela: nil, legenda: nil, fonte: nil, rotulo: nil)
      self.tabela = tabela
      self.legenda = legenda
      self.fonte = fonte
      self.rotulo = rotulo
    end

    def self.cria_atividades(qtde_atividades, meses, legenda, fonte, rotulo)
      tabela = [
        ["Etapas", "Março", "Abril", "Maio", "Junho", "Julho"],
        ["1", "\\X", "", "", "", ""],
        ["2", "\\X", "", "", "", ""],
        ["3", "\\X", "", "", "", ""],
        ["4", "\\X", "", "", "", ""],
        ["5", "\\X", "", "", "", ""],
      ]
      Limarka::Cronograma.new(tabela:tabela, legenda:legenda, fonte:fonte, rotulo:rotulo)
    end
    
    def to_latex
      tex = <<LATEX
\\begin{table}[htb]
\\ABNTEXfontereduzida
\\caption{#{legenda}}
\\label{#{rotulo}}
  \\begin{tabular}{|l||c|c|c|c|c|}
    \\hline
    \\hline
    Fase  &  Março  &  Abril  &  Maio  &  Junho  &  Julho \\\\
    \\hline
    1     &   \\X    &         &        &         &        \\\\
    2     &         &    \\X   &   \\X   &         &        \\\\
    3     &         &         &   \\X   &   \\X    &        \\\\
    4     &         &         &        &   \\X    &   \\X   \\\\
    5     &         &         &        &         &   \\X   \\\\
    \\hline
    \\hline
  \\end{tabular}
\\legend{Fonte: #{fonte}}
\\end{table}
LATEX
    end
  end
end
