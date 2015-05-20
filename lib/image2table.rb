# encoding: utf-8
$: .unshift(File.dirname(__FILE__))

require 'rubygems'
require 'rmagick'
require "image2table/version"

class Image2table

  def initialize(image, html=false)
    @image = Magick::Image.read(image).first
    @rows = @data.rows
    @cols = @data.columns
    @colors = []
  end

  def convert
    extract_colors
    create_html_table
  end

  def extract_colors
    @rows.each do |x|
      @cols.each do |y|
        color = @image.pixel_color(x, y)
        @colors << sprintf('#%02x%02x%02x', color.red&0xff, color.green&0xff, color.blue&0xff)
      end
    end
  end

  def create_html_table
    html = "<table height='#{@rows}' width='#{@cols}'>"
    @rows.each do |x|
      html += "<tr>"
      @cols.each do |y|
        html += "<td style='background-color:#{@colors}'></td>"
      end
      html += "<tr>"
    end
    html += "</table>"
  end
end
