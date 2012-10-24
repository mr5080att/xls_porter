Gem::Specification.new do |s|
  s.name        = 'xls_porter'
  s.version     = '0.0.9'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Export to and Import from XLS'
  s.description = 'Export to and Import from XLS for Ruby and Rails apps'
  s.authors     = ['Michael Reyes']
  s.platform    = Gem::Platform::RUBY
  s.email       = 'mikereyes.kg77@gmail.com'
  s.files       = ['lib/xls_porter.rb','lib/xls_porter/xls_uploader.rb']
  s.homepage    = 'http://rubygems.org/gems/xls_porter'
  s.add_runtime_dependency 'carrierwave'
  s.add_runtime_dependency 'sprockets'
  s.required_ruby_version = '>= 1.9.2'
  s.require_path = 'lib'
end
