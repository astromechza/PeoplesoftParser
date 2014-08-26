describe PeoplesoftParser do
    it 'can retrieve student marks' do
        marks = PeoplesoftParser.new.retrieve('ODNSIO001')
        puts marks
        expect(1).to eq(2)
    end
end
