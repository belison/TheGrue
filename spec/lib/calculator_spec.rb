require 'spec_helper'

describe Calculator do

  let(:rooms) {
    room_config = YAML.load_file(Rails.root.join('spec', 'test_room_config.yml'))
    room_config["rooms"].map do |config|
      ::Room.new(config.first, config[1])
    end
  }

  subject { Calculator.new(rooms) }

  describe '#generate_room_map' do
    before do
      subject.generate_room_map
    end

    context 'from the perspective of Cobalt' do
      let(:cobalt) { subject.__send__(:room_by_name, 'cobalt') }

      it 'shortest direction to Emerald should be south' do
        emerald = subject.__send__(:room_by_name, 'emerald')
        cobalt.shortest_direction_to_room(emerald).should eq 'south'
      end

      it 'shortest direction to Lavender should be south' do
        lavender = subject.__send__(:room_by_name, 'lavender')
        cobalt.shortest_direction_to_room(lavender).should eq 'south'
      end
    end

    context 'from the perspective of Emerald' do
      let(:emerald) { subject.__send__(:room_by_name, 'emerald') }

      it 'shortest direction to Vermilion should be west' do
        verm = subject.__send__(:room_by_name, 'vermilion')
        emerald.shortest_direction_to_room(verm).should eq 'west'
      end

      it 'shortest direction to Violet should be south' do
        violet = subject.__send__(:room_by_name, 'violet')
        emerald.shortest_direction_to_room(violet).should eq 'south'
      end

      it 'shortest direction to Burnt sienna should be east' do
        burnt = subject.__send__(:room_by_name, 'burnt_sienna')
        emerald.shortest_direction_to_room(burnt).should eq 'east'
      end
    end
  end
end