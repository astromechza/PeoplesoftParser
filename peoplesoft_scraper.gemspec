Gem::Specification.new do |s|
    s.name        = 'peoplesoft_scraper'
    s.version     = '0.1'
    s.date        = '2014-08-26'
    s.summary     = 'Download publically accessible grade information from UCT peoplesoft.'
    s.description = 'Download publically accessible grade information from UCT peoplesoft.'
    s.authors     = ['Ben Meier']
    s.email       = 'benmeier42@gmail.com'
    s.files       = ['lib/peoplesoft_scraper.rb']
    s.license     = 'MIT'
    s.executables = ['peoplesoft_get']
    s.require_paths = ['lib']
    s.required_ruby_version     = '>= 2.1.0'
    s.homepage = 'http://github.com/AstromechZA/PeoplesoftParser'

    s.add_dependency 'trollop'
    s.add_dependency 'mechanize'

    s.add_development_dependency 'rspec'
    s.add_development_dependency 'rubocop'
end
