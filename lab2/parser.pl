#!/usr/bin/perl

# Gracjan Puch
# 41490
# 31B
# Zadanie na ocenę 5


if (-t STDIN)
{
    #$filename = "plan_zajec.ics";
    start:
    print "Podaj nazwę pliku: ";
    $filename = <STDIN>;
    chop $filename;

    if (not -e $filename)
    {
        print "Podany plik nie istnieje\n";
        goto start;
    }
    open $file, $filename;
}
else
{
    $file = *STDIN;
}

@lastStart = (0,0);
@lastEnd = (0,0);
$lastDiff = 0;
$hoursSum = 0;

@datesStart;
@datesEnd;
@summaries;

%dict;
%classes;

while(defined($line=<$file>))
{
    if ($line =~ /DTSTART.+:(\d+)T(\d{2})(\d{2})/gm)
    {
        if (defined($1))
        {
            @lastStart = ($2,$3);
            push @datesStart, "$1T$2:$3";
            $j+=1;
        }
    }
    elsif ($line =~ /DTEND.+:(\d+)T(\d{2})(\d{2})/gm)
    {
        @lastEnd = ($2,$3);
        $endMins = $2*60+$3;
        $startMins = $lastStart[0]*60+$lastStart[1];
        $diff = $endMins-$startMins;
        $lastDiff=int($diff/45);
        $hoursSum+=$lastDiff;
        push @datesEnd, "$1T$2:$3";
    }
    elsif (@capture = $line =~ /(?:SUMMARY:)(.+) - (?:.*Grupa: )(.+),/gm) #gets name and group)
    { 
        if (defined($capture[1]))
        {
            push @summaries, $line;
        }
        if (@capture)
        {
            @c2 = $capture[1] =~ /(S|N)(\d)/gm; #group 1 is form of study, group 2 is degree
            @c3 = $capture[1] =~ /_(L|W)/gm; #group 1 is form of class
            $classes{$capture[0]}+=$lastDiff;
            if (!defined($c2[0]))
            {

                $dict{"other"}+=$lastDiff;
            }
            else
            {
                $dict{"$c2[0]"}+=$lastDiff;
                $dict{"$c2[1]"}+=$lastDiff;
                $dict{"$c3[0]"}+=$lastDiff;
            }
        }
    }
}

print "\nŁączna liczba godzin lekcyjnych (45min)=" . $hoursSum;
print "\nLiczba godzin lekcyjnych, studia stacjonarne=" . $dict{"S"};
print "\nLiczba godzin lekcyjnych, studia niestacjonarne=" . $dict{"N"};
print "\nLiczba godzin lekcyjnych, stopień 1=" . $dict{"1"};
print "\nLiczba godzin lekcyjnych, stopień 2=" . $dict{"2"};
print "\nLiczba godzin lekcyjnych, inne (nieokreślony stopień lub tryb w nazwie grupy)=" . $dict{"other"};
print "\nLiczba godzin lekcyjnych, wykłady=" . $dict{"W"};
print "\nLiczba godzin lekcyjnych, laboratoria=" . $dict{"L"};
print "\n\nLiczba godzin lekcyjnych z podziałem na przedmioty:\n";
for $class (keys %classes)
{
    print "\t$class=$classes{$class}\n";
}

print "\n";

open $fh, '>', 'plan.csv';

print {$fh} '"Data","Od","Do","Przedmiot","Grupa","Sala"';
print {$fh} "\n";
for ($i=0; $i < scalar(@summaries); $i++)
{    
    @ds = $datesStart[$i] =~ /(\d{4})(\d{2})(\d{2})T(\d{2}):(\d{2})/gm; #extracts date and time
    print {$fh} "\"$ds[2].$ds[1].$ds[0]\",";
    print {$fh} "\"$ds[3]:$ds[4]\",";
    @de = $datesEnd[$i] =~ /(\d{4})(\d{2})(\d{2})T(\d{2}):(\d{2})/gm;
    print {$fh} "\"$de[3]:$de[4]\",";

    @captures = $summaries[$i] =~ /SUMMARY:(.+) -.+Grupa: (.+), Sala: (.+)/gm; #extracts name(0), group(1) and class(2)
    print {$fh} "\"$captures[0]\",";
    print {$fh} "\"$captures[1]\",";
    chop $captures[2];
    print {$fh} "\"$captures[2]\"";
    print {$fh} "\n";
}

close $fh;

print "Utworzono plik o nazwie plan.csv\n";

close $file;
