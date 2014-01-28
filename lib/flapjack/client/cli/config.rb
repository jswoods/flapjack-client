module Flapjack; module Client; module Cli
  class Config < Thor

    method_option :params, :aliases => "-p", :required => false,
      :desc => "Specify params to write out to the config."
    
    desc "create", "Create a flapjack.rc file."
    long_desc <<-LONGDESC
      Creates or overrides a ~/.flapjack.rc file that can be used by this tool.

      Example:

      $ flappy config create -p url=http://localhost:3081 
    LONGDESC
    def create()
      config = Flapjack::Client::Util::Config.new(parent_options['config'],
                                                parent_options['uri'])     
      config.create_config(options[:params])
    end

    desc "display", "Display the contents of the flapjack.rc file."
    long_desc <<-LONGDESC
      Displays config from the flapjack.rc file.

      Example:

      $ flappy config display -c url=http://localhost:3081 
    LONGDESC
    def display()
      config = Flapjack::Client::Util::Config.new(parent_options['config'],
                                                parent_options['uri'])     
      config.load_config().each do |k,v|
        if k && v
          puts "#{k}=#{v}"
        end
      end
    end

  end
end; end; end
