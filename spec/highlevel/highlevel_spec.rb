describe PeoplesoftScraper do
    it 'can retrieve student marks' do
        marks = PeoplesoftScraper.retrieve('MRXBEN001')
        puts marks.inspect
    end
end
