# frozen_string_literal: true

require_relative "lib/logger/version"

Gem::Specification.new do |spec|
  spec.name = "aws-app-logger"
  spec.version = Aws::App::Logger::VERSION
  spec.authors = ["Ryan Alyn Porter"]
  spec.email = ["rap@endymion.com"]

  spec.summary = "Emit log messages the way you normally do from Ruby, but leverage the power of AWS CloudWatch, with metrics, alerts, Log Insights, visualization, and more."
  spec.description = "Emit log messages the way you normally do from Ruby, but leverage the power of AWS CloudWatch, with metrics, alerts, Log Insights, visualization, and more."
  
  spec.homepage = "https://github.com/VenueDriver/aws-app-logger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'pry', '~> 0.14.1'
  spec.add_dependency 'byebug', '~> 11.1', '>= 11.1.3'
  spec.add_dependency 'rainbow', '~> 3.1', '>= 3.1.1'
  spec.add_dependency 'awesome_print', '1.9.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
