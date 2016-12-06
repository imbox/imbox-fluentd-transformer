# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "imbox-fluentd-transformer"
  s.version = "1.0"
  s.author = "ImBox"
  s.homepage = "https://github.com/imbox/imbox-fluentd-transformer"
  s.summary = "parses JSON and puts entries as we need them"
  s.description = s.summary
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency "fluentd"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
end