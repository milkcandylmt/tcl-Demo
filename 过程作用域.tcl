#ȫ�ֱ����������ⶨ��ı���
#�ֲ������� �����ڲ�����ı���

set a 100
proc testa {} {puts $::a}
testa

#������ �� ȫ��������> ����������1>����������2...... 
puts "********������***********"
set ga 100;#ȫ��
proc test {} {set a 100;puts "test level [info level]"} ;#�ֲ���������
proc test1 {} {set b 200;test;puts "test1 level [info level]"}
proc test2 {} {set c 2000;test1;puts "test2 level [info level]"}

#test2>test1>test ��ô�������ֲ�Σ� [info level]
puts "global: level [info level]"
test2
puts "********������***********"


#1. �����ڲ����� ȫ�ֱ���/�ϲ���� �ķ��� 1. global 2. upvar 3. uplevel 4. ::ȫ����������

puts "global ����ȫ�ֱ���"
#***********global************
#Ŀ�꣺�ڹ����иı�ȫ�ֱ�����ֵ��
set g_a 100;#�����ⶨ��ȫ�ֱ���a
puts "g_a: $g_a"
proc GetGlobal {} {;# ������һ��Ҫλ����ã���������һ��
  global g_a
  set g_a 200 ;#�ڹ����ڱ��ı�
}
GetGlobal
puts "g_a:$g_a" ;# �������ȷʵ���ı�

puts "global ����ȫ�ֱ��� ����\r\n"
#*****************************


puts "ȫ�ֱ���:: ��ʼ"

set g_ab 200
proc setab {} {
set ::g_ab 1000
}
setab
puts "g_ab: $g_ab"
puts "ȫ�ֱ���:: ����\r\n"



puts "upvar ����ȫ�ֱ���/�ϲ����/�������"
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
puts "upvar ����ȫ�ֱ���/�ϲ����/�������/����\r\n"


puts "uplevel�ı�ȫ�ֱ���/�ϼ�����/������� ��ʼ"

set g_level0 100
proc l1 {} {uplevel #0 {set g_level0 5000}}
l1;#ִ��
puts "after l1 g_level0: $g_level0"

puts "uplevel�ı�ȫ�ֱ���/�ϼ�����/������� ����\r\n"





