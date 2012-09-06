require 'spec_helper'

describe GameManager do

  subject { GameManager.new }

  describe '#player_wins?' do

    context 'winning conditions met' do
      before do
        subject.instance_variable_set(:@gem_count, 5)
        subject.instance_variable_set(:@current_room, subject.__send__(:get_room_by_name, 'cobalt'))
      end

      it 'should return true' do
        subject.__send__(:player_wins?).should eq true
      end
    end

    context 'winning conditions not met' do
      it 'should return false' do
        subject.__send__(:player_wins?).should eq false
      end
    end

  end

  describe '#time_to_rest?' do
    context 'just starting' do
      it 'should return false' do
        subject.__send__(:time_to_rest?).should eq false
      end
    end

    context 'move 4' do
      before do
        subject.instance_variable_set(:@moves, 4)
      end

      it 'should return true' do
        subject.__send__(:time_to_rest?).should eq true
      end
    end
  end

  describe '#move_grue' do
    context 'grue is in Cobalt' do
      before do
        subject.instance_variable_set(:@grue_room, subject.__send__(:get_room_by_name, 'cobalt'))
      end

      it 'should move to Vermilion if moving north' do
        subject.__send__(:move_grue, 'north')
        subject.instance_variable_get(:@grue_room).name.should eq 'vermilion'
      end

      it 'should move to Burnt sienna if moving south' do
        subject.__send__(:move_grue, 'south')
        subject.instance_variable_get(:@grue_room).name.should eq 'burnt_sienna'
      end
    end
  end

  describe '#move' do
    context 'player is at Cobalt' do
      before do
        subject.instance_variable_set(:@current_room, subject.__send__(:get_room_by_name, 'cobalt'))
      end

      it 'should move to Vermilion if moving north' do
        subject.__send__(:move, 'north')
        subject.instance_variable_get(:@current_room).name.should eq 'vermilion'
      end

      it 'should move to Vermilion if moving west' do
        subject.__send__(:move, 'west')
        subject.instance_variable_get(:@current_room).name.should eq 'vermilion'
      end

      it 'should move to Burnt sienna if moving south' do
        subject.__send__(:move, 'south')
        subject.instance_variable_get(:@current_room).name.should eq 'burnt_sienna'
      end

      it 'should stay if moving to a locked door (east)' do
        subject.__send__(:move, 'east')
        subject.instance_variable_get(:@current_room).name.should eq 'cobalt'
      end
    end
  end
end