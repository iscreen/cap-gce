require 'google/apis/compute_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'colorize'
require 'terminal-table'
require 'yaml'
require_relative 'utils'
require_relative 'gce-handler'
require_relative 'status-table'

# Load extra tasks
load File.expand_path('../tasks/gce.rake', __FILE__)

module Capistrano
  module DSL
    module Gce
      def gce_handler
        @gce_handler ||= CapGCE::GCEHandler.new
      end

      def gce_role(name, options = {})
        gce_handler.get_servers_for_role(name).each do |server|
          env.role(name, CapGCE::Utils.contact_point(server),
                   options_with_instance_id(options, server))
        end
      end

      def env
        Configuration.env
      end

      private

      def options_with_instance_id(options, server)
        options.merge(instance_id: server.id)
      end
    end
  end
end

extend Capistrano::DSL::Gce

Capistrano::Configuration::Server.send(:include, CapGCE::Utils::Server)
