# -*- coding: utf-8 -*-

def mourn(str)
  puts "rip #{str}"
end

def due_date_calc(marker = Date.today)

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


namespace :document_request do

  task :destroy => :environment do

    IssueCustomField.all.map(&:destroy)
    mourn "IssueCustomField" 

    IssueQuery.all.map(&:destroy)
    mourn "IssueQuery"

    tracker = Tracker.find_by_name("Запрос на документы")
    if tracker
      Issue.where(tracker_id: tracker.id).map(&:destroy) 
      tracker.destroy 
    end
    mourn "Tracker"

    Member.all.map(&:destroy)
    mourn "Members"

    project = Project.find_by_name("Запрос на документы")
    project.destroy if project
    mourn "Project"

  end

  task :create => :environment do
    project = Project.create(name: "Запрос на документы", identifier: "document-request-project")
    # EnabledModule.create(name: 'document_request', project_id: project.id) 

    # нужно тоже самое, но через группы




    role = Role.find_by_name("Запрашивающий документы")
    users = Principal.where(type: 'User')
    users.shift # get rid of admin
    for user in users
      Member.create(user: user, project: project, roles: [role])
    end
    puts "new meat"

  end

  task :reset => [:destroy, :create]

  task :due => :environment do
    
    for d in (1..9)
      date = Time.new(2013, 07, d)
      p [date, due_date_calc(date)]
    end

  end

end
