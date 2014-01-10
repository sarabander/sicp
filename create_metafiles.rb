#! /usr/bin/ruby -w
# -*- coding: utf-8 -*-

# Creates NAV and OPF files used by EPUB3.
# Copyleft 2014 Andres Raba, GNU GPL v.3.

require 'nokogiri'

# Files
DIR = "html/"              # directory where the book files are
IDX = DIR + "index.xhtml"  # index file containing table of contents
NAV = "toc.xhtml"          # epub3 navigation file (generated toc)
OPF = "content.opf"        # epub3 metadata, manifest, and spine

PREFIX = 'x'               # to prepend ids that could start with a digit

# Templates
NAV_T = <<EOF
<?xml version="1.0"?>
<html xmlns="http://www.w3.org/1999/xhtml" 
      xmlns:epub="http://www.idpf.org/2007/ops">
<head><title>SICP</title></head>
<body>
  <nav id="toc" epub:type="toc">
    <h1>Table of Contents</h1>
  </nav>
</body>
</html>
EOF

now = Time.new.strftime("%Y-%m-%dT%H:%M:%SZ")

OPF_T = <<EOF
<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xml:lang="en" 
         unique-identifier="bookid" 
         version="3.0">
  <metadata>
    <dc:title>Structure and Interpretation of Computer Programs, Second Edition</dc:title>
    <dc:creator>Harold Abelson, Gerald Jay Sussman, Julie Sussman</dc:creator>
    <dc:publisher>MIT Press</dc:publisher>
    <dc:date>1996</dc:date>
    <dc:identifier id="bookid">urn:uuid:a412368e-e0ac-42ce-8c01-0f0da52f5731</dc:identifier>
    <dc:language>en-US</dc:language>
    <meta name="cover" content="cover-image" />
    <meta property="dcterms:modified">#{now}</meta>
  </metadata>
  <manifest>
    <item id="css-style" href="#{DIR}css/style.css" media-type="text/css"/>
    <item id="css-prettify" href="#{DIR}css/prettify.css" media-type="text/css"/>
    <item id="css-fonts" href="#{DIR}css/fonts/fonts.css" media-type="text/css"/>
    <item id="cover" href="index.xhtml" properties="svg" media-type="application/xhtml+xml"/>
    <item id="cover-svg" href="#{DIR}fig/coverpage.std.svg" media-type="image/svg+xml"/>
    <item id="cover-image" href="#{DIR}fig/cover.png" properties="cover-image" media-type="image/png"/>
    <item id="cover-jpg" href="#{DIR}fig/bookwheel.jpg" media-type="image/jpeg"/>
    <item id="toc" properties="nav" href="toc.xhtml" media-type="application/xhtml+xml"/>
    <item id="nexus" href="#{DIR}index.xhtml" properties="svg" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="cover" linear="no"/>
    <itemref idref="nexus"/>
  </spine>
  <guide>
    <reference href="index.xhtml" type="cover" title="Cover"/>
  </guide>
</package>
EOF

# Procedures
def make_toc
  # Original toc as unordered list, extracted from IDX file
  toc = Nokogiri::HTML(open(IDX)).css("div.contents > ul")
  toc.css("ul").each do |ul|
    ul.delete('class')  # remove unneeded 'class' attribute
    ul.name = 'ol'      # make unordered list tags to ordered
  end
  toc.css("a").each do |a|
    a['href'] = DIR + a['href'].split('#')[0]  # prepend subdirectory
  end
  return toc
end

def prettyprint(nodeset)
  pretty = Nokogiri::XML(nodeset.inner_html) { |c| c.default_xml.noblanks }
    .to_xml(:indent => 2)
  return pretty
end

def write_nav(toc)
  nav = Nokogiri::XML(NAV_T)
  nav.css("nav#toc")[0].add_child(toc)  # inject toc to template
  pretty = prettyprint(nav)
  IO.write(NAV, pretty)
end

def contains_tag?(tag, link)
  if (/<#{tag}/.match(IO.read(link)))
    return true
  else
    return false
  end
end 

def get_links(type)  # type must be 'svg' or 'woff'
  glob = {
    'svg' => "#{DIR}fig/*/*.svg",
    'woff' => "#{DIR}css/fonts/*.woff"
  }
  pattern = {
    'svg' => %r!(?<=/)[^/]+?(?=\.std|\.svg)!,
    'woff' => %r!(?<=/)[^/]+?(?=\.woff)!
  }
  throw "Type '#{type}' not recognized." unless glob[type]
  links = `ls #{glob[type]}`.split(/\s/)
  linkhashes = links.map do |link|
    key = pattern[type].match(link)[0].tr('.', '-')
    { key => link }
  end
  return linkhashes
end
    
def xml_elem(tag)
  return Nokogiri::XML.fragment("<#{tag} />").css(tag)[0]
end

def put_links(xmlobj, links, mediatype)
  links.each do |link|
    item = xml_elem("item")
    item['id'] = PREFIX + link.keys[0]
    item['href'] = link.values[0]
    item['media-type'] = mediatype
    xmlobj.css("manifest")[0].add_child(item)  # add link to manifest
  end
end

def write_opf(links)
  opf = Nokogiri::XML(OPF_T)
  links.each do |link|
    item = xml_elem("item")
    item['id'] = PREFIX + link.split(/\/|\./)[1]
    item['href'] = link
    properties = []
    properties.push('mathml') if contains_tag?("math", link)
    properties.push('svg') if contains_tag?("object", link)
    item['properties'] = properties.join(' ') if properties.any?
    item['media-type'] = "application/xhtml+xml"
    opf.css("manifest")[0].add_child(item)  # add item to manifest

    itemref = xml_elem("itemref")
    itemref['idref'] = item['id']
    opf.css("spine")[0].add_child(itemref)  # add itemref to spine
  end
  put_links(opf, get_links('svg'), "image/svg+xml")
  put_links(opf, get_links('woff'), "application/font-woff")
  pretty = prettyprint(opf)
  IO.write(OPF, pretty)
end

# Main program
@toc = make_toc()
@links = @toc.css("a").map { |a| a['href'] }

write_nav(@toc)
write_opf(@links)

