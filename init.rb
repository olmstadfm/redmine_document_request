# -*- coding: utf-8 -*-
Redmine::Plugin.register :redmine_document_request do
  name 'Document Request plugin'
  author 'antonovgks'
  description 'Запрос на документы.'
  version '0.0.1'
  url 'https://bitbucket.org/gorkapstroy/redmine_document_request'
  author_url 'https://project.u-k-s.ru/people/479'

  settings :partial => 'document_request/settings'

  menu :top_menu, :document_request, {:controller => :document_request, :action => :new}, :caption => :document_request, :if => Proc.new{User.current.logged?}

  project_module :document_request do 
    permission :view_document_request, {:document_request => :index}
  end


end

Rails.configuration.to_prepare do

  [:enabled_module, :issues_controller].each do |cl|
    require "document_request_#{cl}_patch"
  end

  require_dependency 'issues_controller'

  [
   [EnabledModule, DocumentRequestPlugin::EnabledModulePatch],
   [IssuesController, DocumentRequestPlugin::IssuesControllerPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end

end

