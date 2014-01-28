module Flapjack; module Client; module Util
  class Config
    attr_accessor :rc_file

    def initialize(rc_file=nil, uri=nil, logfile='/tmp/flapjack_diner.log')
      if rc_file
        @rc_file = rc_file
      else
        @rc_file = ENV['HOME'] + '/.flapjack.rc'
      end
      @uri = uri
      @logfile = logfile
    end

    #TODO should accept hash rather than string here.
    def create_config(params=nil)
      File.open(@rc_file, "w") do |f|     
        if params
          values = params.split(' ').each do |value|
            f.write(value + "\n")   
          end
        end
      end
    end

    def load_config
       return_hash = {}
       begin 
        File.open(@rc_file, "r") do |f|     
           contents = f.read()
           k,v = contents.split('=')
           return_hash[k] = v.strip
          end
      rescue
          if not @uri
         raise "Couldn't load Flapjack config file " + rc_file + " " + $!.inspect
          end
       end
       if @uri
          return_hash['uri'] = @uri
       end
       if @logfile
          return_hash['logfile'] = @logfile
       end
       return_hash
    end

    def get_key(key)
      load_config[key]
    end

    def get_uri
      if not get_key('uri')
        raise "Error: the Flapjack rc file does not contain a uri!"
      end
    end
  end
end; end; end
