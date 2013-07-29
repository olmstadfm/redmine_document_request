Redmine::Plugin.register :redmine_document_request do
  name 'Redmine Document Request plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  # settings :partial => 'document_request/settings'

  menu :top_menu, :document_request,
    {:controller => :document_request, :action => :index},
    :caption => :document_request

  project_module :document_request do 
    permission :view_document_request, {:document_request => :index}
  end


end

Rails.configuration.to_prepare do

  [:enabled_module].each do |cl|
    require "document_request_#{cl}_patch"
  end

  [
   [EnabledModule, DocumentRequestPlugin::EnabledModulePatch],
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end

end

