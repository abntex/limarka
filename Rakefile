# coding: utf-8
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'limarka/version'
require 'colorize'
require 'open3'
require 'yaml'
require 'rake/clean'
require 'pdf_forms'

desc 'Executa os testes ruby'
RSpec::Core::RakeTask.new('spec:ruby') do |t|
  t.rspec_opts = "--tag ~compilacao --tag ~dependencias_latex"
end

desc 'Executa os testes com geração de pdf'
RSpec::Core::RakeTask.new('spec:pdf') do |t|
  t.rspec_opts = "--tag compilacao --tag dependencias_latex"
end

desc 'Executa o teste mínimo de compilação'
RSpec::Core::RakeTask.new('spec:latex_minimo') do |t|
  t.rspec_opts = "--tag latex_minimo"
end

namespace :cucumber do
  desc 'Executa testes cucumber que NÃO envolvem gerão de pdfs'
  task :ruby do
    system "cucumber -t 'not @pdf'"
  end

  desc 'Executa testes cucumber que envolvem gerão de pdfs'
  task :pdf do
    system "cucumber -t '@pdf'"
  end
end

task :default => [:configuracao_padrao, 'spec:ruby']

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

desc "Aplica tag v#{Limarka::VERSION}"
task 'tag' do
  system 'git', 'commit', '-m', %Q(Gerando versão v#{Limarka::VERSION})
  system 'git', 'tag',  %Q(v#{Limarka::VERSION})
  system 'git', 'push'
  system 'git', 'push', '--tags'
end

desc "Gera codelog para release de v#{Limarka::VERSION}"
task 'codelog' do
  system 'codelog', 'release', "#{Limarka::VERSION}"
end

# Desatualizado
namespace 'docker' do

  desc 'Constroi imagem docker'
  task 'build' do
    sh 'bin/build-docker.sh'
  end

  desc 'Publica imagens docker do limarka no travis'
  task 'deploy' do
    sh 'bin/deploy-docker.sh'
  end

  desc 'Executa o docker dentro do modelo'
  task 'run' do
    Dir.chdir('modelo-oficial') do
      rm_rf("xxx*")
      sh 'docker run --mount src=`pwd`,target=/trabalho,type=bind  limarka exec'
    end
  end

end

PREAMBULO="templates/preambulo.tex"
PRETEXTUAL = "templates/pretextual.tex"
POSTEXTUAL = "templates/postextual.tex"
CLEAN.include(["xxx-*",PREAMBULO,PRETEXTUAL,POSTEXTUAL,"templates/configuracao.yaml",'tmp'])
