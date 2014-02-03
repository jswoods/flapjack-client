require 'flapjack/client/util'
require 'json'

module Flapjack; module Client; module Cli
  class Entities < Thor

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
      :desc => "Specify a JSON-formatted file that contains the Flapjack entities."

    method_option :input, :aliases => "-i", :default => false, :required => false,
      :type => :boolean, :desc => "Provide a JSON-formatted string to stdin that contains the Flapjack entities."

    desc "create [options]", "Create entities in Flapjack."
    long_desc <<-LONGDESC
      Creates entities in Flapjack.

      Example:

      $ flappy entities create -f /path/to/entities.json
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
        abort("No entities to load. Must specify either -f or -i.")
      end

      begin
        entities = JSON.parse(content)
      rescue
        abort("Could not parse entities. Ensure entities are formatted in valid JSON.")  
      end

      if api.connection.create_entities!(entities)
        puts "Created entities."
      else
        raise "Couldn't create entities " + $!.inspect
      end
    end
  end
end; end; end
