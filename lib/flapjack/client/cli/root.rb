require 'flapjack/client/util'

module Flapjack; module Client; module Cli
  class Root < Thor

    def self.exit_on_failure?
      true
    end

    no_tasks do
      def api
        Flapjack::Client::Util::API.new(
          Flapjack::Client::Util::Config.new(
            options['config'],
            options['uri'])
          )
      end
    end

    class_option :uri, :aliases => "-u", :required => false,
      :desc => "Specify the Flapjack URI."

    class_option :config, :aliases => "-c", :required => false,
      :desc => "Specify the Flapjack config file."


    desc "checks <entity>", "List checks for a given entity"
    long_desc <<-LONGDESC
      List the checks for a given entity.

      Example:

      $ flappy checks <fqdn>
    LONGDESC
    def checks(entity)
      api.connection.checks(entity).each do |check|
        puts check
      end
    end

    desc "status <entity>[:<check>[,<check>]]", "List status of checks for a given entity"
    long_desc <<-LONGDESC
      List the status of checks for a given entity.

      Example:

      $ flappy status <fqdn>
    LONGDESC
    def status(entity_and_check)
      puts Util.get_status(api, entity_and_check)
    end


    desc "config SUBCOMMAND ...ARGS", "Create a ~/.flapjack.rc file that can be used by this CLI tool."
    subcommand "config", Flapjack::Client::Cli::Config

    desc "maintenance SUBCOMMAND ...ARGS", "Enable maintenance mode for entities and checks."
    subcommand "maintenance", Flapjack::Client::Cli::Maintenance

    desc "contacts SUBCOMMAND ...ARGS", "Manage contacts."
    subcommand "contacts", Flapjack::Client::Cli::Contacts

    desc "entities SUBCOMMAND ...ARGS", "Manage entities."
    subcommand "entities", Flapjack::Client::Cli::Entities

  end

end; end; end
