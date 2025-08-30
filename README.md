# Lua-Multi-Threaded-Pure-Lua-
cthread — short for coroutine threads is a pure Lua cooperative multithreading system designed for high control, performance, and portability.
Unlike typical coroutine wrappers, cthread compiles each "thread" into a coroutine with its own sandboxed environment and injects a cooperative scheduler. Built-in functions such as print() are automatically wrapped to yield control, enabling multiple logical threads to execute in parallel without blocking one another.
✅ Key Features:
  Automatic Cooperative Yielding
  Threads yield automatically after key operations like print() or wait(), allowing others to proceed.
  Non-blocking Sleep
  wait(t) suspends only the current thread without halting the entire system.
  Safe Message Passing
  Use send(thread, data) and collect(from, key) for isolated, deterministic communication.
  Injectable Loop Rewriting
  Optionally rewrite for loops to yield per iteration, enabling long loops to share execution time.
  Custom Scheduler
  The core scheduler ticks through all active threads, resuming only those ready to run.
🔧 Design Notes:
  Written in 100% pure Lua
  No C modules, no OS threads, no FFI, no external dependencies
  Compatible with constrained environments (e.g., Windows with no pipe/mmap support)
🧠 Use Cases:
  Sandboxed script environments
  Virtual machine concurrency simulations
  Teaching task scheduling and coroutine-based threading
  Lightweight task schedulers for embedded or low-level Lua systems
🔬 Background:
  This system evolved from prior thread models I designed (LT, GTC, HGTC, HNGTC). Compared to those, cthread offers:
  Faster and safer execution
  Clean message-passing architecture
  Better debugging and logging potential
  A structured cooperative multitasking model
Licence : [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
