#!/usr/bin/env bash
# examples/bracketsChecking.sh
#finding #.h, #.cc #.tpp in src, include of git root folder
#counting brackets in file and after simple parsing giving according warnings
#requirements: cpp(C PreProcessor) git coreutils (find, grep,fgrep, wc) somewhat compatible shell

#relative level
#testing if directory is below the repository directory
# rootrel="";
if [ "$(git rev-parse --is-inside-work-tree)" = true ] ; then
#getting absolute path
    #relative path(would need checkup) : rootrel=$(git rev-parse --show-cdup);
    rootabspath=$(git rev-parse --show-toplevel);
else
    echo "NO git directory or subdirectory of git";
    exit 1;
fi
#rootrel="";
#rootrel=$(git rev-parse --show-cdup);
#if [ -z $rootrel ] ; then
#    echo "NO git directory";
#    exit 1;
#fi
#possible would be another check as well (on empty string)
cd "$rootabspath" || exit 2
#named pipe to be POSIX compatible (piping leaves us without variables)
mkfifo cppPipe
find include/ src/ -type f \( -iname \*.h -o -iname \*.cc -o -iname \*.tpp \) > cppPipe &
warnings=0;
errors=0;
while read -r line; do
	open=$(grep -F -o '{' $line | 'wc -l');
	close=$(grep -F -o '}' $line | 'wc -l');
#call parser only for removing comments then count { and } respectively
#(remove -w for all warnings, nostdinc for no includes)
	openp=$((cpp -w -nostdinc -fpreprocessed -o- $line) | grep '{' | wc -l );
 closep=$((cpp -w -nostdinc -fpreprocessed -o- $line) | grep '}' | wc -l );
	diff=$((open-close));
    diffp=$((openp-closep));
#DEBUG
	#echo "$diff : $line : diffparsed $diffp"; # print difference for filename
	if [ "$diff" -ne "0" ] ; then
	    echo "warning: in file $line diff of brackets is $diff";
        warnings=$((warnings+1));
	fi
    if [ "$diffp" -ne "0" ] ; then
		echo "error: in file $line diff of brackets after parser $diffp";
	    errors=$((errors+1));
	fi
done < cppPipe
if [ "$errors" -ne "0" ] ; then
    echo "error: bracket difference files number is $errors, fix those";
    rm cppPipe;
    exit 2;
fi
if [ "$warnings" -ne "0" ] ; then
    echo "warning: bracket difference files number is $warnings, please fix those";
    rm cppPipe;
    exit 3;
fi
rm cppPipe;