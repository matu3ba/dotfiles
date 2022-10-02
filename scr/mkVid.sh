#!/usr/bin/env bash
#sript to download videos
# check the chunklist of your browser

#ffmpeg -i "url_path_to_file.m3u8" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 file.mp4
ffmpeg -i "streaming_url:prefix/chunklist_somenumber.m3u8" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 file.mp4
