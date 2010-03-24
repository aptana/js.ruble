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
	  js_menu.command "Documentation for Word"
    js_menu.separator
    js_menu.command "Reformat Document"
    js_menu.command "Copy as Bookmarklet to Clipboard"
  end
end

# Extend Ruble::Editor to add special ENV vars
module Ruble
  class Editor
    unless method_defined?(:modify_env_pre_js_bundle)
      alias :modify_env_pre_js_bundle :modify_env
      def modify_env(scope, env)
        env_hash = modify_env_pre_js_bundle(scope, env)
        if scope.start_with? "source.js"
          env_hash['TM_COMMENT_START'] = "// "          
          env_hash.delete('TM_COMMENT_END')
          env_hash['TM_COMMENT_START_2'] = "/* "
          env_hash['TM_COMMENT_END_2'] = " */"
          env_hash.delete('TM_COMMENT_DISABLE_INDENT')
        end
        env_hash
      end
    end
  end
end