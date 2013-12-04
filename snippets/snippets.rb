require 'ruble'

with_defaults :scope => "source.js" do
  
  snippet t(:object_method) do |s|
    s.trigger = ":f"
    s.expansion = "${1:method_name}: function(${2:attribute}){
  $0
}${3:,}"
  end
  
  snippet t(:function) do |s|
    s.trigger = "fun"
    s.expansion = "function ${1:function_name} (${2:argument}) {
  ${0:// body...}
}"
  end
  
  snippet t(:new_function) do |s|
    s.trigger = "fun"
    s.expansion = "function (${1:args}) {
  ${0:// body...}
}"
  end
  
  snippet t(:new_method) do |s|
    s.trigger = ":"
    s.expansion = ": function (${1:args}) {
    $0
},"
  end
  
  snippet t(:prototype) do |s|
    s.trigger = "proto"
    s.expansion = "${1:class_name}.prototype.${2:method_name} = function(${3:first_argument}) {
  ${0:// body...}
};
"
  end
  
  snippet t(:anonymous_function) do |s|
    s.trigger = "f"
    s.expansion = "function($1) {${0:$TM_SELECTED_TEXT}};"
  end
  
  snippet t(:if) do |s|
    s.trigger = "if"
    s.expansion = "if (${1:true}) {${0:$TM_SELECTED_TEXT}};"
  end
  
  snippet t(:if_else) do |s|
    s.trigger = "ife"
    s.expansion = "if (${1:true}) {${0:$TM_SELECTED_TEXT}} else{};"
  end
  
  snippet t(:for) do |s|
    s.trigger = "for"
    s.expansion = "for (var ${2:i}=0; ${2:i} < ${1:Things}.length; ${2:i}++) {
  ${1:Things}[${2:i}]
};"
  end
  
  snippet t(:for_native) do |s|
    s.trigger = "for"
    s.expansion = "for (var ${2:i} = ${1:Things}.length - 1; ${2:i} >= 0; ${2:i}--){
  ${1:Things}[${2:i}]
};"
  end

  snippet "for (...) {...} (High-Performance For-Loop)" do |s|
    s.trigger = "for"
    s.expansion = "for(var ${2:i}=0,${3:j}=${1:Things}.length; ${2:i}<${3:j}; ${2:i}++){
  ${1:Things}[${2:i}]
};"
  end
  
  snippet t(:object_value) do |s|
    s.trigger = ":,"
    s.expansion = "${1:value_name}:${0:value},"
  end
  
  snippet t(:object_key) do |s|
    s.trigger = ":"
    s.expansion = '${1:key}: ${2:"${3:value}"}${4:, }'
  end
  
  snippet t(:setTimeout) do |s|
    s.trigger = "timeout"
    s.expansion = "setTimeout(function() {$0}, ${1:10});"
  end
  
  snippet t(:object_method_string) do |s|
    s.trigger = '":f'
    s.expansion = "'${1:${2:#thing}:${3:click}}': function(element){
  $0
}${4:,}"
  end
  
  snippet t(:console_debug) do |s|
    s.trigger = "cd"
    s.expansion = "console.debug('${1:args}', ${0:// body...});"
  end
  
  snippet t(:console_log) do |s|
    s.trigger = "cl"
    s.expansion = "console.log('${1:args}', ${0:// body...});"
  end
  
  snippet t(:console_warn) do |s|
    s.trigger = "cw"
    s.expansion = "console.warn('${1:args}', ${0:// body...});"
  end
  
  snippet t(:console_info) do |s|
    s.trigger = "ci"
    s.expansion = "console.info('${1:args}', ${0:// body...});"
  end
  
# FIXME Not currently working due to unsupported TextMate functionality
  # snippet "Get Elements" do |s|
    # s.trigger = "get"
    # s.expansion = "getElement${1/(T)|.*/(?1:s)/}By${1:T}${1/(T)|(I)|.*/(?1:agName)(?2:d)/}('$2')"
  # end
  
end