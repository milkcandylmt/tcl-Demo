#itcl��ѵ
#�ඨ��
#itcl::class className {
# inherit baseClass ?baseClass...? 
# constructor args ?init? body 
# destructor body 
# method name ?args? ?body? 
# proc name ?args? ?body? 
# variable varName ?init? ?config? 
# common varName ?init? 
# public command ?arg arg ...? 
# protected command ?arg arg ...? 
# private command ?arg arg ...? 
# set varName ?value? 
# array option ?arg arg ...? 
# } 
package require itcl
namespace import itcl::*
#���캯��/��������==�� �������   ������   �ˣ���һ�����䲻�� ���ߡ� һƬ�Ʋ�
itcl::class Father {
  variable name "NoOne"
  variable money 0
  common peoples 0
  proc getpeople {} {puts "we have $peoples people"}
  method getmoney {} {return "[$this info class] has $money"}
  constructor {{mymoney 500}} {set money $mymoney;puts "have money $mymoney";incr peoples}
  destructor {puts "i am $this,good bye"; incr peoples -1}
}
Father f1
puts [f1 getmoney]
f1 getpeople
#�̳�
itcl::class Sun {
  inherit Father
}
Sun s1
puts [s1 getmoney]
#��̬
class SunOther {
  inherit Father
  method getmoney {} {puts "i am SunOther,not Father!";return "[$this info class] has $money"}
}
SunOther s2
puts [s2 getmoney]
# common �����
# proc �ຯ������Ҷ����Ե���
s1 getpeople
s2 getpeople
f1 getpeople
#public,private,protected �������ӹ�ϵ
class Mother {
  public  method  pubfunc {} {puts "pubfunc"}
  private  method  prifunc {}  {puts "prifunc"}
  protected  method  profunc {} {puts profunc}
  ;#�ڲ�����
  method runpub {} {pubfunc}
  method runpro {} {profunc}
  method runpri {} {prifunc}
}
Mother m1
m1 pubfunc;#�ⲿ���� OK

#�ڲ�����
m1 runpub
m1 runpro
m1 runpri
# m1 prifunc
# m1 profunc
class Dt {
  inherit Mother
  #
  method runpub {} {pubfunc}
  method runpro {} {profunc}
  method runpri {} {prifunc}
  #
}

Dt dt
dt pubfunc

dt runpub
dt runpro
dt runpri
#ʧ��

# dt prifunc
# dt profunc





