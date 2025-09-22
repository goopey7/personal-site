---
layout: post
title: "Left Upon Read"
date: 2025-09-22
thumbnail: /assets/thumbs/LUR.png
description: "Working with a team to make a UE5 Game"
---

<iframe height="390" frameborder="0" src="https://itch.io/embed/2554967?dark=true" width="552"><a href="https://triple7studios.itch.io/left-upon-read">Left Upon Read by Triple7Studios</a></iframe>

<iframe width="627" height="390" src="https://www.youtube.com/embed/zzSJmeyj6sk" title="DARE ACADEMY 2024 WINNER! Left Upon Read, a medieval fantasy of monsters and badly-timed texts" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

# What is it?
I think our description on itch.io sums it up perfectly!

*The King has tasked you, a brave knight of The High Order, to rescue his only daughter and heir to the throne from the clutches of a vicious sea witch. Battle your way through her relentless aquatic creations, collect the keys and defeat the beast that lurks deep within.  Just make sure you're checking your phone, as one missed message might spell doom for not only your relationships, but your life...*

It's an action/adventure rpg with hectic multitasking gameplay!

# Background
In third year, Abertay brings all of the disciplines together to make various games in multidisciplinary groups. Our group was nine people: Two artists, three designers, one producer, and three programmers. We had three months to deliver a prototype level

By the end of the three months we achieved that! We even had a boss fight!
<iframe width="1227" height="690" src="https://www.youtube.com/embed/hsVbruLv-YI" title="Left Upon Read 1.0 - Gameplay Video - 777" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

I had to step away from the project after the above submission to our module. 
While I went to work at Rare, the rest of the team took the game further over the summer with Abertay's DARE Academy and won!

# Personal Contributions
- Various gameplay mechanics (here's some I can think of off the top of my head)
    - Phone UI
    - Phone Camera
    - Player light attack combo
    - Player heavy attack
    - Breakable pots
- Profiling
- Message Editor tool for designers to easily tweak text messages in the message pool
- Git wrangling
- SFX Hooks
- An easy pipeline for first person animations using the control rig
    - Setup anim notifies for sfx and impact frames
    - Educated others and even made a video tutorial!

<iframe width="727" height="314" src="https://www.youtube.com/embed/_E9SUfAWnfQ" title="First Person Animations - 777" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>


# Upcoming
Now that most of the team has graduated and jobs are impossible to find, this game is entering production again!
And I'm doing 4th year, so I'm also able to contribute again! We've all learned a lot about Unreal since we first started the project, so we're actually taking a step back and rewriting ALL of the code. As you can imagine with tight deadlines and less knowledge about Unreal, things got pretty messy!

This time around we're self-hosting gitlab so we can take advantage of LFS without paying for bandwidth. We've also changed our process quite a bit. Every submission to the main branch MUST go through a code review! And I'm working on getting pipelines setup for unit testing and build lights.

I've also been writing a binary delta patcher which will update editor binaries for non-technical contributors which will simply check the current git HEAD and update binaries accordingly. So they don't have to ever compile code! Once that's setup we can also apply it to our own custom Unreal Engine build. Stay tuned for a blog post!

Once we're back to where we were, the codebase should be super easy to maintain, and we'll feel confident when it does come time to release something.
