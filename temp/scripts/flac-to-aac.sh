#!/bin/bash

# Convert flacs in directory to aac
# Brendan Lewis 18/05/2012

if [ ! -z $1 ] && [ -d "$1" ] ; then
	DIRECTORY=$1
else
	echo "Directory doesn't exist!"
	HOSTNAMEBLAH=$(hostname)
	echo $HOSTNAMEBLAH
	exit 1
fi


aacquality=0.65

aacenc=/usr/local/bin/neroAacEnc
aactag=/usr/local/bin/neroAacTag
metaflac=/usr/bin/metaflac
flac=/usr/bin/flac

# Walk through flacs in directory
cd "$DIRECTORY" || exit 1
for FLACFILE in *.flac ; do
	NOEXT=$(echo $FLACFILE | sed -e 's/\.flac//g')
	# Grab track information
	#$metaflac --export-tags-to=-
	TITLE=$($metaflac --show-tag=title "$FLACFILE" | sed -e 's/.*\=//g')
	ARTIST=$($metaflac --show-tag=artist "$FLACFILE" | sed -e 's/.*\=//g')
	YEAR=$($metaflac --show-tag=date "$FLACFILE" | sed -e 's/.*\=//g')
	ALBUM=$($metaflac --show-tag=album "$FLACFILE" | sed -e 's/.*\=//g')
	GENRE=$($metaflac --show-tag=genre "$FLACFILE" | sed -e 's/.*\=//g')
	TRACK=$($metaflac --show-tag=tracknumber "$FLACFILE" | sed -e 's/.*\=//g')
	TOTALTRACKS=$($metaflac --show-tag=totaltracks "$FLACFILE" | sed -e 's/.*\=//g')
	DISC=$($metaflac --show-tag=disc "$FLACFILE" | sed -e 's/.*\=//g')
	TOTALDISCS=$($metaflac --show-tag=totaldiscs "$FLACFILE" | sed -e 's/.*\=//g')

	# Decode to .wav
	$flac -d "$FLACFILE"

	# Encode to AAC
	$aacenc -q 0.65 -if "$NOEXT.wav" -of "$NOEXT.m4a"

	# Add AAC tags
	$aactag -meta:title="$TITLE" -meta:artist="$ARTIST" -meta:year=$YEAR -meta:track=$TRACK -meta:album="$ALBUM" -meta:disc=$DISC -meta:genre="$GENRE" -meta:totaltracks=$TOTALTRACKS -meta:totaldiscs=$TOTALDISCS "$NOEXT.m4a"

	# Delete .wav file
	rm -f "$NOEXT.wav"
	
	echo "Encoded \"$FLACFILE\" to \"$NOEXT.m4a\""
done
