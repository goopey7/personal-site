#import "../../../templates/base.typ": conf

#show: conf.with(
  page-title: "Wii Development From Scratch: Episode 1",
  date: datetime(year: 2026, month: 08, day: 12),
  description: "Using nothing but Zig",
  giscus: true,
)

I'm finally done with higher education.
I've started my new career and am ready to take on fun projects at my own pace.

I did my dissertation on the Wii.
I got some exposure to the hardware while making a "modern" toolchain with Zig.
Unfortunately, I had to focus on my paper and didn't have much time to dive deep into any
topics. So I relied on libogc (a system library for the Wii) to skip a bunch of the low-level things.
Now that it's all over and I can do whatever I want,
I'm gonna make my own Wii software in Zig with ZERO third party dependencies!
And since it's all in Zig we won't need libc either!

= Where do I even start?
Before writing any Wii code, we should figure out how to build an empty raw ELF binary that
targets the Wii. Zig is awesome and can cross-compile to PowerPC out of the box.

== Setup the entrypoint
Let's write one of the simplest programs ever. An empty infinite loop:
```zig
export fn _start() callconv(.naked) noreturn {
    while (true) {}
}
```

Sorry if this is starting to feel like an English class, but let's stop
and digest what the author (me) did here lol.

=== Why not main?
If you've ever worked with Zig on modern systems before,
your infinite loop program would normally look something like this:
```zig
pub fn main() void {
    while (true) {}
}
```
So why aren't we using `pub fn main()` on the Wii?
On modern systems, `main` isn't actually what the CPU immediately jumps to on boot.
Zig's standard library defines the real entry symbol for you
which sets up the environment,
on x86_64 Linux that's zeroing the frame pointer and grabbing current stack pointer
before calling `main`.
It also would handle converting whatever `main` returns into an exit code.
That symbol is usually `_start` on most targets, so we'll follow that convention here.

However, this assumes there's a kernel underneath managing all that setup on your behalf.
On Linux, before `_start` runs, the kernel has already done loads of setup through `execve()`.
From the man-pages:
#quote(block: true, attribution: [https://man7.org/linux/man-pages/man2/execve.2.html])[
execve() executes the program referred to by path.  This causes
       the program that is currently being run by the calling process to
       be replaced with a new program, with newly initialized stack,
       heap, and (initialized and uninitialized) data segments.
]

On the Wii, there is no kernel that exists underneath to set these things up.
So it's up to us to perform every part of that setup by hand.

=== Why are we getting naked?
A normal Zig function doesn't just contain the instructions you write,
the compiler will wrap it in a prologue and epilogue for pushing/saving registers,
setting up stack frame etc. Things necessary for a function to call another function without
corrupting the calling function's state.

Problem is they assume there's a stack which already exists to push onto.
On Linux that's fine since there is already one as seen from `execve()` above.
`callconv(.naked)` tells Zig to only emit the exact instructions in the function body.
So now we control every single instruction that executes from within the body of `_start`.
The compiler will make zero runtime assumptions. The infinite loop doesn't need a stack,
so it's a good program to test if we can compile a valid PowerPC binary.

The `export` keyword is also important because it ensures that the `_start` symbol
shows up in the binary as-is without mangling.

The `noreturn` keyword is not strictly necessary here but is good practice to tell the compiler
that this function will not return due to the infinite loop.
