---
layout: post
title: "UE5 Crash Reporting: Episode 2"
date: 2025-09-28
thumbnail: /assets/thumbs/CrashReportThumb.png
description: "Reverse Engineering the Report File"
---

By the end of [episode 1](https://samcollier.dev/2025/09/27/CrashReporting.html) we managed to extract
the compressed data sent from the crash report client over http.

# Reverse Engineering the Crash Report File
I sent two different crashes to my server. One included the game's logfile and one did not.
With the power of xxd and git diffs maybe we can notice some patterns.

```diff
--- no logfile
+++ with logfile

 00000000: 4352 3104 0100 0055 4543 432d 5769 6e64  CR1....UECC-Wind
-00000010: 6f77 732d 3142 3033 4437 3236 3435 4336  ows-1B03D72645C6
-00000020: 3245 4333 3841 4246 3646 4133 3043 3733  2EC38ABF6FA30C73
-00000030: 3741 3430 5f30 3030 3000 0000 0000 0000  7A40_0000.......
+00000010: 6f77 732d 3843 3133 4541 3934 3444 3442  ows-8C13EA944D4B
+00000020: 3835 3739 3534 3439 3843 4245 4138 4333  857954498CBEA8C3
+00000030: 4232 3246 5f30 3030 3000 0000 0000 0000  B22F_0000.......
 00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000050: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
```

The header remains the same. We can see it starts with CR1 followed by a few mysterious bytes: `04 01 00 00`

Originally I thought the byte after CR1 was the number of files since there are 4 files (including the log).
But the diff don't lie, that byte is 04 even with 3 files.
After those mysterious bytes we get the crash GUID which has obviously changed between crashes.

```diff
 000000e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 000000f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000100: 0000 0000 0000 0000 0000 0004 0100 0055  ...............U
-00000110: 4543 432d 5769 6e64 6f77 732d 3142 3033  ECC-Windows-1B03
-00000120: 4437 3236 3435 4336 3245 4333 3841 4246  D72645C62EC38ABF
-00000130: 3646 4133 3043 3733 3741 3430 5f30 3030  6FA30C737A40_000
+00000110: 4543 432d 5769 6e64 6f77 732d 3843 3133  ECC-Windows-8C13
+00000120: 4541 3934 3444 3442 3835 3739 3534 3439  EA944D4B85795449
+00000130: 3843 4245 4138 4333 4232 3246 5f30 3030  8CBEA8C3B22F_000
 00000140: 302e 7565 6372 6173 6800 0000 0000 0000  0.uecrash.......
 00000150: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
```

Then there's a bunch of padding until we hit the same mysterious bytes `04 01 00 00`
right before hitting what must be the name of the file that was sent to us with the file extension .uecrash

So maybe `04 01 00 00` is some kind of delmiter to mark the start of some data?

```diff
 000001e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 000001f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000200: 0000 0000 0000 0000 0000 0000 0000 0000  ................
-00000210: 0000 0009 180d 0003 0000 0000 0000 0004  ................
+00000210: 0000 00b8 f90d 0004 0000 0000 0000 0004  ................
 00000220: 0100 0043 7261 7368 436f 6e74 6578 742e  ...CrashContext.
 00000230: 7275 6e74 696d 652d 786d 6c00 0000 0000  runtime-xml.....
 00000240: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 ```
 Many zeroes later we get to something interesting! A subtle difference right before this filename?
 Maybe we have some sort of file index since you can see no log has a 3 and with log has a 4.
 But what about the bytes that come before?

 if we skip right to the end of each hexdump we can see which address each byte ends on.
```diff
-000d1800: 0000 0000 0000 0000 00                   .........
+000df9b0: 0000 0000 1900 0000                      ........
```
Windows is little endian so if we read the bytes in the diff backwards:
```diff
-09 180d 00 ==> 000d1809
+b8 f90d 00 ==> 000df9b8
```
We seem to get the address of one byte more than the final byte in the entire dump.
So this marks the end of the entire file and has nothing to do with CrashContext.runtime-xml

After what I'm calling for now the file index, we get a bit of padding, `04 01 00 00`, then the filename.

```diff
 000002f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000300: 0000 0000 0000 0000 0000 0000 0000 0000  ................
 00000310: 0000 0000 0000 0000 0000 0000 0000 0000  ................
-00000320: 0000 0000 0000 00f8 a700 003c 3f78 6d6c  ...........<?xml
+00000320: 0000 0000 0000 0007 9e00 003c 3f78 6d6c  ...........<?xml
 00000330: 2076 6572 7369 6f6e 3d22 312e 3022 2065   version="1.0" e
 00000340: 6e63 6f64 696e 673d 2255 5446 2d38 223f  ncoding="UTF-8"?
 00000350: 3e0d 0a3c 4647 656e 6572 6963 4372 6173  >..<FGenericCras
```
Many zeroes later we get to a difference just before the file's content.
This could be a 4-bit unsigned integer for file size. Reading as little endian we get:

no log: 0xa7f8 = 43,000 bytes

with log: 0x9e07 = 40,455 bytes

it's a reasonable assumption although I wonder what the 3kb of extra stuff in the no log version is.

We can prove this theory by checking our calculator.
The xml starts at 0x032B so if we add our sizes we should get taken to the end of the content.

for no log:
0x032B + 0xa7f8 = 0xab23
```
0000ab10: 6572 6963 4372 6173 6843 6f6e 7465 7874  ericCrashContext
0000ab20: 3e0d 0a01 0000 0004 0100 0043 7261 7368  >..........Crash
0000ab30: 5265 706f 7274 436c 6965 6e74 2e69 6e69  ReportClient.ini
```

for with log:
0x032B + 0x9e07 = 0xa132
```
0000a120: 7269 6343 7261 7368 436f 6e74 6578 743e  ricCrashContext>
0000a130: 0d0a 0100 0000 0401 0000 4372 6173 6852  ..........CrashR
0000a140: 6570 6f72 7443 6c69 656e 742e 696e 6900  eportClient.ini.
```
So yup that's definitely file size!

Since the xml was quite different, the git diff is no longer useful.
Anyways we've almost seen enough.

In both cases, after the content is finished, we go right back to hitting `04 01 00 00` and starting the name of the next file.
So that "file index" I mentioned earlier is just a count for how many files there are since it only appears once.

## So to sum it all up
Unreal's crash report file is as follows:

- 3 byte header "CR1"
- Crash GUID
- Crash report filename
- Total bytes in crash report file (4 bytes)
- Total files included in crash report (1 byte)
- File name
- File content

all strings after the CR1 header begin with `04 01 00 00`
The remainder of the file is just filename + file content for every file included.
