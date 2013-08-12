# -*- coding: utf-8 -*-
require_dependency 'enabled_module'
require_dependency 'issue_custom_field'
require_dependency 'setting'

module DocumentRequestPlugin
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method_chain :new, :document_request_processing

      end

    end

    module ClassMethods
    end

    module InstanceMethods

      private

      def new_with_document_request_processing

        # new_without_document_request_processing


        # @project_id = Setting[:plugin_redmine_document_request][:project_id]
        # @assigned_to_id = Setting[:plugin_redmine_document_request][:assigned_to_id]
        # @tracker_id = Setting[:plugin_redmine_document_request][:tracker_id]
        
        # document_for_field_id = Setting[:plugin_redmine_document_request][:document_for_field_id].to_i


        # @issue = Issue.new({
        #                      tracker_id: @tracker_id,
        #                      project_id: @project_id,
        #                      is_private: 1,
        #                      subject: l(:field_value_document_request_subject),
        #                      due_date: due_date_calc,
        #                      assigned_to_id:@assigned_to_id


      end


    end
  end
end
