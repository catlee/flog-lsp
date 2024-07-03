# frozen_string_literal: true

require_relative "lib/flog_lsp/version"

Gem::Specification.new do |spec|
  spec.name = "flog-lsp"
  spec.version = FlogLsp::VERSION
  spec.authors = ["Chris AtLee"]
  spec.email = ["chris@atlee.ca"]

  spec.summary = "LSP for providing flog metrics in the editor"
  spec.homepage = "https://github.com/catlee/flog-lsp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/catlee/flog-lsp/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("flog", "~> 4.8")
  spec.add_dependency("language_server-protocol", "~> 3.16")
  spec.add_dependency("sorbet-runtime", "~> 0.5")

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
