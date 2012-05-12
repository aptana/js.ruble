require 'ruble'

with_defaults :scope => "source.js" do
  
  snippet t(:object_method) do |s|
    s.trigger = ":f"
    s.expansion = "${1:method_name}: function(${2:attribute}){
  $0
}${3:,}"
  end
  
  snippet t(:function_declaration) do |s|
    s.trigger = "fun"
    s.expansion = "function ${1:function_name} (${2:argument}) {
  ${0:// body...}
}"
  end
  
  snippet t(:function_expression) do |s|
    s.trigger = "fun"
    s.expansion = "var ${1:var_name} = function (${2:argument}) {
  ${0:// body...}
}"
  end

  snippet t(:immediate_invocation_function) do |s|
    s.trigger = "fun"
    s.expansion = "(function () {
  ${0:// body...}
}());"
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
  
  snippet t(:for_in) do |s|
    s.trigger = "for"
    s.expansion = "for (var ${1:key} in ${2:obj}){
  $0
};"
  end
  
  snippet t(:for_in_hasOwnProperty) do |s|
    s.trigger = "for"
    s.expansion = "for (var ${1:key} in ${2:obj}){
    if(${2:obj}.hasOwnProperty(${1:key})){
      $0
    }
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
  
  snippet t(:namespace) do |s|
    s.trigger = "nam"
    s.expansion = "var ${1:name_namespace} = {$0};"
  end
    
  snippet t(:safe_namespace) do |s|
    s.trigger = "nam"
    s.expansion = "var ${1:name_namespace} = ${1:name_namespace} || {};"
  end
    
  snippet t(:module_pattern) do |s|
    s.trigger = "mod"
    s.expansion = "var ${1:module_name} = (function (){$0}());"
  end
    
  snippet t(:extend_module_pattern) do |s|
    s.trigger = "mod"
    s.expansion = "var ${1:module_name} = (function (${1:module_name}){$0}(${1:module_name}));"
  end
    
  snippet t(:revealing_module_pattern) do |s|
    s.trigger = "mod"
    s.expansion = "var ${1:module_name} = (function (){
    // private properties
    // var private_properties = value;

    // private methods
    // privateMethod = function () {};

    // revealing public API
    return {
    // RevealPrivateMethod: privateMethod
    
    };
}());"
  end
  
  snippet t(:init_time_branching) do |s|
    s.trigger = "init"
    s.expansion = "if (${1:statement}) {\n\tvar ${2:function_name} = function (){\n\t\t$0\n\t}\n}\nelse if(${3:statement}) {\n\tvar ${2:function_name} = function(){\n\n\t};\n};"
  end
  
  snippet t(:lazy_function_definition) do |s|
    s.trigger = "lazy"
    s.expansion = "var ${1:foo} = function (){\n\t\tif(${2:statement}) {\n\t\t\t${1:foo} = function ($0){\n\n\t\t\t};\n\t\t}\n\t\telse if(${3:statement}) {\n\t\t\t${1:foo} = function ($0){\n\n\t\t\t};\n\t\t};\n\n\t\treturn ${1:foo}($0);\n};"
  end
  
# FIXME Not currently working due to unsupported TextMate functionality
  # snippet "Get Elements" do |s|
    # s.trigger = "get"
    # s.expansion = "getElement${1/(T)|.*/(?1:s)/}By${1:T}${1/(T)|(I)|.*/(?1:agName)(?2:d)/}('$2')"
  # end
  
end