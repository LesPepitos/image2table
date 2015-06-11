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
        colors[y][x] = if color.to_hsla.last < 1
                         hsla_to_rgba(color.to_hsla)
                       else
                         rgb_to_hexa(color.red, color.green, color.blue)
                       end
      end
    end
  end


  def generate_table
    bgcolor = most_common_color
    html = "<table height='#{rows}' width='#{cols}' style='border-collapse:collapse;border-spacing:0'"
    if image.opaque?
      html << " bgcolor=#{bgcolor}"
    end
    html << ">"

    rows.times do |y|
      html << "<tr>"
      cells = calulate_colspan(colors[y])
      cells.each do |cell|
        html << "<td"
        html << "#{get_style_bg_color(cell[:color])}" if cell[:color] != bgcolor
        html << " colspan='#{cell[:repeat]}'" if cell[:repeat] > 1
        html << "/>"
      end
      html << "</tr>"
    end
    html << "</table>"
  end


  # @return [String]
  def rgb_to_hexa(red, green, blue)
    hexa = sprintf('%02x%02x%02x', red&0xff, green&0xff, blue&0xff)
    if hexa[0] == hexa[1] && hexa[2] == hexa[3] && hexa[4] == hexa[5]
      hexa = "#{hexa[0]}#{hexa[2]}#{hexa[4]}"
    end
    "##{hexa}"
  end


  # @return [String]
  def hsla_to_rgba(color)
    rgba = []
    colors = Magick::Pixel.from_hsla(*color)
    ['red', 'green', 'blue'].each do |c|
      rgba << (colors.send(c) / 257).round()
    end
    rgba << color[3].round(2)
  end


  # @return [String]
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


  # @return [Boolean]
  def color_is_hexa?(color)
    color[0] == '#'
  end


  # @return [String]
  def get_style_bg_color(color)
    html = ""
    if color_is_hexa?(color)
      html = " bgcolor='#{color}'"
    elsif color[3].to_f > 0
      html = " style='background:rgba(#{color.join(',')})'"
    end
  end
end
