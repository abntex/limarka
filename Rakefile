require 'colorize'
require 'open3'
require 'yaml'
require 'rake/clean'
require 'pdf_forms'

def valida_yaml
  metadados = IO.read("metadados.yaml") # Valida o arquivo de metadados
  puts ("Metadados: " + YAML.load(metadados).to_s).green
end

desc "Compila arquivo tex em PDF"
task :compile do
  system "latexmk --xelatex trabalho-academico.tex"
end

PRETEXTUAL = "pretextual.tex"

desc "Gera conteúdo do pré-textual"
task :pretextual  do
  pretextual = ""

  necessita_de_arquivo_de_texto = ["errata"]
  ["folha_de_rosto", "errata", "folha_de_aprovacao", "dedicatoria", "agradecimentos", "epigrafe", "resumo", "abstract", "lista_ilustracoes", "lista_tabelas", "lista_siglas", "lista_simbolos", "sumario"].each_with_index do |secao,indice|
    template = "pretextual#{indice+1}-#{secao}"
    arquivo_de_entrada = if necessita_de_arquivo_de_texto.include?(secao) then "#{secao}.md" else "" end
    Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} -t latex metadados.yaml #{arquivo_de_entrada}") {|stdin, stdout, stderr, wait_thr|
      pretextual = pretextual + stdout.read
      exit_status = wait_thr.value # Process::Status object returned.
      if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
    }
  end

  File.open(PRETEXTUAL, 'w') { |file| file.write(pretextual) }
  puts "#{PRETEXTUAL} criado".green
end

POSTEXTUAL = "postextual.tex"
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
    Open3.popen3("pandoc -f markdown --data-dir=. --template=#{template} --chapter -t latex metadados.yaml #{arquivo_de_entrada}") {|stdin, stdout, stderr, wait_thr|
      postextual = postextual + stdout.read
      exit_status = wait_thr.value # Process::Status object returned.
      if(exit_status!=0) then puts ("Erro: " + stderr.read).red end
    }
  end

  File.open(POSTEXTUAL, 'w') { |file| file.write(postextual) }
  puts "#{POSTEXTUAL} criado".green
end

desc "Gera o arquivo de preambulo"
task :preambulo do
  system "pandoc -f markdown --data-dir=. --template=preambulo metadados.yaml -o preambulo.tex"
  puts "preambulo.txt criado".green
end

task :custom do
  puts "Gerando preambulo-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-preambulo metadados.yaml -o preambulo-customizado.tex"
  puts "Gerando pretextual-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-pretextual metadados.yaml -o pretextual-customizado.tex"
  puts "Gerando postextual-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-postextual metadados.yaml -o postextual-customizado.tex"
  puts "Gerando apendices-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-apendices metadados.yaml --chapter apendices.md -o apendices-customizado.tex"
  puts "Gerando anexos-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-anexos metadados.yaml --chapter anexos.md -o anexos-customizado.tex"
  puts "Gerando indice-remissivo-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-indice-remissivo metadados.yaml -o indice-remissivo-customizado.tex"
  puts "Gerando referencias-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-referencias metadados.yaml referencias.md -o referencias-customizado.tex"
  puts "Gerando errata-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=errata-abntex2 metadados.yaml errata.md -o errata-customizado.tex"
end

desc "Gera trabalho-academico.tex a partir do arquivo markdown e metadados."
task :tex => [:preambulo, :pretextual, :postextual] do
  valida_yaml
  #system "pandoc --smart --standalone --wrap=none --data-dir=. -f markdown -t latex trabalho-academico.md metadados/matedados.yaml -o trabalho-academico.tex"
# --template=templates/default.latex 
# --filter=pandoc-citeproc 
# --template=abntex2-trabalho-academico
  system "pandoc -f markdown -s --normalize --chapter --include-in-header=preambulo.tex --include-before-body=pretextual.tex  --include-after-body=postextual.tex metadados.yaml trabalho-academico.md -o trabalho-academico.tex"
end

file "configuracao.pdf"
file "configuracao.yaml" => ["configuracao.pdf","Rakefile"] do
  @pdftk = PdfForms.new 'pdftk'
  pdf = PdfForms::Pdf.new 'configuracao.pdf', @pdftk, utf8_fields: true
  h = {} # hash

  ["title", "author", "instituicao", "local", "date", "aprovacao_dia", "aprovacao_mes", "orientador", "coorientador","avaliador1", "avaliador2", "avaliador3", "tipo_do_trabalho", "titulacao","curso","programa", "linha_de_pesquisa","ficha_catalografica"].each do |campo|
    if not pdf.field(campo) then puts "Campo faltando: #{campo}".red end
    value = pdf.field(campo).value
    if value == "Off" then value = false end
    if value == "" then value = nil end
    h[campo] = value
  end

  h[:monografia] = h["tipo_do_trabalho"] == "Monografia"
  h["ficha_catalografica"] = h["ficha_catalografica"] == "Incluir ficha-catalografica.pdf da pasta imagens"

  # siglas
  siglas = []
  siglas_str = pdf.field("siglas").value
  siglas_str.each_line do |linha|
    s,d = linha.split(":")
    siglas << { 's' => s.strip, 'd' => d.strip}
  end
  h["siglas"] = siglas
  

  # shows
  h["show_errata"] = pdf.field("show_errata").value == "Utilizar Errata"
  h["folha_de_aprovacao_gerar"] =   pdf.field("folha_de_aprovacao").value == "Gerar folha de aprovação"
  h["folha_de_aprovacao_incluir"] = pdf.field("folha_de_aprovacao").value == "Utilizar folha de aprovação escaneada"
  
  # show_folha_de_aprovacao
  # tipo_do_trabalho

  # salva o arquivo
  File.open('configuracao.yaml', 'w') do |f| 
    f.write h.to_yaml
    f.write "---\n"
  end

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
  task :configuracao => ["configuracao.yaml"]

end


task :default => [:tex, :compile]

CLEAN.include(["trabalho-academico.aux","trabalho-academico.idx","trabalho-academico.lof", "trabalho-academico.pdf","trabalho-academico.fdb_latexmk","trabalho-academico.ilg","trabalho-academico.log","*.*~","trabalho-academico.tex","trabalho-academico.fls","trabalho-academico.ind","trabalho-academico.lot","trabalho-academico.out","trabalho-academico.toc","trabalho-academico.bbl","trabalho-academico.blg","trabalho-academico.brf","preambulo.tex","pretextual.tex","postextual.tex","configuracao.yaml"])
