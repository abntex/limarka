require 'open3'
require 'yaml'
#require 'io'


def valida_yaml
  metadados = IO.read("metadados.yaml")
  puts YAML.load(metadados)
end

task :compile do
  system "latexmk --xelatex trabalho-academico.tex"
end


task :custom do
  puts "Gerando preambulo-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-preambulo metadados.yaml -o preambulo-customizado.tex"
  puts "Gerando pretextual-customizado.tex"
  system "pandoc -f markdown --data-dir=. --template=abntex2-pretextual metadados.yaml -o pretextual-customizado.tex"
end

task :tex => [:custom] do
  valida_yaml
  #system "pandoc --smart --standalone --wrap=none --data-dir=. -f markdown -t latex trabalho-academico.md metadados/matedados.yaml -o trabalho-academico.tex"
# --template=templates/default.latex 
# --filter=pandoc-citeproc 
# --template=abntex2-trabalho-academico
  system "pandoc -f markdown -s --normalize --chapter  --include-in-header=preambulo-customizado.tex  --include-before-body=pretextual-customizado.tex metadados.yaml trabalho-academico.md  -o trabalho-academico.tex"
end


task :default => [:tex, :compile]
