# -*- coding: utf-8 -*-
a = IssueCustomField.new({
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
                     position: 1, 
                     searchable: true,
                     default_value: "",
                     editable: true,
                     visible: true,
                     multiple: false
                   })

IssueCustomField.create({
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
                   })

t = Tracker.create({
                 name: "Запрос на документы",
                 is_in_chlog: false, 
                 position: 4, 
                 is_in_roadmap: true, 
                 fields_bits: 198
               })

IssueQuery.create({ 
                    project_id: 3, 
                    name: "Заявки на документы", 
                    filters: {
                      "status_id"=>{:operator=>"o", :values=>[""]}, 
                      "tracker_id"=>{:operator=>"=", :values=>["4"]}}, 
                    user_id: 1, 
                    is_public: true, 
                    column_names: [:cf_2,
                                   :status, 
                                   :priority, 
                                   :assigned_to, 
                                   :due_date], 
                    sort_criteria: [],
                    group_by: "cf_2",
                    type: "IssueQuery"
                  })

IssueQuery.create ({
                     project_id: 3, 
                     name: "Заявки на документы (по имени)", 
                     filters: {
                       "status_id"=> {:operator=>"o", :values=>[""]}, 
                       "tracker_id"=>{:operator=>"=", :values=>["4"]}
                     }, 
                     user_id: 1, 
                     is_public: true, 
                     column_names: [
                                    :tracker, 
                                    :cf_2, 
                                    :due_date, 
                                    :status, 
                                    :priority, 
                                    :assigned_to
                                   ], 
                     sort_criteria: [["due_date", "desc"]], 
                     group_by: "cf_3", 
                     type: "IssueQuery"
                   })




########################

      def document_request_setup

        return unless name == 'redmine_document_request'

        field_document_type = IssueCustomField.create({
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
#                                                        position: 1, 
                                                        searchable: true,
                                                        default_value: "",
                                                        editable: true,
                                                        visible: true,
                                                        multiple: false
                                                      })

        field_document_for = IssueCustomField.create({
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
 #                                                      position: 2, 
                                                       searchable: true, 
                                                       default_value: nil, 
                                                       editable: true, 
                                                       visible: true, 
                                                       multiple: false
                                                     })

        tracker = Tracker.create({
                         name: "Запрос на документы",
                         is_in_chlog: false, 
                         is_in_roadmap: true, 
                       })

        IssueQuery.create({ 
                            project_id: project_id, 
                            name: "Заявки на документы (по типу)", 
                            filters: {
                              "status_id"=>{:operator=>"o", :values=>[""]}, 
                              "tracker_id"=>{:operator=>"=", :values=>["#{tracker.id}"]}}, 
                            user_id: 1, 
                            is_public: true, 
                            column_names: [:"cf_#{field_document_for.id}",
                                           :status, 
                                           :priority, 
                                           :assigned_to, 
                                           :due_date], 
                            sort_criteria: [],
                            group_by: "cf_#{field_document_type.id}",
                            type: "IssueQuery"
                          })

        IssueQuery.create ({
                             project_id: project_id, 
                             name: "Заявки на документы (по имени)", 
                             filters: {
                               "status_id"=> {:operator=>"o", :values=>[""]}, 
                               "tracker_id"=>{:operator=>"=", :values=>["#{tracker.id}"]}
                             }, 
                             user_id: 1, 
                             is_public: true, 
                             column_names: [
                                            :"cf_#{field_document_type.id}", 
                                            :due_date, 
                                            :status, 
                                            :priority, 
                                            :assigned_to
                                           ], 
                             sort_criteria: [["due_date", "desc"]], 
                             group_by: "cf_#{field_document_for.id}", 
                             type: "IssueQuery"
                           })

      end
