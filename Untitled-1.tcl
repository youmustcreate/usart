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
set b [expr $a+16; set c 8]
#命令置换嵌套
set d [expr [expr $a+16] + 4]
puts "b = $b"
puts "d = $d"
#% b = 8
#% d = 28





