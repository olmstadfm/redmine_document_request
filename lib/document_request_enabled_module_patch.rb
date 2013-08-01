# -*- coding: utf-8 -*-
require_dependency 'enabled_module'
require_dependency 'issue_custom_field'

module DocumentRequestPlugin
  module EnabledModulePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        after_create :document_request_module_enabled

      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def document_request_module_enabled
        if self.name == 'document_request'

          # project
          project = Project.find(self.project_id)

          # tracker
          tracker = Tracker.create({
                                     name: "Запрос на документы",
                                     is_in_chlog: false, 
                                     is_in_roadmap: true, 
                                   })

          source_tracker = Tracker.find(1)        # ошибка
          source_role = Role.find(3)              # менеджер
          target_tracker = tracker
          target_role = source_role

          WorkflowRule.copy(source_tracker, source_role, target_tracker, target_role )
          
          project.trackers = [tracker]

          # role

          hash_for_requester_role = { 
            name: "Запрашивающий документы",
            assignable: false, 
            builtin: 0,
            permissions: [
                          :view_issues,
                          :add_issues,
                          :add_issue_notes,
                         ],
            issues_visibility: "own"
          }
          
          Role.create(hash_for_requester_role)

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

          Role.create(hash_for_executor_role)

          # custom fields
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

          document_type_field = IssueCustomField.create(hash_for_document_type_field)

          tracker.custom_fields << document_type_field
          project.issue_custom_fields << document_type_field

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

          document_for_field = IssueCustomField.create(hash_for_document_for_field)

          tracker.custom_fields << document_for_field
          project.issue_custom_fields << document_for_field

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

          company_name_field = IssueCustomField.create(hash_for_company_name_field)

          tracker.custom_fields << company_name_field
          project.issue_custom_fields << company_name_field


          # query
          hash_for_per_type_query = { 
            name: "Заявки на документы (по типу)", 
            filters: {
              "status_id"=>{:operator=>"o", :values=>[""]}, 
              "tracker_id"=>{:operator=>"=", :values=>["#{tracker.id}"]}}, 
            user_id: 1, 
            is_public: true, 
            column_names: [:"cf_#{document_for_field.id}",
                           :status, 
                           :priority, 
                           :assigned_to, 
                           :due_date], 
            sort_criteria: [],
            group_by: "cf_#{document_type_field.id}",
            type: "IssueQuery"
          }

          per_type_query = IssueQuery.create(hash_for_per_type_query)
          project.queries << per_type_query 

          hash_for_per_user_query = { 
            name: "Заявки на документы (по имени)", 
            filters: {
              "status_id"=> {:operator=>"o", :values=>[""]}, 
              "tracker_id"=>{:operator=>"=", :values=>["#{tracker.id}"]}
            }, 
            user_id: 1, 
            is_public: true, 
            column_names: [
                           :"cf_#{document_type_field.id}", 
                           :due_date, 
                           :status, 
                           :priority, 
                           :assigned_to
                          ], 
            sort_criteria: [["due_date", "desc"]], 
            group_by: "cf_#{document_for_field.id}", 
            type: "IssueQuery"
          }

          per_user_query = IssueQuery.create(hash_for_per_user_query)
          project.queries << per_user_query 

        end
      end

    end
  end
end
