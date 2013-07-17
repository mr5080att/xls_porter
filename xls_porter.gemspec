Gem::Specification.new do |s|
  s.name        = 'xls_porter'
  s.version     = '1.0'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Export to and Import from XLS'
  s.description = 'Export to and Import from XLS for Ruby and Rails apps'
  s.authors     = ['Michael Reyes']
  s.platform    = Gem::Platform::RUBY
  s.email       = 'mikereyes.kg77@gmail.com'
  s.files       = ['lib/xls_porter.rb','lib/xls_porter/xls_uploader.rb']
  s.homepage    = 'https://github.com/mr5080att/xls_porter'
  s.add_runtime_dependency 'carrierwave', '~>0.6.2'
  s.required_ruby_version = '>= 1.9.2'
  s.require_path = 'lib'
end
