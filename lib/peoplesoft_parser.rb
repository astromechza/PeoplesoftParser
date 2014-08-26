require 'net/http'
require 'nokogiri'

class PeoplesoftParser

    PEOPLESOFT_URI = URI 'https://srvslspsw001.uct.ac.za/psp/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL?FolderPath=PORTAL_ROOT_OBJECT.UCT_SS_ADV_PUBLIC_GBL_1&IsFolder=false&IgnoreParamTempl=FolderPath%252cIsFolder'
    REDIRECT_LIMIT = 10

    def initialize
        @cookies = ''
    end

    def retrieve(student_number)
        Net::HTTP.start(PEOPLESOFT_URI.host, PEOPLESOFT_URI.port, use_ssl: PEOPLESOFT_URI.scheme == 'https') do |http|

            response = follow_get(http, PEOPLESOFT_URI)

            response = follow_get(http, URI('https://srvslspsw001.uct.ac.za/psc/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL?FolderPath=PORTAL_ROOT_OBJECT.UCT_SS_ADV_PUBLIC_GBL_1&IsFolder=false&IgnoreParamTempl=FolderPath%252cIsFolder&PortalActualURL=https%3a%2f%2fsrvslspsw001.uct.ac.za%2fpsc%2fpublic%2fEMPLOYEE%2fHRMS%2fc%2fUCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL&PortalContentURL=https%3a%2f%2fsrvslspsw001.uct.ac.za%2fpsc%2fpublic%2fEMPLOYEE%2fHRMS%2fc%2fUCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL&PortalContentProvider=HRMS&PortalCRefLabel=Public%20Access&PortalRegistryName=EMPLOYEE&PortalServletURI=https%3a%2f%2fsrvslspsw001.uct.ac.za%2fpsp%2fpublic%2f&PortalURI=https%3a%2f%2fsrvslspsw001.uct.ac.za%2fpsc%2fpublic%2f&PortalHostNode=HRMS&NoCrumbs=yes&PortalKeyStruct=yes'))

            doc = Nokogiri::HTML(response.body)

            icsid = doc.css('#ICSID').attr('value')

            response = http.request_post(URI('https://srvslspsw001.uct.ac.za/psc/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL'), construct_post_data(student_number, icsid), {'Cookie' => @cookies})

            doc = Nokogiri::HTML(response.body)

            rows = doc.xpath("//table[@id='TERM_CLASSES$scroll$0']/tr/td/table/tr[position()>1]")

            rows.each do |r|
                puts r.css('span').map { |s| s.content }
            end

            open('dump3.txt', "w") { |io| io.write(response.body) }

        end
    end

    private

        def follow_get(http, uri, limit = REDIRECT_LIMIT)
            raise ArgumentError('too many HTTP redirects') if limit == 0

            response = http.request_get(uri, {'Cookie' => @cookies})

            if response.to_hash.include? 'set-cookie'
                @cookies = response.get_fields('set-cookie').map { |c| c.split('; ')[0] }.join('; ')
            end

            case response
            when Net::HTTPSuccess then
                response
            when Net::HTTPRedirection then
                follow_get(http, URI(response['location']), limit - 1)
            else
                response.value
            end
        end

        def construct_post_data(sn, sid)
            "ICAJAX=1&ICNAVTYPEDROPDOWN=0&ICType=Panel&ICElementNum=0&ICStateNum=1&ICAction=UCT_DERIVED_PUB_SS_DERIVED_LINK&ICXPos=0&ICYPos=0&ResponsetoDiffFrame=-1&TargetFrameName=None&FacetPath=None&ICFocus=&ICSaveWarningFilter=0&ICChanged=-1&ICResubmit=0&ICSID=#{sid}&ICActionPrompt=false&ICFind=&ICAddCount=&ICAPPCLSDATA=&UCT_DERIVED_PUB_CAMPUS_ID=#{sn}&UCT_DERIVED_PUB_UCT_DERIVED_LINK6=GI"
        end

end
