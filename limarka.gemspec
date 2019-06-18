# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'limarka/version'

IS_TAGGED = ENV['TRAVIS_TAG'] == "v#{Limarka::VERSION}"
IS_ORIGIN = ENV['TRAVIS_REPO_SLUG'] == 'abntex/limarka'
BUILD_NUMBER = ENV['TRAVIS_BUILD_NUMBER']

Gem::Specification.new do |spec|
  spec.name          = "limarka"
  spec.version       = if BUILD_NUMBER && IS_ORIGIN && !IS_TAGGED
    # Prereleasing on Travis CI
    Limarka::VERSION + ".pre.#{BUILD_NUMBER}"
  else
    Limarka::VERSION
  end
  spec.authors       = ["Eduardo de Santana Medeiros Alexandre"]
  spec.email         = ["eduardo.ufpb@gmail.com"]
  spec.summary       = %q{Ferramenta para compilação de trabalhos acadêmicos com markdown e abnTeX2}
  spec.description   = %q{Com essa ferramenta você poderá escrever sua monografia, dissertação ou tese utilizando Markdown (linguagem mais simples que Latex).}
  spec.homepage      = "https://github.com/abntex/limarka"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  #spec.requirements = 'pandoc, v1.19.1'
  spec.post_install_message = 'Gostou do limarka? Considere contribuir com o projeto: https://opencollective.com/limarka/donate'

# essas são as ferramentas de desenvolvimento
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "github_changelog_generator"

  spec.add_dependency "clipboard"
  spec.add_dependency "ffi"
  spec.add_dependency "colorize"
  spec.add_dependency "pdf-forms", "~> 1.2"
  spec.add_dependency "pandoc-ruby"
  spec.add_dependency "thor"
  spec.add_dependency 'bibtex-ruby'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'pandoc_abnt', "~> 2.0.0"
  spec.add_dependency 'guard'
  spec.add_dependency 'guard-shell'
end
