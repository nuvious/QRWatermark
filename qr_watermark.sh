#!/bin/bash

QRBASE_FRAME_FNAME='qr_frame.png'
ID=$(uuidgen)
QR_SUFFIX="qr"

get_framerate(){
	ffmpeg -i $1 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"
}

get_durration(){
	printf "%.0f" $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1)
}

gen_qrcode_frames(){
	LENGTH=$1
	USERNAME=$2
	TIMESTAMP=$3
	MAX_ALPHA=122
	for i in $(seq -f "%08g" 0 $LENGTH)
	do
		ALPHA=$(( ( RANDOM % $MAX_ALPHA )  + 1 ))
		ALPHA_HEX=$(printf "%x" $ALPHA)
		DATA="$USERNAME - $TIMESTAMP - $i"
		DATA=$(echo "$DATA" | md5sum)$DATA
		qrencode -o "$ID$i$QRBASE_FRAME_FNAME" "$DATA" --background=FFFFFF00 --foreground=$(printf "%08x" $ALPHA)
		echo "Generated frame $i of $(printf "%08g" $LENGTH)"
	done
}

rand_between(){
	shuf -i $1-$2 -n 1
}

get_i_width(){
	identify -format "%w" $1
}

get_i_height(){
	identify -format "%h" $1
}

get_v_height(){
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $1)
size=${streams_stream_0_height}
echo $size
}

get_v_width(){
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $1)
size=${streams_stream_0_width}
echo $size
}


gen_video(){
	vw=$(get_v_width $1)
	vh=$(get_v_height $1)
	cmd="ffmpeg -i $1 "
	for i in $(seq -f "%08g" 0 $LENGTH)
	do
		cmd="$cmd -i $ID$i$QRBASE_FRAME_FNAME "
	done
	cmd="$cmd -filter_complex \"[0:v][1:v] overlay=0:0:enable='between(t,0,1)' [tmp]; "
	for i in $(seq 1 $LENGTH)
       	do
		num=$(( $i + 1 ))
		ifname=$ID$(printf "%08g" $i)$QRBASE_FRAME_FNAME
		iw=$(get_i_width $ifname)
		ih=$(get_i_height $ifname)
		posx=$( rand_between 0 $(( $vw - $iw )) )
		posy=$( rand_between 0 $(( $vh - $ih )) )
		#posx=$(( $posx * 10 ))
		#posy=$(( $posy * 10 ))
		if [[ $i -lt $LENGTH ]]; then
			cmd="$cmd [tmp][$num:v] overlay=$posx:$posy:enable='between(t,$i,$num)' [tmp]; "
		else
			cmd="$cmd [tmp][$num:v] overlay=$posx:$posy:enable='between(t,$i,$num)'"
		fi
        done
	cmd="$cmd \" $1.$QR_SUFFIX.mp4"
	echo "$cmd" > cmd.txt
	eval $cmd
	rm *.png
}

gen_qrcode_frames $(get_durration $1) $2 "$(date)"
gen_video $1
