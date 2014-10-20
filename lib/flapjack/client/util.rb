require 'flapjack/client/util/config'
require 'flapjack/client/util/api'

module Flapjack; module Client
  module Util

    def Util.enable_maintenance(api, entity_and_check, options)
      entity, checks = entity_and_check.split(':')
      if checks.nil?
        if api.connection.bulk_create_scheduled_maintenance!(
          :entity     => [entity],
          :start_time => options['start'],
          :duration   => options['duration'],
          :summary    => options['summary'])
          puts "Set maintenance mode for #{entity}:#{checks} starting at #{options['start']} for #{options['duration']} seconds."
        else
          raise "Couldn't set maintenance mode " + $!.inspect
        end
      elsif checks.split(',').length == 1
        if api.connection.create_scheduled_maintenance!(entity, checks,
          :start_time => options['start'],
          :duration   => options['duration'],
          :summary    => options['summary'])
          puts "Set maintenance mode for #{entity}:#{checks} starting at #{options['start']} for #{options['duration']} seconds."
        else
          raise "Couldn't set maintenance mode " + $!.inspect
        end
      else
        if api.connection.bulk_create_scheduled_maintenance!(
          :check      => { entity => checks.split(',') },
          :start_time => options['start'],
          :duration   => options['duration'],
          :summary    => options['summary'])
          puts "Set maintenance mode for #{entity}:#{checks} starting at #{options['start']} for #{options['duration']} seconds."
        else
          raise "Couldn't set maintenance mode " + $!.inspect
        end
      end
    end

    def Util.disable_maintenance(api, entity_and_check, options)
      now = Time.now
      entity, checks = entity_and_check.split(':')
      if checks.nil? or checks.split(',').length > 1
        checks_in_maint = {}
        api.connection.scheduled_maintenances(entity,
          :start_time => Time.local(2014,01,01),
          :end_time   => now,
        ).each do |check|
          if not checks.nil? and checks.split(',').any?
            next unless checks.split(',').include?(check["check"])
          end
          check["scheduled_maintenance"].each do |maint|
            if Time.at(maint['end_time']) > now and Time.at(maint['start_time']) < now
              checks_in_maint[maint['start_time']] = [] if ! checks_in_maint[maint['start_time']]
              checks_in_maint[maint['start_time']] << check["check"]
            end
          end
        end
        checks_in_maint.each do |start_time, checks|
          if api.connection.bulk_delete_scheduled_maintenance!(
            :check      => { entity => checks },
            :start_time => Time.at(start_time),
          )
            checks.each do |check|
              puts "Removed maintenance mode for #{entity}:#{check} starting at #{Time.at(start_time)}."
            end
          else
            raise "Couldn't disable maintenance mode " + $!.inspect
          end
        end
      else
        api.connection.scheduled_maintenances(entity, {
          :check      => checks,
          :start_time => Time.local(2014,01,01),
          :end_time   => now,
        }).each do |maint|
          if Time.at(maint['end_time']) > now and Time.at(maint['start_time']) < now
            if api.connection.delete_scheduled_maintenance!(entity, checks,
              :start_time => Time.at(maint['start_time']))
              puts "Removed maintenance mode for #{entity}:#{checks} starting at #{Time.at(maint['start_time'])}."
            else
              raise "Couldn't disable maintenance mode " + $!.inspect
            end
          end
        end
      end
    end

    def Util.get_checks(api, entity)
      begin
        api.connection.checks(entity).each do |check|
          puts check
        end
      rescue NoMethodError
      end
    end

    def Util.get_maintenances(api, entity_and_check, start_time, end_time, scheduled, unscheduled)
      entity, checks = entity_and_check.split(':')
      maintenances = []
      if checks.nil? or checks.split(',').length > 1
        if scheduled
          api.connection.scheduled_maintenances(entity,
            :start_time => start_time,
            :end_time   => end_time,
          ).each do |maint|
            maintenances << maint
          end
        end
        if unscheduled
          api.connection.unscheduled_maintenances(entity).each do |maint|
            maintenances << maint
          end
        end
      else
        if scheduled
          api.connection.scheduled_maintenances(entity,
            :check      => checks,
            :start_time => start_time,
            :end_time   => end_time,
          ).each do |maint|
            maintenances << maint
          end
        end
        if unscheduled
          api.connection.unscheduled_maintenances(entity, {:check => check}).each do |maint|
            maintenances << maint
          end
        end
      end
      maintenances
    end

    def Util.format_maintenances(entity_and_check, maintenances)
      entity, checks = entity_and_check.split(':')
      output = []
      output << "Maintenance modes for #{entity}:\n"
      if maintenances.nil?
        output << "  None"
        return output.join("\n")
      end
      if checks.nil?
        maintenances.each do |check|
          check["scheduled_maintenance"].each do |maint|
            output << Util.format_check_maintenance(check["check"], maint)
          end
        end
      elsif checks.split(',').length == 1
        maintenances.each do |maint|
          output << Util.format_check_maintenance(checks, maint)
        end
      else
        checks = checks.split(',')
        maintenances.each do |check|
          if checks.include?(check["check"])
            if not check["scheduled_maintenance"].empty?
              check["scheduled_maintenance"].each do |maint|
                output << Util.format_check_maintenance(check["check"], maint)
              end
            else
              output << "  #{check["check"]}"
              output << "    None"
            end
          end
        end
      end
      output << "  None" if output.length == 1
      output.join("\n")
    end

    def Util.format_check_maintenance(check, maintenance)
      output = []
      output << "  #{check}"
      output << "    Summary    #{maintenance["summary"]}"
      output << "    Start Time #{Time.at(maintenance["start_time"])}"
      output << "    End Time   #{Time.at(maintenance["end_time"])}"
      output << "    Duration   #{maintenance["duration"]}\n"
      output.join("\n")
    end

    def Util.get_status(api, entity_and_check)
      entity, checks = entity_and_check.split(':')

      output = []
      output << entity

      if checks.nil?
        api.connection.status(entity).each do |check|
          output << "#{check["name"]}  #{check["state"]}"
        end
      elsif checks.split(',').length == 1
        check = api.connection.status(entity, :check => checks)
        output << "#{check["name"]}  #{check["state"]}"
      else
        api.connection.bulk_status(:check => {entity => checks.split(',')}).each do |entity|
          output << "#{entity["status"]["name"]}  #{entity["status"]["state"]}"
        end
      end
      output
    end

    def Util.get_contact_id_by_name(api, name)
     contact_ids = []
     begin
       api.connection.contacts.each do |contact|
         first, last = name.split(" ")
         if contact['first_name'] == first and contact['last_name'] == last
           contact_ids << contact['id']
         end
       end
     end
     if contact_ids.count > 1
       raise "Found more than one contact with the name #{name}."
     elsif contact_ids.count < 1
       raise "Could not find contact with name #{name}."
     end
     contact_ids.first
    end   

    def Util.get_contact_id(api, options)
      if options[:contact_name]
        contact_id = Util.get_contact_id_by_name(api, options[:contact_name])
      elsif options[:contact_id]
        contact_id = options[:contact_id]
      else
        raise "Must specify either contact name or contact id!"
      end
    end

    def Util.get_notification_rules(api, contact_id)
      begin
        api.connection.notification_rules(contact_id)
      rescue
        raise "Couldn't get notification_rules " + $!.inspect
      end
    end

    def Util.format_notification_rules(rules)
      output = []
      if rules
        rules.each do |rule|
          output << "#{rule['id']}"
          rule.each do |k,v|
            if not ['id', 'contact_id'].include? k
              output << "    #{k}: #{v}"
            end
          end
        end
      end
      output.join("\n")
    end

    def Util.delete_notification_rule(api, rule_id)
      begin
        api.connection.delete_notification_rule!(rule_id)
      rescue
        raise "Couldn't delete notification_rule #{rule_id} " + $!.inspect
      end
    end

    def Util.get_default_notification_rules(api, rules)
      default_rules = []
      rules.each do |rule|
        if rule['tags'] == [] and rule['entities'] == [] and 
          rule['warning_media'] == ["email", "sms", "jabber", "pagerduty"] and
          rule['critical_media'] == ["email", "sms", "jabber", "pagerduty"] and
          rule['unknown_blackhole'] == false and rule['warning_blackhole'] == false and
          rule['critical_blackhole'] == false
          default_rules << rule
        end
      end
      default_rules
    end

    def Util.notification_rule_exists(api, rule)
      existing_rules = Util.get_notification_rules(api, rule['contact_id'])
      ['tags', 'entities', 'unknown_media', 'warning_media', 'critical_media'].each do |k|
        if not rule.has_key?(k)
          rule[k] = []
        end
      end
      ['unknown_blackhole', 'warning_blackhole', 'critical_blackhole'].each do |k|
        if not rule.has_key?(k)
          rule[k] = false
        end
      end
      if not rule.has_key?('time_restrictions')
        rule['time_restrictions'] = nil
      end
      if existing_rules
        existing_rules.each do |existing_rule|
          existing_rule.delete('id')
          if existing_rule == rule
            return true
          end
        end
      end
      false
    end

    def Util.blackhole_default_rule(api, contact_id)
      blackhole_rule = {'contact_id' => contact_id,
              'unknown_blackhole'    => true,
              'warning_blackhole'    => true,
              'critical_blackhole'   => true}
      while true
        rules = Util.get_notification_rules(api, contact_id)
        default_rules = Util.get_default_notification_rules(api, rules)
        if default_rules.count == 1
          default_rules.each do |default_rule|
            Util.update_notification_rule(api, default_rule['id'], blackhole_rule)  
          end
        elsif default_rules.count > 1
          default_rules.each do |default_rule|
            Util.delete_notification_rule(api, default_rules.first['id'])  
          end
        elsif default_rules.count == 0
          break
        end
      end
            
    end

    def Util.update_notification_rule(api, rule_id, rule)
      begin
        api.connection.update_notification_rule!(rule_id, rule)
      rescue
        raise "Couldn't update notification_rule #{rule_id} " + $!.inspect
      end
    end

  end
end; end
