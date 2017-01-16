source [file join [file dir [info script]] commfunc.tcl]
#LAN IP地址设置
# IP地址/子网掩码
set ip 192.168.0.1
set mask 255.255.255.0

# 1.检查IP地址是否合法：checkipvalid
#2. 检查MASK地址是否合法 checkmask
#3.  需要计算出 IP 地址和 mask 所指示的IP 地址的范围：getiprange

#getiprange 还调用了以下几个过程：
    # numbertoip#为了方便计算得到数字形式的IP地址和子网掩码
    # getmaskreverse #为了计算 广播地址，需要得到子网掩码的 反转
    # numbertoip #将计算之后的数字 转换回 IP地址的形式
    
#4. 通过判断 检查给定的IP地址是否在 IP 和MASK 指定的范围内，来判断将电脑的IP 地址设置成该 地址后，能否正常 访问设备：
#checkclientip->checkinrange


#过程名：checkipvalid
# 作用： 检查输入的IP地址是否合法
# 参数:
      # IP地址
# 输出：0--检查不通过 1-检查通过

#检查点： 1.IP地址都是0-10的数字
#         2.IP地址都是介于0-255之间
#         3.IP 地址由三个"." 和 4个数字组成
#         4. IP地址的第一个和最后一个必须不为0
proc checkipvalid {args} {
  set argnames {ip}
  check_set_arg
  set iplst [split $ip "."]
  if {[llength $iplst]!=4} {puts "ip地址必须是由.号分割的四个数字";return 0}
  foreach item $iplst {
      if {![string is integer $item]} {puts "IP地址的每一项必须是数字";return 0}
      if {!($item<=255 && $item>=0)} {puts "IP地址的每一项必须介于0-255之间";return 0}
  }
  if {[lindex $iplst 0] in {0 00 000}} {puts "IP地址第一项必须不为 0";return 0}
  return 1
}


# puts [checkipvalid 123.168.255.101] 


#过程名：checkmask
# 作用： 检查输入的子网掩码是否合法
# 参数:
      # mask: 子网掩码
# 输出：0--检查不通过 1-检查通过

#检查点： 1.子网掩码符合IP地址的格式
#         2.子网掩码的二进制必须是 连续的1和0组成，例如1000000或者11000000 等

proc checkmask {args} {
  set argnames {mask}
  check_set_arg
  #子网掩码必须先符合IP地址规则
  if {[checkipvalid ip=$mask]==0} {return 0}
  set masklst [split $mask "."]
  #子网掩码的二进制必须是 连续的1和0组成，例如1000000或者11000000
  foreach item $masklst {
      if {!([lindex $item 0] in {128 192 224 240 248 252 254 255 0})} {puts "子网掩码 \"$item\" 不正确";return 0}
  }
  return 1
}



# 过程名：numbertoip
# 作用：得到IP地址的 10进制数字形式
#参数: 
    #ip:ip地址
#输出 ip地址的数字形式
#举例： ip地址是192.168.0.1 则输出结果是 192 * 2^24  +  168 * 2^16 + 0* 2^8 + 1* 2^0 的值

proc iptonumber {args} \
{
  set argnames {ip}
  check_set_arg
  set iplst [split $ip "."]
  set ipnumber [expr ([lindex $iplst 0]<<24) + ([lindex $iplst 1]<<16) +([lindex $iplst 2]<<8) +([lindex $iplst 3]<<0) ]
  return $ipnumber
}


# 过程名：getmaskreverse
# 作用：反转子网掩码
#参数: 
    #mask： 子网掩码
#输出: 子网掩码的反转形式
#举例： 如果子网掩码为 255.255.255.0 则输出 255，如果子网掩码为 255.255.255.240 则输出15
#       如果子网掩码为 255.255.255.100 则输出 报错，提示原因



# 过程名：numbertoip
# 作用：将数字格式的IP地址转换为点分制
#参数: 
    # number：32位的IP地址数字格式
    # 输出: 点分进制的IP地址格式
#举例： numbertoip 3232235521 即 192*2^24 + 168*2^16 + 1 输出为 192.168.0.1 
proc numbertoip {args} {
  set argnames {number}
  check_set_arg
  append ip [expr ($number &0xff000000)>>24].[expr ($number & 0x00ff0000)>>16].[expr ($number &0xff00)>>8].[expr ($number & 0xff)]
  return $ip
}


proc getmaskreverse {args} {
  set argnames {mask}
  check_set_arg
  checkmask mask=$mask
  set mask [iptonumber  ip=$mask]
  return [expr ~$mask & 0xffffffff]
}
# 过程名：checkinrange
# 作用：检查目的IP是否在ip地址和子网掩码一起指示的范围内
#参数: 
    #ip:ip地址
    #mask:子网掩码
    #targetip: 目的IP，PC的网卡将要被设置的IP地址
#输出: 目的IP是否在 IP地址范围内，1表示在 0 表示不在
#举例： 如果子网掩码为 255.255.255.0 则输出 255，如果子网掩码为 255.255.255.240 则输出15
#       如果子网掩码为 255.255.255.100 则输出 报错，提示原因
proc checkinrange {args} {
  set argnames {ip mask targetip}
  check_set_arg
  set ipbegin [expr  [iptonumber  ip=$ip ] & [iptonumber  ip=$mask ] ] 
  set maskreverse [getmaskreverse mask=$mask]
  set ipend [expr $ipbegin | $maskreverse]
  set targetipnumber [iptonumber  ip=$targetip]
  #比较是否在范围内
  if {$targetipnumber>$ipbegin && $targetipnumber <$ipend} {return 1} else {puts "目的ip地址 $targetip 不在ip和掩码($ip $mask)指定的范围内";return 0}
}


# 过程名：checkclientip
# 作用：设置LAN口的IP之后，检查PC设置的IP能否连上 设备
#参数: 
    #ip:ip地址
    #mask:子网掩码
    #targetip: 目的IP，检查将PC的IP设置成该IP之后，是否能访问设备的IP地址
#举例： 如果将LAN口地址设置为 192.168.1.1 子网掩码设置为 255.255.255.128 如果将PC 的IP地址设置成192.168.1.240 则连接不上，返回0
#checkclientip 192.168.1.1 255.255.255.128  192.168.1.240 结果是0，checkclientip 192.168.1.1 255.255.255.128  192.168.1.8 结果是1

proc checkclientip {args} {
  set argnames {ip mask targetip}
  check_set_arg
  if {[checkipvalid ip=$ip]==0} {return 0}; #检查IP地址有效性
  if {[checkipvalid ip=$targetip]==0} {return 0}; #检查目的IP地址有效性
  if {[checkmask mask=$mask]==0} {return 0};#检查子网掩码有效性
  return [checkinrange ip=$ip mask=$mask targetip=$targetip] ;#检查目的IP是否在  IP 和子网掩码 规定的范围内
}
# puts [checkclientip ip=192.168.1.1 mask=255.255.255.128  targetip=192.168.1.240]









proc testip {args} {
  set argnames {ip mask}
  check_set_arg
  puts "ip:$ip ; mask:$mask"
  #继续使用ip mask
}
# testip  ip=192.168.0.1 mask=255.255.255.0


# 过程名：getiprange
# 作用：#根据ip地址 子网掩码 得到 IP地址的范围
#参数: 
    # ip：ip地址
    # mask: 子网掩码
#举例： getiprange 192.168.0.1 255.255.240.0 得到 192.168.0.1-192.168.0.15
proc getiprange {args} {
   set argnames {ip mask}
   check_set_arg
   checkipvalid ip=$ip
   checkmask mask=$mask
  set ipbegin [expr  ([iptonumber  ip=$ip ] & [iptonumber  ip=$mask ]) +1] 
  set maskreverse [getmaskreverse mask=$mask]
  set ipend [expr ($ipbegin | $maskreverse) -1]
  return "[numbertoip number=$ipbegin] [numbertoip number=$ipend]"
}

getiprange ip=192.168.0.1 mask=255.255.240.0




#********************** 以下过程 为配合DHCP 功能实现*********




# 过程名：getiprangenumber
# 作用：#根据ip地址 子网掩码 得到 IP地址的范围的数字形式
#参数: 
    # ip：ip地址
    # mask: 子网掩码
#举例： getiprangenumber 192.168.0.1 255.255.240.0 得到 192.168.0.1 和 192.168.0.15 的数字形式 
      #即 numbertoip 192.168.0.1 和getipnumber 192.168.0.15 的结果加在一起
proc getiprangenumber {args} {
   set argnames {ip mask}
   check_set_arg
   checkipvalid ip=$ip
   checkmask mask=$mask
   set ipbegin [expr  ([iptonumber  ip=$ip ] & [iptonumber  ip=$mask ]) +1] 
   set maskreverse [getmaskreverse mask=$mask]
   set ipend [expr ($ipbegin | $maskreverse) -1]
   return "$ipbegin $ipend"
}
# 过程名：getiprangenumber1
# 作用：#根据ip地址 子网掩码 得到 IP地址的范围的数字形式
#参数: 
    # ip：ip地址
    # mask: 子网掩码
#举例： getiprangenumber1 192.168.0.1 192.168.0.254 得到 192.168.0.1 和 192.168.0.254 的数字形式 
      #即 numbertoip 192.168.0.1 和getipnumber 192.168.0.254 的结果合在一起
proc getiprangenumber1 {args} {
  set argnames { ipstart ipend}
  check_set_arg
  checkipvalid ip=$ipstart
  checkipvalid ip=$ipend
  return "[iptonumber  ip=$ipstart] [iptonumber  ip=$ipend] "
}

# 过程名：checkipnumber
# 作用：# 检查给定的IP地址 是否在 两个 数字形式的IP地址表示的范围内
#参数: 
    # startnumber：开始IP地址的数字形式
    # endnumber: 结束IP地址的数字形式
    #ip: 被检查的IP地址
#返回值： 如果指定的IP 在给定的范围内，返回1
    #举例：  checkipnumber  3232235521 3232235774 192.168.0.15 结果返回1, 3232235521 对应192.168.0.1，3232235774 对应 192.168.0.254 所以192.168.0.15 在这个范围内
proc checkipnumber {args} {
  set argnames {startnumber endnumber ip}
  check_set_arg
  set ip [iptonumber  ip=$ip]
  if {$ip >=$startnumber && $ip <=$endnumber} {return 1} else {return 0}
}


#ip mask 和 不合法
#能访问
#不能访问


