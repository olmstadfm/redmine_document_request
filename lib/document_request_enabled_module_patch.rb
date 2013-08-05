# -*- coding: utf-8 -*-
require_dependency 'enabled_module'
require_dependency 'issue_custom_field'
require_dependency 'setting'

module DocumentRequestPlugin
  module EnabledModulePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        after_create :document_request_module_enabled
        before_destroy :document_request_module_disabled

      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def document_request_module_enabled
        if self.name == 'document_request'
          document_request_project_setup
          document_request_tracker_setup
          document_request_role_setup
          document_request_custom_fields_setup
          document_request_query_setup
        end
      end

      def document_request_module_disabled

        setting = Setting[:plugin_redmine_document_request]
        
        # here goes some stuff that will help erase module completly, if such necessity arises

        # IssueCustomField.all.map(&:destroy)

        # IssueQuery.all.map(&:destroy)

        # tracker = Tracker.find_by_name("Запрос на документы")
        # if tracker
        #   Issue.where(tracker_id: tracker.id).map(&:destroy) 
        #   tracker.destroy 
        # end

        # Member.all.map(&:destroy)

        # project = Project.find_by_name("Запрос на документы")
        # project.destroy if project

        # Setting[:plugin_redmine_document_request][:requester_role_id] = requester_role.id
        # Setting[:plugin_redmine_document_request][:executor_role_id] = executor_role.id
        # Setting[:plugin_redmine_document_request][:document_type_field_id] = document_type_field.id
        # Setting[:plugin_redmine_document_request][:document_for_field_id] = document_for_field.id
        # Setting[:plugin_redmine_document_request][:company_name_field_id] = company_name_field.id

        # Setting[:plugin_redmine_document_request][:per_type_query_id] = per_type_query.id
        # Setting[:plugin_redmine_document_request][:per_user_query_id] = per_user_query.id

      end

      private

      def document_request_project_setup
        @document_request_project = Project.find(self.project_id)
      end

      def document_request_tracker_setup
          @document_request_tracker = Tracker.find(Setting[:plugin_redmine_document_request][:tracker_id])

          @document_request_tracker.core_fields = [
                                                   "assigned_to_id", 
                                                   "category_id", 
                                                   "fixed_version_id", 
                                                   "parent_issue_id", 
                                                   "start_date", 
                                                   "due_date"
                                                  ]
          @document_request_tracker.save

          @document_request_project.trackers << @document_request_tracker
      end

      def document_request_role_setup
        hash_for_requester_role = { 
          name: "Запрашивающий документы",
          assignable: false, 
          builtin: 0,
          permissions: [
                        :view_issues,
                        :add_issues,
                        :edit_issues,
                        :add_issue_notes,
                       ],
          issues_visibility: "own"
        }
        
        @document_request_requester_role = find_or_create(Role, hash_for_requester_role)
        Setting[:plugin_redmine_document_request][:requester_role_id] = @document_request_requester_role.id

        hash_for_executor_role = {
          name: "Исполнитель заявок на документ", 
          assignable: true, 
          builtin: 0, 
          permissions: [
                        :view_calendar,
                        :view_document_request,
                        :view_documents,
                        :view_files,
                        :view_gantt,
                        :view_issues,
                        :add_issues,
                        :edit_issues,
                        :add_issue_notes,
                        :edit_issue_notes,
                        :edit_own_issue_notes,
                        :view_private_notes,
                        :set_notes_private,
                        :move_issues,
                        :delete_issues,
                        :manage_public_queries,
                        :save_queries,
                        :view_issue_watchers,
                        :add_issue_watchers,
                        :delete_issue_watchers,
                        :browse_repository,
                        :view_changesets,
                        :view_time_entries,
                        :view_wiki_pages,
                        :view_wiki_edits
                       ], 
          issues_visibility: "all"
        }

        @document_request_executor_role = find_or_create(Role, hash_for_executor_role)
        Setting[:plugin_redmine_document_request][:executor_role_id] = @document_request_executor_role.id
      end

      def document_request_custom_fields_setup

        hash_for_document_type_field = {
          name: "Тип документа", 
          field_format: "list", 
          possible_values: [
                            "копия трудовой книжки",
                            "характеристика с места работы",
                            "справка на визу",
                            "справка для банка в свободной форме",
                            "2-НДФЛ",
                            "другое"
                           ],
          regexp: "", 
          min_length: 0, 
          max_length: 0, 
          is_required: true, 
          is_for_all: false, 
          is_filter: true, 
          searchable: true,
          default_value: "",
          editable: true,
          visible: true,
          multiple: false
        }

        @document_request_document_type_field = find_or_create(IssueCustomField, hash_for_document_type_field)
        Setting[:plugin_redmine_document_request][:document_type_field_id] = @document_request_document_type_field.id

        @document_request_tracker.custom_fields << @document_request_document_type_field
        @document_request_project.issue_custom_fields << @document_request_document_type_field

        hash_for_document_for_field = {
          type: "IssueCustomField", 
          name: "Документ для", 
          field_format: "user", 
          possible_values: nil,
          regexp: "", 
          min_length: 0, 
          max_length: 0, 
          is_required: true, 
          is_for_all: false, 
          is_filter: true, 
          position: 2, 
          searchable: true, 
          default_value: nil, 
          editable: true, 
          visible: true, 
          multiple: false
        }

        @document_request_document_for_field = find_or_create(IssueCustomField, hash_for_document_for_field)
        Setting[:plugin_redmine_document_request][:document_for_field_id] = @document_request_document_for_field.id

        @document_request_tracker.custom_fields << @document_request_document_for_field
        @document_request_project.issue_custom_fields << @document_request_document_for_field

        hash_for_company_name_field = {
          name: "Компания", 
          field_format: "list", 
          possible_values: [
                            "Горкапстрой"
                           ],
          regexp: "", 
          min_length: 0, 
          max_length: 0, 
          is_required: true, 
          is_for_all: false, 
          is_filter: true, 
          searchable: true,
          default_value: "",
          editable: true,
          visible: true,
          multiple: false
        }

        @document_request_company_name_field = find_or_create(IssueCustomField, hash_for_company_name_field)
        Setting[:plugin_redmine_document_request][:company_name_field_id] = @document_request_company_name_field.id

        @document_request_tracker.custom_fields << @document_request_company_name_field
        @document_request_project.issue_custom_fields << @document_request_company_name_field

      end

      def document_request_query_setup

        hash_for_per_type_query = { 
          name: "Заявки на документы (по типу)", 
          project_id: @document_request_project.id,
          filters: {
            "status_id"=>{:operator=>"o", :values=>[""]}, 
            "tracker_id"=>{:operator=>"=", :values=>["#{@document_request_tracker.id}"]}}, 
          user_id: 1, 
          is_public: true, 
          column_names: [:"cf_#{@document_request_document_for_field.id}",
                         :status, 
                         :priority, 
                         :assigned_to, 
                         :due_date], 
          sort_criteria: [],
          group_by: "cf_#{@document_request_document_type_field.id}",
          type: "IssueQuery"
        }

        @document_request_per_type_query = IssueQuery.where(name: "Заявки на документы (по типу)").last || IssueQuery.create(hash_for_per_type_query)
        Setting[:plugin_redmine_document_request][:per_type_query_id] = @document_request_per_type_query.id
        @document_request_project.queries << @document_request_per_type_query 
        

        hash_for_per_user_query = { 
          name: "Заявки на документы (по имени)", 
          project_id: @document_request_project.id,
          filters: {
            "status_id"=> {:operator=>"o", :values=>[""]}, 
            "tracker_id"=>{:operator=>"=", :values=>["#{@document_request_tracker.id}"]}
          }, 
          user_id: 1, 
          is_public: true, 
          column_names: [
                         :"cf_#{@document_request_document_type_field.id}", 
                         :due_date, 
                         :status, 
                         :priority, 
                         :assigned_to
                        ], 
          sort_criteria: [["due_date", "desc"]], 
          group_by: "cf_#{@document_request_document_for_field.id}", 
          type: "IssueQuery"
        }

        @document_request_per_user_query = IssueQuery.where(name: "Заявки на документы (по имени)").last || IssueQuery.create(hash_for_per_user_query)
        Setting[:plugin_redmine_document_request][:per_user_query_id] = @document_request_per_user_query.id
        @document_request_project.queries << @document_request_per_user_query 

      end

      # rails 4, hobo style
      def find_or_create(model, hash)
        model.send(:where, hash).last || model.send(:create, hash)
      end

    end
  end
end
