# QRWatermark

Dependencies:

ffmpeg - https://ffmpeg.org/
qrencode - https://linux.die.net/man/1/qrencode

Tested Environments:

Ubuntu Bash on Windows 10

Use Case:

This is designed for people wanting to protect video content exposed on a website or other online media provider where they want to be able to identify the person/entity that downloaded the content while making it obvious to the downloader that the content is tracked. To facilitate this an information payload is encoded in a QR code which moves around the video to make it resistant to cropping and filters normally used to remove stationary watermarks. To be as generic as possible the payload for the qr code is just a string.

Usage:

./qr_watermark_adv.sh [VIDEO_FILE] [STRING PAYLOAD]

This generates a video [VIDEO_FILE].qr.mp4 which contains the QR watermark. By default it is encoded by h264 with lossless quality settings.

To extract the watermark from a video:

./qr_watermark_diff.sh [QR_VIDEO_FILE] [SOURCE_VIDEO_SCALED_TO_QR_VIDEO]

This creates a video [QR_VIDEO_FILE].diff.mp4] that is a basic white-background video with the qr code exposed in black. The qr code is resilient to scaling down to about 50% in testing and glitches in the video may make the qr code not readble throughout the whole video but you only need one read to get the string payload.
