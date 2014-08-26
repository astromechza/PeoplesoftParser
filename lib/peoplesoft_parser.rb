require 'net/http'
require 'nokogiri'

class PeoplesoftParser

    REDIRECT_LIMIT = 10

    NOT_FOUND_TEXT = 'No student record found for this Campus ID'
    FAIL_TEXT = "It's now at <a href=\"https://srvslspsw001.uct.ac.za/psc/public/EMPLOYEE/HRMS/c/?cmd=logout\""

    PAGE_PATH = '/psc/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL'

    def initialize
        @cookies = ''
    end

    def retrieve(student_number)
        Net::HTTP.start('srvslspsw001.uct.ac.za', use_ssl: true) do |http|

            response = follow_get(http, PAGE_PATH)

            doc = Nokogiri::HTML(response.body)

            icsid = doc.css('#ICSID').attr('value')

            response = http.request_post(PAGE_PATH, construct_post_data(student_number, icsid), {'Cookie' => @cookies})

            if response.body.include? FAIL_TEXT
                raise 'Failed. Please retry.'
            elsif response.body.include? NOT_FOUND_TEXT
                return nil
            else
                doc = Nokogiri::HTML(response.body)
                rows = doc.xpath("//table[@id='TERM_CLASSES$scroll$0']/tr/td/table/tr[position()>1]")

                return rows.map { |r| construct_course_model(r.css('span'))  }
            end
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

        def construct_course_model(span_array)
            {
                course: span_array[0].content,
                description: span_array[1].content,
                units: span_array[2].content,
                grading: span_array[3].content,
                grade: span_array[4].content,
                points: span_array[5].content
            }
        end

        def construct_post_data(student_number, sid)
            """
            Construct the data string that will be POSTED to complete the form.
            This must contain the ID from the previous page, and the student_number
            to lookup.
            """
            URI.encode_www_form({
                'ICAJAX' => 1,
                'ICNAVTYPEDROPDOWN' => 0,
                'ICType' => 'Panel',
                'ICElementNum' => 0,
                'ICStateNum' => 1,
                'ICAction' => 'UCT_DERIVED_PUB_SS_DERIVED_LINK',
                'ICXPos' => 0,
                'ICYPos' => 0,
                'ResponsetoDiffFrame' => -1,
                'TargetFrameName' => 'None',
                'FacetPath' => 'None',
                'ICFocus' => '',
                'ICSaveWarningFilter' => '',
                'ICChanged' => -1,
                'ICResubmit' => 0,
                'ICActionPrompt' => false,
                'ICFind' => '',
                'ICAddCount' => '',
                'ICAPPCLSDATA' => '',
                'UCT_DERIVED_PUB_UCT_DERIVED_LINK6' => 'GI',
                'UCT_DERIVED_PUB_CAMPUS_ID' => student_number.upcase,
                'ICSID' => sid
            })
        end

end
