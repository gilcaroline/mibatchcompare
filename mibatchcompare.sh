#!/bin/bash

# mibatchcompare: organizes batch mediainfo reporting
# requires mediainfo

if [ -z "$3" ]; then
depth=0
else
depth="$3"
fi
find "$1" -maxdepth "$depth" -mindepth "$depth" -type d > "/tmp/subdirs.txt"

cat "/tmp/subdirs.txt" | while read subdir; do
	subdirname=`basename "$subdir"`
	mibatchcompare_filename_root="mibatchcompare"
	scriptdir=`dirname "$0"`
	date=`date "+%Y-%m-%dT%H-%M-%S"`
	reportcsv="${2}/${mibatchcompare_filename_root}_${date}/${subdirname}_comparisonreport_${date}.csv"
	filemanifest="${2}/${mibatchcompare_filename_root}_${date}/${subdirname}_reportfilemanifest_${date}.txt"
	mkdir -p "${2}/${mibatchcompare_filename_root}_${date}"

	if [ "$#" != 3 ]; then
		echo mibatchcompare: requires an input and output directory. 
	    echo mibatchcompare: usage is:
	    echo mibatchcompare: ./mibatchcompare.sh [input directory] [output directory] 0
		exit 1
	fi
	if [ ! -d "$1" ]; then
	    echo $1 is not a valid directory
	    exit 2
	fi
	if [ ! -d "$2" ]; then
	    echo $2 is not a valid directory
	    exit 3
	fi
	
	find_opts+="-type f ! -name '.*'"
	
	if [ ! -e "$reportcsv" ]; then
	echo "filename,general_format,general_format_version,general_encoded_application,video_format,video_format_version,video_codecid,video_width,video_height,video_displayaspectratio,video_framerate,video_colorspace,video_bitdepth,video_compression_mode,audio_format,audio_codecid,audio_channels,audio_samplingrate,audio_bitdepth, general_format_profile, file_size, file_duration, display_aspect_ratio, file_standard " > "$reportcsv"
	fi

	echo "mibatchcompare: Running batch MediaInfo reporting on the following files:"
	
	eval "find \"${subdir}\" ${find_opts}" > "${filemanifest}"
	cat "${filemanifest}" | while read file; do
	        echo "$file"
        filename=`basename "${file}"`
        general_format=`mediainfo --Inform="General;%Format%" "${file}"`
        general_format_version=`mediainfo --Inform="General;%Format_Version%" "${file}"`
		general_encoded_application=`mediainfo --Inform="General;%Encoded_Application%" "${file}"`
		video_format=`mediainfo --Inform="Video;%Format%" "${file}"`
		video_format_version=`mediainfo --Inform="Video;%Format_Version%" "${file}"`
		video_codecid=`mediainfo --Inform="Video;%CodecID%" "${file}"`
		video_width=`mediainfo --Inform="Video;%Width%" "${file}"`
		video_height=`mediainfo --Inform="Video;%Height%" "${file}"`
		video_displayaspectratio=`mediainfo --Inform="Video;%DisplayAspectRatio%" "${file}"`
		video_framerate=`mediainfo --Inform="Video;%FrameRate%" "${file}"`
		video_colorspace=`mediainfo --Inform="Video;%ColorSpace%" "${file}"`
		video_bitdepth=`mediainfo --Inform="Video;%BitDepth%" "${file}"`
		video_compression_mode=`mediainfo --Inform="Video;%Compression_Mode%" "${file}"`
		audio_format=`mediainfo --Inform="Audio;%Format%" "${file}"`
		audio_codecid=`mediainfo --Inform="Audio;%CodecID%" "${file}"`
		audio_channels=`mediainfo --Inform="Audio;%Channel(s)%" "${file}"`
		audio_samplingrate=`mediainfo --Inform="Audio;%SamplingRate%" "${file}"`
		audio_bitdepth=`mediainfo --Inform="Audio;%BitDepth%" "${file}"`
		general_format_profile=`mediainfo --Inform="Format_;%Profile%" "${file}"`
		file_size=`mediainfo --Inform="File;%Size%" "${file}"`
		file_duration=`mediainfo --Inform="Duration;%" "${file}"`
		display_aspect_ration=`mediainfo --Inform="Display;%AspectRatio%" "${file}"`
		file_standard= `mediainfo --Inform="Standard;%" "${file}"`
		


        # report out to csv file
        echo "${filename},${general_format},${general_format_version},${general_encoded_application},${video_format},${video_format_version},${video_codecid},${video_width},${video_height},${video_displayaspectratio},${video_framerate},${video_colorspace},${video_bitdepth},${video_compression_mode},${audio_format},${audio_codecid},${audio_channels},${audio_samplingrate},${audio_bitdepth}${general_format_profile}${file_size}${file_duration}${display_aspect_ratio}${file_standard}" >> "$reportcsv"
	done
	echo "mibatchcompare: Batch MediaInfo reporting complete."
	echo "mibatchcompare: A report CSV can be found at:"
	echo "${reportcsv}"
done
