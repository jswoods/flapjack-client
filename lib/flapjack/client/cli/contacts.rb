require 'flapjack/client/util'
require 'json'

module Flapjack; module Client; module Cli
  class Contacts < Thor

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
      :desc => "Specify a JSON-formatted file that contains the Flapjack contacts."

    method_option :input, :aliases => "-i", :default => false, :required => false,
      :type => :boolean, :desc => "Provide a JSON-formatted string to stdin that contains the Flapjack contacts."

    desc "create [options]", "Create contacts in Flapjack."
    long_desc <<-LONGDESC
      Creates contacts in Flapjack.

      Example:

      $ flappy contacts create -f /path/to/contacts.json
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
        abort("No contacts to load. Must specify either -f or -i.")
      end

      begin
        contacts = JSON.parse(content)
      rescue
        abort("Could not parse contacts. Ensure contacts are formatted in valid JSON.")  
      end

      if api.connection.create_contacts!(contacts)
        puts "Created contacts."
      else
        raise "Couldn't create contacts " + $!.inspect
      end
    end
  end
end; end; end
