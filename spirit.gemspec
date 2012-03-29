Gem::Specification.new do |s|
  s.name              = "spirit"
  s.version           = "0.0.1"
  s.summary           = "Spirit - Modern era representations"
  s.description       = ""
  s.authors           = ["elcuervo"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/spirit"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("net-http-pool")

  s.add_development_dependency("cutest", "~> 1.1.3")
  s.add_development_dependency("capybara", "~> 1.1.2")
  s.add_development_dependency("mock-server", "~> 0.1.2")
end
