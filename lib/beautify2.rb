# In porting we actually fixed behavior that erased '\' chars!
=begin

JS Beautifier ported from the original in PHP by:

(c) 2007, Einars "elfz" Lielmanis
http://elfz.laacz.lv/beautify/

=end
class Beautifier

  # Whitespace characters
  WHITESPACE = "\n\r\t ".split('')
 
  # words which should always start on new line.
  LINE_STARTERS = 'continue,try,throw,return,var,if,switch,case,default,for,while,break,function'.split(',')
  
  # Word characters
  WORDCHAR = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$'.split('')
  
  # Punctuation
  # <!-- is a special case (ok, it's a minor hack actually)
  PUNCT = '+ - * / % & ++ -- = += -= *= /= %= == === != !== > < >= <= >> << >>> >>>= >>= <<= && &= | || ! !! , : ? ^ ^= |= ::'.split(' ')
  
  def js_beautify(js_source_text, options = {})
    tab_size = options[:indent_size] || 4
    tab_char = options[:indent_char] || ' '
    @indent_string = tab_char * tab_size

    @input = js_source_text
    @input_length = @input.length

    @last_word = ''     # last :TK_WORD passed
    @last_type = :TK_START_EXPR # last token type
    @last_text = ''     # last token text
    @output    = []

    # states showing if we are currently in expression (i.e. "if" case) - :IN_EXPR, or in usual block (like, procedure), :IN_BLOCK.
    # some formatting depends on that.
    @mode       = :IN_BLOCK
    @mode_stack      = [@mode]


    @indent_level   = 0
    @parser_pos      = 0 # parser position
    @in_case  = false # flag for parser that case/default has been processed, and next colon needs special attention

    while (true)
        @token_text, @token_type = get_next_token()
        
        break if (@token_type == :TK_EOF)

        # @output << " [@token_type:@last_type]"

        case @token_type

        when :TK_START_EXPR

            in_push(:IN_EXPR)
            if (@last_type == :TK_END_EXPR or @last_type == :TK_START_EXPR)
                # do nothing on (( and )( and ][ and ]( .. 
            elsif (@last_type != :TK_WORD and @last_type != :TK_OPERATOR)
                space()
            elsif (LINE_STARTERS.include?(@last_word) and @last_word != 'function')
                space()
            end
            token()
        when :TK_END_EXPR
            token()
            in_pop()
        when :TK_START_BLOCK
            in_push(:IN_BLOCK)
            if (@last_type != :TK_OPERATOR and @last_type != :TK_START_EXPR)
                if (@last_type == :TK_START_BLOCK)
                    nl()
                # else
                #   space()
                end
            end
            token()
            indent()
        when :TK_END_BLOCK
            if (@last_type == :TK_END_EXPR)
                unindent()
                nl()
            elsif (@last_type == :TK_END_BLOCK)
                unindent()
                nl()
            elsif (@last_type == :TK_START_BLOCK)
                # nothing
                unindent()
            else
                unindent()
                nl()
            end
            token()
            in_pop()
        when :TK_WORD
            if (@token_text == 'case' or @token_text == 'default')
                if (@last_text == ':')
                    # switch cases following one another
                    remove_indent()
                else
                    @indent_level -= 1
                    nl()
                    @indent_level += 1
                end
                token()
                @in_case = true
                # Converted break
                @last_type = @token_type
                @last_text = @token_text
                next
            end

            prefix = :PRINT_NONE
            if (@last_type == :TK_END_BLOCK)
                if !['else', 'catch', 'finally'].include?(@token_text)
                    prefix = :PRINT_NL
                else
                    prefix = :PRINT_SPACE
                    space()
                end
            elsif (@last_type == :TK_END_COMMAND && @mode == :IN_BLOCK)
                prefix = :PRINT_NL
            elsif (@last_type == :TK_END_COMMAND && @mode == :IN_EXPR)
                prefix = :PRINT_SPACE
            elsif (@last_type == :TK_WORD)
                if (@last_word == 'else') # else if
                    prefix = :PRINT_SPACE
                else
                    prefix = :PRINT_SPACE
                end
            elsif (@last_type == :TK_START_BLOCK)
                prefix = :PRINT_NL
            elsif (@last_type == :TK_END_EXPR)
                space()
            end

            if (LINE_STARTERS.include?(@token_text) or prefix == :PRINT_NL)

                if (@last_text == 'else')
                    # no need to force newline on else break
                    # DONOTHING
                    space()
                elsif ((@last_type == :TK_START_EXPR or @last_text == '=') and @token_text == 'function')
                    # no need to force newline on 'function': (function
                    # DONOTHING
                elsif (@last_type == :TK_WORD and (@last_text == 'return' or @last_text == 'throw'))
                    # no newline between 'return nnn'
                    space()
                elsif (@last_type != :TK_END_EXPR)
                    if ((@last_type != :TK_START_EXPR or @token_text != 'var') and @last_text != ':')
                        # no need to force newline on 'var': for (var x = 0...)
                        if (@token_text == 'if' and @last_type == :TK_WORD and @last_word == 'else')
                            # no newline for } else if {
                            space()
                        else
                            nl()
                        end
                    end
                end
            elsif (prefix == :PRINT_SPACE)
                space()
            end
            token()
            @last_word = @token_text
        when :TK_END_COMMAND
            token()
        when :TK_STRING
            if (@last_type == :TK_START_BLOCK or @last_type == :TK_END_BLOCK)
                nl()
            elsif (@last_type == :TK_WORD)
                space()
            end
            token()
        when :TK_OPERATOR
            start_delim = true
            end_delim   = true

            if (@token_text == ':' and @in_case)
                token() # colon really asks for separate treatment
                nl()
                @expecting_case = false
                # Converted break
                @last_type = @token_type
                @last_text = @token_text
                next
            end

            @in_case = false            
            
            if (@token_text == ',')
                if (@last_type == :TK_END_BLOCK)
                    token()
                    nl()
                else
                    if (@mode == :IN_BLOCK)
                        token()
                        nl()
                    else
                        token()
                        space()
                    end
                end
                
                # Converted break
                @last_type = @token_type
                @last_text = @token_text
                next
                
            elsif (@token_text == '--' or @token_text == '++') # unary operators special case
                if (@last_text == ';')
                    # space for (;; ++i)  
                    start_delim = true
                    end_delim = false
                else           
                    start_delim = false
                    end_delim = false
                end
            elsif (@token_text == '!' and @last_type == :TK_START_EXPR)
                # special case handling: if (!a)
                start_delim = false
                end_delim = false
            elsif (@last_type == :TK_OPERATOR)
                start_delim = false
                end_delim = false
            elsif (@last_type == :TK_END_EXPR)
                start_delim = true
                end_delim = true
            elsif (@token_text == '.')
                # decimal digits or object.property
                start_delim = false
                end_delim   = false
            elsif (@token_text == ':')
                # zz: xx
                # can't differentiate ternary op, so for now it's a ? b: c; without space before colon
                start_delim = false
            end
            
            space() if (start_delim)
            token()
            space() if (end_delim)
        when :TK_BLOCK_COMMENT
            nl()
            token()
            nl()
        when :TK_COMMENT
            #if (@last_type != :TK_COMMENT)
            nl()
            #end
            token()
            nl()
        when :TK_UNKNOWN
            token()
        end

        if (@token_type != :TK_COMMENT)
            @last_type = @token_type
            @last_text = @token_text
        end
    end

    # clean empty lines from redundant spaces
    return @output.join('').gsub(/^ +$/m, '')
  end

  def nl(ignore_repeated = true)
    @output.pop() while (!@output.empty? && (@output.last == ' ' || @output.last == @indent_string))  # remove possible indent
  
    return if @output.empty? # no newline on start of file
  
    @output << "\n" if (@output.last != "\n" || !ignore_repeated)
  
    @indent_level.times { @output << @indent_string }
  end
  
  def space    
    @output << ' ' if !@output.empty? and @output.last != ' ' and @output.last != @indent_string # prevent occassional duplicate space
  end

  def token
    @output << @token_text
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
  
  def in_push(new_mode)
    @mode_stack << @mode
    @mode = new_mode
  end

  def in_pop
    @mode = @mode_stack.pop
  end
  
  def get_next_token
    n_newlines = 0
    c = nil
    begin
        return ['', :TK_EOF] if (@parser_pos >= @input_length)
        
        c = @input[@parser_pos, 1]
        @parser_pos += 1
        if (c == "\n")
            nl(n_newlines == 0)
            n_newlines += 1
        end
    end while WHITESPACE.include?(c)
    
    if WORDCHAR.include?(c)
        if (@parser_pos < @input_length)
            while WORDCHAR.include?(@input[@parser_pos, 1])
                c << @input[@parser_pos, 1]
                @parser_pos += 1
                break if (@parser_pos == @input_length)
            end
        end

        # small and surprisingly unugly hack for 1E-10 representation
        if (@parser_pos != @input_length and c.match('/^\d+[Ee]$/') and @input[@parser_pos, 1] == '-')
            @parser_pos += 1
            next_word, next_type = get_next_token()
            c << '-' + next_word
            return [c, :TK_WORD]
        end
        
        return [c, :TK_OPERATOR] if (c == 'in') # hack for 'in' operator
        return [c, :TK_WORD]
    end
    
    return [c, :TK_START_EXPR] if (c == '(' || c == '[')
    return [c, :TK_END_EXPR] if (c == ')' || c == ']')
    return [c, :TK_START_BLOCK] if (c == '{')
    return [c, :TK_END_BLOCK] if (c == '}')
    return [c, :TK_END_COMMAND] if (c == ';')

    if (c == '/')
        # peek for comment /* ... */
        if (@input[@parser_pos, 1] == '*')
            comment = ''
            @parser_pos += 1
            if (@parser_pos < @input_length)
                while (!(@input[@parser_pos, 1] == '*' && @input[@parser_pos + 1, 1] == '/') && @parser_pos < @input_length)
                    comment << @input[@parser_pos, 1]
                    @parser_pos += 1
                    break if (@parser_pos >= @input_length)
                end
            end
            @parser_pos +=2
            return ["/*#{comment}*/", :TK_BLOCK_COMMENT]
        end
        # peek for comment // ...
        if (@input[@parser_pos, 1] == '/')
            comment = c;
            while (@input[@parser_pos, 1] != "\x0d" && @input[@parser_pos, 1] != "\x0a")
                comment << @input[@parser_pos, 1]
                @parser_pos += 1
                break if (@parser_pos >= @input_length)
            end
            @parser_pos += 1
            return [comment, :TK_COMMENT]
        end

    end

    if (c == "'" || # string
        c == '"' || # string
        (c == '/' && 
            ((@last_type == :TK_WORD and @last_text == 'return') or (@last_type == :TK_START_EXPR || @last_type == :TK_END_BLOCK || @last_type == :TK_OPERATOR || @last_type == :TK_EOF || @last_type == :TK_END_COMMAND)))) # regexp
        sep = c
        c   = ''
        esc = false

        if (@parser_pos < @input_length)
            while (esc || @input[@parser_pos, 1] != sep)
                c << @input[@parser_pos, 1]
                if !esc
                    esc = @input[@parser_pos, 1] == '\\'
                else
                    esc = false;
                end
                @parser_pos += 1;
                break if (@parser_pos >= @input_length) 
            end
        end

        @parser_pos += 1
        
        nl() if (@last_type == :TK_END_COMMAND)

        return ["#{sep}#{c}#{sep}", :TK_STRING]
    end

    if PUNCT.include?(c)
        while (@parser_pos < @input_length and PUNCT.include?("#{c}#{@input[@parser_pos, 1]}"))
            c << @input[@parser_pos, 1]
            @parser_pos += 1
             break if (@parser_pos >= @input_length)
        end
        return [c, :TK_OPERATOR]
    end

    return [c, :TK_UNKNOWN]
  end

end
