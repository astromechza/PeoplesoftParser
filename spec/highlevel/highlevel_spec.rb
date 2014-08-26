describe PeoplesoftParser do
    it 'can retrieve student marks' do
        marks = PeoplesoftParser.new.retrieve('MRXBEN001')
        puts marks.inspect
        expect(1).to eq(2)
    end
end
