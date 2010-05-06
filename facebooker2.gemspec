spec = Gem::Specification.new do |s|
  s.name = 'facebooker2'
  s.version = '0.0.2'
  s.summary = "Facebook Connect integration library for ruby and rails"
  s.description = "Facebook Connect integration library for ruby and rails"
  s.files = Dir['lib/**/*.rb']
  s.require_path = 'lib'
  s.has_rdoc = false
  s.author = "Mike Mangino"
  s.email = "mmangino@elevatedrails.com"
  s.homepage = "http://developers.facebook.com/docs/api"
  s.add_dependency('mogli', ">=0.0.4")
end
