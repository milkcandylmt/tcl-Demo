#命名空间
#作用:防止同名变量冲突，对变量和过程 划分区域， 针对多个文件引用。

#1. 基本概念
set bb 2000;#全局变量

namespace eval no1 {
  variable name 20
  proc testfun {} {puts "i am in no1"}
}
namespace eval no2 {
  variable name 30
  proc testfun {} {puts "i am in no2"}
}
puts "$no1::name"
puts "$no2::name"
no1::testfun
no2::testfun

puts "****************adv app*******"
namespace eval test {
  namespace export get_var get_global
  variable aa 20
  variable bb 4000
  proc get_var {} {variable aa; set aa 200;return $aa}
  proc get_global {} {puts "global bb:$::bb"}
}
puts $test::aa
puts "aa: [test::get_var]"
test::get_global
#2.导入和导出 省略命名空间
puts "导入和导出，"
namespace import test::get_var
puts [get_var]
namespace import test::get_global
get_global
#>>namespace import test::*

#3.命名空间嵌套
namespace eval t1 {
  namespace eval t2 {
    variable mytest 2000
  }
}
puts $t1::t2::mytest