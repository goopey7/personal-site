---
layout: post
title: "UE5 on the Wii: Episode 2"
date: 2025-11-07
thumbnail: /assets/thumbs/LUR-WiiCover.png
description: "Remember, this is an honors project"
---

For my honors project, I'm porting Unreal Engine 5 to the Wii. 
You might think achieving this crazy ambitious goal would be enough, and it would be for my personal satisfaction.
However, the honors project is more about research and applying the scientific method in an academic paper. The artifact that gets developed
is more of a secondary priority as far as the module is concerned.

So instead of going in guns blazing and rushing to get Unreal Engine 5 compiling, I needed to take a step back and think about my paper.

# The proposal

I had to submit a formal three page proposal, which was graded by my supervisor.
This was the first time I had to really think about the meaning behind my project.
What actual research will I be contributing to the academic world?
Sadly that can't just be a yes or no answer. A question like "Can I get Unreal Engine 5 on the Wii?" is not good enough.
Even after writing the proposal, I still have no idea what my research question will be.

The proposal is obviously very subject to change, it was just a formal deadline I had to meet.
But it is going in a direction which could turn into some good academic research.
As suggested in the paper, I could focus on graphics. The Wii doesn't have programmable shaders, it's on a fixed-function pipeline.
As far as I understand, Unreal's material system generates HLSL code under the hood.
So, not only will I have the challenge of wrapping a legacy graphics API into a modern graphics wrapper,
but I'll also have to come up with fixed-function techniques to use in the absense of shaders.

My personal aim is to get the game I've been working on with 777 Studios up and running on the Wii with motion controls.
But my project may have to dive deep on graphics research to fulfill academic expectations and deadlines.

Another vertical to explore is asset cooking. The Wii's byte order is big endian which is different from any platform supported by Unreal Engine.
We also need to heavily optimize assets for the Wii's architecture and very limited system memory.

<object data="/assets/HonorsProposal.pdf" width="800" height="500" type='application/pdf'></object>

# What would a mimimum viable product look like?
What if it's just not feasible to get Unreal Engine 5 on the Wii? It's too early to know for sure.
If my research question is something to do with fixed-function techniques without shaders, I'd be able to pivot pretty easily.
I could at least port a modern graphics wrapper such as webGPU to the Wii instead and go all in on fixed-function vs programmable pipelines.

But there's also so much more to the Wii than graphics! It has a sick controller with IR and motion sensors that I also want to spend time playing with, but I don't know how I can scope a research question that broadly encompasses the Wii.

The next submission is a couple weeks away. It's a feasibility demo where I must provide a research question, gantt chart, risk analysis, code, structured diagram, and a literature review in a ~20 minute presentation/discussion.

# Ethical concerns
<img src="../../../assets/nintendo-lawyers.webp" alt="Nintendo Lawyers" width="500"/>

I am no lawyer, but I think this project is legal in the UK.
I don't expect this will be high on Nintendo's hitlist anyway since it doesn't aid piracy in any way.

The only potential line I may have crossed is CDPA 1988, s.296ZA-296ZB which is prohibition of circumvention.
It's not 100% clear to me,
but I might not have been allowed to circumvent the Wii's security measures to install the homebrew channel and run my own code on the Wii.
I think I'm good though because I'm not doing it for the purpose of obtaining access to copyrighted or protected work, and I'm also not distributing any code or information on how to circumvent the Wii's security.

I also just don't have to mention it in my project at all. I should just say I ran my code on the Wii without going into depth on how I loaded it on there.
