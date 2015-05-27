# encoding: utf-8

$: .unshift(File.dirname(__FILE__))

require 'rmagick'
require "image2table/version"

class Image2table
  def initialize
    @colors = []
  end

  def add_image(image)
    @image = Magick::Image.read(image).first
    @rows = @image.rows
    @cols = @image.columns
  end

  def to_table
    extract_colors
    generate_table
  end

  def to_html(output='image.html')
    extract_colors
    html = "<style>*{border:0;margin:0;padding:0;}td{width:1;height:1;}</style>"
    html << generate_table
    File.open(output, 'w') do |f|
      f.puts html
    end
  end

  private

  def extract_colors
    10.times do |y|
      @colors[y] = []
      10.times do |x|
        color = @image.pixel_color(x, y)
        @colors[y][x] = rgb_to_hexa(color.red, color.green, color.blue)
      end
    end
  end

  def generate_table
    bgcolor = most_common_color
    html = "<table height='#{@rows}' width='#{@cols}' bgcolor='#{bgcolor}' style='border-collapse:collapse;border-spacing:0'>"
    @rows.times do |y|
      html << "<tr>"
      cells = calulate_colspan(@colors[y])
      cells.each do |cell|
        html << "<td"
        html << " bgcolor='#{cell[:color]}'" if cell[:color] != bgcolor
        html << " colspan='#{cell[:repeat]}'" if cell[:repeat] > 1
        html << "/>"
      end
      html << "</tr>"
    end
    html << "</table>"
  end

  def rgb_to_hexa(red, green, blue)
    hexa = sprintf('%02x%02x%02x', red&0xff, green&0xff, blue&0xff)
    if hexa[0] == hexa[1] && hexa[2] == hexa[3] && hexa[4] == hexa[5]
      hexa = "#{hexa[0]}#{hexa[2]}#{hexa[4]}"
    end
    "##{hexa}"
  end

  def most_common_color
    colors = @colors.flatten
    colors.group_by(&:itself).values.max_by(&:size).first
  end

  def calulate_colspan(colors)
    cells = []
    colors.each_with_index do |color, index|
      previous_cell = cells.last
      if index > 0 && color == previous_cell[:color]
        previous_cell[:repeat] += 1
      else
        cells << {color: color, repeat: 1}
      end
    end
    cells
  end
end
