class Wkhtmltopdf
  
  attr_accessor :file_name, :file_path, :pdf_file, :html_file, :source, :optional_params, :params_string
  
  def initialize(options)
    @file_name = options[:pdf]
    @file_path = options[:file_path]
    @pdf_file = "#{@file_path}/#{@file_name}.pdf"
    @html_file = options[:html_file] if options.has_key?(:html_file)
    @source = options[:source] if options.has_key?(:source)
    @optional_params = options[:wkhtmltopdf_options] if options.has_key?(:wkhtmltopdf_options)
    create_params_string
  end
  
  def generate
    wkhtml_call = "wkhtmltopdf "
    if @source.present?
      puts "source"
      wkhtml_call << "#{@source}"
    else
      puts "local html"
      wkhtml_call << "#{@html_file}"
    end
    wkhtml_call << " #{pdf_file} #{@params_string}"
    system "#{wkhtml_call}"
  end
  
  private
  
  def create_params_string
    params_arr = []
    @optional_params.each do |key, val|
      if val && val.is_a?(String)
        params_arr << "--#{key.to_s} '#{val}'"
      elsif val
        params_arr << "--#{key.to_s}"
      end
    end
    @params_string = params_arr.join(' ')
  end
  
end
