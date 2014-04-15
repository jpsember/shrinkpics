require 'rake'

Gem::Specification.new do |s|
  s.name        = 'shrinkpics'
  s.version     = '0.0.0'
  s.date        = '2014-04-14'
  s.summary     = "Wrapper for OSX sips utility to uniformly scale directories of images"
  s.description = "Shrinks images, preserving aspect ratio, so their maximum dimension is bounded; creates backups of originals"
  s.authors     = ["Jeff Sember"]
  s.email       = 'jpsember@gmail.com'
  s.files = FileList['lib/**/*.rb',
                      'bin/*',
                      '[A-Z]*',
                      'test/**/*',
                      ]
  s.executables << s.name
  s.add_runtime_dependency 'js_base'
  s.add_runtime_dependency 'backup_set'
  s.homepage = 'http://www.cs.ubc.ca/~jpsember'
  s.test_files  = Dir.glob('test/*.rb')
  s.license     = 'MIT'
end

