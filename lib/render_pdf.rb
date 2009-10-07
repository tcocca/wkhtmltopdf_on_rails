module RenderPdf
  
  def render_to_pdf(options = {})
    make_pdf(options)
    pdf_file_name = "#{options[:file_path]}/#{options[:pdf]}.pdf"
    send_pdf_options = {
      :filename => "#{options[:pdf]}.pdf",
      :type     => 'application/pdf'
    }
    if options[:delete_generated_pdf]
      send_pdf_options[:stream] = false
    end
    
    send_file(pdf_file_name, send_pdf_options)
    
    if options[:delete_generated_pdf] && File.exists?(pdf_file_name)
      File.delete(pdf_file_name)
    end
  end
  
  private
  
  def make_pdf(options)
    if options.has_key?(:template)
      html_string = generate_html(options)
      timestamp = Time.now.strftime("%y%m%d%H%M%S")
      html_file_name = "#{timestamp}_#{options[:pdf]}.html"
      html_file_path = File.join(RAILS_ROOT, 'tmp', html_file_name)
      File.open(html_file_path, 'w') do |f|
        f.write(html_string)
      end
      options[:html_file] = html_file_path
    end
    
    pdf = Wkhtmltopdf.new(options)
    pdf.generate

    if html_file_path.present? && File.exists?(html_file_path)
      File.delete(html_file_path)
    end
  end
  
  def generate_html(options)
    render_options = {}
    render_options[:template] = options.delete(:template)
    render_options[:layout] = options.delete(:layout) if options.has_key?(:layout)
    
    html_string = render_to_string(render_options)
    
    # re-route absolute paths for images, scripts and stylesheets
    html_string.gsub!( /src=["']+([^:]+?)["']/i ) { |m| "src=\"#{RAILS_ROOT}/public/" + $1 + '"' }
    html_string.gsub!( /<link href=["']+([^:]+?)["']/i ) { |m| "<link href=\"#{RAILS_ROOT}/public/" + $1 + '"' }
    
    # Remove asset ids on images, scripts, and stylesheets with a regex
    html_string.gsub!( /src=["'](\S+\?\d*)["']/i ) { |m| 'src="' + $1.split('?').first + '"' }
    html_string.gsub!( /<link href=["'](\S+\?\d*)["']/i ) { |m| '<link href="' + $1.split('?').first + '"' }
    
    return html_string
  end
  
end

