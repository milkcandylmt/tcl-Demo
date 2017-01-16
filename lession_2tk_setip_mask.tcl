#加载函数库
source [file join [file dir [info script]] base.tcl]
#如果存在配置文件，则加载配置，否则 设置默认设置
set configfile [file join [file dir [info script]] setting.tcl]
if {[file exists $configfile ]} {source $configfile} \
else {
set ip1 192
set ip2 168
set ip3 0
set ip4 1

set mip1 255
set mip2 255
set mip3 255
set mip4 0
set gateway 192.165.0.1
}
#界面设置
package require Tk
wm title . "设置IP地址和子网掩码"
wm minsize . 120 160
frame .fip

label .fip.lbip -text "IP 地址:"
pack .fip.lbip -side left

entry .fip.ip1 -width 3 -textvariable ip1
label .fip.lip1 -text " . "
pack .fip.ip1 -side left
pack .fip.lip1 -side left 

entry .fip.ip2 -width 3 -textvariable ip2
label .fip.lip2 -text " . "
pack .fip.ip2 -side left
pack .fip.lip2 -side left 

entry .fip.ip3 -width 3 -textvariable ip3
label .fip.lip3 -text " . "
pack .fip.ip3 -side left
pack .fip.lip3 -side left 

entry .fip.ip4 -width 3 -textvariable ip4
pack .fip.ip4 -side left

pack .fip -side top

frame .fmask
label .fmask.lbip -text "mask地址"
pack .fmask.lbip -side left

entry .fmask.ip1 -width 3 -textvariable mip1
label .fmask.lip1 -text " . "
pack .fmask.ip1 -side left -expand false
pack .fmask.lip1 -side left 

entry .fmask.ip2 -width 3 -textvariable mip2
label .fmask.lip2 -text " . "
pack .fmask.ip2 -side left
pack .fmask.lip2 -side left 

entry .fmask.ip3 -width 3 -textvariable mip3
label .fmask.lip3 -text " . "
pack .fmask.ip3 -side left
pack .fmask.lip3 -side left 

entry .fmask.ip4 -width 3 -textvariable mip4
pack .fmask.ip4 -side left
pack .fmask -side top

frame .gateway
label .gateway.lb -text "网关"
entry .gateway.ip -width 20 -textvariable gateway

pack .gateway.lb -side left
pack .gateway.ip -side left
pack .gateway -side top


frame .range 
label .range.lb -text "IP地址范围"
label .range.to -text "--"
entry .range.start -width 20 -textvariable ipstart
entry .range.end -width 20 -textvariable ipend
pack .range.lb -side left
pack .range.start -side left
pack .range.to -side left
pack .range.end -side left
pack .range -side top

frame .submit
button .submit.do -text "确定" -command checksetting
pack .submit.do -side bottom
pack .submit -side top

#界面实现结束
proc shownotice {} {
  tk_messageBox -message "发生错误，请查看日志信息" -icon question -type ok;
}

proc checksetting {} {
  global ip1 ip2 ip3 ip4 ;#ip地址框
  global mip1 mip2 mip3 mip4 ;#子网掩码框
  global gateway ipstart ipend configfile;# 网关，开始IP，结束IP，配置文件路径
  set ipaddress $ip1.$ip2.$ip3.$ip4;#ip地址
  set mask $mip1.$mip2.$mip3.$mip4;# 子网掩码
  #1. 判断IP地址 和网关不能相同
  if {$ipaddress==$gateway} {puts "ip地址不能和网关重复";shownotice;return}
  #2.判断IP地址，子网掩码，网关 都符合既定的格式
  if {[checkipvalid ip=$ipaddress] && [checkmask mask=$mask] && [checkipvalid ip=$gateway]} {
    #3. 判断IP 网关地址 在  IP地址和 子网掩码指定的范围内
    if {![checkinrange ip=$ipaddress mask=$mask targetip=$gateway]} {shownotice;return}
    #4. 判定IP地址 在 IP地址和 子网掩码指定的范围内
    if {![checkinrange ip=$ipaddress mask=$mask targetip=$ipaddress]} {shownotice;return}
    #5. 得到 IP地址和 子网掩码 指定的 IP地址的范围
    set iprange [getiprange ip=$ipaddress mask=$mask]
    set ipstart [lindex $iprange 0]
    set ipend [lindex $iprange 1]
  } else {
    shownotice
    set ipstart ""
    set ipend ""
  }
  #将正确的IP地址，子网掩码，网关 等参数设置 保存到文件中，下一次启动自动加载
  set savestr "set ip1 $ip1;set ip2 $ip2;set ip3 $ip3;set ip4 $ip4;set mip1 $mip1;set mip2 $mip2;set mip3 $ip3;set mip4 $mip4; set gateway $gateway"
  set fd [open $configfile "w+"]
  puts $fd $savestr
  close $fd
  tk_messageBox -message "搞定" -icon question -type ok;
}

