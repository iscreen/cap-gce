require 'google/apis/compute_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

module CapGCE
  class GCEHandler
    include CapGCE::Utils

    def initialize
      load_config
      @authorizer = fetch_authorizer
      load_gce
    end

    def load_gce
      compute = Google::Apis::ComputeV1::ComputeService.new
      compute.authorization = @authorizer
      configured_zones = get_zones(fetch(:gce_zone))
      @gce = {}
      configured_zones.each do |zone|
        @gce[zone] = compute.list_instances(
          fetch(:gce_project_id),
          zone,
          filter: fetch(:gce_filter)
        )
      end
    end

    def status_table
      CapGCE::StatusTable.new(
        defined_roles.map { |r| get_servers_for_role(r) }.flatten.uniq(&:id)
      )
    end

    def server_names
      puts defined_roles
        .map { |r| get_servers_for_role(r) }
        .flatten
        .uniq(&:id)
        .map(&:name)
        .join("\n")
    end

    def instance_ids
      puts defined_roles
        .map { |r| get_servers_for_role(r) }
        .flatten
        .uniq(&:id)
        .map(&:id)
        .join("\n")
    end

    def defined_roles
      roles(:all).flat_map(&:roles_array).uniq.sort
    end

    def stage
      Capistrano::Configuration.env.fetch(:stage).to_s
    end

    def application
      Capistrano::Configuration.env.fetch(:application).to_s
    end

    def tag(tag_name)
      "tag:#{tag_name}"
    end

    def get_servers_for_role(role)
      servers = []
      @gce.each do |_, gce|
        servers += gce.items.select do |i|
          instance_has_tag?(i, roles_tag, role) &&
            instance_has_tag?(i, stages_tag, stage) &&
            instance_has_tag?(i, project_tag, application)
        end
      end
      servers.sort_by(&:name)
    end

    private

    def instance_has_tag?(instance, key, value)
      (tag_value(instance, key) || '').split(',').map(&:strip).include?(value.to_s)
    end
  end
end
