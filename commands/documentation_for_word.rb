require 'ruble'
require 'ruble/ui'
 
command "Documentation for Word" do |cmd|
  cmd.key_binding = "CTRL+H"
  cmd.output = :show_as_html
  cmd.input = :selection 
  #cmd.input = [:selection, :word]
  cmd.scope = "source.js"
  cmd.invoke do |context|
    word = $stdin.read
    require 'docs'
    ref = JS_DOCS[word]
    if !ref.nil?
      "<meta http-equiv='Refresh' content='0;URL=http://devguru.com/technologies/javascript/#{ref}'>"
    else
      Ruble::UI.tool_tip "No documentation found."
      nil # return nil to avoid having the browser open
    end
  end
end