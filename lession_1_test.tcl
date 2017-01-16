proc IPtoHex {ip} {
	set  result "" ;# 定义一个输出
  set ip [split $ip "."]; puts $ip ;#拆分
  foreach  number $ip  { ;# 逐个
    puts "10进制: $number"
    set number  [format  %02X  $number] ;# 转换成16进制
    puts "16进制: $number"
    append result $number ;# 合并
  }
    return $result
} 
puts [IPtoHex 192.168.100.200]

proc HextoIP {Hex} {
  set  result "" ;# 定义一个输出
  set hexs "" ;#保存拆分后的变量
  set  iplist "" ;#保存转换后的10进制
  
  # 拆分成 C0 A8 64 64 的形式,取第 （2n,2n+1）个，n=0,1,2,3
  for  {set i 0} {$i< [expr  [string length $Hex]/2]} {incr i}  {
      lappend hexs  [string range  $Hex  [expr 2*$i]  [expr 2*$i +1]]
  }
  
  foreach  number $hexs  { ;# 逐个
    set number  [format  %d 0x$number] ;# 转换成16进制
    lappend iplist $number ;# 合并
  }
  
  return [join $iplist "."]
}
puts [HextoIP c0a80102]



proc p1.2.1  {} {puts "        p1.2.1"} 
proc p1.2.2  {} {puts "        p1.2.2"}
proc p1.1 {} {puts "p1.1"} 
proc p1.2 {} {p1.2.1;p1.2.2;puts "p 1.2"}
proc p1 {} {p1.1;p1.2;puts "p 1"}
p1


set a 100; 
proc p2 {} {upvar 1 pa1 pa2;set pa2 2000}; 
proc p1 {} {set pa1 100; puts $pa1; p2; puts $pa1}
p1

proc p20 {} {uplevel 1 {set pa1 2000}}; 
proc p10 {} {p20; puts "pa1=$pa1"}
p10

puts [info proc p*]
puts [info body p10]


proc  testarg {arg1 arg2 arg3} {}
puts [info args testarg]


set code {set a 100;set b 200; puts "$a+$b=[expr $a+$b]"}
eval $code

proc test {} {puts "100 in test"}
proc test {} {puts "200 in test"}
test


namespace eval testnmsp {
	variable var1 2000
	proc p1 {} {variable var1;puts "$var1 in p1"}
  namespace eval testnmsp2 {
    variable var2 5000
    proc p2 {} {variable var2;puts "$var2 in p2"}
  }
}
puts "var1=$testnmsp::var1"
testnmsp::p1
puts "var2=$testnmsp::testnmsp2::var2"
testnmsp::testnmsp2::p2


