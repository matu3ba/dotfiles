package dotfiles.templates.common;

// import java.io.*;
// import java.net.*;
// import java.nio.ByteBuffer;
// import java.nio.channels.*;
// import java.util.*;
// import java.util.concurrent.atomic.*;
// SHENNANIGAN bad naming for atomics: getAndSet, compareAndSet, weakCompareAndSet
// SHENNANIGAN ClassNotFoundException
// chmod 664 example.jar
// missing jar, which has the class to the classpath ie : java -cp example.jar com..main.startMain

// SHENNANIGAN lsp setup requires alot useless configuration

// To run main(), use java file.java or javac file.java

// Print stacktrace to stderr without exception
// System.err.print(Arrays.toString(Thread.currentThread().getStackTrace()).replace( ',', '\n' ));

// using future for tasks with fixed deadline
// https://www.baeldung.com/java-future
// https://www.baeldung.com/java-start-thread
// https://www.baeldung.com/java-future

// thread pool and task queues:
// ExecutorService executor = Executors.newFixedThreadPool(10);
// executor.submit(() -> {
//     new Task();
// });
// ScheduledThreadPoolExecutor for flexibility and power, Timer for simplicity
// ScheduledFuture for Future and Delayed interface,
// RunnableScheduledFuture with periodicity

// Future: future result of asynchronous computation.
// Code example for non-blocking task scheduling with timeout.
public class FutureExampleClass {
  // private final AtomicBoolean is_running = new AtomicBoolean(false);
  private ExecutorService executor = Executors.newSingleThreadExecutor();
  public Future<int> addOne(int input) {
    return executor.submit(() -> {
      Thread.sleep(1_000);
      return input + 1;
    });
  }
  public runme() {
    // Future<int> future = new FutureExampleClass().addOne();
    // while(!future.isDone()) {
    //   Thread.sleep(300);
    // }
    // int res = future.get(); // no timeout
    // int result = future.get(500, TimeUnit.MILLISECONDS); // blocking, not good

    ScheduledExecutorService executor = Executors.newScheduledThreadPool(2);
    // Note: This does not work
    Future future = executor.submit(new FutureExampleClass().addOne(1));
    // on error, we should cleanup is_running
    // 'Callable' or 'Runnable' can not capture and modify context aside of
    // const objects (static final)
    Runnable cancelTask = () -> future.cancel(true);
    executor.schedule(cancelTask, 3000, TimeUnit.MILLISECONDS); // cancelTask runs after 3s
    executor.shutdown();

    // 'cancelTask' sets interrupt flag in the thread via 'Thread.interrupt()'
    // Recommendation: Callee 'FutureExampleClass' should handle 'InterruptedException' or something like
    // if (Thread.interrupted()) {
    //  throw new InterruptedException();
    // }
    // Without this, there is no hard guarantee.

    // SHENNANIGAN socket resources might need additional cleanup
  }
}

//Create a Runnable with parameter
// String paramStr = "a parameter";
// Runnable myRunnable = createRunnable(paramStr);
// private Runnable createRunnable(final String paramStr){
//     Runnable aRunnable = new Runnable(){
//         public void run(){
//             someFunc(paramStr);
//         }
//     };
//     return aRunnable;
// }
// Future fut = sched_exec_service.submit(myRunnable);
// idea: make someFun a functor, if java supports that

// SHENNANIGAN
// maven clean compile, package
// Without package, there are no .jar files generated.
