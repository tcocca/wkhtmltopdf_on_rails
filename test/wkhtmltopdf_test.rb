require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/wkhtmltopdf'

include WkhtmltopdfHelper

class WkhtmltopdfTest < Test::Unit::TestCase
  
  context "new wkhtmltopdf with a source url" do
    setup do
      @options = valid_pdf_source_attributes
      @pdf = Wkhtmltopdf.new(@options)
    end
    
    subject { @pdf }
    
    should "set the instance methods on instantiation" do
      assert_equal @options[:source], @pdf.source
      assert_equal File.join(File.dirname(__FILE__), 'pdfs', 'wkhtmltopdf_test.pdf'), @pdf.pdf_file
      assert_nil @pdf.html_file
      assert_nil @pdf.optional_params
    end
    
    should "set the params_string" do
      assert_equal "", @pdf.params_string
    end
    
    should "create the pdf" do
      @pdf.generate
      assert File.exists?(@pdf.pdf_file)
      remove_pdf_after_generation(@pdf)
    end
  end
  
  context "new wkhtmltopdf with a local html file" do
    setup do
      @options = valid_pdf_html_attributes
      @pdf = Wkhtmltopdf.new(@options)
    end
    
    subject { @pdf }
    
    should "set the instance methods on instantiation" do
      assert_equal File.join(File.dirname(__FILE__), 'fixtures', 'wkhtmltopdf.html'), @pdf.html_file
      assert_equal File.join(File.dirname(__FILE__), 'pdfs', 'wkhtmltopdf_test.pdf'), @pdf.pdf_file
      assert_nil @pdf.source
      assert_nil @pdf.optional_params
    end
    
    should "set the params_string" do
      assert_equal "", @pdf.params_string
    end
    
    should "create the pdf" do
      @pdf.generate
      assert File.exists?(@pdf.pdf_file)
      remove_pdf_after_generation(@pdf)
    end
  end
  
  context "with optional params" do
    setup do
      @options = valid_pdf_source_attributes
      @optional_params = {
          :wkhtmltopdf_options => {
            "footer-line" => true,
            "footer-center" => "[page] / [toPage]",
          }
        }
      @pdf = Wkhtmltopdf.new(@options.merge(@optional_params))
    end
    
    subject { @pdf }
    
    should "set the instance methods on instantiation" do
      assert_equal @options[:source], @pdf.source
      assert_equal File.join(File.dirname(__FILE__), 'pdfs', 'wkhtmltopdf_test.pdf'), @pdf.pdf_file
      assert_nil @pdf.html_file
      assert_not_nil @pdf.optional_params
      assert_equal @optional_params[:wkhtmltopdf_options], @pdf.optional_params
    end
    
    should "set the params_string" do
      assert_not_nil @pdf.params_string
      assert_match /--footer-line/, @pdf.params_string
      assert_match /--footer-center '\[page\] \/ \[toPage\]'/, @pdf.params_string
    end
    
    should "create the pdf" do
      @pdf.generate
      assert File.exists?(@pdf.pdf_file)
      remove_pdf_after_generation(@pdf)
    end
    
    context "with symbol keys for optional params" do
      setup do
        @options = valid_pdf_source_attributes
        @optional_params = {
          :wkhtmltopdf_options => {
            "footer-line" => true,
            "footer-center" => "[page] / [toPage]",
            :lowquality  => true,
            :'print-media-type'  => true
          }
        }
        @pdf = Wkhtmltopdf.new(@options.merge(@optional_params))
      end
      
      subject { @pdf }
      
      should "set the params_string" do
        assert_not_nil @pdf.params_string
        assert_match /--footer-line/, @pdf.params_string
        assert_match /--footer-center '\[page\] \/ \[toPage\]'/, @pdf.params_string
        assert_match /--lowquality/, @pdf.params_string
        assert_match /--print-media-type/, @pdf.params_string
      end
    end
    
    
    context "with false values for optional params" do
      setup do
        @options = valid_pdf_source_attributes
        @optional_params = {
          :wkhtmltopdf_options => {
            "footer-line" => false,
            :lowquality  => false,
            :'print-media-type'  => false
          }
        }
        @pdf = Wkhtmltopdf.new(@options.merge(@optional_params))
      end
      
      subject { @pdf }
      
      should "set the params_string" do
        assert_equal "", @pdf.params_string
      end
    end
  end
  
  def remove_pdf_after_generation(pdf)
    File.delete(pdf.pdf_file) if File.exists?(pdf.pdf_file)
  end
  
end
