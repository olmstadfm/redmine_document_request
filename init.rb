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

    project_module :document_request do 
      permission :create_document_request, {:document_request => :index}
    end

    parent = menu.exists?(:internal_intercourse) ? :internal_intercourse : :top_menu
    menu.push( :document_request, {:controller => :document_request, :action => :new}, 
               { :parent => parent,            
                 :caption => :document_request,
                 :if => Proc.new{ false }
               })

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

