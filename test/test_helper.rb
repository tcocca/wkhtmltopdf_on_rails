require 'rubygems'

#require 'action_controller/mime_types'
#require File.dirname(__FILE__) + '/../init.rb'

require File.dirname(__FILE__) + '/../lib/wkhtmltopdf'

require 'test/unit'
require 'shoulda'

module WkhtmltopdfHelper
  
  def valid_pdf_source_attributes
    {
      :pdf => 'wkhtmltopdf_test',
      :file_path => File.join(File.dirname(__FILE__), 'pdfs'),
      :source => "http://www.google.com/"
    }
  end
  
  def valid_pdf_html_attributes
    {
      :pdf => 'wkhtmltopdf_test',
      :file_path => File.join(File.dirname(__FILE__), 'pdfs'),
      :html_file => File.join(File.dirname(__FILE__), 'fixtures', 'wkhtmltopdf.html')
    }
  end
  
end

