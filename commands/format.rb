require 'radrails'
require 'beautify2'
 
command "Reformat Document" do |cmd|
  cmd.key_binding = [ :ALT, :H ] # TODO Get right keybinding
  cmd.output = :replace_selection
  cmd.input = :selection 
  #cmd.input = [:selection, :document]
  cmd.scope = "source.js"
  cmd.invoke do |context|
    src = context.in.read
    Beautifier.new.js_beautify(src)
  end
end