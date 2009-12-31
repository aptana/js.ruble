require 'radrails'

# its ruby, so this just adds commands/snippets in bundle (or replaces those with same name)
# many ruby files could add to a single bundle
bundle 'JavaScript' do |bundle|
  bundle.author = "Christopher Williams"
  bundle.copyright = <<END
© Copyright 2009 Aptana Inc. Distributed under GPLv3 and Aptana Source license.
END

  bundle.description = <<END
Javascript bundle for RadRails 3
END

  bundle.git_repo = "git://github.com/aptana/js-rrbundle.git"

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