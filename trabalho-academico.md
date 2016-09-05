# Introdução {#indroducao}

Introdução do trabalho.[^intro]

[^intro]: Exemplo de nota de rodapé.


# Referencial teórico

## Como citar e referenciar

O arquivo de referências é configurado em "configuracao.pdf", utilize-o
para gerenciar suas referências.

Veja um exemplo de citação e referenciação a seguir:

> Alguém falou algo bem bonito aqui, mas não esquecer que para fazer
> uma citação desta forma é necessário ter no mínimo três linhas de
> acordo com a ABNT \cite{abntex2cite}.

Consulte \citeonline{abntex2cite} para conhecer como referenciar os
conteúdos.

## Como inserir imagens

As imagens precisam ser inseridas utilizando código em latex, pois o
markdown não oferece suporte a inserir as fontes das imagens. Veja um exemplo:

\begin{figure}[htbp]
\caption{\label{fig_bandeira}Pássaro com as cores da bandeira do Brasil}
\begin{center}
\includegraphics[width=0.85\textwidth]{imagens/passaro.jpg}
\end{center}
\legend{Fonte: \citeonline{limarka}}.
\end{figure}

Ajuste o valor de "width" para redimencionar a figura.

## Tabelas latex

Utilize código Latex para criar as tabelas.

\begin{table}[htbp]
\IBGEtab{%
  \caption{Cronograma da pesquisa}%
  \label{tabela-ibge}
}{%
  \begin{tabular}{ccccc}
  \toprule
   Etapa & Set & Out & Nov & Dez \\
  \midrule \midrule
   Conclusão da implementação da ferramenta & X \\
  \midrule 
	Publicação da Ferramenta e convite para experimentos on-line &  & X \\
  \midrule 
	Condução de experimentos controlados &  & X \\
  \midrule 
	Análise dos resultados dos experimentos &  & X & X \\
  \midrule 
	Escrita da dissertação & X & X & X \\
  \midrule 
	Experimento realístico & X & X  \\
  \midrule 
	Defesa da dissertação &  &  &  & X \\

\bottomrule
\end{tabular}%
}{%
  \fonte{Autor}%
  }
\end{table}

# Resultados

Resultados aqui.

# Conclusão

Conclusão do trabalho.
