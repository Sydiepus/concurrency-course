# Lab 1 lectures reports
## Lecture 1
- Files:
    - `labs/java-concurrency/LAB 1/README.md`

## Lecture 2
- Files:
    - `labs/java-concurrency/LAB 1/explanation_paragraph.txt`
    - `labs/java-concurrency/LAB 1/cpu_pool10.csv`
    - `labs/java-concurrency/LAB 1/cpu_pool13.csv`
    - `labs/java-concurrency/LAB 1/cpu_pool24.csv`
    - `labs/java-concurrency/LAB 1/cpu_pool50.csv`
    - `labs/java-concurrency/LAB 1/cpu_pool120.csv`

### Thread Pool Performance

| Pool Size | p50 Latency (ms) | p95 Latency (ms) | Throughput (req/s) |
|-----------|------------------|------------------|--------------------|
| 120       | 316              | 410              | 154.44             |
| 24        | 326              | 397              | 146.75             |
| 13        | 333              | 387              | 147.50             |

### CPU-Bound Comparison

| Pool Size | p50 Latency (ms) | p95 Latency (ms) | Throughput (req/s) |
|-----------|------------------|------------------|--------------------|
| 10        | 306              | 380              | 156.09             |
| 50        | 315              | 407              | 153.91             |

#### Analysis

For CPU-bound workloads, the tuning formula predicts an optimal pool size of 13 threads, which aligns with Amdahl's Law where pool size should be around core count.

## Lecture 3

### Amdahl's Law Speedup Table

| Parallel % | 2 cores | 4 cores | 8 cores | 16 cores | ∞ cores |
|------------|---------|---------|---------|----------|---------|
| 50         | 1.33    | 1.60    | 1.78    | 1.88     | 2.00    |
| 75         | 1.60    | 2.29    | 2.91    | 3.37     | 4.00    |
| 90         | 1.82    | 3.08    | 4.71    | 6.40     | 10.00   |
| 95         | 1.90    | 3.48    | 5.93    | 9.14     | 20.00   |

- Why does speedup plateau?
    - Because threads do not create CPU power, we will reach a point where adding threads would not benefit us and could also hurt us because of context switching overhead.

## Lecture 4

1. **Why did latency drop with threads?**
   - Multi-threading allows concurrent request processing instead of sequential queuing. Requests no longer wait for previous requests to complete, reducing wait time and overall latency.

2. **Why did p95 increase under heavy load?**
   - Comparing pool=10 (p95: 380ms) vs pool=50 (p95: 407ms), excessive threads beyond optimal capacity cause context switching overhead which increase latency.

3. **Why didn't throughput grow infinitely?**
   - Throughput plateaus around 154-156 req/s regardless of pool size due to Amdahl's Law: the system is limited by fixed core count.

4. **Was the system I/O-bound or CPU-bound?**
   - The CPU-bound comparison showed optimal performance at pool=13 (close to core count), indicating CPU-bound behavior. I/O-bound workloads would benefit from much larger pools.

## Lecture 5

1. **Why is Redis single-threaded for request processing?**
   - Redis operations are extremely fast (memory-bound, not CPU-bound). A single-threaded event loop avoids lock contention overhead and context switching.

2. **When does a single-thread event loop fail?**
   - It fails when the queue grows too long.

3. **Why did throughput plateau in the lock-based counter?**
   - Threads have access to a shared counter. Even with multiple threads, only one can acquire the lock at a time, creating a bottleneck which plateaus then degrades.

4. **Use Little's Law: if W doubles and $\lambda$ stays constant, what happens to L?**
   - $L = \lambda × W$ If W doubles, then L also doubles.

5. **Why does SQLite serialize writes?**
   - Concurrent writes could corrupt the database file.
