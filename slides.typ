#import "@preview/fletcher:0.3.0" as fletcher: node, edge
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code
#import "@preview/xarrow:0.3.0": xarrow
#import "lib/index.typ": *

#show: conf

#set list(marker: [-])

// 1
#title-slide(title: "Asynchrony Deep Dive")[

  #line(length: 65%, stroke: 2pt + color_medium)

  #poolc_badge #h(.3em) 양제성

  #v(.5em)
  #set text(size: fontsize_small)
  #let date = datetime(year: date.year(), month: date.month(), day: date.day()).display(
    "[year]/[month]/[day] ([weekday repr:short])"
  )

  Source: #github_icon_link("https://github.com/J3m3/poolc-async.git") #h(1em) #date
]

#let hierarchy_table(highlight_pos: int) = {
  set table(
    stroke: none,
  )
  table(
    columns: 2,
    table(
      columns: 1,
      inset: (top: 1em, bottom: 1em, right: 3em, left: 3em),
      [#if highlight_pos == 0 [_Application_] else [Application]], 
      table.hline(),
      [#if highlight_pos == 1 [_Library_] else [Library]], 
      table.hline(),
      [#if highlight_pos == 2 [_Kernel_] else [Kernel]], 
      table.hline(),
      [#if highlight_pos == 3 [_Hardware_] else [Hardware]], 
    ),
    table(
      columns: 1,
      inset: (top: 1em, bottom: 1em),
      [#text(fill: rgb(0,0,0,40%))[library calls]], 
      [#if highlight_pos == 1 [_system calls_] else [system calls]], 
      [#if highlight_pos == 2 [_interrupts_] else [interrupts]],
    )
  )
}

// 2
#absolute-center-slide(title: "Table of Contents")[
  #hierarchy_table(highlight_pos: -1)
]

// 3
#absolute-center-slide(title: "Warm up!")[
  #hierarchy_table(highlight_pos: 0)
]

// 4
#relative-center-slide(title: "Misconceptions on Promise")[
  ```js
  const p = new Promise((resolve, reject) => {
    setTimeout(() => resolve("done"), 1000)
  })

  p.then(console.log)
  console.log("I'm gonna be printed first!")
  ```
]

// 5
#relative-center-slide(title: "Misconceptions on Promise")[
  ```js
  const p = new Promise((resolve, reject) => {
    for (let i = 0; i < 1000000000; i++) {}
    console.log("Hmm...")
    resolve("done")
  });

  p.then(console.log);
  console.log("Hi!");
  ```
]

// 6
#relative-center-slide(title: "Misconceptions on Promise")[
  ```js
  async function foo() {
      for (let i = 0; i < 10000000000; i++) {}
      console.log("foo")
  }
  async function bar() {
      await foo()
      console.log("bar")
  }

  bar()
  console.log("Hi!")
  ```
]

// 7
#absolute-center-slide(title: "Contract of Promise")[
  #set text(size: fontsize_big)
  Promise doesn't make something non-blocking\
  \
  _"Don't run compute-heavy codes w/ Promise, rather_\
  _use inherently non-blocking APIs by the runtime"_
]

// 8
#relative-center-slide(title: "Misconceptions on Promise")[
  ```js
  async function foo() {
      for (let i = 0; i < 10000000000; i++) {}
      console.log("foo");
  }
  async function bar() {
      let a = 3; console.log("bar")
      await foo()
      a = 5; console.log("a =", a) // Where did `a` stored?
  }
  bar()
  console.log("Hi")
  ```
]

// 9
#absolute-center-slide(title: "Mental model of async/await")[
  #set text(size: fontsize_big)
  _"Cooperative (↔ preemptive) multi-tasking"_\
  ...in a very high-level, abstracted view
]

// 10
#slide()[
  #align(center + horizon)[
    #text(size: 50pt, weight: "medium")[Terminology Time!]
  ]
]


// 11
#top-left-slide(title: "Parallel vs. Concurrent")[
  #set enum(number-align: top + start, indent: 1em)

  == Parallel

  + A parallel system can run multiple tasks _simultaneously_
  + Tasks _necessarily_ run at the same time
  + ex. Multi-core CPU

  == Concurrent

  + A concurrent system can _handle_ multiple tasks
  + Tasks _not necessarily_ run at the same time
  + ex. Time sharing system
]

// 12
#top-left-slide(title: "async/sync & block/non-block")[
  #set list(indent: 1em)

  === Synchronous blocking

  - disk I/O (not really after Linux 2.5.23) TODO: see man page.
  - `Promise` w/o `await`

  === Asynchronous non-blocking

  - `setTimeout`, `fetch`, `Promise`

  === Synchronous blocking

  - polling
]

// 13
#relative-center-slide(title: "Async blocking?")[
  #image("assets/figure1.gif", width: 60%)
  #v(-1em)
  #text(size: 10pt)[https://developer.ibm.com/articles/l-async/]
]

// 14
#absolute-center-slide(title: "Again, Table of Contents")[
  #hierarchy_table(highlight_pos: 1)
]

// 15
#top-left-slide(title: "A bit of history: web servers")[
  #set list(indent: 1em)

  #grid(
    columns: 2,
    column-gutter: 3em,
    [
      == I/O by multi-processing

      - `fork` + `exec`
      - even w/ COW... too heavy!

      == I/O by multi-threading

      - `pthread_create` + `pthread_join`
      - share as much as possible
    ],
    table(
      columns: 1,
      align: center,
      inset: (top: .5em, bottom: .5em, right: 1em, left: 1em),
      [#highlight(fill: color_light, extent: .25em)[Kernel]],
      [Stack],
      [_Shared Libraries_],
      [_Heap_],
      [_Data_],
      [_Text_],
      table.hline(stroke: 3pt),
      table.cell(stroke: none)[HW context],
      table.hline(stroke: 3pt),
    )
  )
]

// 16
#relative-center-slide(title: "I/O multiplexing")[
  #image("assets/figure3.gif", width: 60%)
  #v(-1em)
  #text(size: 10pt)[https://developer.ibm.com/articles/l-async/]
]

// 17
#absolute-center-slide(title: "I/O multiplexing")[
  #set text(size: fontsize_big)
  _"Do works only when it is possible to proceed"_
]

// 18
#top-left-slide(title: [#text(fill: color_dark)[UNIX] I/O multiplexing: `select`])[
  == `$ man 2 select`
  #set text(size: 23pt)
  - allows _a_ program to _monitor multiple file descriptors_, waiting until\ one or more of the file descriptors become "ready" for some class\ of I/O operation

  - A file descriptor is considered ready if it is possible to perform a corresponding I/O operation

  - WARNING: can _monitor at most FD_SETSIZE (1024) file descriptors_... and this limitation will not change. All modern applications should instead use poll(2) or epoll(7)...
]

// 19
#top-left-slide(title: [#text(fill: color_dark)[UNIX] I/O multiplexing: `select`], header: "CAUTION: NOT 100% CORRECT!")[
  #set text(size: 20pt)
  ```c
  fd_set reads; FD_SET(server_socket, &readfds);

  while (true) {
      select(server_socket + 1, &readfds, ...) // block
      for (auto fd : readfds) {
          if (FD_ISSET(fd, &readfds)) {
              if (fd == server_socket) {
                  client_socket = accept(server_soccet, ...);
                  FD_SET(client_socket, &readfds);
              } else
                  read(fd, buffer, ...);
          }
      }
  }
  ```
]

// 20
#top-left-slide(title: [Linux I/O multiplexing: `epoll`])[
  == `$ man 7 epoll` `(since Linux 2.5.45)`

  - The epoll API performs a similar task to poll(2): _monitoring\ multiple file descriptors_ to see if I/O is possible on any of them

  - The epoll API can be used either as an _edge-triggered_ or a\ _level-triggered_ interface and _scales well_ to large numbers of watched file descriptors
]

// 21
#top-left-slide(title: [Linux I/O multiplexing: `epoll`], header: "CAUTION: NOT 100% CORRECT!")[
  #set text(size: 20pt)
  ```c
  epfd = epoll_create(EPOLL_SIZE);
  ep_events = (epoll_event*) malloc(sizeof(struct epoll_event) * EPOLL_SIZE);
  struct epoll_event event;
  epoll_ctl(epfd, EPOLL_CTL_ADD, server_socket, &event);
  ```
]

// 22
#top-left-slide(title: [Linux I/O multiplexing: `epoll`], header: "CAUTION: NOT 100% CORRECT!")[
  #set text(size: 20pt)
  ```c
  while (true) {
      event_count = epoll_wait(epfd, ep_events, EPOLL_SIZE, ...); // block
      for (int i = 0; i < event_count; i++) {
          if (ep_events[i].data.fd == server_socket) {
              client_socket = accept(server_socket, ...);
              ...
              event.data.fd = client_socket;
              epoll_ctl(epfd, EPOLL_CTL_ADD, client_socket, &event);
          } else
              read(ep_events[i].data.fd, buffer, ...);
      }
  }
  ```
]

// 23
#top-left-slide(title: [Linux I/O multiplexing: `epoll`], header: "level-triggered vs edge-triggered")[
  #set list(indent: 1em)
  #set text(size: 23pt)

  === Level-triggered

  - `fd` is considered ready if it is possible to perform a corresponding\ I/O operation

  - A partially read socket is also read in the next loop (same with `select`)

  === Edge-triggered

  - `fd` is considered ready if the I/O event has occurred since the last `epoll_wait` call

  - partially read socket won't be read in the next loop

]

// 24
#top-left-slide(title: [Linux I/O multiplexing: `epoll`], header: "level-triggered vs edge-triggered")[
  #set list(indent: 1em)
  #set text(size: 23pt)

  === Caution!

  - When using edge-triggered mode, always make sure to use\ non-blocking I/O (for sockets, use `O_NONBLOCK`)

  - You also need to read/write until `EWOULDBLOCK` is returned

  - With this contract, it gives you more efficiency\ ($O(1)$ multiplexing where $N$ is the number of file descriptors)

]

// 25
#top-left-slide(title: [Linux Async I/O: `aio`])[
  == `$ man 7 aio` `(since Linux 2.5.23)`

  - allows applications to initiate one or more I/O operations that are performed asynchronously (i.e., _in the background_)

  - The application can elect to be notified of completion of the I/O operation in a variety of ways: 
    - by delivery of a signal
    - by instantiation of a thread
    - or no notification at all
]

// 26
#top-left-slide(title: [Linux Async I/O: `io_uring`])[
  #set text(size: 23pt)

  == `$ man 7 io_uring` `(since Linux 5.1)`

  - allows the user to submit one or more I/O requests, which are processed asynchronously _without blocking the calling process_

  - uses 2 buffers called "ring buffer" which are _shared between user and kernel space_; avoiding the overhead of copying data between them, where possible

  - "The biggest limitation of `aio` is that it only supports async IO for `O_DIRECT` access, which bypasses cache and has size/alignment restraints"\ \[Axboe(2019). "Efficient IO with io_uring"\]
]

// 27
#relative-center-slide(title: [Linux Async I/O: `io_uring`])[
  #image("assets/uring_0.png", width: 65%)
  #v(-1em)
  #text(size: 10pt)[https://developers.redhat.com/articles/2023/04/12/why-you-should-use-iouring-network-io]
]

// 28
#relative-center-slide(title: [Linux Async I/O: `liburing`])[
  #set text(size: 24pt)
  ```c
  struct io_uring_sqe sqe;
  struct io_uring_cqe cqe;
  /* get an sqe and fill in a READV operation */
  sqe = io_uring_get_sqe(&ring);
  io_uring_prep_readv(sqe, fd, &iovec, 1, offset);
  /* tell the kernel we have an sqe ready for consumption */
  io_uring_submit(&ring);
  /* wait for the sqe to complete */
  io_uring_wait_cqe(&ring, &cqe);
  /* read and process cqe event */
  app_handle_cqe(cqe);
  io_uring_cqe_seen(&ring, cqe);
  ```
]

// 29
#top-left-slide(title: [Linux Async I/O: `io_uring`])[
  #set text(size: 23pt)

  == Reduced system calls

  - system calls(e.g. `read`, `write`, ...) are packed(not an official term)\ into _a single system call_, `io_uring_enter`

  == Even more reduced system calls

  - supports _"Kernel side polling"_...
    - \# of `io_uring_enter` calls are even reduced

  - the kernel spawns a dedicated kernel thread to poll the\ submission queue
]

// 30
#relative-center-slide(title: [Linux Async I/O: `io_uring`])[
  _Sharing always causes some problems_

  #grid(
    columns: 2,
    column-gutter: 1em,
    image("assets/docker_uring.png"),
    image("assets/google_uring.png"),
  )
]

// 31
#slide()[
  #align(center + horizon)[
    #text(size: fontsize_big, weight: "medium")[
      So... why did we go through all the way down here? \
      Let's take a breath and think about the original goal...
    ]
  ]
]

// 32
#absolute-center-slide(title: "Async runtime implementation")[
  #set text(size: 40pt)
  "Asynchronous systems are implemented \
  _with the help of the kernel_!"
]

// 33
#top-left-slide(title: "Async runtime implementation")[
  #set list(indent: 1em)

  == Various ways to implement async runtime

    - forking

    - pre-forked

    - threaded

    - pre-threaded (a.k.a. thread pool)

    - I/O multiplexing
]

// 34
#absolute-center-slide(title: "Async runtime implementation")[
  #image("assets/comparison.png", width: 73%)
  #v(-1.5em)
  #text(size: 10pt)[https://unixism.net/loti/async_intro.html]
]

// 35
#top-left-slide(title: "Async runtime implementation")[
#set text(size: 23pt)

+ "As you can see, prethreaded, or _the thread pool based web server gives the epoll(7) based server a run for its money up until a concurrency of 11,000 users_ in this particular benchmark.

+ And that is a lot of concurrent users. ... 

+ This is very significant, given that in terms of complexity, _thread pool based programs are way easier to code_ compared to their asynchronous counterparts. 

+ This also means _they are way easier to maintain_ as well, since they are natually a lot easier to understand."
]

// 36
#top-left-slide(title: "Async runtime implementation")[
  == Node.js
    - use a _cross-platform library_ `libuv` as its event loop
    - `libuv` uses OS-specific I/O multiplexing system calls to handle multiple I/O operations
      - Linux: `epoll`, `io_uring` (since Node.js 20.3.0)
      - BSD: `kqueue`
      - Windows: `IOCP`
    - `libuv` also maintains a thread pool(!) for DNS operations and _file system operations_
]

// 37
#absolute-center-slide(title: "Async runtime implementation")[
  #show link: underline

  Let's dig in and see how `libuv` gives us the asynchronous capability!

  https://github.com/J3m3/node-experiment/
]

// 38
#top-left-slide(title: "Async runtime implementation")[
  == Golang
    - use _green thread_ model to provide async capability
    - _M:N threading model_ (M user threads -> N kernel threads)
    - goroutines, _stackful coroutines_!
    - delegates inherently blocking system calls to different OS threads
    - _net poller_ thread for I/O multiplexing
]

// 39
#relative-center-slide(title: "Async runtime implementation")[
  #image("assets/go_scheduler.png", width: 73%)
  #v(-.5em)
  #text(size: 10pt)[https://velog.io/@khsb2012/go-goroutine]
]

// 40
#top-left-slide(title: "Async runtime implementation")[
  == Rust
    - green thread(!) model (until Rust 0.9)
    - _stackless couroutine_ apporach
    - `Future` trait (something like `Promise` but _inert_)
    - Rust _standard library does not provide async runtime_;\ they are provided by external crates like `tokio`, `async-std`, etc.
]

// 41
#top-left-slide(title: "Async runtime implementation")[
  == Rust (tokio crate)
    - one of the _executor_ of `Future` (again, `Future` is inert)
    - uses `mio` crate for _I/O multiplexing_
    - multiple executor instances can run in _parallel_
    - _Async mutexes_?
  
  "The spawned task may be executed on the same thread as where\ it was spawned, or it may execute on a different runtime thread.\ The task can also be moved between threads after being spawned."
]

// 42
#relative-center-slide(title: "Async runtime implementation", header: [Async mutexes?])[
  #set text(size: fontsize_small)
  ```rs
  // Let's assume we use a single-threaded runtime
  async fn main() {
      let x = Arc::new(Mutex::new(0));

      let x1 = Arc::clone(&x);
      tokio::spawn(async move {
          let mut x = x1.lock(); // mutex locked
          some_async_fn().await; // yield
      });

      let x2 = Arc::clone(&x);
      tokio::spawn(async move {
          let mut x = x2.lock(); // deadlock!
      });
  }
  ```
]

// 43
#relative-center-slide(title: "Async runtime implementation", header: [Async mutexes?])[
  #set text(size: fontsize_small)
  ```rs
  // Let's assume we use a single-threaded runtime
  async fn main() {
      let x = Arc::new(Mutex::new(0));

      let x1 = Arc::clone(&x);
      tokio::spawn(async move {
          *x1.lock() += 1;
      });

      let x2 = Arc::clone(&x);
      tokio::spawn(async move {
          *x2.lock() -= 1; // What about now?
      });
  }
  ```
]

// 44
#top-left-slide(title: "Choosing the right I/O strategy")[
  == CPU-bound tasks
  - thread pool is sutiable
  - what about single-threaded I/O multiplexing (e.g. Node.js)?

  == I/O-bound tasks
  - single-threaded I/O multiplexing is suitable
  - what about thread pools?

  #align(center)[
    #v(1em)
    _Actually, we can mix and match different strategies!_
  ]
]

// 45
#absolute-center-slide(title: [Again \* 2, Table of Contents])[
  #hierarchy_table(highlight_pos: 2)
]

// 46
#top-left-slide(title: "Interrupts")[
  == How do we communicate with hardwares?
    - interrupts!
    - interrupt handlers, a part of a device driver, are executed when\ CPU receives an interrupt signal
    - let's briefly see how interrupts are combined with I/O multiplexing implementation
]

// 50
#absolute-center-slide(title: [Device driver side])[
  #image("assets/syscall.png", width: 65%)
  #v(-1em)
  #text(size: 10pt)[Linux	Device	Driver by Prof.	Yan	Luo]
]


// 47
#top-left-slide(title: [`poll` syscall implementation])[
  #set enum(number-align: top + start, indent: 1em)
  == Some of kernel functions involved in `poll` syscall
    - `sys_poll` syscall handler
    - `do_poll` kernel function
    - `do_pollfd` kernel function
    - `xxx_poll` function defined in xxx device driver
    - `poll_wait` function called by `xxx_poll`
    - xxx device driver's `wake_up` function in ISR
]

// 48
#top-left-slide(title: [`poll` syscall implementation])[
  ```
  foreach fd (given from user space):
    find device corresponding to fd
    call device poll function to setup wait queues \
    (with poll_wait) and to collect its "ready-now" mask

  while time remaining in timeout and no devices are ready:
    sleep

  return from system call (either due to timeout or to ready devices)
  ```
]

// 50
#absolute-center-slide(title: [`poll` in device driver])[
  #image("assets/poll.png", width: 65%)
  #v(-1em)
  #text(size: 10pt)[Linux	Device	Driver by Prof.	Yan	Luo]
]


// 49
#absolute-center-slide(title: [`poll` in device driver])[
  #image("assets/uio_poll.png", width: 80%)
  #v(-1em)
  #text(size: 10pt)[https://elixir.bootlin.com/linux/v6.12.1/source/drivers/uio/uio.c]
]

