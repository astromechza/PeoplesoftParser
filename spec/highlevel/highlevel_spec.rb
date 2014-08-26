describe PeoplesoftParser do
    it 'can retrieve student marks' do
        marks = PeoplesoftParser.new.retrieve('ODNSIO001')
    end
end
