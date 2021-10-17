puts "helloasdasdadassdad"
if {0} {
    Next are notes
    It's a test
    Good luck!
}

#建议分行写
set "str" "Hello World !"
puts "$str"
#% Hello World !

set str "Hello"
puts "$str Worllllllllllllllld !"

#% Hello World !


set a "8"
set b "$a+16"
puts "$b"

#% 8+16



set a 8
set b [expr $a+16]
puts "b = $b"
#% b = 24


#使用多行命令时，以最后命令行返回的结果为准
set b [expr $a+15; set c 9]
#命令置换嵌套
set d [expr [expr $a+16] + 4]
puts "b = $b"
puts "d = $d"
#% b = 8
#% d = 28


# set str1 "Hello World1"  
# set str2 \n             
# set str3 \x31           
# puts "$str1 $str2 $str3"
#% Hello World1 !
#%  1


namespace import ::tcl::mathfunc::*
set pi 3.1415926
# sin(pi/6) = 1/2
puts "sin(pi/6) : [sin [expr $pi/6]]"
# acos(0.5) = pi/3
puts "acos(0.5) : [acos 0.5]"
# atan(1) = pi/4
puts "atant2(5/5) : [atan2 5 5]"
#% sin(pi/6) : 0.49999999226497965
#% acos(0.5) : 1.0471975511965979
#% atant2(5/5) : 0.7853981633974483