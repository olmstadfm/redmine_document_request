# -*- coding: utf-8 -*-

def mourn(str)
  puts "rip #{str}"
end

namespace :document_request do

  task :add_categories => :environment do

    categories = {
                  "копия трудовой книжки" => 5, 
                  "характеристика с места работы"=> 5,
                  "справка на визу"=> 5,
                  "справка для банка"=> 5,
                  "2-НДФЛ"=> 6,
                  "другое"=> nil
                 }

    project = Project.find_by_name("Заявки на документ")

    for name, user in categories
      puts name
      project.issue_categories.create({name: name, assigned_to_id: user })
    end

  end

  task :destroy => :environment do

    IssueCustomField.all.map(&:destroy)
    mourn "IssueCustomField" 

    IssueQuery.all.map(&:destroy)
    mourn "IssueQuery"

    tracker = Tracker.find_by_name("Заявки на документ")
    if tracker
      Issue.where(tracker_id: tracker.id).map(&:destroy) 
      tracker.destroy 
    end
    mourn "Tracker"

    Member.all.map(&:destroy)
    mourn "Members"

    setting = Setting.where(name: "plugin_redmine_document_request").first
    setting.destroy if setting
    mourn "Setting"

    project = Project.find_by_name("Заявки на документ")
    project.destroy if project
    mourn "Project"

  end

  task :create => :environment do
    project = Project.create(name: "Заявки на документ", identifier: "document-request-project")

    # EnabledModule.create(name: 'document_request', project_id: project.id) 

    # нужно тоже самое, но через группы
    # role = Role.find_by_name("Запрашивающий документы")
    # users = Principal.where(type: 'User')
    # users.shift # get rid of admin
    # for user in users
    #   Member.create(user: user, project: project, roles: [role])
    # end

    puts "new meat"

  end

  task :reset => [:destroy, :create, :add_categories]

  task :due => :environment do
    
    for d in (1..9)
      date = Time.new(2013, 07, d)
      p [date, due_date_calc(date)]
    end

  end

end
