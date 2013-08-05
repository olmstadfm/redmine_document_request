# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  def index

    @project_id = Setting[:plugin_redmine_document_request][:project_id]
    @assigned_to_id = Setting[:plugin_redmine_document_request][:assigned_to_id]
    @tracker_id = Setting[:plugin_redmine_document_request][:tracker_id]
    
    document_for_field_id = Setting[:plugin_redmine_document_request][:document_for_field_id].to_i

    auto_enable_module

    redirect_to new_project_issue_path(
                                       'format' => 'html',
                                       'project_id' => @project_id,
                                       'issue[tracker_id]' => @tracker_id,
                                       'issue[is_private]' => 1,
                                       'issue[subject]' => l(:field_value_document_request_subject),
                                       'issue[due_date]' => due_date_calc,
                                       'issue[assigned_to_id]' => @assigned_to_id,
                                       "issue[custom_field_values][#{document_for_field_id}]" => User.current.id
                                       )

  end

  private

  def auto_enable_module
    module_arguments = {name: 'document_request', project_id: @project_id}
    unless EnabledModule.where(module_arguments).last
      EnabledModule.create(module_arguments)
    end
  end

  def due_date_calc
    due_date = Date.today
    case due_date.strftime('%A')
    when 'Saturday'
      due_date += 3.days
    when 'Sunday'
      due_date += 2.days
    else
      delay = Time.now.hour > 13 ? 2 : 1
      while delay > 0
        delay -= 1
        due_date += 1.day
        due_date += 2.day if due_date.saturday?
      end
    end
    due_date
  end

end
