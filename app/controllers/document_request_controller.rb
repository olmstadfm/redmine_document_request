# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :settings_setup

  def new
  end

  def create

    @issue.project_id = @project_id
    @issue.tracker_id = @tracker_id
    @issue.author = User.current
    @issue.is_private = true

    
    if (category_id = params[:issue][:category_id]).present?
      @document_type = IssueCategory.find(category_id.to_i).name
      @issue.category_id = category_id.to_i
    end

    @custom_document = params.delete(:custom)
    custom_document_valid = true
    unless @document_type == @other_category_name
      @issue.subject = "#{l(:value_document_request_subject)}: #{@document_type}"
    else
      if @custom_document[:title].present? && @custom_document[:comment].present?
        @issue.subject = "#{l(:value_document_request_subject)}: #{@custom_document[:title]}"
        @issue.description = "#{@custom_document[:comment]}"
        @issue.assigned_to_id = @assigned_to_id
      else
        custom_document_valid = false
      end
    end
    @issue.safe_attributes = params[:issue]
    params[:custom] = @custom_document

    if @issue.valid? && @issue.due_date >= due_date_calc && @issue.category_id && custom_document_valid
      @issue.save
      redirect_to controller: 'issues', action: 'show', id: @issue.id
    else
      if @issue.due_date < due_date_calc
        @issue.errors.messages[:due_date] = [l(:error_due_date_to_early)]
      end
      unless @issue.category_id
        @issue.errors.messages[:category] = [l(:empty, scope: "activerecord.errors.messages")]
      end
      unless custom_document_valid
        @issue.errors.messages[:subject] = [l(:empty, scope: "activerecord.errors.messages")]
        @issue.errors.messages[:description] = [l(:empty, scope: "activerecord.errors.messages")]
      end
      render 'new' 
    end

  end

  private

  def settings_setup

    @setting = Setting[:plugin_redmine_document_request]

    @project_id = @setting[:project_id]
    @assigned_to_id = @setting[:assigned_to_id]
    @tracker_id = @setting[:tracker_id]

    @company_name_field_id = @setting[:company_name_field_id]
    @document_for_field_id = @setting[:document_for_field_id]

    @other_category_id = @setting[:other_category_id]
    @other_category_name = IssueCategory.find(@other_category_id).try(:name)

    @project = Project.find(@project_id)
    @due_date = due_date_calc

    @categories = @project.issue_categories.sort_by{|c| -c.assigned_to_id.to_i} # issue_categories


    @companies = IssueCustomField.find(@company_name_field_id).possible_values.map{|c| [c,c] }

    @issue = Issue.new

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
