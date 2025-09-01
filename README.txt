# Lua-Multi-Threaded-Pure-Lua
What Is Cthread?
  cthread is a cooperative multithreading system written entirely in pure Lua.
  It allows you to execute multiple logic threads concurrently using coroutines, automatic yielding, and sandboxed environments, without requiring any native
  dependencies or external libraries.
Why Use Cthread?
  cthread gives you true cooperative multithreading in pure Lua — no C, no dependencies, and no hacks.
  Unlike basic coroutine wrappers or while true do coroutine.yield() end tricks, cthread offers:
  ⚙️ Structured Multitasking
    Each thread runs inside its own sandboxed coroutine with controlled globals, reducing side effects and improving reliability.
  🧵 Automatic Yielding
    No need to manually sprinkle coroutine.yield() in your code. The system injects yield points automatically, even inside long loops or sequential logic.
  ⏱ Non-blocking Sleep
    Use sleep(1) (or wait(1)) without freezing your entire program. Only the current thread is paused; others continue running.
  📡 Safe Communication
    Built-in send() and collect() allow threads to exchange messages without shared memory or unsafe globals.
  🔍 Debuggable and Deterministic
    Execution order is controlled and predictable. This helps with debugging, simulation, and teaching scheduling logic.
  🧬 Fully Portable
    Runs anywhere Lua runs — no need for threads, shared memory, or platform-specific features. Works even on restricted systems (e.g. CC:Tweaked, Love2D sandbox, 
    Windows CLI Lua).
✅ Features : [[
---- Automatic Yield Injection
---- Code is automatically rewritten to insert sleep(0) after non-blocking instructions, enabling fairness across threads.
---- Built-in Cooperative Functions
---- Functions like print() and wait() are wrapped to yield, ensuring control returns to the scheduler without blocking other threads.
---- Non-blocking wait(t)
---- Delays only the current thread, allowing others to proceed.
---- Message Passing
---- Use send(thread, key, ...) and collect(from, key) for safe, isolated thread communication.
---- Deterministic Scheduler
---- Threads are resumed in order; only active threads are scheduled. No randomness or race conditions.
]]
🔧 Technical Notes : [[
---- 💡 100% Pure Lua — No C modules, FFI, or OS threads
---- 🧱 Self-contained — No dependencies; works in minimal or sandboxed environments
---- 🔐 Safe Execution — Each thread runs in its own sandboxed environment with controlled globals
---- ⚙️ Lightweight — Suitable for embedded systems, scripting engines, and constrained VMs
]]
🧠 Use Cases : [[
---- Sandboxed scripting environments
---- Teaching multitasking and coroutine scheduling
---- Custom task schedulers in embedded systems
---- Virtual machines or interpreters that need cooperative execution
---- Lua-based automation, plugins, or simulations
]]
📝 License : MIT License : [https://github.com/Bidram-coder/Lua-Multi-Threaded-Pure-Lua-/blob/main/LICENSE]

Created By @Bidram-Coder
