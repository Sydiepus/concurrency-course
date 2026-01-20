package course;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        System.out.println("Main thread: " + Thread.currentThread().getName());

        Thread t1 = new Thread(() -> {
            for (int i = 1; i <= 5; i++) {
                System.out.println("Worker-1 i=" + i + " on " + Thread.currentThread().getName());
                sleep(120);
            }
        }, "worker-1");

        Thread t2 = new Thread(() -> {
            for (int i = 1; i <= 5; i++) {
                System.out.println("Worker-2 i=" + i + " on " + Thread.currentThread().getName());
                sleep(120);
            }
        }, "worker-2");

        t1.start();
        t2.start();

        t1.join();
        t2.join();

        System.out.println("Done.");
    }

    private static void sleep(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException ignored) {}
    }
}
