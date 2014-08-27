require 'net/http'
require 'mechanize'

# PeoplesoftScraper provides the .retrieve method in order to retrieve the
# marks for any UCT student.
module PeoplesoftScraper
    module_function

    # url of peoplesoft public access page
    PUBLIC_ACCESS_URL = 'https://srvslspsw001.uct.ac.za/psc/public/EMPLOYEE/HRMS/c/UCT_PUBLIC_MENU.UCT_SS_ADV_PUBLIC.GBL'

    # nbsp; token for replacing
    NBSP = Nokogiri::HTML('&nbsp;').text

    # Retrieve the marks for the given student number
    # * +student_number+ - The student number (eg: CCCAAA001 )
    #
    # The result is a hash of the form: {
    #     student_number: <student_number>,
    #     student_name: <student_name>,
    #     terms: [
    #         {
    #             year: <year>,
    #             career: <career eg: Undergrad>,
    #             institution: University of Cape Town,
    #             results: [
    #                 {
    #                     course: <course code>,
    #                     description: <course name>,
    #                     units: <course credits>,
    #                     grading: <grading status>,
    #                     grade: <mark for course>
    #                 }
    #                 ...
    #             ]
    #         }
    #         ...
    #     ]
    # }
    #
    # If the student number doesn't match any student a NameError is thrown.
    #
    def retrieve(student_number)
        # validation
        if student_number.nil? or student_number.strip == ''
            fail ArgumentError, "student_number can't be blank"
        end

        # sanitize
        student_number = student_number.strip.upcase

        m = Mechanize.new
        m.get(PUBLIC_ACCESS_URL) do |page|

            form = page.form(name: 'win0')
            form.UCT_DERIVED_PUB_CAMPUS_ID = student_number
            form.UCT_DERIVED_PUB_UCT_DERIVED_LINK6 = 'GI'
            form.ICAction = 'UCT_DERIVED_PUB_SS_DERIVED_LINK'
            page = m.submit(form)

            if page.body.include? 'No student record found for this Campus ID'
                fail NameError.new('No student record found for ' + student_number, student_number)
            end

            term_links = page.links_with(id: 'DERIVED_SSS_SCT_SSS_TERM_LINK')
            unless term_links.empty?
                form = page.form(name: 'win0')
                form.ICAction = 'DERIVED_SSS_SCT_SSS_TERM_LINK'
                page = m.submit(form)
            end

            dataset = {
                student_number: student_number,
                student_name: page.search("//span[@id='DERIVED_SCC_SUM_PERSON_NAME$5$']")[0].content,
                terms: []
            }

            terms = page.search("//table[@id='SSR_DUMMY_RECV1$scroll$0']/tr[position()>2]")
            terms.each_with_index do |t, i|
                year, career, institution = t.xpath('.//span')[0..2].map do |s|
                    s.content.gsub(NBSP, ' ').strip
                end

                term_dataset = {
                    year: year.to_i,
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
                    course_name, description, units, grading, grade = c.xpath('.//span')[0..4].map do |s|
                        s.content.gsub(NBSP, ' ').strip
                    end

                    grade = (grade == '') ? nil : grade.to_f
                    units = (units == '') ? nil : units.to_f

                    term_dataset[:results] << {
                        course: course_name,
                        description: description,
                        units: units,
                        grading: grading,
                        grade: grade
                    }
                end

                dataset[:terms] << term_dataset

                if page.links_with(id: 'DERIVED_SSS_SCT_SSS_TERM_LINK').empty?
                    fail IOError, 'Form logic failed (no route to terms page)'
                end

                form = page.form(name: 'win0')
                form.ICAction = 'DERIVED_SSS_SCT_SSS_TERM_LINK'
                page = m.submit(form)
            end

            return dataset
        end
    end
end
