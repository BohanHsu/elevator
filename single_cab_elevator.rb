class Controller
  attr_accessor :floors, :num_of_floors, :people, :cab

  class Request
    attr_accessor :up, :down
    def initialize
      @up = false
      @down = false
    end
  end

  def initialize(num_of_floors)
    @num_of_floors = num_of_floors
    @floors = @num_of_floors.times.map {Request.new}
    @cab = Cab.new(self)
    @people = []
  end

  def call_cab(floor, direction)
    if direction == :up
      @floors[floor].up = true
    else
      @floors[floor].down = true
    end
  end

  def open_door(cab, floor, direction)
    if direction == :up
      @floors[floor].up = false
    else
      @floors[floor].down = false
    end

    @people.each do |pe|
      pe.open_door(cab, floor, direction)
    end
  end

  def check_cab_floor
    return @cab.floor
  end

  def check_cab_direction
    return @cab.direction
  end

  def add_people(pe)
    @people << pe
  end

  def delete_people(p)
    @people.delete(p)
  end
end

class Cab
  attr_accessor :cur_floor, :direction, :destination

  def initialize(controller)
    @controller = controller
    @cur_floor = 0
    @direction = nil
    @destination = [] # btn with light on
  end

  def goto_floor(floor)
    if !@destination.include?(floor)
      @destination << floor
    end
  end

  def make_decision
    # check if door need to be opened
    if @destination.include?(@cur_floor) || (@controller.floors[@cur_floor].up && @direction != :down) || (@controller.floors[@cur_floor].down && @direction != :up)
      @controller.open_door(self, @cur_floor, @direction)
      if @destination.include?(@cur_floor)
        @destination.delete(@cur_floor)
      end
    end

    # check if direction need to be change
    if @direction.nil?
      @controller.floors.each_with_index do |request, i|
        if request.up || request.down || @destination.include?(i)
          if @cur_floor < i
            @direction = :up
            break
          elsif @cur_floor > i
            @direction = :down
            break
          end
        end
      end
    elsif @direction == :up
      i = @cur_floor + 1
      while i < @controller.num_of_floors do
        if @destination.include?(i) || @controller.floors[i].up || @controller.floors[i].down
          break
        end
        i += 1
      end

      if i >= @controller.num_of_floors
        @direction = nil
        (0...@cur_floor).each do |i| 
          if @destination.include?(i) || @controller.floors[i].up || @controller.floors.down
            @direction = :down
            break
          end
        end
      end
    elsif @direction == :down
      i = 0
      while i < @cur_floor do
        if @destination.include?(i) || @controller.floors[i].up || @controller.floors.down
          break
        end
        i += 1
      end

      if i >= @cur_floor
        @direction = nil
        (@cur_floor...@controller.num_of_floors).each do |i| 
          if @destination.include?(i) || @controller.floors[i].up || @controller.floors.down
            @direction = :up
            break
          end
        end
      end
    end

    if @direction == :up
      @cur_floor += 1
    elsif @direction == :down
      @cur_floor -= 1
    end
    return
  end
end

class People
  attr_accessor :succeed
  def initialize(controller, src, tgt)
    @cab = nil
    @direction = src > tgt ? :down : :up
    @succeed = false
    @controller = controller
    @controller.add_people(self)
    @controller.call_cab(src, @direction)
  end


  def open_door(cab, floors, direction)
    if floors == @src && direction == @direction
      @cab = cab
    end

    if floors == @tgt
      @cab = nil
      @controller.delete_people(self)
      @succeed = true
    end
  end
end
