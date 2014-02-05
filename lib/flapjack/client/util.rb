require 'flapjack/client/util/config'
require 'flapjack/client/util/api'

module Flapjack; module Client
  module Util

    def Util.get_maintenances(api, entity_and_check, start_time, end_time, scheduled, unscheduled)
      entity, check = entity_and_check.split(':')
      maintenances = []
      if scheduled
        api.connection.scheduled_maintenances(entity, {
          :check      => check,
          :start_time => start_time,
          :end_time   => end_time,
        }).each do |maint|
          maintenances << maint
        end
      end
      if unscheduled
        api.connection.unscheduled_maintenances(entity, {:check => check}).each do |maint|
          maintenances << maint
        end
      end
      maintenances
    end

    def Util.format_maintenances(entity_and_check, maintenances)
      output = []
      output << "Maintenance modes for #{entity_and_check}:\n"
      if ! maintenances.nil?
        maintenances.each do |maint|
          output << "Summary    #{maint['summary']}"
          output << "Start Time #{Time.at(maint['start_time'])}"
          output << "End Time   #{Time.at(maint['end_time'])}"
          output << "Duration   #{maint['duration']}\n"
        end
      else
        output << "None"
      end
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

  end
end; end
