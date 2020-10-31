#!/bin/bash

echo "unfa's proxy manager v. 0.1 · https://github.com/unfa/proxy"
echo


help () {
	echo -e "\nUsage - the script expects to be run in a directory containing MKV and MP4 footage and will work recursively from there. Possible commands are::\n"
	echo -e "proxy.sh encode →\tgenerates proxy footage, renames original footage and creates symlinks under original footage filenames pointing to proxy. Use this before starting your editing."
	echo -e "proxy.sh original →\treplaces symlinks to point to the original footage. Use this before a full quality render."
	echo -e "proxy.sh proxy →\treplaces symlinks to point to the proxy footage. Use this before getting back to editin after a full quality render."
	echo -e "proxy.sh help →\t\tprint this help text"
	echo -e "proxy.sh clean →\tremoves proxy footage the symlinks, brings back the original footage to original state. Use before archiving the project. [NOT IMPLEMENTED]"
	echo -e "proxy.sh status s→\trecursively analyzes current directory and reports what's going on in there [NOT IMPLEMENTED"
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
		
	find . -type f -name '*.m[kp][v4]' > files

	while read f; do
		echo "Processed $(find . -type f -name *.original | wc -l), $(find . -type f -name *.m[kp][v4] | grep -v '*.proxy' | grep -v '*.original' | wc -l) more to go."
		echo
		echo "Processing $f..."
		
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

	done < files
	rm files
}

original () {
	echo "Link original footage"

	find . -type l -name '*.m[kp][v4]' > files
	
	while read f; do
		ln -svf "$(basename "$f").original" "$f"
		echo

	done < files
	rm files
}

proxy () {
	echo "Link proxy footage"

	find . -type l -name '*.m[kp][v4]' > files
	
	while read f; do
		ln -svf "$(basename "$f").proxy" "$f"
		echo

	done < files
	rm files
}

clean () {
	echo "Return the footage to it's initial state - not implemented yet"
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
