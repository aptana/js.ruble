require 'ruble'
require 'beautify2'
 
command "Reformat Document" do |cmd|
  cmd.key_binding = "CTRL+SHIFT+H"
  cmd.output = :replace_selection
  cmd.input = :selection, :document
  cmd.scope = "source.js"
  cmd.invoke { Beautifier.new.js_beautify($stdin.read) }
end