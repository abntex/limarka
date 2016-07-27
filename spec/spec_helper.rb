# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'limarka'
require 'yaml'
require 'pry-byebug'

def configuracao_padrao
  config = <<-CONFIG
---
nome_exemplo: Escreva seu primeiro nome aqui
instituicao: Universidade/Faculdade do Brasil
author: Nome do autor
tipo_do_trabalho: Monografia
title: Título do trabalho
coorientador: 
orientador: Nome-do-Orientador
date: '2016'
local: Cidade - UF
titulacao: Minha-titulação
curso: Meu-curso
programa: Programa de Pós-Graduação em XXX
linha_de_pesquisa: minha-linha
referencias_origem: 'Banco de referências Bibtex: referencias.bib'
resumo: 
palavras_chave: 
abstract_texto: 
keywords: 
resumen: 
palabras_clave: 
resume: 
mots_cles: 
siglas:
- s: ABNT
  d: Associação Brasileira de Normas Técnicas
simbolos: 
lista_ilustracoes: false
lista_tabelas: false
ficha_catalografica: false
dedicatoria: 
agradecimentos: 
epigrafe: 
folha_de_aprovacao: Não gerar folha de aprovação
aprovacao_dia: '1'
aprovacao_mes: Agosto
avaliador1: Nome-do-Prof-Convidado1
avaliador2: Nome-do-Prof-Convidado2
avaliador3: 
errata: false
monografia: true
folha_de_aprovacao_gerar: false
folha_de_aprovacao_incluir: false
referencias_bib: true
referencias_texto: false
referencias_md: false
referencias-manual: false
citacao-numerica: true
---

CONFIG
  YAML.load(config)
end

# Retorna o texto do pdf
def pdftext(pdf_file)
  <<-PDF
Citações podem ser numéricas (1).

Referências

1 ASSOCIAÇÃO BRASILEIRA"
PDF
end
