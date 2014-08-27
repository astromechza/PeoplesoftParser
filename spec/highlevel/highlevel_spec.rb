describe PeoplesoftScraper do
    it 'can retrieve student marks' do
        marks = PeoplesoftScraper.retrieve('MRXBRU000')
        puts marks.inspect
    end
end
