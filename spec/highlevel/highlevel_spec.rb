describe PeoplesoftScraper do
    it 'can retrieve student marks' do
        marks = PeoplesoftScraper.retrieve(ENV['STUDENT_NUMBER'])
        puts marks.inspect
    end
end
