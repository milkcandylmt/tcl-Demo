#字典  由三个部分组成   字典名字  关键字  值
set school(class) "class one"
set school(teacher) "Mr li"
set school(class) "class two"
parray school;#打印内容
# school: 字典名
# teacher: 关键字(key)
# "Mr li":值

#快速建立一个字典
set value {class "class one" teacher "Mrli"}
puts "value: $value"
array set myschool $value
#读取其中的元素
puts $myschool(class)
puts $myschool(teacher)
#也可以用变量表示 关键字：
set keyname teacher
puts $myschool($keyname)
#有时候将字典转换成 列表保存，因为数组不能直接作为 函数的参数传递
set schoollist [array get myschool]
puts $schoollist;#可以发现字典的顺序是无序的，所以转换回来后 会乱序
#那么怎么排序呢？ 自己制定关键字的顺序
#1. 得到关键字 array name + 数组名
#2. 对关键字进行排序 lsort
#3. 根据关键字 进行索引
set keys [array names myschool]
set keys [lsort $keys]
foreach key $keys {
  puts -nonewline "$key [list $myschool($key)] "
}
puts "******************"
#判断字典是否存在？1:存在 2:不存在
puts [array exist myschool]
puts [info exist myschool(teacher)]
puts [info exist myschool(teacherabc)]
#删除，释放字典
unset myschool
puts [array exist myschool]
#关键字: array exist, array set, array get,