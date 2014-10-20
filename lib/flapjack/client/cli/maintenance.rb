require 'flapjack/client/util'

module Flapjack; module Client; module Cli
  class Maintenance < Thor

    no_tasks do
      def api
        Flapjack::Client::Util::API.new(
          Flapjack::Client::Util::Config.new(
            parent_options['config'],
            parent_options['uri'])
          )
      end
    end

    method_option :start,
      :aliases  => "-s",
      :default  => Time.now,
      :required => false,
      :desc     => "Specify the start time."
    method_option :duration,
      :aliases  => "-d",
      :type     => :numeric,
      :default  => 86000,
      :required => false,
      :desc     => "Specify the duration."
    method_option :summary,
      :aliases  => "-S",
      :default  => "Set by flappy",
      :required => false,
      :desc     => "Specify the summary message."
    desc "enable <entity>[:<check>[,<check>]] [options]", "Enable maintenance mode for an entity and check."
    long_desc <<-LONGDESC
      Enables maintenance mode for an entity and check(s).

      Example:

      $ flappy maintenance enable <entity name>[:<check>[,<check>]]
    LONGDESC
    def enable(entity_and_check)
      Util.enable_maintenance(api, entity_and_check, options)
    end

    method_option :start,
      :aliases  => "-s",
      :default  => Time.now,
      :required => false,
      :desc     => "Specify the time that the maintenance should be disabled."
    desc "disable <entity>[:<check>[,<check>]] [options]", "Disable maintenance mode for an entity and check."
    long_desc <<-LONGDESC
      Disables maintenance mode for an entity and check.

      Example:

      $ flappy maintenance disable <entity name>[:<check>[,<check>]]
    LONGDESC
    def disable(entity_and_check)
      Util.disable_maintenance(api, entity_and_check, options)
    end

    method_option :start,
      :aliases  => "-s",
      :default  => Time.now,
      :required => false,
      :desc     => "Specify the start time."
    method_option :end,
      :aliases  => "-e",
      :default  => Time.now+31536000,
      :required => false,
      :desc     => "Specify the end time."
    method_option :scheduled,
      :aliases  => "-S",
      :type     => :boolean,
      :default  => true,
      :required => false,
      :desc     => "Get scheduled maintenance periods"
    method_option :unscheduled,
      :aliases  => "-U",
      :type     => :boolean,
      :default  => false,
      :required => false,
      :desc     => "Get unscheduled maintenance periods"
    desc "get <entity>[:<check>[,<check>]] [options]", "Gets maintenance mode status for an entity (and checks)."
    long_desc <<-LONGDESC
      Retrieves maintenance mode status for an entity and check.

      Example:

      $ flappy maintenance get <entity name>[:<check[,<check>]]
    LONGDESC
    def get(entity_and_check)
      maintenances = Util.get_maintenances(
        api,
        entity_and_check,
        options[:start],
        options[:end],
        options[:scheduled],
        options[:unscheduled])
      puts Util.format_maintenances(entity_and_check, maintenances)
    end

  end
end; end; end
