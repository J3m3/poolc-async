# poolc-async

> [!NOTE]
> 연세대학교 공과대학 프로그래밍 동아리 [풀씨](https://poolc.org/)에서 진행한 `Asynchrony Deep Dive` 세미나 자료입니다.

![PoolC Banner](https://poolc.org/assets/main-banner-DAW2HCpy.png)

## Table of contents

0. **Design principles of this seminar**

   - Top-down approach
     - library
     - kernel
     - hardware
   - Unveiling interfaces
     - user <----> library
     - library <----> kernel
     - kernel <----> hardware

1. **Warm up**

   - Semantics of terminologies
     - concurrent vs parallel
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
   - Case studies
     - Node.js
     - Golang
     - Rust (feat. `tokio`)

3. **Kernel-hardware boundary**

   - Interrupt & device driver
   - System call implementations

## Assets

Icons: [Primer Octicons](https://github.com/primer/octicons/tree/main) by GitHub, Inc.

## References

TBD

## License

[MIT License](LICENSE)
