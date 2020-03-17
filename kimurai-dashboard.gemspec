
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kimurai/dashboard/version"

Gem::Specification.new do |spec|
  spec.name          = "kimurai-dashboard"
  spec.version       = Kimurai::Dashboard::VERSION
  spec.authors       = ["Victor Afanasev"]
  spec.email         = ["vicfreefly@gmail.com"]

  spec.summary       = "Simple dashboard for a Kimurai web scraping framework"
  spec.homepage      = "https://github.com/vifreefly/kimurai-dashboard"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "kimurai", ">= 1.3.0"
  spec.add_dependency "sequel"
  spec.add_dependency "sinatra-contrib"
  spec.add_dependency "pagy", "~> 3.5"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
