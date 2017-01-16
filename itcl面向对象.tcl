#itcl培训
#类定义
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
#构造函数/析构函数==》 我轻轻的   “来”   了，挥一挥衣袖不带 “走” 一片云彩
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
#继承
itcl::class Sun {
  inherit Father
}
Sun s1
puts [s1 getmoney]
#多态
class SunOther {
  inherit Father
  method getmoney {} {puts "i am SunOther,not Father!";return "[$this info class] has $money"}
}
SunOther s2
puts [s2 getmoney]
# common 类变量
# proc 类函数，大家都可以调用
s1 getpeople
s2 getpeople
f1 getpeople
#public,private,protected 描述父子关系
class Mother {
  public  method  pubfunc {} {puts "pubfunc"}
  private  method  prifunc {}  {puts "prifunc"}
  protected  method  profunc {} {puts profunc}
  ;#内部调用
  method runpub {} {pubfunc}
  method runpro {} {profunc}
  method runpri {} {prifunc}
}
Mother m1
m1 pubfunc;#外部调用 OK

#内部调用
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
#失败

# dt prifunc
# dt profunc





