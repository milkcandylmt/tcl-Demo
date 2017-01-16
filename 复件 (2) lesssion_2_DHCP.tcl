source [file join [file dir [info script]] base.tcl]
#DHCP高阶培训
#主要步骤：
#1. 设定ip 子网掩码
#2. setiprange： 配置DHCP 的起始IP 和终止IP，覆盖默认设置
#3. static_assign： DHCP 静态绑定页面，绑定 IP 和MAC
#4.client_getip： 通过简单的规则，客户端向服务器端获取IP地址
#5. show_client： 显示当前的 以分配给客户端的IP 地址和MAC 地址的对应关系

#******************页面变量定义**************
set config_lan_ipaddr 192.168.0.1
set config_lan_mask 255.255.255.0
set iprange [getiprange ip=$config_lan_ipaddr mask=$config_lan_mask]
set ipstart [lindex $iprange 0]
set ipend [lindex $iprange 1]
#******************内部变量定义***************
array set iptable {} ;#保存已经分配的IP地址和MAC地址
array set ipbind {};#保存绑定的IP地址 和MAC地址
set iplst {} ;# 保存已经分配的IP地址

#判断 newipstart newipend 范围的IP地址 填写的是否在IP和mask 指定的范围之内
proc checkrange {ip mask newipstart newipend} {
  set newipstart [iptonumber ip=$newipstart]
  set newipend [iptonumber ip=$newipend]
  if {$newipstart>$newipend} {puts "起始IP地址不能大于终止IP地址";return 0}
  set iprange  [getiprangenumber ip=$ip mask=$mask]
  set ipstart  [lindex $iprange 0]
  set ipend  [lindex $iprange 1]
  if {$newipstart>=$ipstart && $newipend<=$ipend} {return 1} else { puts "ip地址不在指定范围内";return 0}
}
# puts [checkrange 192.168.0.1 255.255.255.0 192.168.0.1 192.168.2.2]

proc setiprange {ip mask newipstart newipend} {
  global ipstart ipend iptable
  if {[checkrange $ip $mask $newipstart $newipend]==0} {return 0}
  set ipstart $newipstart
  set ipend $newipend
  unset iptable
  array set iptable {}
  return 1;
}
proc checkmac {mac} {
  regsub -all {\-} $mac "" mac
  if {[string length $mac]!=12} {puts "长度必须为12";return 0}
  if {![regexp -nocase  {^[0-9a-f]+$} $mac]} {puts "mac必须为0-9,a-f";return 0;}
  return 1
}



proc static_assign {ip mac} {
  checkipvalid ip=$ip
  if {![checkmac $mac]} {return 0}
  global ipbind
  if {[info exist ipbind($ip)]} {
    if {$ipbind($ip)==$mac} {
      puts "请不要重复添加"
    } else {
      set ipbind($ip) $mac
    }
  } else {
    set ipbind($ip) $mac
  }
}
proc getnextip {ip} {
  global ipstart ipend 
  set ipnumbers [getiprangenumber1 ipstart=$ipstart ipend=$ipend]
  set startnumber [lindex $ipnumbers 0]
  set endnumber [lindex $ipnumbers 1]
  set ipnumber [iptonumber ip=$ip]
  set nextipnumber [expr $ipnumber+1]
  if {$nextipnumber<=$endnumber && $nextipnumber >=$startnumber}  {
    return [numbertoip number=$nextipnumber]
  } else {puts "no ip address";return 0}
}
proc client_getip {mac} {
  global ipstart ipend ipbind iptable
  #得到开始IP和结束IP的数字形式
  set ipnumbers [getiprangenumber1 ipstart=$ipstart ipend=$ipend]
  set startnumber [lindex $ipnumbers 0]
  set endnumber [lindex $ipnumbers 1]
  #将第一个IP 设置成起始IP
  set thisip [numbertoip number=$startnumber]
  
  #如果有绑定的优先分配绑定的
  #检查是当前MAC是否绑定，如果绑定则按照绑定分配
  foreach ip [array names ipbind] {
    if {$ipbind($ip) == $mac} {
      #如果IP在范围内，则分配
      if {[checkipnumber startnumber=$startnumber endnumber=$endnumber ip=$ip]==1} {
        set iptable($ip) $mac
        return 1
      }
    }
  }

  #否则按照规则分配，从小到大分配
  set assinediplst [array names iptable] ;#已经分配出去的IP
  for {set start $startnumber} {$start<$endnumber} {incr $endnumber} {
    if {$thisip in $assinediplst} {
      #如果IP地址已经分配，则查看下一个IP地址
      set thisip [getnextip $thisip]
    } else {
      #否则直接分配
      set iptable($thisip) $mac
      return $thisip
    }
  }
  return 0
}

proc show_client {} {
  global iptable
  puts "*****************"
  foreach ip [array names iptable] {
    puts "ip:$ip mac:$iptable($ip)"
  }
  puts  "*****************"
}
# 1. 设定范围
# 2. 设定绑定
# 3. 获取IP
# 4. 显示客户端
# 5. 获取IP
# 6.显示客户端
setiprange 192.168.0.1 255.255.255.0 192.168.0.4 192.168.0.100
static_assign 192.168.0.50 02-02-03-04-05-06
client_getip 02-05-06-08-06-09
show_client
client_getip 02-05-06-08-06-1f
show_client
client_getip 02-02-03-04-05-06
show_client
client_getip 02-02-03-04-05-06
static_assign 192.168.0.50 02-02-03-04-05-06
show_client






