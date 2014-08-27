require 'net/http'
require 'mechanize'
require 'logger'

class PeoplesoftParser

    def initialize
    end

    def retrieve(student_number)
        m = Mechanize.new
        m.get('https://srvslspsw001.uct.ac.za/psc/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL') do |page|

            open('dump_1.txt', 'w') { |io| io.write(page.body) }

            form = page.form(name: 'win0')
            form.UCT_DERIVED_PUB_CAMPUS_ID = student_number
            form.UCT_DERIVED_PUB_UCT_DERIVED_LINK6 = 'GI'
            form.ICAction = 'UCT_DERIVED_PUB_SS_DERIVED_LINK'
            page = m.submit(form)

            if page.body.include? 'No student record found for this Campus ID'
                return nil
            end

            term_links = page.links_with(id: 'DERIVED_SSS_SCT_SSS_TERM_LINK')
            unless term_links.empty?
                form = page.form(name: 'win0')
                form.ICAction = 'DERIVED_SSS_SCT_SSS_TERM_LINK'
                page = m.submit(form)
            end

            dataset = {
                student_number: student_number.upcase,
                student_name: page.search("//span[@id='DERIVED_SCC_SUM_PERSON_NAME$5$']")[0].content,
                terms: []
            }

            terms = page.search("//table[@id='SSR_DUMMY_RECV1$scroll$0']/tr[position()>2]")
            terms.each_with_index do |t, i|
                year, career, institution = t.xpath(".//span")[0..2].map { |s| nonbsp(s.content).strip  }

                term_dataset = {
                    year: year,
                    career: career,
                    institution: institution,
                    results: []
                }

                form = page.form(name: 'win0')
                form.ICAction = 'DERIVED_SSS_SCT_SSR_PB_GO'
                form.radiobuttons[i].check
                page = m.submit(form)

                courses = page.search("//table[@id='TERM_CLASSES$scroll$0']/tr/td/table/tr[position()>1]")

                courses.each do |c|
                    course_name, description, units, grading, grade, points = c.xpath(".//span")[0..5].map { |s| nonbsp(s.content).strip  }

                    points = nil if points == ""
                    grade = nil if grade == ""
                    units = nil if units == ""

                    term_dataset[:results] << {
                        course: course_name,
                        description: description,
                        units: units,
                        grading: grading,
                        points: points
                    }
                end

                dataset[:terms] << term_dataset

                unless page.links_with(id: 'DERIVED_SSS_SCT_SSS_TERM_LINK').empty?
                    form = page.form(name: 'win0')
                    form.ICAction = 'DERIVED_SSS_SCT_SSS_TERM_LINK'
                    page = m.submit(form)
                end
            end

            return dataset
        end
    end

    private

        def nonbsp(str)
            nbsp = Nokogiri::HTML("&nbsp;").text
            str.gsub(nbsp,'')
        end

end
