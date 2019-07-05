require 'csv'

Dado("um diretório com o template oficial") do
  @modelo_dir = File.join(@inicio,'modelo-oficial')
  @dir = File.join('tmp/cucumber', [*('a'..'z')].sample(8).join)
  FileUtils.mkdir_p @dir
  Dir.chdir @dir
end

Dado("arquivo {string} com o seguinte conteúdo:") do |arquivo, string|
  File.open(arquivo, 'w'){|f| f.write string}
end

Quando("executar limarka {string}") do |string|
  @params = (string + " -t "+ @modelo_dir).parse_csv(:col_sep =>" ")
  Limarka::Cli.start(@params)
end

Então("o arquivo tex gerado contém {string}") do |string|
  expect(Limarka::Cli.cv.texto_tex).to include(string)
end

Então("o arquivo tex gerado não contém {string}") do |string|
  expect(Limarka::Cli.cv.texto_tex).not_to include(string)
end

Dado("adiciona-se em configuracao.yaml:") do |string|
  toMerge = YAML.load(string)
  configuracao = YAML::load_file('configuracao.yaml')
  configuracao.merge! toMerge
  File.open('configuracao.yaml', 'w'){|f| f.write(configuracao.to_yaml + "\n\n---")}
end

Dado("arquivo configuracao.yaml com configuração padrão") do
  FileUtils.cp_r File.join(@inicio, "spec/configuracao_padrao/configuracao.yaml"),'.'
end
