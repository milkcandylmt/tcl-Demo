source [file join [file dir [info script]] base.tcl]
#DHCP�߽���ѵ
#��Ҫ���裺
#1. �趨ip ��������
#2. setiprange�� ����DHCP ����ʼIP ����ֹIP������Ĭ������
#3. static_assign�� DHCP ��̬��ҳ�棬�� IP ��MAC
#4.client_getip�� ͨ���򵥵Ĺ��򣬿ͻ�����������˻�ȡIP��ַ
#5. show_client�� ��ʾ��ǰ�� �Է�����ͻ��˵�IP ��ַ��MAC ��ַ�Ķ�Ӧ��ϵ

#******************ҳ���������**************
set config_lan_ipaddr 192.168.0.1
set config_lan_mask 255.255.255.0
set iprange [getiprange ip=$config_lan_ipaddr mask=$config_lan_mask]
set ipstart [lindex $iprange 0]
set ipend [lindex $iprange 1]
#******************�ڲ���������***************
array set iptable {} ;#�����Ѿ������IP��ַ��MAC��ַ
array set ipbind {};#����󶨵�IP��ַ ��MAC��ַ
set iplst {} ;# �����Ѿ������IP��ַ

#�ж� newipstart newipend ��Χ��IP��ַ ��д���Ƿ���IP��mask ָ���ķ�Χ֮��
proc checkrange {ip mask newipstart newipend} {
  set newipstart [iptonumber ip=$newipstart]
  set newipend [iptonumber ip=$newipend]
  if {$newipstart>$newipend} {puts "��ʼIP��ַ���ܴ�����ֹIP��ַ";return 0}
  set iprange  [getiprangenumber ip=$ip mask=$mask]
  set ipstart  [lindex $iprange 0]
  set ipend  [lindex $iprange 1]
  if {$newipstart>=$ipstart && $newipend<=$ipend} {return 1} else { puts "ip��ַ����ָ����Χ��";return 0}
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
  if {[string length $mac]!=12} {puts "���ȱ���Ϊ12";return 0}
  if {![regexp -nocase  {^[0-9a-f]+$} $mac]} {puts "mac����Ϊ0-9,a-f";return 0;}
  return 1
}



proc static_assign {ip mac} {
  checkipvalid ip=$ip
  if {![checkmac $mac]} {return 0}
  global ipbind
  if {[info exist ipbind($ip)]} {
    if {$ipbind($ip)==$mac} {
      puts "�벻Ҫ�ظ����"
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
  #�õ���ʼIP�ͽ���IP��������ʽ
  set ipnumbers [getiprangenumber1 ipstart=$ipstart ipend=$ipend]
  set startnumber [lindex $ipnumbers 0]
  set endnumber [lindex $ipnumbers 1]
  #����һ��IP ���ó���ʼIP
  set thisip [numbertoip number=$startnumber]
  
  #����а󶨵����ȷ���󶨵�
  #����ǵ�ǰMAC�Ƿ�󶨣���������հ󶨷���
  foreach ip [array names ipbind] {
    if {$ipbind($ip) == $mac} {
      #���IP�ڷ�Χ�ڣ������
      if {[checkipnumber startnumber=$startnumber endnumber=$endnumber ip=$ip]==1} {
        set iptable($ip) $mac
        return 1
      }
    }
  }

  #�����չ�����䣬��С�������
  set assinediplst [array names iptable] ;#�Ѿ������ȥ��IP
  for {set start $startnumber} {$start<$endnumber} {incr $endnumber} {
    if {$thisip in $assinediplst} {
      #���IP��ַ�Ѿ����䣬��鿴��һ��IP��ַ
      set thisip [getnextip $thisip]
    } else {
      #����ֱ�ӷ���
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
# 1. �趨��Χ
# 2. �趨��
# 3. ��ȡIP
# 4. ��ʾ�ͻ���
# 5. ��ȡIP
# 6.��ʾ�ͻ���
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






