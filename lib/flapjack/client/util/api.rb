require 'logger'
require 'flapjack-diner'

module Flapjack; module Client; module Util
  class API
    attr_accessor = :connection

    def initialize(config)
      @config = config
      Flapjack::Diner.logger = Logger.new(@config.get_key('logfile'))
      @conn = nil
    end

    def connection
      if not @conn
        Flapjack::Diner::base_uri(@config.get_key('uri'))
      end
      Flapjack::Diner
    end
  end
end; end; end
