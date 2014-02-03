module Flapjack; module Client; module Cli
  class Root < Thor

    class_option :uri, :aliases => "-u", :required => false,
      :desc => "Specify the Flapjack URI."

    class_option :config, :aliases => "-c", :required => false,
      :desc => "Specify the Flapjack config file."

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
