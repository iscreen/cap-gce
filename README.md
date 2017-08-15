# Cap::Gce

[![Gem Version](https://badge.fury.io/rb/cap-gce.svg)](http://badge.fury.io/rb/cap-gce) [![Code Climate](https://codeclimate.com/github/iscreen/cap-gce.png)](https://codeclimate.com/github/iscreen/cap-gce)

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

Imagine you have four servers on Google Cloud Platform named and metadata as follows:

<table>
  <tr>
    <td>'Name' metadata</td>
    <td>'Roles' metadata</td>
    <td>'Stages' metadata</td>
  </tr>
  <tr>
    <td>server-1</td>
    <td>web</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-2</td>
    <td>web,app</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-3</td>
    <td>app,db</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-4</td>
    <td>web,db,app</td>
    <td>staging</td>
  </tr>
</table>

Imagine also that we've called our app "testapp", as defined in `config/deploy.rb` like so:

    set :application, "testapp"

### Defining the roles in `config/deploy/[stage].rb`

To define a role, edit `config/deploy/[stage].rb` and add the following:

    gce_role :web

Let's say we edited `config/deploy/production.rb`. Adding this configuration to the file would assign
the role `:web` to any instance that has the following properties:
* has a metadata called "Roles" that contains the string "web"
* has a metadata called "Project" that contains the string "testapp"
* has a metadata called "Stages" that contains the current stage we're executing (in this case, "production")

Looking at the above table, we can see we would match `server-1` and `server-2`. (You can have multiple
roles in metadata separated by commas.)

Now we can define the other roles:

    gce_role :app
    gce_role :db

In the "production" stage, the `:app` role would apply to `server-2` and `server-3`, and the `:db`
role would apply to `server-3`.

In the "staging" stage, all roles would apply *only* to `server-4`.

### Servers belonging to multiple projects

If you require your servers to have multiple projects deployed to them, you can simply specify
all the project names you want to the server to be part of in the 'Projects' metadata, separated
by commas. For example, you could place a server in the `testapp` and `myapp` projects by
setting the 'Projects' metadata to `testapp,myapp`.

### Servers in multiple stages

If your use-case requires servers to be in multiple stages, simply specify all the stages you want
the server to be in 'Stages' metadata, separated by commas. For example, you could place a server in
the `production` and `staging` stages by setting the 'Stages' metadata to `production,staging`.

### Tasks and deployment

You can now define your tasks for these roles in exactly the same way as you would if you weren't
using this gem.


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

Bug reports and pull requests are welcome on GitHub at https://github.com/iscreen/cap-gce. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

