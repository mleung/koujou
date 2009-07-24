# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{koujou}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Leung"]
  s.date = %q{2009-07-19}
  s.description = %q{Koujou is a fixture replacement that requires no effort to use. You don't have to define a single thing in your test_helper or whatever. Just call the koujou method on your active record model, and you're  off.   check out: http://www.michaelleung.us/koujou for all the juicy details.}
  s.email = ["me@michaelleung.us"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/koujou.rb", "lib/koujou/builder.rb", "lib/koujou/data_generator.rb", "lib/koujou/sequence.rb", "lib/koujou/validation_reflection.rb", "script/console", "script/destroy", "script/generate", "test/lib/active_record_test_connector.rb", "test/lib/models/comment.rb", "test/lib/models/post.rb", "test/lib/models/profile.rb", "test/lib/models/user.rb", "test/test_builder.rb", "test/test_data_generator.rb", "test/test_helper.rb", "test/test_kojo.rb", "test/test_sequence.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mleung/koujou}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{koujou}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Koujou is a fixture replacement that requires no effort to use}
  s.test_files = ["test/test_builder.rb", "test/test_data_generator.rb", "test/test_helper.rb", "test/test_kojo.rb", "test/test_sequence.rb"]
  s.add_dependency('faker', '>= 0.3.1')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
