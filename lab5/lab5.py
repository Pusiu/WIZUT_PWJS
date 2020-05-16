#! /usr/bin/python3
import os
import sys
import stat

if (len(sys.argv) <= 1):
    print("Błąd: Należy podać katalog lub katalogi jako argumenty")
    exit()

allFiles = dict()
duplicates = dict()

def AnalyzeTree(path):
    for root, dirs, files in os.walk(path):
        #p = root.split(os.sep)
        #print((len(path) - 1) * '---', os.path.basename(root))
        for file in files:
            #print(len(path) * '---', file)
            fullpath=root +"/" + file
            st = os.stat(fullpath)
            if (allFiles.get(st.st_size) == None):
                allFiles[st.st_size] = list()
            allFiles[st.st_size].append(fullpath)

def FindSameSizes():
    for v in allFiles.keys():
        Compare(allFiles[v])

def Compare(files):
    for f in files:
        for v in files:
            if (f == v):
                continue
            if (CompareBytes(f,v)):
                if (duplicates.get(v) == None):
                    if (duplicates.get(f) == None):
                        duplicates[f] = list()
                    duplicates[f].append(v)
                else:
                    if (not f in  duplicates[v]):
                        duplicates[v].append(f) 


def CompareBytes(f1, f2):
    with open(f1, "r") as file1:
        with open(f2, "r") as file2:
            while True:
                b1 = file1.read(1)
                b2 = file2.read(1)
                if (b1 != b2):
                    return False
                if (b1 == b2 == ''):
                    break
                    

    return True

args=sys.argv[1:len(sys.argv)]

for arg in args:
    f = os.stat(arg)
    if (f != None and stat.S_ISDIR(f.st_mode)):
        AnalyzeTree(arg)
    else:
        print("Nieprawidłowy argument: " + arg)
        exit()

FindSameSizes()
print ("Znalezione duplikaty:")
for it in duplicates:
    print("Duplikaty dla pliku " + it + ":")
    i=1
    for dup in duplicates[it]:
        print("\t" + str(i) + ". " + dup)
        i+=1