require 'ruble'
 
command t(:reformat_document) do |cmd|
  cmd.key_binding = "CTRL+SHIFT+H"
  cmd.output = :replace_selection
  cmd.input = :selection, :document
  cmd.scope = "source.js"
  cmd.invoke { require 'beautify2'; Beautifier.new.js_beautify($stdin.read) }
end