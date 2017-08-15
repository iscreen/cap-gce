# Cap::Gce

Cap-GCE is used to generate Capistrano namespaces and tasks from Google Cloud Compute Engine instance metadata, dynamically building the list of servers to be deployed to.

This documentation assumes familiarity with Capistrano 3.x.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cap-gce'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cap-gce

You also need to add the gem to your Capfile:

```
require "cap-gce/capistrano"
```

## Configuration

Configurable options, shown here with defaults:

```
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
set :gce_contact_point, nil # nat_ip, network_ip
```

### Secret Config
:gce_secret_config is credential file of GCP, now it only accept Service account key json certificate.

### Zones

:gce_zone is an array of GCP zones and is required. Only list zones which you wish to query for instances

### Misc settings

* project_tag

  Cap-GCE will look for a metadata with this name when searching for instances that belong to this project. The metadata name defaults to "Project".

* stages_tag

  Cap-GCE will look for a metadata with this name to determine which instances belong to a given stage. The metadata name defaults to "Stages".

* roles_tag

  Cap-GCE will look for a metadata with this name to determine which instances belong to a given role. The metadata name defaults to "Roles".

## Usage

## Utility tasks

Cap-GCE adds a few utility tasks to Capistrano for displaying information about the instances that you will be deploying to. Note that unlike Capistrano 2.x, all tasks require a stage.

### View instances

This command will show you information all the instances your configuration matches for a given stage.

```
cap [stage] gce:status
```

Example:
```
$ cap production gce:status

Num  Name                  ID                    Type      IP           Zone         Roles      Stage
00   machine-learning-01   3805131608224908200   g1-small  10.138.0.2   us-west1-a   web,app    production
00   machine-learning-02   3805131608224908300   g1-small  10.138.0.3   us-west1-a   web,app    production
```

### View server names

This command will show you the server names of the instances matching the given stage:

```
cap [stage] gce:server_names
```

Example:
```
$ cap production gce:server_names
machine-learning-01
machine-learning-02
```

### View server instance IDs

This command will show the instance IDs of the instances matching the given stage:
```
cap [stage] gce:instance_ids
```

Example:

```
$ cap production gce:instance_ids
3805131608224908200
3805131608224908300
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cap-gce. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

