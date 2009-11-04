require 'action_controller'
require File.dirname(__FILE__) + '/test_helper'
require 'shoulda/rails'
require File.dirname(__FILE__) + '/../init.rb'

RAILS_ROOT = File.dirname(__FILE__)

class WkhtmltopdfTestController < ActionController::Base
  def test_source
    respond_to do |format|
      format.pdf do
        render_to_pdf({
          :pdf       => "source", 
          :file_path => File.join(File.dirname(__FILE__), 'pdfs'), 
          :source    => "http://www.google.com/"
        })
      end
    end
  end
  
  def test_source_with_delete
    respond_to do |format|
      format.pdf do
        render_to_pdf({
          :pdf       => "source", 
          :file_path => File.join(File.dirname(__FILE__), 'pdfs'), 
          :source    => "http://www.google.com/",
          :delete_generated_pdf  => true
        })
      end
    end
  end
  
  def test_html
    respond_to do |format|
      format.pdf do
        render_to_pdf({
          :pdf                   => "html", 
          :file_path             => File.join(File.dirname(__FILE__), 'pdfs'), 
          :template              => File.join(File.dirname(__FILE__), 'fixtures', 'wkhtmltopdf.html')
        })
      end
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :pdfs,
    :controller => 'wkhtmltopdf_test',
    :collection => [:test_source, :test_source_with_delete, :test_html]
end

class WkhtmltopdfTestControllerTest < ActionController::TestCase
  
  context "on GET to pdf from a source" do
    setup do
      get :test_source, :format => "pdf"
    end
    
    subject { @controller }
    
    should_respond_with :success
    should_respond_with_content_type "application/pdf"
  end
  
  context "on GET to pdf with deleting the pdf after generation" do
    setup do
      get :test_source_with_delete, :format => "pdf"
    end
    
    subject { @controller }
    
    should_respond_with :success
    should_respond_with_content_type "application/pdf"
    
    should "delete the pdf after sending the file" do
      assert !File.exists?(File.join(File.dirname(__FILE__), 'pdfs', 'source.pdf'))
    end
  end
  
  context "on GET to pdf from a template" do
    setup do
      get :test_html, :format => "pdf"
    end
    
    subject { @controller }
    
    should_respond_with :success
    should_respond_with_content_type "application/pdf"
  end
  
end
