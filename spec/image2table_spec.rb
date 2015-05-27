# encoding: utf-8

require 'spec_helper'

describe Image2table do
  it 'has a version number' do
    expect(Image2table::VERSION).not_to be nil
  end

  it 'should be an instance of Image2table' do
    image2table = Image2table.new
    expect(image2table).to be_an_instance_of(Image2table)
  end

  describe 'add image' do
    it 'should initialize rows and cols' do
      image = Image2table.new.add_image('./examples/example.jpg')
      expect(image.cols).to eq(100)
      expect(image.rows).to eq(100)
    end
  end

  describe 'should ransform color from rgb to hexa' do
    let(:image2table) { Image2table.new }

    it 'should return #fff for white' do
      expect(image2table.send(:rgb_to_hexa, 65535, 65535, 65535)).to eq('#fff')
    end

    it 'should return #f00 for red' do
      expect(image2table.send(:rgb_to_hexa, 255, 0, 0)).to eq('#f00')
    end

    it 'should return #f63b02 for orange' do
      expect(image2table.send(:rgb_to_hexa, 246, 59, 2)).to eq('#f63b02')
    end
  end
end
