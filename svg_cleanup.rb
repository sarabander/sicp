#! /usr/bin/ruby -w
# -*- coding: utf-8 -*-

# Deletes those elements and attributes from SVG files
# that are not in SVG 1.1 specification and will cause
# epubcheck to complain. Give files to process as arguments.

require 'nokogiri'

deletables = {
  'g'     => ['groupmode', 'label'],
  'path'  => ['connector-curvature', 'nodetypes'],
  'svg'   => ['docname', 'export-filename', 'export-xdpi',
             'export-ydpi', 'version'],
  'text'  => ['linespacing'],
  'tspan' => ['role']
}

def delete_attributes(svg, deletables)
  deletables.each do |element, attributes|
    svg.css(element).each do |tag|
      attributes.each do |attribute|
        tag.delete(attribute)
      end
    end
  end
end

ARGV.each do |file|
  svg = Nokogiri::XML(open(file))
  # gives error if 'sodipodi' namespace is not declared:
  svg.css("sodipodi|namedview").each { |e| e.remove }
  delete_attributes(svg, deletables)
  svg.css("svg").each { |e| e['version'] = "1.1" }
  IO.write(file, svg)
end
