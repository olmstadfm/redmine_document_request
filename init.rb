# -*- coding: utf-8 -*-
Redmine::Plugin.register :redmine_document_request do
  name 'Document Request'
  author 'antonovgks'
  description 'Запрос на документы.'
  version '0.0.1'
  url 'https://bitbucket.org/gorkapstroy/redmine_document_request'
  author_url 'https://project.u-k-s.ru/people/479'

  settings :partial => 'document_request/settings'

  Redmine::MenuManager.map :top_menu do |menu| 

    unless menu.exists?(:internal_intercourse)
      menu.push(:internal_intercourse, "#", 
                { :after => :public_intercourse,
                  :parent => :top_menu, 
                  :caption => :label_internal_intercourse_menu
                })
    end

    menu.push( :document_request, {:controller => :document_request, :action => :new}, 
               { :parent => :internal_intercourse,            
                 :caption => :document_request,
                 :if => Proc.new{User.current.logged?}
               })

  end

  project_module :document_request do 
    permission :view_document_request, {:document_request => :index}
  end

end

Rails.configuration.to_prepare do

  [:enabled_module, :issue_category].each do |cl|
    require "document_request_#{cl}_patch"
  end

  require_dependency 'issue_category'

  [
   [EnabledModule, DocumentRequestPlugin::EnabledModulePatch],
   [IssueCategory, DocumentRequestPlugin::IssueCategoryPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end

end

