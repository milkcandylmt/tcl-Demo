proc check_set_arg {} {
  uplevel 1 {set procname [lindex  [info level [info level]] 0]}
  uplevel 1 {foreach argname $argnames {set [lindex $argname 0] ""}}
  upvar 1 args _arglist
  upvar 1 argnames _argnames
  upvar 1 procname _procname
  foreach arg $_arglist {
    set arg [split $arg "="]
    set argname [lindex $arg 0]
    set argvalue [lindex $arg 1]
    if {!($argname in $_argnames)} {error " 调用 $_procname 时参数 $argname 不存在，args(参数): $_argnames"} else {
      upvar 1 $argname $argname
      set $argname $argvalue
    }
  }
}