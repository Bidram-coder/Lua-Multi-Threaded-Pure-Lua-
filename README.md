# Lua-Multi-Threaded-Pure-Lua-
Hey! I made a design that might be one of my best ideas. I call it cthread — short for coroutine threads.
Before you assume this is just another basic coroutine wrapper, it's not.
In this system, when a cthread is created, it’s compiled into a coroutine with its own environment and injected with a scheduler. All standard functions like print() are wrapped to yield, allowing multiple threads to co-operatively interleave execution without blocking.
Each cthread runs in true cooperative multitasking, meaning:
Threads yield automatically after important calls
You can wait(t) without freezing others
You can use send() and collect() for safe message passing
You can rewrite loops to yield per iteration
The scheduler resumes active threads each tick
This is all done in pure Lua, with no C modules, no OS threads, and no external libraries.
It works even on limited environments like Windows without pipe/memory access.
Perfect for:
Sandboxed script execution
Simulated multitasking systems
Teaching VM-level concurrency design
Lightweight task schedulers in constrained Lua environments
I designed this after exploring other threading models like LT, GTC, HGTC, and HNGTC.
This version is faster, more debuggable, safer, and cleaner.
