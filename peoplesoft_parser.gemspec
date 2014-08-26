Gem::Specification.new do |s|
    s.name        = 'peoplesoft_parser'
    s.version     = '0.1'
    s.date        = '2014-08-26'
    s.summary     = 'Download publically accessible information from UCT peoplesoft.'
    s.description = 'Download publically accessible information from UCT peoplesoft.'
    s.authors     = ['Ben Meier']
    s.email       = 'benmeier42@gmail.com'
    s.files       = ['lib/peoplesoft_parser.rb']
    s.license     = 'MIT'
    s.executables = []
    s.require_paths = ['lib']
    s.required_ruby_version     = '>= 2.1.0'
    s.homepage = 'http://github.com/AstromechZA/PeoplesoftParser'

    s.add_development_dependency 'rspec'
end
