# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  before_filter :settings_setup

  # def index

  #   auto_enable_module

  #   redirect_to new_project_issue_path(
  #                                      'format' => 'html',
  #                                      'project_id' => @project_id,
  #                                      'issue[tracker_id]' => @tracker_id,
  #                                      'issue[is_private]' => 1,
  #                                      'issue[subject]' => l(:field_value_document_request_subject),
  #                                      'issue[due_date]' => due_date_calc,
  #                                      'issue[assigned_to_id]' => @assigned_to_id,
  #                                      "issue[custom_field_values][#{@document_for_field_id}]" => User.current.id
  #                                      )

  # end

  def new

    @project = Project.find(@project_id)
    @due_date = due_date_calc

    @company_name_field_id = @setting[:company_name_field_id]
    @document_for_field_id = @setting[:document_for_field_id]
    @document_type_field_id = @setting[:document_type_field_id]

    @categories = @project.issue_categories
    @companies = IssueCustomField.find(@company_name_field_id).possible_values.map{|c| [c,c] }

  end

  def create

    @project = Project.find(@project_id)

    @document_type_field_id = @setting[:document_type_field_id]
    @document_type = params[:issue][:custom_field_values][@document_type_field_id.to_s]

    user_id = params[:issue][:custom_field_values][@document_for_field_id.to_s]
    @user = User.find(user_id)

    issue = Issue.new

    issue.project_id = @project_id
    issue.tracker_id = @tracker_id
    issue.author = User.current
    issue.subject = "Запрос на документ: #{@document_type} для #{@user.name}"
    issue.safe_attributes = params[:issue]
    issue.category_id = IssueCategory.where(project_id: @project_id, name: @document_type).first.try(:id)
    issue.is_private = true

    if issue.save
      redirect_to controller: 'issues', action: 'show', id: issue.id
    else
      render action: 'new' 
    end
    # redirect_to do
    #   if issue.save
    #     issue_path(issue)
    #   else
    #     {:controller => 'document_request', :action => 'new'}
    #   end
    # end

  end

  private

  def settings_setup
    @setting = Setting[:plugin_redmine_document_request]
    @project_id = @setting[:project_id]
    @assigned_to_id = @setting[:assigned_to_id]
    @tracker_id = @setting[:tracker_id]
    @document_for_field_id = @setting[:document_for_field_id].to_i
  end

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
