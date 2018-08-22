module CapGCE
  module Utils
    module Server
      def gce_tags
        id = properties.fetch(:gce_instance_id)
        gce_handler.get_server(id).tags
      end
    end

    def project_tag
      fetch(:gce_project_tag)
    end

    def roles_tag
      fetch(:gce_roles_tag)
    end

    def stages_tag
      fetch(:gce_stages_tag)
    end

    def tag_value(instance, key)
      return nil unless instance.metadata.items
      find = instance.metadata.items.detect { |t| t.key == key.to_s }
      return nil unless find
      find.value
    end

    def self.contact_point_mapping
      {
        public_ip: :nat_ip,
        private_ip: :network_ip
      }
    end

    def self.contact_point(instance)
      gce_interface = contact_point_mapping[fetch(:gce_contact_point)]
      network_interfaces = all_network_interfaces(instance)
      return network_interfaces[gce_interface] if gce_interface

      !network_interfaces[:nat_ip].empty? && network_interfaces[:nat_ip] ||
        !network_interfaces[:network_ip].empty? && network_interfaces[:network_ip]
    end

    def self.all_network_interfaces(instance)
      {
        network_ip: instance.network_interfaces.map(&:network_ip),
        nat_ip: nat_ip(instance)
      }
    end

    def self.nat_ip(instance)
      return [] if (instance.network_interfaces.map(&:access_configs).flatten - [nil]).empty?
      instance.network_interfaces.map(&:access_configs).flatten.map(&:nat_ip) - [nil]
    end

    private

    def load_config
      secret_location = File.expand_path(fetch(:gce_secret_config), Dir.pwd)
      unless secret_location && File.exist?(secret_location)
        raise 'You must specify secret config file.'
      end

      config_location = File.expand_path(fetch(:gce_config), Dir.pwd)
      return unless config_location && File.exist?(config_location)
      config = YAML.load_file fetch(:gce_config)
      return unless config

      set :gce_project_tag, config['project_tag'] if config['project_tag']
      set :gce_roles_tag, config['roles_tag'] if config['roles_tag']
      set :gce_stages_tag, config['stages_tag'] if config['stages_tag']

      set :gce_project_id, config['project_id'] if config['project_id']
      set :gce_filter, config['filter'] if config['filter']
      set :gce_zone, config['zones'] if config['zones']
      set :gce_scope, config['scopes'] if config['scopes']
    end

    def fetch_authorizer
      secret_location = File.expand_path(fetch(:gce_secret_config), Dir.pwd)
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(secret_location),
        scope: fetch(:gce_scope)
      )
      authorizer.fetch_access_token!
      authorizer
    end

    def get_zones(zones_array = nil)
      if zones_array.nil? || zones_array.empty?
        return raise 'You must specify at least one GCE zone.'
      end
      zones_array
    end
  end
end
