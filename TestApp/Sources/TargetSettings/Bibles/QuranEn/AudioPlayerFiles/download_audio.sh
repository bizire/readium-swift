#!/bin/bash

# To launch:  ./download_audio.sh

DESTDIR=./Quran

mkdir $DESTDIR

echo $DESTDIR

for (( c=1; c<=9; c++ ))
do  
   wget --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" -P $DESTDIR "http://www.truemuslims.net/Quran/English/00$c.mp3"
done

for (( c=10; c<=99; c++ ))
do  
   wget --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" -P $DESTDIR "http://www.truemuslims.net/Quran/English/0$c.mp3"
done

for (( c=100; c<=114; c++ ))
do  
   wget --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" -P $DESTDIR "http://www.truemuslims.net/Quran/English/$c.mp3"
done
