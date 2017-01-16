#全局变量：过程外定义的变量
#局部变量： 过程内部定义的变量

set a 100
proc testa {} {puts $::a}
testa

#作用域 ： 全局作用域> 过程作用域1>过程作用域2...... 
puts "********作用域***********"
set ga 100;#全局
proc test {} {set a 100;puts "test level [info level]"} ;#局部作用域名
proc test1 {} {set b 200;test;puts "test1 level [info level]"}
proc test2 {} {set c 2000;test1;puts "test2 level [info level]"}

#test2>test1>test 怎么样来区分层次？ [info level]
puts "global: level [info level]"
test2
puts "********作用域***********"


#1. 过程内部访问 全局变量/上层变量 的方法 1. global 2. upvar 3. uplevel 4. ::全局作用域名

puts "global 访问全局变量"
#***********global************
#目标：在过程中改变全局变量的值。
set g_a 100;#过程外定义全局变量a
puts "g_a: $g_a"
proc GetGlobal {} {;# 左括号一定要位于最好，以连接下一行
  global g_a
  set g_a 200 ;#在过程内被改变
}
GetGlobal
puts "g_a:$g_a" ;# 经过检查确实被改变

puts "global 访问全局变量 结束\r\n"
#*****************************


puts "全局变量:: 开始"

set g_ab 200
proc setab {} {
set ::g_ab 1000
}
setab
puts "g_ab: $g_ab"
puts "全局变量:: 结束\r\n"



puts "upvar 访问全局变量/上层变量/本层变量"
set g_b 1000
proc Getupvar {} {
  upvar g_b local_b
  puts "local_b: $local_b"
  set local_b 2000
}
puts "$g_b:$g_b"


proc level1 {} {
  set b 200
  puts "b in level 1:$b"
  level2
  puts "b in level 1:$b"
}
proc level2 {} {
  upvar 1 b local_b
  set local_b 800
}
puts "upvar 访问全局变量/上层变量/本层变量/结束\r\n"


puts "uplevel改变全局变量/上级变量/本层变量 开始"

set g_level0 100
proc l1 {} {uplevel #0 {set g_level0 5000}}
l1;#执行
puts "after l1 g_level0: $g_level0"

puts "uplevel改变全局变量/上级变量/本层变量 结束\r\n"





