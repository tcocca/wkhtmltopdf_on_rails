require 'render_pdf'

Mime::Type.register 'application/pdf', :pdf

ActionController::Base.send(:include, RenderPdf)

