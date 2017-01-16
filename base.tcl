source [file join [file dir [info script]] commfunc.tcl]
#LAN IP��ַ����
# IP��ַ/��������
set ip 192.168.0.1
set mask 255.255.255.0

# 1.���IP��ַ�Ƿ�Ϸ���checkipvalid
#2. ���MASK��ַ�Ƿ�Ϸ� checkmask
#3.  ��Ҫ����� IP ��ַ�� mask ��ָʾ��IP ��ַ�ķ�Χ��getiprange

#getiprange �����������¼������̣�
    # numbertoip#Ϊ�˷������õ�������ʽ��IP��ַ����������
    # getmaskreverse #Ϊ�˼��� �㲥��ַ����Ҫ�õ���������� ��ת
    # numbertoip #������֮������� ת���� IP��ַ����ʽ
    
#4. ͨ���ж� ��������IP��ַ�Ƿ��� IP ��MASK ָ���ķ�Χ�ڣ����жϽ����Ե�IP ��ַ���óɸ� ��ַ���ܷ����� �����豸��
#checkclientip->checkinrange


#��������checkipvalid
# ���ã� ��������IP��ַ�Ƿ�Ϸ�
# ����:
      # IP��ַ
# �����0--��鲻ͨ�� 1-���ͨ��

#���㣺 1.IP��ַ����0-10������
#         2.IP��ַ���ǽ���0-255֮��
#         3.IP ��ַ������"." �� 4���������
#         4. IP��ַ�ĵ�һ�������һ�����벻Ϊ0
proc checkipvalid {args} {
  set argnames {ip}
  check_set_arg
  set iplst [split $ip "."]
  if {[llength $iplst]!=4} {puts "ip��ַ��������.�ŷָ���ĸ�����";return 0}
  foreach item $iplst {
      if {![string is integer $item]} {puts "IP��ַ��ÿһ�����������";return 0}
      if {!($item<=255 && $item>=0)} {puts "IP��ַ��ÿһ��������0-255֮��";return 0}
  }
  if {[lindex $iplst 0] in {0 00 000}} {puts "IP��ַ��һ����벻Ϊ 0";return 0}
  return 1
}


# puts [checkipvalid 123.168.255.101] 


#��������checkmask
# ���ã� �����������������Ƿ�Ϸ�
# ����:
      # mask: ��������
# �����0--��鲻ͨ�� 1-���ͨ��

#���㣺 1.�����������IP��ַ�ĸ�ʽ
#         2.��������Ķ����Ʊ����� ������1��0��ɣ�����1000000����11000000 ��

proc checkmask {args} {
  set argnames {mask}
  check_set_arg
  #������������ȷ���IP��ַ����
  if {[checkipvalid ip=$mask]==0} {return 0}
  set masklst [split $mask "."]
  #��������Ķ����Ʊ����� ������1��0��ɣ�����1000000����11000000
  foreach item $masklst {
      if {!([lindex $item 0] in {128 192 224 240 248 252 254 255 0})} {puts "�������� \"$item\" ����ȷ";return 0}
  }
  return 1
}



# ��������numbertoip
# ���ã��õ�IP��ַ�� 10����������ʽ
#����: 
    #ip:ip��ַ
#��� ip��ַ��������ʽ
#������ ip��ַ��192.168.0.1 ���������� 192 * 2^24  +  168 * 2^16 + 0* 2^8 + 1* 2^0 ��ֵ

proc iptonumber {args} \
{
  set argnames {ip}
  check_set_arg
  set iplst [split $ip "."]
  set ipnumber [expr ([lindex $iplst 0]<<24) + ([lindex $iplst 1]<<16) +([lindex $iplst 2]<<8) +([lindex $iplst 3]<<0) ]
  return $ipnumber
}


# ��������getmaskreverse
# ���ã���ת��������
#����: 
    #mask�� ��������
#���: ��������ķ�ת��ʽ
#������ �����������Ϊ 255.255.255.0 ����� 255�������������Ϊ 255.255.255.240 �����15
#       �����������Ϊ 255.255.255.100 ����� ������ʾԭ��



# ��������numbertoip
# ���ã������ָ�ʽ��IP��ַת��Ϊ�����
#����: 
    # number��32λ��IP��ַ���ָ�ʽ
    # ���: ��ֽ��Ƶ�IP��ַ��ʽ
#������ numbertoip 3232235521 �� 192*2^24 + 168*2^16 + 1 ���Ϊ 192.168.0.1 
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
# ��������checkinrange
# ���ã����Ŀ��IP�Ƿ���ip��ַ����������һ��ָʾ�ķ�Χ��
#����: 
    #ip:ip��ַ
    #mask:��������
    #targetip: Ŀ��IP��PC��������Ҫ�����õ�IP��ַ
#���: Ŀ��IP�Ƿ��� IP��ַ��Χ�ڣ�1��ʾ�� 0 ��ʾ����
#������ �����������Ϊ 255.255.255.0 ����� 255�������������Ϊ 255.255.255.240 �����15
#       �����������Ϊ 255.255.255.100 ����� ������ʾԭ��
proc checkinrange {args} {
  set argnames {ip mask targetip}
  check_set_arg
  set ipbegin [expr  [iptonumber  ip=$ip ] & [iptonumber  ip=$mask ] ] 
  set maskreverse [getmaskreverse mask=$mask]
  set ipend [expr $ipbegin | $maskreverse]
  set targetipnumber [iptonumber  ip=$targetip]
  #�Ƚ��Ƿ��ڷ�Χ��
  if {$targetipnumber>$ipbegin && $targetipnumber <$ipend} {return 1} else {puts "Ŀ��ip��ַ $targetip ����ip������($ip $mask)ָ���ķ�Χ��";return 0}
}


# ��������checkclientip
# ���ã�����LAN�ڵ�IP֮�󣬼��PC���õ�IP�ܷ����� �豸
#����: 
    #ip:ip��ַ
    #mask:��������
    #targetip: Ŀ��IP����齫PC��IP���óɸ�IP֮���Ƿ��ܷ����豸��IP��ַ
#������ �����LAN�ڵ�ַ����Ϊ 192.168.1.1 ������������Ϊ 255.255.255.128 �����PC ��IP��ַ���ó�192.168.1.240 �����Ӳ��ϣ�����0
#checkclientip 192.168.1.1 255.255.255.128  192.168.1.240 �����0��checkclientip 192.168.1.1 255.255.255.128  192.168.1.8 �����1

proc checkclientip {args} {
  set argnames {ip mask targetip}
  check_set_arg
  if {[checkipvalid ip=$ip]==0} {return 0}; #���IP��ַ��Ч��
  if {[checkipvalid ip=$targetip]==0} {return 0}; #���Ŀ��IP��ַ��Ч��
  if {[checkmask mask=$mask]==0} {return 0};#�������������Ч��
  return [checkinrange ip=$ip mask=$mask targetip=$targetip] ;#���Ŀ��IP�Ƿ���  IP ���������� �涨�ķ�Χ��
}
# puts [checkclientip ip=192.168.1.1 mask=255.255.255.128  targetip=192.168.1.240]









proc testip {args} {
  set argnames {ip mask}
  check_set_arg
  puts "ip:$ip ; mask:$mask"
  #����ʹ��ip mask
}
# testip  ip=192.168.0.1 mask=255.255.255.0


# ��������getiprange
# ���ã�#����ip��ַ �������� �õ� IP��ַ�ķ�Χ
#����: 
    # ip��ip��ַ
    # mask: ��������
#������ getiprange 192.168.0.1 255.255.240.0 �õ� 192.168.0.1-192.168.0.15
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




#********************** ���¹��� Ϊ���DHCP ����ʵ��*********




# ��������getiprangenumber
# ���ã�#����ip��ַ �������� �õ� IP��ַ�ķ�Χ��������ʽ
#����: 
    # ip��ip��ַ
    # mask: ��������
#������ getiprangenumber 192.168.0.1 255.255.240.0 �õ� 192.168.0.1 �� 192.168.0.15 ��������ʽ 
      #�� numbertoip 192.168.0.1 ��getipnumber 192.168.0.15 �Ľ������һ��
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
# ��������getiprangenumber1
# ���ã�#����ip��ַ �������� �õ� IP��ַ�ķ�Χ��������ʽ
#����: 
    # ip��ip��ַ
    # mask: ��������
#������ getiprangenumber1 192.168.0.1 192.168.0.254 �õ� 192.168.0.1 �� 192.168.0.254 ��������ʽ 
      #�� numbertoip 192.168.0.1 ��getipnumber 192.168.0.254 �Ľ������һ��
proc getiprangenumber1 {args} {
  set argnames { ipstart ipend}
  check_set_arg
  checkipvalid ip=$ipstart
  checkipvalid ip=$ipend
  return "[iptonumber  ip=$ipstart] [iptonumber  ip=$ipend] "
}

# ��������checkipnumber
# ���ã�# ��������IP��ַ �Ƿ��� ���� ������ʽ��IP��ַ��ʾ�ķ�Χ��
#����: 
    # startnumber����ʼIP��ַ��������ʽ
    # endnumber: ����IP��ַ��������ʽ
    #ip: ������IP��ַ
#����ֵ�� ���ָ����IP �ڸ����ķ�Χ�ڣ�����1
    #������  checkipnumber  3232235521 3232235774 192.168.0.15 �������1, 3232235521 ��Ӧ192.168.0.1��3232235774 ��Ӧ 192.168.0.254 ����192.168.0.15 �������Χ��
proc checkipnumber {args} {
  set argnames {startnumber endnumber ip}
  check_set_arg
  set ip [iptonumber  ip=$ip]
  if {$ip >=$startnumber && $ip <=$endnumber} {return 1} else {return 0}
}


#ip mask �� ���Ϸ�
#�ܷ���
#���ܷ���


