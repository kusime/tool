#!/usr/bin/python
import  os

zhpath='/home/kusime/Desktop/blog/content/zh/posts/'
enpath='/home/kusime/Desktop/blog/content/en/posts/'
path='/home/kusime/Desktop/blog/content/'
print("THIS SCRPIT FILE RUN AT " + path +" FLODER")

signal='.md'
muten='.en.md'
mutzh='.zh.md'
print("zh or en")
x=input("please  input the language for this content >>>")

if  x == "zh":
    print("do you want to creat english file for this post ??")
    choise=input("y or n>>>")
    name=input("please input the name for the post>>")
    if choise == "y":

        os.system("echo "+name+">" + zhpath + name + muten )
        os.system("echo "+name+">" + zhpath + name + signal)
        os.system("gedit -w " + zhpath + name + muten + ' ' + zhpath + name + signal)
    else:
        os.system("echo "+name+">" + zhpath + name + signal )
        os.system("gedit -w " + zhpath + name + signal)

elif  x == "en":

    print("do you want to creat chinese file for this post ??")
    choise=input("y or n>>>")
    name=input("please input the name for the post>>")
    if choise == "y":
        os.system("echo "+name+">" + enpath + name  + mutzh )
        os.system("echo "+name+">" + enpath + name  + signal)
        os.system("gedit -w " + enpath + name + mutzh + ' ' + enpath + name + signal)
    else:
        os.system("echo "+name+">" + enpath + name  + signal )
        os.system("gedit -w " + enpath + name + signal)

else:
    print("creat error")



    
