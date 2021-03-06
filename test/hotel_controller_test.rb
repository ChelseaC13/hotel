require_relative "test_helper"

describe Hotel::HotelController do
  before do
    @hotel_controller = Hotel::HotelController.new
    @date = Date.parse("2020-08-04")
  end
  describe "wave 1" do
    describe "rooms" do
      it "returns a list" do
        rooms = @hotel_controller.rooms
        expect(rooms).must_be_kind_of Array
      end
    end

    describe "reserve_room" do
      it "takes two Date objects and returns a Reservation" do
        start_date = @date
        end_date = start_date + 3

        reservation = @hotel_controller.reserve_room(start_date, end_date,1)

        expect(reservation).must_be_kind_of Hotel::Reservation
      end

      it "start_date and end_date should be instances of class Date" do
        start_date = @date
        end_date = start_date + 3

        reservation = @hotel_controller.reserve_room(start_date, end_date,1)

        expect(reservation.end_date).must_be_kind_of Date
        expect(reservation.start_date).must_be_kind_of Date
      end
    end

    describe "reservations" do
      it "takes a Date and returns a list of Reservations" do
        reservation_list = @hotel_controller.reservations(@date)

        expect(reservation_list).must_be_kind_of Array
        reservation_list.each do |res|
          res.must_be_kind_of Reservation
        end
      end
      it "takes a Date and returns a list of Reservations" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-10",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-09", "2020-08-12",3)

        reservation_list = @hotel_controller.reservations("2020-08-04")

        expect(reservation_list).must_be_kind_of Array
        expect(reservation_list[0].start_date).must_be_kind_of Date
        expect(reservation_list[0].start_date).must_equal Date.parse("2020-08-04")
        expect(reservation_list[0].end_date).must_equal Date.parse("2020-08-10")
        expect(reservation_list[1].start_date).must_equal Date.parse("2020-08-04")
        expect(reservation_list[1].end_date).must_equal Date.parse("2020-08-08")
        
        reservation_list1 = @hotel_controller.reservations("2020-08-11")
        expect(reservation_list1[0].start_date).must_equal Date.parse("2020-08-09")
        expect(reservation_list1[0].end_date).must_equal Date.parse("2020-08-12")
      end
    end

    describe "reservation_by_room_date" do
      it "takes a date and room and returns a list of Reservations" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-10",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-09", "2020-08-12",3)

        reservation_list2 = @hotel_controller.reservation_by_date_room(@date,1)
        expect(reservation_list2[0].start_date).must_equal Date.parse("2020-08-04")
      end
      
      it "takes a date and room and returns the correct reservation and room" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-10",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-09", "2020-08-12",3)

        reservation_list3 = @hotel_controller.reservation_by_date_room(@date,2)

        expect(reservation_list3[0].start_date).must_equal Date.parse("2020-08-04")
        expect(reservation_list3[0].end_date).must_equal Date.parse("2020-08-08")
        expect(reservation_list3[0].room).must_equal 2
        expect(reservation_list3.length).must_equal 1
        
      end 
    end
  end

  describe "wave 2" do
    describe "available_rooms" do
      it "takes two dates and returns a list" do
        start_date = @date
        end_date = start_date + 3

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list).must_be_kind_of Array
      end
    
      it "takes two dates and returns and array with the first entry of room one" do
        start_date = @date
        end_date = start_date + 3

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list[0]).must_equal 1
      end

      it "takes two dates and returns a list all available rooms" do
        start_date = @date
        end_date = start_date + 3

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list.length).must_equal 20
      end

      it "takes two dates and returns the correct rooms when dates overlap or are before or after" do
        reservation1 = @hotel_controller.reserve_room("2020-08-01", "2020-08-10",1) #front overlap
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2) #inside/contained
        reservation3 = @hotel_controller.reserve_room("2020-08-09", "2020-08-19",3) #back overlap
        reservation4 = @hotel_controller.reserve_room("2020-08-04", "2020-08-14",4) #same
        reservation5 = @hotel_controller.reserve_room("2020-08-02", "2020-08-20",6) #containing- note also skipped room 5!
        reservation6 = @hotel_controller.reserve_room("2020-08-14", "2020-08-20",5) #starts on end date, room 5 should be available
        reservation7 = @hotel_controller.reserve_room("2020-08-01", "2020-08-04",7) #res ends on a start date
        reservation8 = @hotel_controller.reserve_room("2020-07-24", "2020-08-01",8) #before
        reservation9 = @hotel_controller.reserve_room("2020-08-24", "2020-08-27",8) #after

        start_date = @date #2020-08-04
        end_date = start_date + 10

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list.length).must_equal 15
        expect(room_list).must_equal [5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
      end

      it "takes two dates and returns the correct rooms when range starts on an end date" do
        reservation1 = @hotel_controller.reserve_room("2020-08-01", "2020-08-04",1)

        start_date = @date #2020-08-04
        end_date = start_date + 10

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list.length).must_equal 20
        expect(room_list).must_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
      end

      it "takes two dates and returns the correct rooms when range is with in a reservation" do
        reservation1 = @hotel_controller.reserve_room("2020-08-01", "2020-08-10",1)

        start_date = @date #2020-08-04
        end_date = start_date + 2

        room_list = @hotel_controller.available_rooms(DateRange.new(start_date, end_date))

        expect(room_list.length).must_equal 19
        expect(room_list).must_equal [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
      end

      it "Returns Argument error for bad dates" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",1)
        
        start_date = @date #2020-08-04
        end_date = start_date - 10

        expect{@hotel_controller.available_rooms(DateRange.new(start_date, end_date))}.must_raise ArgumentError
      end

      it "Returns Argument error for no rooms available" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",3)
        reservation4 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",4)
        reservation5 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",5)
        reservation6 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",6)
        reservation7 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",7)
        reservation8 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",8)
        reservation9 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",9)
        reservation10 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",10)
        reservation11 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",11)
        reservation12 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",12)
        reservation13 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",13)
        reservation14 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",14)
        reservation15 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",15)
        reservation16 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",16)
        reservation17 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",17)
        reservation18 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",18)
        reservation19 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",19)
        reservation20 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",20)

        start_date = @date #2020-08-04
        end_date = start_date +3

        expect{@hotel_controller.available_rooms(DateRange.new(start_date, end_date))}.must_raise ArgumentError
      end
    end
    
    describe "res_with_valid_dates" do
      it "makes valid reservation with dates" do
        start_date = @date   #"2020-08-04"
        end_date = start_date + 3

        reservation = @hotel_controller.res_with_valid_dates(DateRange.new(start_date, end_date))

        expect(reservation).must_be_kind_of Hotel::Reservation
        expect(reservation.room).must_equal 1     #valid room
        expect(reservation.start_date).must_equal start_date
        expect(reservation.end_date).must_equal end_date
      end

      it "accounts for other reservations" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-10",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-09", "2020-08-12",3)

        start_date = @date #2020-08-04
        end_date = start_date + 3

        reservation = @hotel_controller.res_with_valid_dates(DateRange.new(start_date, end_date))

        expect(reservation.room).must_equal 3 
        
      end

      it "returns and error if all rooms are booked" do
        reservation1 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",1)
        reservation2 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",2)
        reservation3 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",3)
        reservation4 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",4)
        reservation5 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",5)
        reservation6 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",6)
        reservation7 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",7)
        reservation8 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",8)
        reservation9 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",9)
        reservation10 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",10)
        reservation11 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",11)
        reservation12 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",12)
        reservation13 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",13)
        reservation14 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",14)
        reservation15 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",15)
        reservation16 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",16)
        reservation17 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",17)
        reservation18 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",18)
        reservation19 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",19)
        reservation20 = @hotel_controller.reserve_room("2020-08-04", "2020-08-08",20)

        start_date = @date #2020-08-04
        end_date = start_date + 3

        expect{@hotel_controller.res_with_valid_dates(DateRange.new(start_date, end_date))}.must_raise ArgumentError
      end
    end
  end

  describe "wave 3" do
    describe "set_aside_block" do
  
      it "reserves rooms in a date range" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")
  
        expect(@hotel_controller.reservation_array).must_be_kind_of Array 
        expect(@hotel_controller.reservation_array.length).must_equal 5
      end

      it "does not reserve rooms in a block if a reservation comes in with the same date." do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")
        
        new_res = @hotel_controller.res_with_valid_dates(DateRange.new(@date,@date + 3))
        
        expect(@hotel_controller.reservation_array.length).must_equal 6
        expect(@hotel_controller.reservation_array[5].room).must_equal 6 # could not reserve room 1-5 because it was reserved
      end

      it "reserves room on end date of block" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")
  
        new_res = @hotel_controller.res_with_valid_dates(DateRange.new(@date + 3,(@date + 6))) #reserving room on block end date

        expect(@hotel_controller.reservation_array.length).must_equal 6
        expect(@hotel_controller.reservation_array[5].room).must_equal 1
      end

      it "cannot make a block on a block" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")

        expect{@hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")}.must_raise ArgumentError
      end

      it "raises argument error if block has an unavailable room" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]

        new_res = @hotel_controller.res_with_valid_dates(DateRange.new(@date,(@date + 3))) 

        expect{@hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")}.must_raise ArgumentError
      end

      it "cannot make a block on with one overlap in room" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")

        collection_of_rooms2 = [5, 6, 7, 8, 9]

        expect{@hotel_controller.set_aside_block(date_range, collection_of_rooms2, "id1")}.must_raise ArgumentError
      end

      it "cannot make a block on with one day overlap" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block = @hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")

        date_range2 = DateRange.new(@date + 2,(@date + 4))

        expect{@hotel_controller.set_aside_block(date_range2, collection_of_rooms, "id1")}.must_raise ArgumentError
      end

      it "cannot make a block with 6 rooms" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5, 6]
        
        expect{@hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")}.must_raise ArgumentError
      end

      it "cannot make a block with 1 rooms" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1]
        
        expect{@hotel_controller.set_aside_block(date_range, collection_of_rooms, "id1")}.must_raise ArgumentError
      end
    end

    describe "block_status_by_id" do
  
      it " returns true if there is an available room in a block" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block_id = "ada"
        @hotel_controller.set_aside_block(date_range, collection_of_rooms, block_id)

        expect(@hotel_controller.block_status_by_id("ada")).must_equal true
      end

      it " returns true if the 5th room is the only availble room" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block_id = "ada"
        @hotel_controller.set_aside_block(date_range, collection_of_rooms, block_id)

        @hotel_controller.reserve_block_room("ada",1)
        @hotel_controller.reserve_block_room("ada",2)
        @hotel_controller.reserve_block_room("ada",3)
        @hotel_controller.reserve_block_room("ada",4)

        expect(@hotel_controller.block_status_by_id("ada")).must_equal true
      end

      it " returns false if no rooms are available" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block_id = "ada"
        @hotel_controller.set_aside_block(date_range, collection_of_rooms, block_id)

        @hotel_controller.reserve_block_room("ada",1)
        @hotel_controller.reserve_block_room("ada",2)
        @hotel_controller.reserve_block_room("ada",3)
        @hotel_controller.reserve_block_room("ada",4)
        @hotel_controller.reserve_block_room("ada",5)

        expect(@hotel_controller.block_status_by_id("ada")).must_equal false
      end
    end

    describe "reserve_block_room" do
  
      it "Makes set aside block room unavailable" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block_id = "ada"
        @hotel_controller.set_aside_block(date_range, collection_of_rooms, block_id)
        @hotel_controller.reserve_block_room("ada",3)

        expect(@hotel_controller.reservation_array[2].blocks_room_status).must_equal "unavilable"
      end

      it "returns an error if no block rooms are available" do
        date_range = DateRange.new(@date,(@date + 3))
        collection_of_rooms = [1, 2, 3, 4, 5]
        block_id = "ada"
        @hotel_controller.set_aside_block(date_range, collection_of_rooms, block_id)
        
        @hotel_controller.reserve_block_room("ada",1)
        @hotel_controller.reserve_block_room("ada",2)
        @hotel_controller.reserve_block_room("ada",3)
        @hotel_controller.reserve_block_room("ada",4)
        @hotel_controller.reserve_block_room("ada",5)

        expect{@hotel_controller.reserve_block_room("ada",3)}.must_raise ArgumentError
      end
    end
  end
end