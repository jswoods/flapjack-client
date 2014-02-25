require 'flapjack/client/util'
require 'json'

module Flapjack; module Client; module Cli
  class NotificationRules < Thor

    no_tasks do
      def api
        Flapjack::Client::Util::API.new(
          Flapjack::Client::Util::Config.new(
            parent_options['config'],
            parent_options['uri'])
          )
      end
    end

    method_option :file, :aliases => "-f", :default => false, :required => false,
      :desc => "Specify a JSON-formatted file that contains the Flapjack notification_rules."

    method_option :input, :aliases => "-i", :default => false, :required => false,
      :type => :boolean, :desc => "Provide a JSON-formatted string to stdin that contains the Flapjack notification_rules."

    desc "create [options]", "Create notification_rules in Flapjack."
    long_desc <<-LONGDESC
      Creates notification_rules in Flapjack.

      Example:

      $ flappy notification_rules create -f /path/to/notification_rules.json
    LONGDESC

    def create()
      if options['file']
        begin
          content = File.read(options['file'])
        rescue
          raise "Could not open file #{options['file']} " + $!.inspect
        end
      elsif options['input']
        content = $stdin.read
      else
        abort("No notification_rules to load. Must specify either -f or -i.")
      end

      begin
        notification_rules = JSON.parse(content)
      rescue
        abort("Could not parse notification_rules. Ensure notification_rules are formatted in valid JSON.")  
      end

      if not notification_rules.kind_of?(Array)
        notification_rules = [notification_rules]
      end

      notification_rules.each do |notification_rule|
        if api.connection.create_notification_rule!(notification_rule)
          puts "Created notification_rule."
        else
          raise "Couldn't create notification_rule " + $!.inspect
        end
      end
    end

    desc "list [options]", "List notification_rules in Flapjack."
    long_desc <<-LONGDESC
      Lists notification_rules in Flapjack for a specific contact.

      Example:

      $ flappy notification_rules list -i 1234
    LONGDESC

    method_option :contact_id, :aliases => "-i", :default => nil, :required => false,
      :desc => "Specify the contact id."

    method_option :contact_name, :aliases => "-n", :default => nil, :required => false,
      :desc => "Specify the contact name."

    def list()
      contact_id = Util.get_contact_id(api, options)
      rules = Util.get_notification_rules(api, contact_id)
      puts Util.format_notification_rules(rules)
    end

    desc "clean [options]", "Cleanup the default notification_rules in Flapjack."
    long_desc <<-LONGDESC
      Removes all but one default notification_rules in Flapjack for a specific contact,
and then blackholes that rule.

      Example:

      $ flappy notification_rules clean -i 1234
    LONGDESC

    method_option :contact_id, :aliases => "-i", :default => nil, :required => false,
      :desc => "Specify the contact id."

    method_option :contact_name, :aliases => "-n", :default => nil, :required => false,
      :desc => "Specify the contact name."

    def clean()
      contact_id = Util.get_contact_id(api, options)
      Util.blackhole_default_rule(api, contact_id)
    end
  end
end; end; end
