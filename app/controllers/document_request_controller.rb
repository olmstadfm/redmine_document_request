# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  def index
    
    due_date = due_date_calc

    assigned_to_id = Setting[:plugin_redmine_document_request][:assigned_to_id]
    
    project_id = Setting[:plugin_redmine_document_request][:project_id]

    module_arguments = {name: 'document_request', project_id: project_id}
    unless EnabledModule.where(module_arguments).last
      EnabledModule.create(module_arguments)
    end
                                         
    redirect_to new_project_issue_path(
                                       'format' => 'html',
                                       'project_id' => project_id,
                                       'issue[is_private]' => 1,
                                       'issue[subject]' => l(:field_value_document_request_subject),
                                       'issue[due_date]' => due_date,
                                       'issue[assigned_to_id]' => assigned_to_id
                                       )

  end

  def test
  end

  private

  def due_date_calc
    marker = Date.today
    case marker.strftime('%A')
    when 'Saturday'
      marker += 3.days
    when 'Sunday'
      marker += 2.days
    else
      days = Time.now.hour > 13 ? 2 : 1
      while days > 0
        days -=1
        marker += 1.day
        marker += 2.days if marker.saturday?
      end
    end
    marker
  end

  # just wrong
  #
  # def due_date_calc
  #   # # business days remix
  #   # time = Time.now
  #   # days = Time.now.hour < 14 ? 1.day : 2.days
  #   # while days > 0 && !(1..5).include?(time.wday)
  #   #   days -= 1 if (1..5).include?(time.wday)
  #   #   time = time + 1.day
  #   # end
  #   # time

  #   # # rubynovich blues
  #   # start_date = Date.today
  #   # due_date = start_date + 2.days
  #   # due_date += 2.days if (4..6).include?(start_date.wday)
    
  #   due_date = Date.today

  #   due_date += 1.day
  #   today += 2.days if due_date.saturday?
  #   due_date += 1.day if Time.now.hour > 14

  # end

end
