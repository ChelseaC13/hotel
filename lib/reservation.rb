require 'Date'

module Hotel
  class Reservation 
    attr_accessor :start_date, :end_date

    def initialize(start_date, end_date, id = nil)  #is a third item needed here an id?
     @id = id
     @date_range = DateRange.new(start_date, end_date)

      if start_date.class == String
        start_date = Date.parse(start_date)
      end
      @start_date = start_date
    
      if end_date.class == String
        end_date = Date.parse(end_date)
      end
      @end_date = end_date
    
      if @end_date && (@end_date < @start_date)
        raise ArgumentError, "End time cannot be before start time."
      end
    
      if @end_date && (@end_date == @start_date)
        raise ArgumentError, "You cannot have a 0 length date range."
      end
    end

    def cost(start_date, end_date)
      cost = DateRange.new(start_date, end_date).nights * 200
      return cost.to_i
    end
  end
end