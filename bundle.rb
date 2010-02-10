require 'ruble'

bundle 'JavaScript' do |bundle|
  bundle.author = "Christopher Williams"
  bundle.copyright = "© Copyright 2010 Aptana Inc. Distributed under GPLv3 and Aptana Source license."
  bundle.description = "Javascript bundle for RadRails"
  bundle.repository = "git://github.com/aptana/js.ruble.git"
  # Folding
  folding_start_marker = /^.*\bfunction\s*(\w+\s*)?\([^\)]*\)(\s*\{[^\}]*)?\s*$/
  folding_stop_marker = /^\s*\}/
  bundle.folding['source.js'] = folding_start_marker, folding_stop_marker
  # Indentation
  decrease_indent_pattern = /^(.*\*\/)?\s*(\}|\))([^{]*\{)?([;,]?\s*|\.[^{]*|\s*\)[;\s]*)$/
  increase_indent_pattern = /^.*(\{[^}"'']*|\([^)"'']*)$/
  bundle.indent["source.js"] = increase_indent_pattern, decrease_indent_pattern
  
  # most commands install into a dedicated JS menu
  bundle.menu "JavaScript" do |js_menu|
    # this menu should be shown when any of the following scopes is active:
    js_menu.scope = [ "source.js" ]
    
	  # command/snippet names must be unique within bundle and are case insensitive
	  js_menu.command "Documentation for Word"
    js_menu.separator
    js_menu.command "Reformat Document"
    js_menu.command "Copy as Bookmarklet to Clipboard"
  end
end