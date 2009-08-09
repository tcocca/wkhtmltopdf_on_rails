module RenderPdf
  
  def render_to_pdf(options = {})
    make_pdf(options)
    pdf_file_name = "#{options[:file_path]}/#{options[:pdf]}.pdf"
    send_pdf_options = {
      :filename => "#{options[:pdf]}.pdf",
      :type     => 'application/pdf'
    }
    if options[:delete_generated_pdf]
      send_file(
        pdf_file_name,
        send_pdf_options.merge({:stream => false})
      )
      File.delete(pdf_file_name) if File.exists?(pdf_file_name)
    else
      send_file(
        pdf_file_name,
        send_pdf_options
      )
    end
  end
  
  private
  
  def make_pdf(options)
    if options.has_key?(:source)
      system "wkhtmltopdf #{options[:source]} #{options[:file_path]}/#{options[:pdf]}.pdf"
    else
      html_string = generate_html(options)
      timestamp = Time.now.strftime("%y%m%d%H%M%S")
      html_file_name = "#{timestamp}_#{options[:pdf]}.html"
      html_file_path = File.join(RAILS_ROOT, 'tmp', html_file_name)
      File.open(html_file_path, 'w') do |f|
        f.write(html_string)
      end
      system "wkhtmltopdf #{html_file_path} #{options[:file_path]}/#{options[:pdf]}.pdf"
      File.delete(html_file_path) if File.exists?(html_file_path)
    end
  end
  
  def generate_html(options)
    render_options = {}
    render_options[:template] = options[:template]
    render_options[:layout] = options[:layout] if options.has_key?(:layout)
    
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

