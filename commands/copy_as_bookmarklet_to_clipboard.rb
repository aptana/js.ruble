require 'ruble'
 
command "Copy as Bookmarklet to Clipboard" do |cmd|
  cmd.key_binding = "CTRL+SHIFT+H"
  cmd.output = :copy_to_clipboard
  cmd.input = :selection 
  #cmd.input = [:selection, :document]
  cmd.scope = "source.js"
  cmd.invoke do |context|    
    #
    # Written by John Gruber, taken with permission from:
    # http://daringfireball.net/2007/03/javascript_bookmarklet_builder
    src = STDIN.read
    
    # Zap the first line if there's already a bookmarklet comment:
    src.sub!(/^\/\/ ?javascript:.+\n/, '')
    bookmarklet = src
    
    bookmarklet.gsub!(/^\s*\/\/.+\n/m, '')  # Kill comments.
    bookmarklet.gsub!(/\t/m, ' ')         # Tabs to spaces
    bookmarklet.gsub!(/ +/m, ' ')         # Space runs to one space
    bookmarklet.gsub!(/^\s+/m, '')        # Kill line-leading whitespace
    bookmarklet.gsub!(/\s+$/m, '')        # Kill line-ending whitespace
    bookmarklet.gsub!(/\n/m, '')           # Kill newlines
    
    # TODO Escape single- and double-quotes, spaces, control chars, unicode:
    # uri_escape_utf8(bookmarklet, qq('" \x00-\x1f\x7f-\xff))
    bookmarklet = "javascript:#{bookmarklet}"
  end
end