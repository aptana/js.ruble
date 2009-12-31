# TODO Debug/test, doesn't seem to treat newlines the same way that Textmate does
# TODO Continue to clean this code up and make it more readable. This stuff is heinous
=begin

 JS Beautifier
---------------


  Written by Einar Lielmanis, <einars@gmail.com>
      http://jsbeautifier.org/

  Originally converted to javascript by Vital, <vital76@gmail.com>
  Then converted to Ruby by Christopher Williams, <cwilliams@aptana.com>

  You are free to use this in any way you want, in case you find this useful or working for you.

  Usage:
    js_beautify(js_source_text)
    js_beautify(js_source_text, options)

  The options are:
    :indent_size (default 4) Ñ indentation size,
    :indent_char (default space) Ñ character to indent with,
    :preserve_newlines (default true) Ñ whether existing line breaks should be preserved,
    :indent_level (default 0)  Ñ initial indentation level, you probably won't need this ever,

    :space_after_anon_function (default false) Ñ if true, then space is added between "function ()"
            (jslint is happy about this); if false, then the common "function()" output is used.

    e.g

    js_beautify(js_source_text, {:indent_size => 1, :indent_char => '\t'})


=end
class Beautifier
  # Whitespace characters
  WHITESPACE = "\n\r\t ".split('')
 
  # words which should always start on new line.
  LINE_STARTERS = 'continue,try,throw,return,var,if,switch,case,default,for,while,break,function'.split(',')
  
  # Numbers
  DIGITS = '0123456789'.split('')
  
  # Word characters
  WORDCHAR = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$'.split('')
  
  # Punctuation
  # <!-- is a special case (ok, it's a minor hack actually)
  PUNCT = '+ - * / % & ++ -- = += -= *= /= %= == === != !== > < >= <= >> << >>> >>>= >>= <<= && &= | || ! !! , : ? ^ ^= |= ::'.split(' ')
  
  private
  def trim_output
    @output.pop() while (!@output.empty? && (@output.last == ' ' || @output.last == @indent_string))
  end

  def print_newline(ignore_repeated = true)
    return if @opt_keep_array_indentation && is_array(@flags[:mode])

    @flags[:if_line] = false
    trim_output()
        
    return if @output.empty? # no newline on start of file

    if (@output.last != "\n" || !ignore_repeated)
        @just_added_newline = true
        @output.push("\n")
    end
    
    @indent_level.times { |i| @output.push(@indent_string) }  
  end

  def print_single_space
    last_output = ' '
    last_output = @output.last if !@output.empty?
    
    @output.push(' ') if (last_output != ' ' && last_output != '\n' && last_output != @indent_string) # prevent occassional duplicate space
  end


  def print_token
    @just_added_newline = false
    @output.push(@token_text)
  end

  def indent
    @indent_level += 1
  end

  def unindent
    @indent_level -= 1 if @indent_level
  end

  def remove_indent
    @output.pop() if !@output.empty? && (@output.last == @indent_string)
  end

  def print_javadoc_comment
    lines = @token_text.split('\n')
    @output.push(lines[0])
    
    (1...lines.length).each do |i|
        print_newline()
        @output.push(' ')
        @output.push(lines[i].replace(/^\s+/, ''))
    end
  end

  def set_mode(mode)
    @flag_store.push(@flags) if @flags
        
    @flags = {
          :mode => mode,
          :var_line => false,
          :var_line_tainted => false,
          :if_line => false,
          :in_case => false,
          :indentation_baseline => -1
    }
  end

  def is_expression(mode)
    return mode == '[EXPRESSION]' || mode == '[INDENTED-EXPRESSION]' || mode == '(EXPRESSION)'
  end

  def is_array(mode)
    return mode == '[EXPRESSION]' || mode == '[INDENTED-EXPRESSION]'
  end

  def restore_mode
    @do_block_just_closed = (@flags[:mode] == 'DO_BLOCK')
    @flags = @flag_store.pop() if !@flag_store.empty?
  end

  # Walk backwards from the colon to find a '?' (colon is part of a ternary op)
  # or a '{' (colon is part of a class literal).  Along the way, keep track of
  # the blocks and expressions we pass so we only trigger on those chars in our
  # own level, and keep track of the colons so we only trigger on the matching '?'.
  def is_ternary_op
    level = 0
    colon_count = 0
    @output.reverse_each do |c|
      case c
      when ':'
        colon_count += 1 if level == 0
      when '?'
        if (level == 0)
          return true if colon_count == 0
          colon_count -= 1
        end
      when '{'
         return false if level == 0
         level -= 1
      when '(', '['
         level -= 1
      when ')', ']', '}'
         level += 1
      end
    end
  end

  def get_next_token
    @n_newlines = 0

    return ['', 'TK_EOF'] if (@parser_pos >= @input.length)

    c = @input[@parser_pos, 1]
    @parser_pos += 1

    keep_whitespace = @opt_keep_array_indentation && is_array(@flags[:mode])
    @wanted_newline = false

    if (keep_whitespace)

          #
          # slight mess to allow nice preservation of array indentation and reindent that correctly
          # first time when we get to the arrays:
          # var a = [
          # ....'something'
          # we make note of whitespace_count = 4 into @flags[:indentation_baseline]
          # so we know that 4 whitespaces in original source match indent_level of reindented source
          #
          # and afterwards, when we get to
          #    'something,
            # .......'something else'
            # we know that this should be indented to indent_level + (7 - indentation_baseline) spaces
            #
            whitespace_count = 0

            while WHITESPACE.include?(c)
                if (c == "\n")
                    trim_output()
                    @output.push("\n")
                    @just_added_newline = true
                    whitespace_count = 0
                else
                    if (c == '\t')
                        whitespace_count += 4
                    else
                        whitespace_count += 1
                    end
                end

                return ['', 'TK_EOF'] if (@parser_pos >= @input.length)

                c = @input[@parser_pos, 1]
                @parser_pos += 1
            end
            
            @flags[:indentation_baseline] = whitespace_count if (@flags[:indentation_baseline] == -1)

            if @just_added_newline
                (@indent_level + 1).times {|i| @output.push(@indent_string) }
                (0...(whitespace_count - @flags[:indentation_baseline])).each {|i| @output.push(' ') } if (@flags[:indentation_baseline] != -1)
            end

        else
            while WHITESPACE.include?(c)
                @n_newlines += 1 if (c == "\n")
                
                return ['', 'TK_EOF'] if (@parser_pos >= @input.length)
               
                c = @input[@parser_pos, 1]
                @parser_pos += 1
            end

            if @opt_preserve_newlines
              @n_newlines.times do |i|
                print_newline(i == 0)
                @just_added_newline = true
              end
            end
            @wanted_newline = @n_newlines > 0
        end


        if WORDCHAR.include?(c)
            if (@parser_pos < @input.length)
                while WORDCHAR.include?(@input[@parser_pos, 1])
                    c += @input[@parser_pos, 1]
                    @parser_pos += 1
                    break if @parser_pos == @input.length
                end
            end

            # small and surprisingly unugly hack for 1E-10 representation
            if (@parser_pos != @input.length && c.match(/^[0-9]+[Ee]$/) && (@input[@parser_pos, 1] == '-' || @input[@parser_pos, 1] == '+'))

                sign = @input[@parser_pos, 1]
                @parser_pos += 1

                t = get_next_token() # TODO Do we need t to become @t here?
                c += sign + t[0]
                return [c, 'TK_WORD']
            end
            
            return [c, 'TK_OPERATOR'] if c == 'in' # hack for 'in' operator
            
            if (@wanted_newline && @last_type != 'TK_OPERATOR' && !@flags[:if_line] && (@opt_preserve_newlines || @last_text != 'var'))
                print_newline()
            end
            return [c, 'TK_WORD']
        end

        return [c, 'TK_START_EXPR'] if (c == '(' || c == '[')
        return [c, 'TK_END_EXPR'] if (c == ')' || c == ']')
        return [c, 'TK_START_BLOCK'] if c == '{'
        return [c, 'TK_END_BLOCK'] if c == '}'
        return [c, 'TK_SEMICOLON'] if c == ';'

        if (c == '/')
            comment = ''
            # peek for comment /* ... */
            if (@input[@parser_pos, 1] == '*')
                @parser_pos += 1
                if (@parser_pos < @input.length)
                    while (! (@input[@parser_pos, 1] == '*' && @input[@parser_pos + 1, 1] && @input[@parser_pos + 1, 1] == '/') && @parser_pos < @input.length)
                        comment += @input[@parser_pos, 1]
                        @parser_pos += 1
                        break if (@parser_pos >= @input.length)
                    end
                end
                @parser_pos += 2
                return ['/*' + comment + '*/', 'TK_BLOCK_COMMENT']
            end
            # peek for comment // ...
            if (@input[@parser_pos, 1] == '/')
                comment = c
                while (@input[@parser_pos, 1] != "\x0d" && @input[@parser_pos, 1] != "\x0a")
                    comment += @input[@parser_pos, 1]
                    @parser_pos += 1
                    break if (@parser_pos >= @input.length)
                end
                @parser_pos += 1                
                print_newline() if @wanted_newline                
                return [comment, 'TK_COMMENT']
            end
        end

        if (c == "'" || # string
        c == '"' || # string
        (c == '/' && ((@last_type == 'TK_WORD' && ['return', 'do'].include?(@last_text)) || (@last_type == 'TK_START_EXPR' || @last_type == 'TK_START_BLOCK' || @last_type == 'TK_END_BLOCK' || @last_type == 'TK_OPERATOR' || @last_type == 'TK_EOF' || @last_type == 'TK_SEMICOLON')))) # regexp
            sep = c
            esc = false
            resulting_string = c

            if @parser_pos < @input.length
                if (sep == '/')
                    #
                    # handle regexp separately...
                    #
                    in_char_class = false
                    while (esc || in_char_class || @input[@parser_pos, 1] != sep)
                        resulting_string += @input[@parser_pos, 1]
                        if (!esc)
                            esc = @input[@parser_pos, 1] == '\\'
                            if (@input[@parser_pos, 1] == '[')
                                in_char_class = true
                            elsif (@input[@parser_pos, 1] == ']')
                                in_char_class = false
                            end
                        else
                            esc = false
                        end
                        @parser_pos += 1
                        
                        # incomplete string/rexp when end-of-file reached. 
                        # bail out with what had been received so far.
                        return [resulting_string, 'TK_STRING'] if @parser_pos >= @input.length
                    end

                else
                    #
                    # and handle string also separately
                    #
                    while (esc || @input[@parser_pos, 1] != sep)
                        resulting_string += @input[@parser_pos, 1]
                        if (!esc)
                            esc = @input[@parser_pos, 1] == '\\'
                        else
                            esc = false
                        end
                        @parser_pos += 1
                        
                        # incomplete string/rexp when end-of-file reached. 
                        # bail out with what had been received so far.
                        return [resulting_string, 'TK_STRING'] if @parser_pos >= @input.length
                    end
                end
            end

            @parser_pos += 1
            resulting_string += sep

            if (sep == '/')
                # regexps may have modifiers /regexp/MOD , so fetch those, too
                while (@parser_pos < @input.length && WORDCHAR.include?(@input[@parser_pos, 1]))
                    resulting_string += @input[@parser_pos, 1]
                    @parser_pos += 1
                end
            end
            return [resulting_string, 'TK_STRING']
        end

        if (c == '#')
            # Spidermonkey-specific sharp variables for circular references
            # https://developer.mozilla.org/En/Sharp_variables_in_JavaScript
            # http://mxr.mozilla.org/mozilla-central/source/js/src/jsscan.cpp around line 1935
            sharp = '#'
            if (@parser_pos < @input.length && DIGITS.include?(@input[@parser_pos, 1]))
                begin
                  c = @input[@parser_pos, 1]
                  sharp += c
                  @parser_pos += 1
                end while (@parser_pos < @input.length && c != '#' && c != '=')
                if (c == '#')
                    return [sharp, 'TK_WORD']
                else
                    return [sharp, 'TK_OPERATOR']
                end
            end
        end

        if (c == '<' && @input[@parser_pos - 1, 4] == '<!--')
            @parser_pos += 3
            return ['<!--', 'TK_COMMENT']
        end

        if (c == '-' && @input[@parser_pos - 1, 3] == '-->')
            @parser_pos += 2
            print_newline() if @wanted_newline
            return ['-->', 'TK_COMMENT']
        end

        if PUNCT.include?(c)
            while (@parser_pos < @input.length && PUNCT.include?(c + @input[@parser_pos, 1]))
                c += @input[@parser_pos, 1]
                @parser_pos += 1
                break if (@parser_pos >= @input.length)
            end
            return [c, 'TK_OPERATOR']
        end

        return [c, 'TK_UNKNOWN']
    end

public

def js_beautify(js_source_text, options = {})
   
    @opt_preserve_newlines = options.has_key?(:preserve_newlines) ? options[:preserve_newlines] : true 
    opt_space_after_anon_function = options[:space_after_anon_function] # only used once below in this huge function
    @opt_keep_array_indentation = options.has_key?(:keep_array_indentation) ? options[:keep_array_indentation] : true

    @just_added_newline = false
    #----------------------------------
    
    # Generate indent string
    opt_indent_size = options[:indent_size] || 4 # only used here
    opt_indent_char = options[:indent_char] || ' ' # only used here
    @indent_string = opt_indent_char * opt_indent_size

    @indent_level = options[:indent_level] || 0 # starting indentation
    @input = js_source_text

    last_word = '' # last 'TK_WORD' passed (Only used inside this function)
    @last_type = 'TK_START_EXPR' # last token type
    @last_text = '' # last token text
    last_last_text = '' # pre-last token text (Only used inside this function)
    @output = []

    @do_block_just_closed = false

    # states showing if we are currently in expression (i.e. "if" case) - 'EXPRESSION', or in usual block (like, procedure), 'BLOCK'.
    # some formatting depends on that.
    @flag_store = []
    set_mode('BLOCK')

    @parser_pos = 0
    while (true)
        t = get_next_token()
        @token_text = t[0]
        token_type = t[1] # Only used inside loop
        break if (token_type == 'TK_EOF')

        case (token_type)

        when 'TK_START_EXPR'

            if (@token_text == '[')
                if (@last_type == 'TK_WORD' || @last_text == ')')
                    # this is array index specifier, break immediately
                    # a[x], fn()[x]
                    if (last_word == 'return' || last_word == 'throw')
                        print_single_space()
                    end
                    set_mode('(EXPRESSION)')
                    print_token()
                    # Replacement for 'break'
                    last_last_text = @last_text
                    @last_type = token_type
                    @last_text = @token_text
                    next
                end

                if (@flags[:mode] == '[EXPRESSION]' || @flags[:mode] == '[INDENTED-EXPRESSION]')
                    if (last_last_text == ']' && @last_text == ',')
                        # ], [ goes to new line
                        if (!@opt_keep_array_indentation)
                            indent()
                            print_newline()
                        end
                        set_mode('[INDENTED-EXPRESSION]')
                    elsif (@last_text == '[')
                        if (!@opt_keep_array_indentation)
                            indent()
                            print_newline()
                        end
                        set_mode('[INDENTED-EXPRESSION]')
                    else
                        set_mode('[EXPRESSION]')
                    end
                else
                    set_mode('[EXPRESSION]')
                end
            else
                set_mode('(EXPRESSION)')
            end

            if (@last_text == ';' || @last_type == 'TK_START_BLOCK')
                print_newline()
            elsif (@last_type == 'TK_END_EXPR' || @last_type == 'TK_START_EXPR')
                # do nothing on (( and )( and ][ and ]( ..
            elsif (@last_type != 'TK_WORD' && @last_type != 'TK_OPERATOR')
                print_single_space()
            elsif (last_word == 'function')
                # function() vs function ()
                print_single_space() if opt_space_after_anon_function
            elsif LINE_STARTERS.include?(last_word)
                print_single_space()
            end
            print_token()

        when 'TK_END_EXPR'
            if (@token_text == ']' && @flags[:mode] == '[INDENTED-EXPRESSION]')
                unindent()
            end
            restore_mode()
            print_token()

        when 'TK_START_BLOCK'
            if (last_word == 'do')
                set_mode('DO_BLOCK')
            else
                set_mode('BLOCK')
            end
            if (@last_type != 'TK_OPERATOR' && @last_type != 'TK_START_EXPR')
                if (@last_type == 'TK_START_BLOCK')
                    print_newline()
                else
                    print_single_space()
                end
            end
            print_token()
            indent()

        when 'TK_END_BLOCK'
            if (@last_type == 'TK_START_BLOCK')
                # nothing
                if @just_added_newline
                    remove_indent()
                    # {
                    #
                    # }
                else
                    # {}
                    trim_output()
                end
                unindent()
            else
                unindent()
                print_newline()
            end
            print_token()
            restore_mode()

        when 'TK_WORD'

            # no, it's not you. even I have problems understanding how this works
            # and what does what.
            if @do_block_just_closed
                # do {} ## while ()
                print_single_space()
                print_token()
                print_single_space()
                @do_block_just_closed = false
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            end

            if (@token_text == 'function')
                if ((@just_added_newline || @last_text == ';') && @last_text != '{')
                    # make sure there is a nice clean space of at least one blank line
                    # before a new function definition
                    @n_newlines = @just_added_newline ? @n_newlines : 0
                    (0...(2 - @n_newlines)).each {|i| print_newline(false) }
                end
            end
            if (@token_text == 'case' || @token_text == 'default')
                if (@last_text == ':')
                    # switch cases following one another
                    remove_indent()
                else
                    # case statement starts in the same line where switch
                    unindent()
                    print_newline()
                    indent()
                end
                print_token()
                @flags[:in_case] = true
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            end

            prefix = 'NONE'

            if (@last_type == 'TK_END_BLOCK')
                if !['else', 'catch', 'finally'].include?(@token_text.downcase)
                    prefix = 'NEWLINE'
                else
                    prefix = 'SPACE'
                    print_single_space()
                end
            elsif (@last_type == 'TK_SEMICOLON' && (@flags[:mode] == 'BLOCK' || @flags[:mode] == 'DO_BLOCK'))
                prefix = 'NEWLINE'
            elsif (@last_type == 'TK_SEMICOLON' && is_expression(@flags[:mode]))
                prefix = 'SPACE'
            elsif (@last_type == 'TK_STRING')
                prefix = 'NEWLINE'
            elsif (@last_type == 'TK_WORD')
                prefix = 'SPACE'
            elsif (@last_type == 'TK_START_BLOCK')
                prefix = 'NEWLINE'
            elsif (@last_type == 'TK_END_EXPR')
                print_single_space()
                prefix = 'NEWLINE'
            end

            if (@last_type != 'TK_END_BLOCK' && ['else', 'catch', 'finally'].include?(@token_text.downcase))
                print_newline()
            elsif (LINE_STARTERS.include?(@token_text) || prefix == 'NEWLINE')
                if (@last_text == 'else')
                    # no need to force newline on else break
                    print_single_space()
                elsif ((@last_type == 'TK_START_EXPR' || @last_text == '=' || @last_text == ',') && @token_text == 'function')
                    # no need to force newline on 'function': (function
                    # DONOTHING
                elsif (@last_text == 'return' || @last_text == 'throw')
                    # no newline between 'return nnn'
                    print_single_space()
                elsif (@last_type != 'TK_END_EXPR')
                    if ((@last_type != 'TK_START_EXPR' || @token_text != 'var') && @last_text != ':')
                        # no need to force newline on 'var': for (var x = 0...)
                        if (@token_text == 'if' && last_word == 'else' && @last_text != '{')
                            # no newline for } else if {
                            print_single_space()
                        else
                            print_newline()
                        end
                    end
                else
                  print_newline() if (LINE_STARTERS.include?(@token_text) && @last_text != ')')
                end
            elsif (prefix == 'SPACE')
                print_single_space()
            end
            print_token()
            last_word = @token_text

            if (@token_text == 'var')
                @flags[:var_line] = true
                @flags[:var_line_tainted] = false
            end

            @flags[:if_line] = true if (@token_text == 'if' || @token_text == 'else')

        when 'TK_SEMICOLON'
            print_token()
            @flags[:var_line] = false
        when 'TK_STRING'
            if (@last_type == 'TK_START_BLOCK' || @last_type == 'TK_END_BLOCK' || @last_type == 'TK_SEMICOLON')
                print_newline()
            elsif (@last_type == 'TK_WORD')
                print_single_space()
            end
            print_token()
        when 'TK_OPERATOR'
            start_delim = true
            end_delim = true
            if (@flags[:var_line] && @token_text == ',' && is_expression(@flags[:mode]))
                # do not break on comma, for(var a = 1, b = 2)
                @flags[:var_line_tainted] = false
            end

            if @flags[:var_line]
                if (@token_text == ',')
                    if @flags[:var_line_tainted]
                        print_token()
                        print_newline()
                        @output.push(@indent_string)
                        @flags[:var_line_tainted] = false
                        # Replacement for 'break'
                        last_last_text = @last_text
                        @last_type = token_type
                        @last_text = @token_text
                        next
                    else
                        @flags[:var_line_tainted] = false
                    end
                else
                    @flags[:var_line_tainted] = true
                    @flags[:var_line] = false if (@token_text == ':')
                end
            end

            if (@last_text == 'return' || @last_text == 'throw')
                # "return" had a special handling in TK_WORD. Now we need to return the favor
                print_single_space()
                print_token()
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            end

            if (@token_text == ':' && @flags[:in_case])
                print_token() # colon really asks for separate treatment
                print_newline()
                @flags[:in_case] = false
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            end

            if (@token_text == '::')
                # no spaces around exotic namespacing syntax operator
                print_token()
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            end

            if (@token_text == ',')
                if (@flags[:var_line])
                  print_token()
                  if @flags[:var_line_tainted]
                    print_newline()
                    @flags[:var_line_tainted] = false
                  else
                    print_single_space()
                  end
                elsif (@last_type == 'TK_END_BLOCK')
                  print_token()
                  print_newline()
                else
                  print_token()
                  if (@flags[:mode] == 'BLOCK')
                    print_newline()
                  else
                    # EXPR or DO_BLOCK
                    print_single_space()
                  end
                end
                # Replacement for 'break'
                last_last_text = @last_text
                @last_type = token_type
                @last_text = @token_text
                next
            elsif (@token_text == '--' || @token_text == '++') # unary operators special case
                if (@last_text == ';')
                    # { foo; --i }
                    print_newline() if (@flags[:mode] == 'BLOCK')
                    start_delim = true
                else
                    # {--i
                    print_newline() if @last_text == '{'
                    start_delim = false                    
                end
                end_delim = false
            elsif ((@token_text == '!' || @token_text == '+' || @token_text == '-') && (@last_text == 'return' || @last_text == 'case'))
                start_delim = true
                end_delim = false
            elsif ((@token_text == '!' || @token_text == '+' || @token_text == '-') && @last_type == 'TK_START_EXPR')
                # special case handling: if (!a)
                start_delim = false
                end_delim = false
            elsif (@last_type == 'TK_OPERATOR')
                start_delim = false
                end_delim = false
            elsif (@last_type == 'TK_END_EXPR')
                start_delim = true
                end_delim = true
            elsif (@token_text == '.')
                # decimal digits or object.property
                start_delim = false
                end_delim = false
            elsif (@token_text == ':')
              start_delim = is_ternary_op()
            end
            
            print_single_space() if start_delim
            print_token()
            print_single_space() if end_delim
        when 'TK_BLOCK_COMMENT'
            print_newline()
            if (@token_text[0, 3] == '/**')
                print_javadoc_comment()
            else
                print_token()
            end
            print_newline()
        when 'TK_COMMENT'
            # print_newline()
            if @wanted_newline
                print_newline()
            else
                print_single_space()
            end
            print_token()
            print_newline()
        when 'TK_UNKNOWN'
            print_token()
        end

        last_last_text = @last_text
        @last_type = token_type
        @last_text = @token_text
    end

    return @output.join('').gsub(/\n+$/, '')
end

end