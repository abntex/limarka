---
title: 'Limarka: making possible Brazilian students writing dissertation and thesis with Markdown'
tags:
  - limarka
  - markdown
  - writing
  - dissertation
  - thesis
authors:
 - name: Eduardo S M Alexandre
   orcid: 0000-0002-9165-9438
   affiliation: 1
affiliations:
 - name: Universidade Federal da Paraíba
   index: 1
date: 8 December 2016
bibliography: paper.bib
---

# Summary

Many Brazilian's students have to write Monograph, Dissertation or Thesis at the
end of their course. But these documents must be written according to Brazilian's 
@NBR14724:2011 standard (ABNT). Despite the fact that this standard is not public available 
(it's for sale), it changes over time and has many rules.

Limarka makes possible to produce these documents according to ABNT standard,
by writing it with Markdown. Where the Markdown syntax is not expressive enough 
to follow ABNT rules, the user will need to input Latex code, and limarka 
makes it easier.

Limarka uses @pandoc to convert documents from Markdown to Latex, but uses custom
templates based on @abnTeX2 and configuration is done by filling a PDF @form, 
instead of editing files with @YAML format.

# References

