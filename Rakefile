require 'colorize'
require 'open3'
require 'yaml'
require 'rake/clean'
require 'pdf_forms'

task :default => ['clean','pdf:configuracao', :tex, :compile]

PDF = "configuracao.pdf"

def tipo_do_trabalho
  tipo="Monografia"
  if File.exist?(PDF) then
    @pdftk = PdfForms.new 'pdftk'
    pdf = PdfForms::Pdf.new PDF, @pdftk, utf8_fields: true
    tipo = pdf.field('tipo_do_trabalho').value
    if tipo == "Dissertação" then tipo = "Dissertacao" end
  end
  puts "Tipo do trabalho: #{tipo}".green
  tipo
end

def target()
  "xxx-#{tipo_do_trabalho}.tex"
end 

def valida_yaml
  metadados = IO.read("templates/configuracao-tecnica.yaml") # Valida o arquivo de metadados
  puts ("configuracao-tecnica.yaml: " + YAML.load(metadados).to_s).green
  metadados = IO.read("templates/configuracao.yaml") # Valida o arquivo de metadados
  puts ("configuracao.yaml: " + YAML.load(metadados).to_s).green

end

desc "Compila arquivo tex em PDF"
task :compile do
  system "latexmk --xelatex #{target()}"
end

PRETEXTUAL = "templates/pretextual.tex"

desc "Gera conteúdo do pré-textual"
task :pretextual  do
  pretextual = ""

  necessita_de_arquivo_de_texto = ["errata"]
  ["folha_de_rosto", "errata", "folha_de_aprovacao", "dedicatoria", "agradecimentos", 
  "epigrafe", "resumo", "abstract", "lista_ilustracoes", "lista_tabelas", 
  "lista_siglas", "lista_simbolos", "sumario"].each_with_index do |secao,indice|
    template = "pretextual#{indice+1}-#{secao}"
    arquivo_de_entrada = if necessita_de_arquivo_de_texto.include?(secao) then "#{secao}.md" else "" end
    Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} -t latex templates/configuracao.yaml #{arquivo_de_entrada}") {|stdin, stdout, stderr, wait_thr|
      pretextual = pretextual + stdout.read
      exit_status = wait_thr.value # Process::Status object returned.
      if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
    }
  end

  File.open(PRETEXTUAL, 'w') { |file| file.write(pretextual) }
  puts "#{PRETEXTUAL} criado".green
end

POSTEXTUAL = "templates/postextual.tex"
desc "Gera conteúdo do pós-textual"
task :postextual  do
  # Referências (obrigatório)
  # Glossário (opcional)
  # Apêndice (opcional)
  # Anexo (opcional)
  # Índice (opcional)

  postextual = ""

  necessita_de_arquivo_de_texto = ["referencias", "apendices","anexos"]
  ["referencias", "glossario", "apendices", "anexos", "indice"].each_with_index do |secao,indice|
    template = "postextual#{indice+1}-#{secao}"
    arquivo_de_entrada = if necessita_de_arquivo_de_texto.include?(secao) then "#{secao}.md" else "" end
    Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} --chapter -t latex templates/configuracao.yaml #{arquivo_de_entrada}") {|stdin, stdout, stderr, wait_thr|
      postextual = postextual + stdout.read
      exit_status = wait_thr.value # Process::Status object returned.
      if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
    }
  end

  File.open(POSTEXTUAL, 'w') { |file| file.write(postextual) }
  puts "#{POSTEXTUAL} criado".green
end

PREAMBULO="templates/preambulo.tex"
desc "Gera o arquivo de preambulo"
task :preambulo do
  system "pandoc -f markdown --data-dir=. --template=preambulo templates/configuracao.yaml -o #{PREAMBULO}"
  puts "#{PREAMBULO} criado".green
end

desc "Gera xxx-trabalho-academico.tex a partir do arquivo markdown e metadados."
task :tex => [:preambulo, :pretextual, :postextual] do
  valida_yaml
  #system "pandoc --smart --standalone --wrap=none --data-dir=. -f markdown -t latex trabalho-academico.md metadados/matedados.yaml -o xxx-trabalho-academico.tex"
# --template=templates/default.latex 
# --filter=pandoc-citeproc 
# --template=abntex2-trabalho-academico
  system "pandoc -f markdown -s --normalize --chapter --include-in-header=#{PREAMBULO} --include-before-body=#{PRETEXTUAL}  --include-after-body=#{POSTEXTUAL} templates/configuracao-tecnica.yaml templates/configuracao.yaml trabalho-academico.md -o #{target()}"
end

file "configuracao.pdf"
file "templates/configuracao.yaml" => ["configuracao.pdf","Rakefile"] do |t|
  @pdftk = PdfForms.new 'pdftk'
  pdf = PdfForms::Pdf.new 'configuracao.pdf', @pdftk, utf8_fields: true
  h = {} # hash

  # Campos do PDF

=begin
  ["title", "author", "instituicao", "local", "date", "aprovacao_dia", "aprovacao_mes", "orientador", "coorientador","avaliador1", "avaliador2", "avaliador3", "tipo_do_trabalho", "titulacao","curso","programa", "linha_de_pesquisa","ficha_catalografica","dedicatoria","agradecimentos","epigrafe","resumo","palavras_chave",
"keywords","abstract_texto","resume", "resumen", "mots_cles"].each do |campo|

    if not pdf.field(campo) then puts "Campo faltando: #{campo}".red end
    value = pdf.field(campo).value
    if value == "Off" then value = false end
    if value == "" then value = nil end
    h[campo] = value
  end
=end

  # Campos do PDF
  pdf.fields.each do |f|
    value = f.value
    if value == "Off" then value = false end
    if value == "" then value = nil end
    h[f.name] = value
  end

  # Substitui ',' e ';' por '.'
  ['palavras_chave', 'palabras_clave', 'keywords', 'mots_cles'].each do |p|
    if(h[p])
      h[p] = h[p].gsub(/[;,]/, '.')   
    end
  end

  h['monografia'] = h["tipo_do_trabalho"] == "Monografia"
  h["ficha_catalografica"] = h["ficha_catalografica"] == "Incluir ficha-catalografica.pdf da pasta imagens"


  # siglas e simbolos
  ['siglas','simbolos'].each do |sigla_ou_simbolo|
    if (h[sigla_ou_simbolo]) then
      sa = [] # sa: s-array
      h[sigla_ou_simbolo].each_line do |linha|
        s,d = linha.split(":")
        sa << { 's' => s.strip, 'd' => d ? d.strip : ""}
      end
      h[sigla_ou_simbolo] = sa
    end
  end
  

  # shows
  h["errata"] = pdf.field("errata").value == "Utilizar Errata"
  h["folha_de_aprovacao_gerar"] =   pdf.field("folha_de_aprovacao").value == "Gerar folha de aprovação"
  h["folha_de_aprovacao_incluir"] = pdf.field("folha_de_aprovacao").value == "Utilizar folha de aprovação escaneada"
  h["lista_ilustracoes"] = pdf.field("lista_ilustracoes").value == "Gerar lista de ilustrações"
  h["lista_tabelas"] = pdf.field("lista_tabelas").value == "Gerar lista de tabelas"

  # salva o arquivo
  File.open(t.name, 'w') do |f| 
    f.write h.to_yaml
    f.write "---\n\n"
  end
  puts "Arquivo criado: #{t.name}".green

end

# http://stackoverflow.com/questions/19841865/ruby-gem-to-extract-form-data-from-fillable-pdf
# https://github.com/jkraemer/pdf-forms/blob/master/test/pdf_test.rb

namespace :pdf do
  desc "Imprime a configuração em PDF"
  task :test => ["configuracao.pdf"] do
    @pdftk = PdfForms.new 'pdftk'
    pdf = PdfForms::Pdf.new 'configuracao.pdf', @pdftk, utf8_fields: true
    puts "Fields: #{pdf.fields}"
    puts "Título do tabalho: #{pdf.field('title').value}"
    puts "Autor: #{pdf.field('autor').value}"
    puts "Ano: #{pdf.field('date').value}"
  end
  desc "Ler configuração do PDF e salva em configuracao.yaml"
  task :configuracao => ["templates/configuracao.yaml"]

end




CLEAN.include(["xxx-*",PREAMBULO,PRETEXTUAL,POSTEXTUAL,"templates/configuracao.yaml"])
