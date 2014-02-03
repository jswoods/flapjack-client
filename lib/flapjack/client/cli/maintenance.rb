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

    method_option :start, :aliases => "-s", :default => Time.now, :required => false,
      :desc => "Specify the start time."

    method_option :duration, :aliases => "-d", :default => 86000, :required => false,
      :desc => "Specify the duration."

    method_option :summary, :aliases => "-S", :default => "Set by flappy", :required => false,
      :desc => "Specify the summary message."

    desc "enable <entity>:<check> [options]", "Enable maintenance mode for an entity and check."
    long_desc <<-LONGDESC
      Enables maintenance mode for an entity and check.

      Example:

      $ flappy maintenance enable <entity name>:<check name>
    LONGDESC

    def enable(entity_and_check)
      entity, check = entity_and_check.split(':')
      if api.connection.create_scheduled_maintenance!(entity, check,
        :start_time => options['start'],
        :duration => options['duration'],
        :summary => options['summary'])
        puts "Set maintenance mode for #{entity}:#{check} starting at #{options['start']} for #{options['duration']} seconds."
      else
        raise "Couldn't set maintenance mode " + $!.inspect
      end
    end

    method_option :start, :aliases => "-s", :default => Time.now, :required => false,
      :desc => "Specify the time that the maintenance should be disabled."

    desc "disable <entity>:<check> [options]", "Enable maintenance mode for an entity and check."
    long_desc <<-LONGDESC
      Disables maintenance mode for an entity and check.

      Example:

      $ flappy maintenance disable <entity name>:<check name>
    LONGDESC

    def disable(entity_and_check)
      now = Time.now
      entity, check = entity_and_check.split(':')
      api.connection.scheduled_maintenances(entity,
        {:check => check, :start_time => Time.local(2014,01,01), :end_time   => now}).each do |maint|
        if Time.at(maint['end_time']) > now
          if api.connection.delete_scheduled_maintenance!(entity, check,
            :start_time => Time.at(maint['start_time']))
            puts "Removed maintenance mode for #{entity}:#{check} starting at #{Time.at(maint['start_time'])}."
          else
            raise "Couldn't disable maintenance mode " + $!.inspect
          end
        end
      end
    end

    method_option :start, :aliases => "-s", :default => Time.now, :required => false,
      :desc => "Specify the start time."
    method_option :end, :aliases => "-e", :default => Time.now+31536000, :required => false,
      :desc => "Specify the end time."
    method_option :scheduled, :aliases => "-S", :type => :boolean, :default => true, :required => false,
      :desc => "Get scheduled maintenance periods"
    method_option :unscheduled, :aliases => "-U", :type => :boolean, :default => false, :required => false,
      :desc => "Get unscheduled maintenance periods"

    desc "get <entity>:<check> [options]", "Gets maintenance mode status for an entity and check."
    long_desc <<-LONGDESC
      Retrieves maintenance mode status for an entity and check.

      Example:

      $ flappy maintenance get <entity name>:<check name>
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
