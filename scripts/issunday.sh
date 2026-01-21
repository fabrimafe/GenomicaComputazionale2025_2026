#!/bin/bash
### Programma che dice se e' Domenica
#X is 1 if Sun, 0 otherwise
X=$( date | grep Sun | wc -l )
if [ $X == 1 ];then
	echo "E' Domenica!"
else
	echo "No, svegliati!"
fi
