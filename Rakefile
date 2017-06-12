# coding: utf-8
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'limarka/version'
require 'colorize'
require 'open3'
require 'yaml'
require 'rake/clean'
require 'pdf_forms'
require 'github_changelog_generator/task'


desc 'Executa os testes ruby'
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = "--tag ~compilacao --tag ~dependencias_latex" 
end

desc 'Executa os testes com compilação Latex'
RSpec::Core::RakeTask.new('spec:latex') do |t|
  t.rspec_opts = "--tag compilacao --tag dependencias_latex"
end

task :default => [:configuracao_padrao, 'spec']

GitHubChangelogGenerator::RakeTask.new :changelog do |c|
  c.future_release = "v"+Limarka::VERSION
  c.bug_prefix="**Bugs corrigidos:**"
  c.issue_prefix = "**Issues fechados:**"
  c.enhancement_prefix="**Melhorias implementadas:**"
  c.since_tag="0.2.0"
end


# http://stackoverflow.com/questions/19841865/ruby-gem-to-extract-form-data-from-fillable-pdf
# https://github.com/jkraemer/pdf-forms/blob/master/test/pdf_test.rb

namespace :pdf do
  ## "Imprime a configuração em PDF"
  task :test => ["configuracao.pdf"] do
    @pdftk = PdfForms.new 'pdftk'
    pdf = PdfForms::Pdf.new 'configuracao.pdf', @pdftk, utf8_fields: true
    puts "Fields: #{pdf.fields}"
    puts "Título do tabalho: #{pdf.field('title').value}"
    puts "Autor: #{pdf.field('autor').value}"
    puts "Ano: #{pdf.field('date').value}"
  end
end

desc 'Cria configuração padrão para execução dos testes, o libreoffice precisa está fechado!'
task :configuracao_padrao do
  Dir.chdir('modelo-oficial') do
    system "libreoffice --headless --convert-to pdf configuracao.odt"
  end
  configuracao_padrao_spec_dir = File.absolute_path('spec/configuracao_padrao')
  system 'bundle', 'exec', 'limarka', 'configuracao', 'exporta', '-o', configuracao_padrao_spec_dir,'-i','modelo-oficial'
end

directory 'dissertacao-limarka/output'

desc 'Compila dissertação'
task :dissertacao => 'dissertacao-limarka/output' do
  system 'bundle', 'exec', 'limarka', 'exec', '-i', 'dissertacao-limarka', '-o', 'dissertacao-limarka/output'
end

PREAMBULO="templates/preambulo.tex"
PRETEXTUAL = "templates/pretextual.tex"
POSTEXTUAL = "templates/postextual.tex"
CLEAN.include(["xxx-*",PREAMBULO,PRETEXTUAL,POSTEXTUAL,"templates/configuracao.yaml",'tmp'])
