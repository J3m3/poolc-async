# poolc-async

> [!NOTE]
> 연세대학교 공과대학 프로그래밍 동아리 [풀씨](https://poolc.org/)에서 진행한 `Asynchrony Deep Dive` 세미나 자료입니다.

![PoolC Banner](https://poolc.org/assets/main-banner-DAW2HCpy.png)

## Quick notes

To follow the experiments on Node.js, please refer to [the 'experiment' directory in the `node-experiment` submodule](https://github.com/J3m3/node-experiment/tree/1f6b6427f46e4712ed8c05805afd4e067f404286/experiment).

Note that the size of `node-experiment` submodule is over 1.5 GB. You might want to shallowly clone it by using the command below.

```console
git clone --recurse-submodules --shallow-submodules https://github.com/J3m3/poolc-async.git
```

## Table of contents

0. **Design principles of this seminar**

   - Top-down approach
     - library
     - kernel
     - hardware
   - Unveiling interfaces
     - user ↔ library
     - library ↔ kernel
     - kernel ↔ hardware

1. **Warm up**

   - Terminology semantics
     - concurrent vs. parallel
     - blocking / non-blocking
     - async / await
   - Misconceptions on JS `Promise`
     - `Promise` does not make something async

2. **User-kernel boundary** (feat. Linux)

   - I/O by Multi-threading
     - multi-processing
     - multi-threading
   - I/O by Multiplexing
     - `select`
     - `epoll`
   - Asynchronous I/O
     - `aio`
     - `io_uring`
   - Choosing the right I/O strategy
     - handling cpu-bound tasks
     - handling I/O-bound tasks
   - Async runtime case studies
     - Node.js
     - Golang
     - Rust (feat. `tokio`)

3. **Kernel-hardware boundary**

   - Interrupts & device drivers
   - System call implementations

## Assets

Icons: [Primer Octicons](https://github.com/primer/octicons/tree/main) by GitHub, Inc.

## References

- https://eklitzke.org/blocking-io-nonblocking-io-and-epoll
- https://unixism.net/loti/tutorial/sq_poll.html

## License

[MIT License](LICENSE)
