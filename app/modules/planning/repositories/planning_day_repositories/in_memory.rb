# frozen_string_literal: true

module Planning
  module Repositories
    module PlanningDayRepositories
      class InMemory
        def initialize
          @objects = {}
        end

        def find_for_day(day)
          @objects[day]
        end

        def store(planning_day)
          @objects[planning_day.day] = planning_day
        end
      end
    end
  end
end
