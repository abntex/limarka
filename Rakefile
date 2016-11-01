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


desc 'Executa os testes rápidos, que não possuem a tag :lento'
RSpec::Core::RakeTask.new('spec:fast') do |t|
  t.rspec_opts = "--tag ~lento"
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:configuracao_padrao, 'spec:fast']

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.future_release = Limarka::VERSION
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
  system "libreoffice --headless --convert-to pdf configuracao.odt"
  system 'bundle', 'exec', 'limarka', 'configuracao', 'exporta', '-o', 'spec/configuracao_padrao'
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
