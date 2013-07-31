# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  def index
    
    due_date = due_date_calc
    assigned_to_id = Setting[:plugin_redmine_document_request][:assigned_to_id]

    redirect_to new_issue_path(
                               :project_id => 27,
                               :'issue[due_date]' => due_date,
                               :'issue[assigned_to_id]' => assigned_to_id
                               )
  end

  private

  def due_date_calc
    
    test = Time.now.hour < 14 ? 1.day : 2.days
    due_date = Date.now + test 
    [6,7].include?(due_date.wday) ? 

  end

end
