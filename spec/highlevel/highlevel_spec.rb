describe PeoplesoftScraper do
    it 'can retrieve student marks' do
        marks = PeoplesoftScraper.retrieve('MRXBRU001')
        puts marks.inspect
        expect(1).to eq(2)
    end
end
