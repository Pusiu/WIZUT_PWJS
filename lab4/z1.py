#! /usr/bin/python3
import sys;
import string;

if (len(sys.argv) == 1):
    sys.stderr.write("Należy podać nazwę pliku jako argument\n");
    exit()

letters = dict();
for k in string.ascii_uppercase:
    letters[k]=0

letterSum=0


def AnalyzeLine(line):
    global letterSum
    for char in line:
        if (char.upper() in letters):
            letters[char.upper()]+=1
            letterSum+=1



try:
    with open(sys.argv[1]) as file:
        for line in file:
            AnalyzeLine(line)

    letters = sorted(letters.items(), key=lambda item:item[1], reverse=True);
    
    print("Litera\tLiczba wystapien\tUdzial procentowy\n")
    for k,v in letters:
        if (v == 0):
            continue
        p=round((v/letterSum)*100, 2);
        psum+=p
        print(k + "\t\t" +  str(v) + "\t\t" + str(p) + " %\n")

    print(str(psum))

except FileNotFoundError:
    sys.stderr.write("Blad, nie znaleziono pliku\n")