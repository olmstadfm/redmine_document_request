# -*- coding: utf-8 -*-

def mourn(str)
  puts "rip #{str}"
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

    # нужно тоже самое, но через группы
    Member.all.map(&:destroy)
    mourn "Members"

    project = Project.find_by_name("yet another project")
    project.destroy if project
    mourn "Project"

  end

  task :create => :environment do
    project = Project.create(name: "yet another project", identifier: "dfgadgg")
    EnabledModule.create(name: 'document_request', project_id: project.id) 

    manager = Role.find(3)
    for user in Principal.where(type: 'User')
      Member.create(user: user, project: project, roles: [manager])
    end
    puts "new meat"

  end

  task :reset => [:destroy, :create]

end
