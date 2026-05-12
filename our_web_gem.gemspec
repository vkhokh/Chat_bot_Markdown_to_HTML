# frozen_string_literal: true

require_relative "lib/our_web_gem/version"

Gem::Specification.new do |spec|
  spec.name = "our_web_gem"
  spec.version = OurWebGem::VERSION
  spec.authors = ["DmitriyGul123"]
  spec.email = ["dimagulyakin177@gmail.com"]

  spec.summary = "Markdown to HTML renderer"
  spec.description = "Converts AST to HTML"
  spec.homepage = "https://example.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://example.com"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  excluded_file = lambda do |path|
    (path == gemspec) ||
      path.start_with?(*%w[.git/ bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
  end

  spec.files = begin
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls.readlines("\x0", chomp: true).reject { |path| excluded_file.call(path) }
    end
  rescue Errno::EACCES, Errno::ENOENT
    Dir.chdir(__dir__) do
      Dir.glob("**/*", File::FNM_DOTMATCH)
        .select { |path| File.file?(path) }
        .reject { |path| excluded_file.call(path) }
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
