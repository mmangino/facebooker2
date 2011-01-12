spec = Gem::Specification.new do |s|
  s.name = 'facebooker2'
  s.version = '0.0.7'
  s.summary = "Facebook Connect integration library for ruby and rails"
  s.description = "Facebook Connect integration library for ruby and rails"
  s.files = Dir['lib/**/*.rb']
  s.require_path = 'lib'
  s.has_rdoc = false
  s.author = "Mike Mangino"
  s.email = "mmangino@elevatedrails.com"
  s.homepage = "http://developers.facebook.com/docs/api"
  s.add_dependency('mogli', ">=0.0.12")
  s.add_dependency('ruby-hmac')
end
