require "rmagick"
require_relative "image2table/version"

class Image2table
  attr_reader :colors, :image, :rows, :cols

  STYLE = '<style>*{border:0;margin:0;padding:0;}td{width:1;height:1;}</style>'.freeze

  def initialize
    @colors = []
  end

  # @return [Image2table]
  def add_image(path)
    @image = Magick::Image.read(path).first
    @rows = image.rows
    @cols = image.columns
    self
  end

  # @return [String]
  def to_table
    extract_colors
    generate_table
  end

  # @return [String]
  def to_html(output='image.html')
    extract_colors
    File.open(output, 'w') do |f|
      f << STYLE
      f << generate_table
    end
  end

  private

  def extract_colors
    rows.times do |y|
      colors[y] = []
      cols.times do |x|
        color = image.pixel_color(x, y)
        colors[y][x] = rgb_to_hexa(color.red, color.green, color.blue)
      end
    end
  end

  def generate_table
    bgcolor = most_common_color
    html = "<table height='#{rows}' width='#{cols}' bgcolor='#{bgcolor}' style='border-collapse:collapse;border-spacing:0'>"
    rows.times do |y|
      html << "<tr>"
      cells = calulate_colspan(colors[y])
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
    colors.flatten.group_by(&:itself).values.max_by(&:size).first
  end

  def calulate_colspan(color_rows)
    cells = []
    color_rows.each_with_index do |color, index|
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
