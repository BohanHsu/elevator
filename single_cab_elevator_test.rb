require 'minitest/autorun'
require './single_cab_elevator'

describe 'Controller' do
  it 'should work' do
    all_people = []
    num = 20
    @controller = Controller.new(num)


    100.times do 
      Random.rand(10).times do
        src = Random.rand(num)
        tgt = Random.rand(num)
        while tgt == src do
          tgt = Random.rand(num)
        end
        people = People.new(@controller, src, tgt)
        all_people << people
      end
      @controller.cab.make_decision
    end

    while @controller.people.length > 0 do
      @controller.cab.make_decision
    end

    all_people.select do |p|
      !p.succeed
    end.length.must_equal(0)
  end
end
