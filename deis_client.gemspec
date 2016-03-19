Gem::Specification.new do |s|
  s.name        = 'deis_client'
  s.version     = '1.5.2'
  s.date        = Date.today.to_s
  s.summary     = "Client library to communicate with a [Deis](http://deis.io/) Controller"
  s.description = "[Deis](http://deis.io/) is an open source application platform for public and private clouds.
  This gem makes it easy to communicate with a Deis controller programmatically
  via the [Deis controller api](http://docs.deis.io/en/latest/reference/api-v1.5/)"
  s.authors     = ["Franz Liedke", "Cornelius Bock"]
  s.files       = ["lib/deis_client.rb"]
  s.homepage    = 'https://github.com/franzliedke/deis-client'
  s.license     = 'MIT'
  s.add_runtime_dependency "httparty", ["~> 0.13"]
end
