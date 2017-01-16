#���غ�����
source [file join [file dir [info script]] base.tcl]
#������������ļ�����������ã����� ����Ĭ������
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
#��������
package require Tk
wm title . "����IP��ַ����������"
wm minsize . 120 160
frame .fip

label .fip.lbip -text "IP ��ַ:"
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
label .fmask.lbip -text "mask��ַ"
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
label .gateway.lb -text "����"
entry .gateway.ip -width 20 -textvariable gateway

pack .gateway.lb -side left
pack .gateway.ip -side left
pack .gateway -side top


frame .range 
label .range.lb -text "IP��ַ��Χ"
label .range.to -text "--"
entry .range.start -width 20 -textvariable ipstart
entry .range.end -width 20 -textvariable ipend
pack .range.lb -side left
pack .range.start -side left
pack .range.to -side left
pack .range.end -side left
pack .range -side top

frame .submit
button .submit.do -text "ȷ��" -command checksetting
pack .submit.do -side bottom
pack .submit -side top

#����ʵ�ֽ���
proc shownotice {} {
  tk_messageBox -message "����������鿴��־��Ϣ" -icon question -type ok;
}

proc checksetting {} {
  global ip1 ip2 ip3 ip4 ;#ip��ַ��
  global mip1 mip2 mip3 mip4 ;#���������
  global gateway ipstart ipend configfile;# ���أ���ʼIP������IP�������ļ�·��
  set ipaddress $ip1.$ip2.$ip3.$ip4;#ip��ַ
  set mask $mip1.$mip2.$mip3.$mip4;# ��������
  #1. �ж�IP��ַ �����ز�����ͬ
  if {$ipaddress==$gateway} {puts "ip��ַ���ܺ������ظ�";shownotice;return}
  #2.�ж�IP��ַ���������룬���� �����ϼȶ��ĸ�ʽ
  if {[checkipvalid ip=$ipaddress] && [checkmask mask=$mask] && [checkipvalid ip=$gateway]} {
    #3. �ж�IP ���ص�ַ ��  IP��ַ�� ��������ָ���ķ�Χ��
    if {![checkinrange ip=$ipaddress mask=$mask targetip=$gateway]} {shownotice;return}
    #4. �ж�IP��ַ �� IP��ַ�� ��������ָ���ķ�Χ��
    if {![checkinrange ip=$ipaddress mask=$mask targetip=$ipaddress]} {shownotice;return}
    #5. �õ� IP��ַ�� �������� ָ���� IP��ַ�ķ�Χ
    set iprange [getiprange ip=$ipaddress mask=$mask]
    set ipstart [lindex $iprange 0]
    set ipend [lindex $iprange 1]
  } else {
    shownotice
    set ipstart ""
    set ipend ""
  }
  #����ȷ��IP��ַ���������룬���� �Ȳ������� ���浽�ļ��У���һ�������Զ�����
  set savestr "set ip1 $ip1;set ip2 $ip2;set ip3 $ip3;set ip4 $ip4;set mip1 $mip1;set mip2 $mip2;set mip3 $ip3;set mip4 $mip4; set gateway $gateway"
  set fd [open $configfile "w+"]
  puts $fd $savestr
  close $fd
  tk_messageBox -message "�㶨" -icon question -type ok;
}

