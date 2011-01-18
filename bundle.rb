require 'ruble'

bundle do |bundle|
  bundle.author = 'Christopher Williams'
  bundle.copyright = "© Copyright 2010 Aptana Inc. Distributed under the MIT license."
  bundle.display_name = 'JavaScript'
  bundle.description = "Javascript bundle for RadRails, ported from the TextMate bundle"
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
	  
	  js_menu.menu "Core" do |core_menu|
	    core_menu.menu "Control" do |control_menu|
	      control_menu.command "if"
	      control_menu.command "if ... else"
	      control_menu.separator
	      control_menu.command "for (...) {...}"
	      control_menu.command "for (...) {...} (Improved Native For-Loop)"
	    end
	    core_menu.menu "Language" do |language_menu|
        language_menu.command "Object key - key: \"value\""
	      language_menu.command "Object Value JS"
	      language_menu.separator
	      language_menu.command "Prototype"
	    end
	    core_menu.menu "Function" do |function_menu|
	      function_menu.command "Anonymous Function"
	      function_menu.command "Function"
	      function_menu.separator
	      function_menu.command "New Function"
	      function_menu.command "New Method"
        function_menu.separator
	      function_menu.command "Object Method"
	      function_menu.command "Object Method String"
	    end
	  end
	  
	  # js_menu.menu "DOM" do |dom_menu|
	  #   dom_menu.command "Get Elements"
	  # end
	  
	  js_menu.menu "BOM" do |bom_menu|
	    bom_menu.command "setTimeout function"
	  end
	  
	  js_menu.command "Documentation for Word"
    js_menu.separator
    js_menu.command "Reformat Document"
    js_menu.command "Copy as Bookmarklet to Clipboard"
  end
end

# Add special ENV vars
env "source.js" do |e|
  e['TM_COMMENT_START'] = "// "          
  e.delete('TM_COMMENT_END')
  e['TM_COMMENT_START_2'] = "/* "
  e['TM_COMMENT_END_2'] = " */"
  e.delete('TM_COMMENT_DISABLE_INDENT')
end

#smart_typing_pairs["source.js"] = ['"', '"', '(', ')', '{', '}', '[', ']', "'", "'"]