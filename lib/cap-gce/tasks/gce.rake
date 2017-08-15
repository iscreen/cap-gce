namespace :gce do
  desc 'Show all information about GCE instances that match this project'
  task :status do
    gce_handler.status_table
  end

  desc 'Show GCE server names that match this project'
  task :server_names do
    gce_handler.server_names
  end

  desc 'Show GCE instance IDs that match this project'
  task :instance_ids do
    gce_handler.instance_ids
  end
end

namespace :load do
  task :defaults do
    set :gce_config, 'config/gce.yml'
    set :gce_project_tag, 'Project'
    set :gce_roles_tag, 'Roles'
    set :gce_stages_tag, 'Stages'

    set :gce_project_id, nil
    set :gce_zone, %w[]
    set :gce_filter, '(status eq "RUNNING")'
    set :gce_fields, nil
    set :gce_scope, %w[https://www.googleapis.com/auth/compute]
    set :gce_secret_config, 'config/compute_engine_secret.json'
    set :gce_contact_point, nil # public_ip_address, private_ip_address
  end
end
