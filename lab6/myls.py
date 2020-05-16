#!/usr/bin/python3

# Gracjan Puch
# 41490
# 31B
# Zadanie na ocenę 5
# Na podstawie pierwszego laboratorium

import sys
import pwd
import stat
import os
import datetime

rootDir = os.getcwd()
printLong=False
printName=False

for arg in sys.argv[1:len(sys.argv)]:
    if(arg == "-l"):
        printLong=True
    elif (arg=='-L'):
        printName=True
    elif (os.path.exists(arg)):
        rootDir=arg
    else:
        print("Nierozpoznany argument lub nieistniejąca ścieżka: " + arg)
        exit()

allFiles = os.listdir(rootDir)
allFiles = sorted(allFiles, reverse=True)

for file in os.listdir(rootDir):
        line = ""
        fullpath=rootDir +"/" + file
        st = os.stat(fullpath)

        if (printLong):
            line += file.ljust(30) + " "
            line += str(st.st_size).ljust(10) + " "
            line += datetime.datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M:%S") + " "
            line += stat.filemode(st.st_mode) + " "
        else:
            line += file

        if (printName):
            line += pwd.getpwuid(st.st_uid).pw_name + " "

        print(line)
