---
layout: post
title: "Honors Project Idea: UE5 on the Wii"
date: 2025-09-06
thumbnail: /assets/thumbs/LUR-WiiCover.png
description: "Can our Unreal Engine 5 game run on the Wii?"
---

## Why?
I have to write a dissertation for my final year of Computer Games Technology at Abertay University. I left my internship at Rare wanting more experience grappling with low level code. I've also been working on a game in Unreal Engine 5 with my team at 777 studios. So how cool would it be to get our awesome game working on Wii hardware? And as an extra bonus, what if we could control the player's sword with the Wiimote's motion sensors? This is quite an ambitious undertaking, but I think it'd make a very interesting read whether it goes well or not. And if it does go very well, there'll be a pretty awesome demo for the digital grad show!

## Setting Expectations
My goal would be to bring gameplay from a UE5 project to Wii hardware. I don't want to do a dissertation on graphics, so all I want is to chuck 3D stuff on the screen. Any extra graphics features like lighting, anti aliasing, VFX, etc. are stretch goals (after adding motion controls). Same with audio. Nothing crazy to begin with but we can go for some stretch goals later on. I'm not porting the visual fidelity of UE5 to the Wii, I just want to be able to take any existing UE5 project and see a beautifully scuffed looking version of it playable on the Wii with minimal engine modifications. I'm not bothered about additional engine modules and plugins, but if I have to heavily change the engine's code in such a way that it could become difficult to take in engine upgrades, other people might be less inclined to mess with this project.

## Where do I start?

### A Hello world on the Wii
I've never done any programming for the Wii, so I'd like to get the toolchain setup and see some code running within [Dolphin Emulator](https://dolphin-emu.org). I came across [devkitPro](https://github.com/devkitPro) which includes a toolchain for Wii/GC's PowerPC architecture, and a [series of examples](https://github.com/devkitPro/wii-examples) including a hello triangle and audio! DevkitPro needs a posix style environment so it installed MSYS onto my Windows installation. In the future I'll likely be developing on Arch because having this weird fake linux thing on the horrible experience that is Windows is gonna be frustrating. But all I had to do was fire up MSYS and run make on a few examples and load them into Dolphin! All worked out the box!

<img src="../../../assets/wii_hello_triangle.png" alt="Wii Hello Triangle" width="1000"/>

## This is just the beginning
So it looks easy to iterate code on the Wii thanks to Dolphin. I can quickly compile and run which is real nice and it looks like Dolphin does come with some debugging capabilities too! I'm glad that we're starting with a pleasant base though because what is to come will be challenging and hopefully an academic year's worth of exploration!

### There's still plenty to sink my teeth into
- Compiling Unreal Engine 5.6 using devkitPro's PowerPC g++ compiler
    - Maybe start with GNU g++ first
    - Hopefully now that Unreal is on C++20 which has permissive- enabled on MSVC, there shouldn't be too much weirdness unless devkitPro does very weird non conformant things
- Cooking uassets for the Wii
- Implementing the Wii's platform classes
- A simple rendering backend for the Wii
    - There's an [SDL](https://github.com/dborth/sdl-wii) and [SDL2](https://github.com/devkitPro/pacman-packages/blob/master/wii/SDL2/PKGBUILD) implementation for the Wii! Hopefully this is all we'll need for a primitive renderer

This list is already easier said than done, but there's also going to be unforseen issues. Especially since UE5 is targeting latest gen consoles and modern PCs. We might have to rework core engine technologies such as asset streaming. Hopefully these modifications are feasible enough and aren't too intrusive in order to keep the codebase maintainable for all other platforms.
