# -*- coding: utf-8 -*-
class DocumentRequestController < ApplicationController
  unloadable

  helper CustomFieldsHelper

  before_filter :require_login
  before_filter :settings_setup, :only => [:new, :create]

  before_filter :company_check, :only => [:new]

  def new
    
  end

  def create

    @issue.project_id = @project_id
    @issue.author = User.current
    @issue.is_private = true
    
    category_id = params[:issue][:category_id]

    if category_id.present?
      @category = IssueCategory.find(category_id.to_i) 
      @document_type = @category.name
      @issue.category_id = category_id.to_i

      # rubynovich broke automatical issue assigment by applying
      # category. now you must fill assigned_to_id manually.
      @issue.assigned_to_id = @category.assigned_to_id

      case @category.id
        when @other_category_id # @other_category_id
          process_custom_document
        when @roaming_category_id
          process_roaming
        else
          @issue.subject = "#{l(:value_document_request_subject)}: #{@document_type}"
          @issue.tracker_id = @tracker_id
      end

    end

    @issue.safe_attributes = params[:issue] ##################

    @issue.start_date = Date.today

    if @issue.valid? && @issue.due_date && @issue.due_date >= due_date_calc && @issue.category_id
      @issue.save
      redirect_to controller: 'issues', action: 'show', id: @issue.id
    else
      if @issue.due_date && @issue.due_date < due_date_calc
        @issue.errors.messages[:due_date] = [l(:error_due_date_to_early)]
      end
      unless @issue.category_id
        @issue.errors.messages[:category] = [l(:empty, scope: "activerecord.errors.messages")]
      end
      render 'new' 
    end

  end

  private

  def process_custom_document
    @custom_document = params.delete(:custom)

    if @custom_document[:title].present? 
      @issue.subject = "#{l(:value_document_request_subject)}: #{@custom_document[:title]}"
    else
      @issue.errors.messages[:subject] = [l(:empty, scope: "activerecord.errors.messages")]
    end
    if @custom_document[:comment].present?
      @issue.description = "#{@custom_document[:comment]}"
    else 
      @issue.errors.messages[:description] = [l(:empty, scope: "activerecord.errors.messages")]
    end

    @issue.assigned_to_id = @assigned_to_id
    @issue.tracker_id = @tracker_id

    params[:custom] = @custom_document
  end

  def process_roaming
    @issue.subject = l(:value_roaming_issue_subject)
    @issue.tracker_id = @roaming_tracker.id
  end

  def settings_setup

    @setting = Setting[:plugin_redmine_document_request]

    @project_id = @setting[:project_id]
    @assigned_to_id = @setting[:assigned_to_id]
    @tracker_id = @setting[:tracker_id]

    @company_name_field_id = @setting[:company_name_field_id]
    @document_for_field_id = @setting[:document_for_field_id].to_i

    @other_category_id = @setting[:other_category_id].to_i
    @other_category_name = IssueCategory.find(@other_category_id).try(:name)

    @project = Project.find(@project_id)
    @due_date = due_date_calc

    @categories = @project.issue_categories.sort_by{|c| c.name}

    @roaming_tracker_id = @setting[:roaming_tracker_id]
    @roaming_tracker = Tracker.find(@roaming_tracker_id)
    @roaming_country_field_id = @setting[:country_field_id].to_i
    @roaming_turn_on_date_field_id = @setting[:roaming_on_field_id].to_i
    @roaming_turn_off_date_field_id = @setting[:roaming_off_field_id].to_i
    @roaming_category_id = @setting[:roaming_category_id].to_i

    @companies = IssueCustomField.find(@company_name_field_id).possible_values.map{|c| [c,c] }

    @issue = @project.issues.new

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

  def company_check
    render_403 unless Group.find(455).users.include?(User.current)
  end

end
