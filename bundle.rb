require 'ruble'

bundle do |bundle|
  bundle.author = 'Christopher Williams'
  bundle.copyright = "Copyright 2010 Aptana Inc. Distributed under the MIT license."
  bundle.display_name = t(:bundle_name)
  bundle.description = "Javascript bundle for RadRails, ported from the TextMate bundle"
  bundle.repository = "git://github.com/aptana/js.ruble.git"
  # Set up folding. Folding is now done in Java code for this language
  # folding_start_marker = /\/\*+|^.*\bfunction\s*(\w+\s*)?\([^\)]*\)(\s*\{[^\}]*)?\s*$/
  # folding_stop_marker = /\*+\/|^\s*\}/
  # bundle.folding['source.js'] = folding_start_marker, folding_stop_marker
  # Indentation
  decrease_indent_pattern = /^(.*\*\/)?\s*(\}|\))([^{]*\{)?([;,]?\s*|\.[^{]*|\s*\)[;\s]*)$/
  increase_indent_pattern = /^.*(\{[^}"'']*|\([^)"'']*)$/
  bundle.indent["source.js"] = increase_indent_pattern, decrease_indent_pattern
  
  # most commands install into a dedicated JS menu
  bundle.menu t(:bundle_name) do |js_menu|
    # this menu should be shown when any of the following scopes is active:
    js_menu.scope = [ "source.js" ]
    
	  # command/snippet names must be unique within bundle and are case insensitive
	  
	  js_menu.menu t(:core) do |core_menu|
	    core_menu.menu t(:control) do |control_menu|
	      control_menu.command t(:if)
	      control_menu.command t(:if_else)
	      control_menu.separator
	      control_menu.command t(:for)
	      control_menu.command t(:for_native)
	    end
	    core_menu.menu t(:language) do |language_menu|
        language_menu.command t(:object_key)
	      language_menu.command t(:object_value)
	      language_menu.separator
	      language_menu.command t(:prototype)
	    end
	    core_menu.menu t(:function) do |function_menu|
	      function_menu.command t(:anonymous_function)
	      function_menu.command t(:function)
	      function_menu.separator
	      function_menu.command t(:new_function)
	      function_menu.command t(:new_method)
        function_menu.separator
	      function_menu.command t(:object_method)
	      function_menu.command t(:object_method_string)
	    end
	  end
	  
	  # js_menu.menu "DOM" do |dom_menu|
	  #   dom_menu.command "Get Elements"
	  # end
	  
	  js_menu.menu t(:bom) do |bom_menu|
	    bom_menu.command t(:setTimeout)
	  end
	  
	  js_menu.command t(:doc_for_word)
    js_menu.separator
    js_menu.command t(:copy_as_bookmarklet)
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

smart_typing_pairs["source.js"] = ['"', '"', '(', ')', '{', '}', '[', ']', "'", "'"]