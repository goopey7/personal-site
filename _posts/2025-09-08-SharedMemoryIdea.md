---
layout: post
title: "Honors Project Idea: Shared Memory for UE5 Servers"
date: 2025-09-08
thumbnail: /assets/thumbs/SharedMemoryIdea.png
description: "Can we share memory across servers on a VM?"
---

## Why?
I have to write a dissertation for my final year of Computer Games Technology at Abertay University. I left my internship at Rare wanting more experience grappling with low level code. It's common for AAA game server infrastructure to run several virtual machines which each will run a few instances of the game server. There's signaficant chunk of data that gets copied to memory each time a new server process is executed. Can we share non-trivial amounts of memory between seperate running processes on Windows and Linux. And if so, can we take advantage of this by integrating this tech into an Unreal Engine server?

### Why Unreal Engine?
Designing my own game engine from the ground up around shared memory architecture would be too easy to spend an entire year on. Retrofitting this new tech into an existing established game engine is much more challenging, and could prove useful since Unreal Engine has loads of users and is the industry standard game engine.

## Feasibility
This idea only works if we can share large non-trivial amounts of memory between processes, so let's figure out if we can do that.

### Windows
We could try creating a page file backed [section object](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/section-objects-and-views) and see what happens. All virtual memory in Windows is backed by a file just in case we run out of physical memory. Unfortunately, this is a part of the Windows driver development kit, and I don't want to make a driver, I just want a userspace program. Fortunately there's another established API known as [File Mapping](https://learn.microsoft.com/en-us/windows/win32/memory/sharing-files-and-memory). If we pass an `INVALID_HANDLE_VALUE` for `hFile` in `CreateFileMapping`, the mapping object will access memory backed by the system paging file. Here's a quick and dirty example of this API in action. I have to run this in administrator mode in order to make use of the global namespace. There might be a way around that, but running servers in admin mode is not a deal breaker either.

```c
#include <stdio.h>
#include <Windows.h>

#define BUFFER_SIZE 500

int main(int argc, char** argv)
{
	HANDLE hMappingObject = CreateFileMappingW(
		INVALID_HANDLE_VALUE,
		NULL,
		PAGE_READWRITE,
		0,
		BUFFER_SIZE,
		L"Global\\UnrealServerMappingMem");

	char* pBuf = (char*)MapViewOfFile(
		hMappingObject,
		FILE_MAP_ALL_ACCESS,
		0,
		0,
		BUFFER_SIZE);

	memcpy(pBuf, argv[1], strlen(argv[1]));

	printf("Copied %s to shared memory\n", argv[1]);
	printf("Press enter key to read and exit...");
	getchar();

	printf("Shared Memory Contents: %s\n", pBuf);

	UnmapViewOfFile(pBuf);
	CloseHandle(hMappingObject);

	return 0;
}
```

I made a reciprocal program that grabs the mapping object with `OpenFileMappingW`, reads the buffer, then after user input will write something new to it. 
This seems to work fine for 500 bytes. But what about 500 megabytes? Or 5 gigabytes? The answer is yes!

So we know it's possible to share large blocks of memory betwen processes on Windows. What about Linux?

### Linux
It's very similar to how Windows goes about it. First create a shared memory object with `shm_open`, truncate it to the size of the buffer, then map it to virtual memory with `mmap`. God bless the man pages.
```c
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define BUFFER_SIZE 500
#define SHM_NAME "/UnrealServerMappingMem"

int main(int argc, char** argv)
{
    int shm_fd = shm_open(SHM_NAME, O_CREAT | O_RDWR, 0666);

    ftruncate(shm_fd, BUFFER_SIZE);

    char* pBuf = (char*)mmap(NULL, BUFFER_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);

    memcpy(pBuf, argv[1], strlen(argv[1]));

    printf("Copied %s to shared memory\n", argv[1]);
    printf("Press enter key to read and exit...");
    getchar();

    printf("Shared Memory Contents: %s\n", pBuf);

    munmap(pBuf, BUFFER_SIZE);
    close(shm_fd);
    shm_unlink(SHM_NAME);

    return 0;
}
```
Trying buffer sizes of 500 megabytes and 5 gigabytes worked just the same as 500 bytes!

## So it's totally possible!
Both operating systems can provide what we need to share large amounts of memory between processes!
The hard part is going to be bringing this architecture into Unreal Engine. That's where the academic year of exploration would go.
Can we get Unreal servers to operate in a shared memory architecture? What would the developer experience be like? How would a gamedev using my artefact articulate what should be shared and what should not be?
