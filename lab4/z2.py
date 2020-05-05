#! /usr/bin/python3
from collections import OrderedDict

import sys;
import string;

frequencyMap = OrderedDict()
frequencyDict = dict()
for k in string.ascii_uppercase:
    frequencyDict[k]=0;


def ReadCipherSource(line):
    for c in line:
        if (c in string.ascii_uppercase):
            frequencyMap[c] = "-";

def AnalyzeLine(line):
    for k in line:
        if (k in frequencyDict):
            frequencyDict[k]+=1

def Decipher(line):
    nl = ""
    for c in line:
        if (c in frequencyMap):
            nl += frequencyMap[c]
        else:
            nl += c
    return nl


filename = "cipher.txt"
if (len(sys.argv) > 1):
    filename=sys.argv[1]


try:
    with open(filename) as file:
        ReadCipherSource(file.readline())
        for line in file:
                AnalyzeLine(line)

        frequencyDict = sorted(frequencyDict.items(), key=lambda item:item[1], reverse=True);

        keys = list(frequencyMap.keys())
        for i in range (0, len(keys)):
            frequencyMap[keys[i]]=frequencyDict[i][0]

        file.seek(0)
        for line in file:
            print(Decipher(line))
    


except FileNotFoundError:
    sys.stderr.write("Blad, nie znaleziono pliku\n")