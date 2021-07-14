#!/bin/bash

echo "unfa's proxy manager v. 0.1.2"
echo


help () {
	echo "This script uses ffmpeg and symlinks to generate and manage proxy (low bitrate) footage that's suitable for video editing. The script will encode low-bitrate versions of original footage and store them under diffenet file names in respective directories. The idea is - the vidoe editor references the original files, but this script will replace the original files wiht symlinks pointing to either original full quality footage, or low-bitrate proxyu versions. For editing - you'd want to use the proxy versions, while for rendering - you'd want to close your video editor, replace the links so they point to original high-quality footage , then reload your video editing project and let it render using high quality sources. The main purpose of using this is to speed up footage decoding and disk read for video editing, as well as lower RAM usage during editing. Sometimes high bitrate footage may cause playback to drop off or stutter, using low bitrate footage can help with that. I've created this tool when I had to edit a video project in Olive 0.12 that had over 5 hours of high 15MPBS 4:4:4 3840x1080p 60 FPS footage as well as 4:2:0 30 FPS 4K footage of even higher bitrate. On my hardware Olive would not be able to play that smoothly, and the RAM usage would quickly kill my PC. Thanks to using this proxy tool, the editing and rendering both went smooth. This script encodes low-quality H.264 with GOP of 10 to balance betweeen file size and speed of seeking the file. Original resolution is preserved, and all audio tracks are encoded as 16-bit PCM for ease of seeking. Feel free to tweak the settings and suggest improvements."
	echo -e "\nUsage - the script expects to be run in a directory containing MKV and MP4 footage and will work recursively from there. Possible commands are::\n"
	echo -e "proxy.sh encode →\tgenerates proxy footage, renames original footage and creates symlinks under original footage filenames pointing to proxy. Use this before starting your editing."
	echo -e "proxy.sh original →\treplaces symlinks to point to the original footage. Use this before a full quality render."
	echo -e "proxy.sh proxy →\treplaces symlinks to point to the proxy footage. Use this before getting back to editin after a full quality render."
	echo -e "proxy.sh help →\t\tprint this help text"
	echo -e "proxy.sh clean →\tremoves proxy footage the symlinks, brings back the original footage to original state. Use before archiving the project."
	echo -e "proxy.sh status →\trecursively analyzes current directory and reports what's going on in there [NOT IMPLEMENTED YET]"
}

no_command () {
	echo -e "No command given. Printing help text:\n"
	help
}

status () {
	echo "Analyze current directory and print status - not implemented yet"
}

encode () {
	echo "Encode proxy"
	
#	exit
	
	rm files-mkv files-mp4
	
	find . -type f -iname '*.mp4' > files-mp4
	
	while read f; do
		#echo "Processed $(find . -type f -name *.original | wc -l), $(find . -type f -iname '*.m[kp][v4]' | grep -v '*.proxy' | grep -v '*.original' | wc -l) more to go."
		#echo
		echo "Processing MP4 $f..."
		
		if [[ $(readlink "$f") ]]; then
			echo "The files was already processed, skipping."
			continue
		fi

		ffmpeg -y -i "$f" -map 0:0 -map 0:1 -c:v libx264 -tune film -crf 38 -x264opts keyint=10 -pix_fmt yuv420p -b:a 128k -f mp4 "$f.proxy" 2> "$(basename "$f").ffmpeg_log"
		
		if [ $? -eq 0 ]; then
			echo -ne " OK\n"
		else
			echo -ne " FAIL\n"
			continue
		fi
		mv "$f" "$f.original"
		ln -s "$(basename "$f").proxy" "$f"
		echo

	done < files-mp4
	
	find . -type f -iname '*.mkv' > files-mkv

	while read f; do
		#echo "Processed $(find . -type f -name *.original | wc -l), $(find . -type f -iname '*.m[kp][v4]' | grep -v '*.proxy' | grep -v '*.original' | wc -l) more to go."
		#echo
		echo "Processing MKV $f..."
		
		if [[ $(readlink "$f") ]]; then
			echo "The files was already processed, skipping."
			continue
		fi

		ffmpeg -y -i "$f" -c:v libx264 -tune animation -crf 38 -x264opts keyint=10 -pix_fmt yuv420p -c:a pcm_s16le -map 0 -f matroska "$f.proxy" 2> "$(basename "$f").ffmpeg_log"
		
		if [ $? -eq 0 ]; then
			echo -ne " OK\n"
		else
			echo -ne " FAIL\n"
			continue
		fi
		mv "$f" "$f.original"
		ln -s "$(basename "$f").proxy" "$f"
		echo

	done < files-mkv
	
	

}

original () {
	echo "Link original footage"

	find . -type l -iname '*.m[kp][v4]' > files
	
	while read f; do
		ln -svf "$(basename "$f").original" "$f"
		echo

	done < files
	rm files
}

proxy () {
	echo "Link proxy footage"

	find . -type l -iname '*.m[kp][v4]' > files
	
	while read f; do
		ln -svf "$(basename "$f").proxy" "$f"
		echo

	done < files
	rm files
}

clean () {
	echo "Clean up, restoring the files to their original state."
	echo "WARNING! This is a destructive operation. All the proxy files will be irrevocably deleted. Original files will be restored. You'd normally only want to do this before archiving your project. Are you sure you want to continue?"
	
	while true; do
		read -p "$* [y/n]: " yn
		case $yn in
			[Yy]*) break  ;;  
			[Nn]*) echo "Clean-up aborted" ; return  1 ;;
		esac
	done
		
	find . -type l -iname '*.m[kp][v4]' > files
	
	while read f; do
		rm -v "$f.proxy"
		mv -vf "$f.original" "$f"
		echo

	done < files
	rm files
}


case "$1"
in
status) status;;
encode) encode;;
original) original;;
proxy) proxy;;
clean) clean;;
help) help;;
*) no_command
esac
