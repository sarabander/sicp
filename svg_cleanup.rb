#! /usr/bin/ruby -w
# -*- coding: utf-8 -*-

require 'nokogiri'

ARGV.each do |file|
  svg = Nokogiri::XML(open(file))
  svg.at("metadata").inner_html = 
    "\n  <!--" + svg.at("metadata").inner_html + "-->\n"
  svg.css("flowRoot").each { |e| e.remove }
  IO.write(file, svg)
end
