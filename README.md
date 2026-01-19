🧵 Java Concurrency Course — Docker & VS Code Environment

Instructor: Dr. Mohamad Aoude
Institution: Lebanese University — Faculty of Engineering
Course: Concurrency & Distributed Systems
Policy: Attendance is mandatory

🎯 Course Philosophy

This course uses Docker + VS Code Dev Containers to provide a clean, identical Java environment for all students.

⚠️ Do NOT install Java, Gradle, Maven, or SDKs locally.
Everything runs inside Docker.

This eliminates:

“Works on my machine” problems

Version conflicts

OS differences

Broken local setups

📦 What You Need (One Time Only)
✅ Required

Windows 10 / 11 (64-bit)
(macOS & Linux also supported)

Internet connection

Administrator rights (for Docker install)

~10 GB free disk space

6 GB RAM allocated to Docker (recommended)

❌ You Do NOT Need

Java

Gradle

Maven

IntelliJ

Any SDKs

1️⃣ Install Docker Desktop

Download Docker Desktop
👉 https://www.docker.com/products/docker-desktop/

Install using default options

Enable WSL2 backend when asked (Windows)

Restart your computer if requested

Open Docker Desktop

Wait until it says Docker is running 🟢

Verify installation
Open PowerShell and run:

docker --version
docker compose version

2️⃣ Install Visual Studio Code

Download VS Code
👉 https://code.visualstudio.com/

Install with default options

Open VS Code and install these extensions:

Dev Containers (Microsoft)

Java Extension Pack (recommended)

3️⃣ Get the Course Code
Option A — Clone from GitHub (recommended)
git clone https://github.com/maoude/concurrency-course.git
cd concurrency-course

Option B — Download ZIP

Download the repository as ZIP

Extract to a simple path, for example:

D:\courses\concurrency-course

4️⃣ Allow Scripts (Windows — One Time per Session)

Open PowerShell in the project folder:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass


This is temporary and safe.

5️⃣ Start the Course Environment

Run:

.\scripts\course.ps1 up


What this does:

Builds the Docker image

Starts the container

Fixes Gradle permissions

Verifies Java + Gradle

⏳ First run may take several minutes.

When finished, you should see:

OK. Next:
  .\scripts\course.ps1 run
  .\scripts\course.ps1 shell
  .\scripts\course.ps1 down

6️⃣ Open VS Code Inside Docker

Open VS Code

Open the course folder

When prompted:

“Reopen in Container”

👉 Click Reopen in Container

VS Code is now running inside Docker.

7️⃣ Verify Everything Works (Inside VS Code)

Open Terminal → New Terminal in VS Code.

Check user:

whoami


Expected:

vscode


Check Java:

java -version


Check Gradle:

cd labs/java-concurrency/week-01-threads
./gradlew --version


Run the first lab:

./gradlew run


Expected output:

Main thread: main
Worker-1 ...
Worker-2 ...
BUILD SUCCESSFUL


✅ Environment is fully ready.

8️⃣ Daily Commands (PowerShell)
▶ Run the lab
.\scripts\course.ps1 run

🐚 Open container shell
.\scripts\course.ps1 shell

🛑 Stop everything
.\scripts\course.ps1 down

9️⃣ Common Issues & Fixes
❌ Docker not running

Open Docker Desktop

Wait until it shows Running

Retry

❌ Gradle permission errors

Never delete .gradle manually.

Run:

.\scripts\course.ps1 up

❌ Container stopped
docker compose -f tools/docker-compose.yml ps


If stopped:

.\scripts\course.ps1 up

🔟 Rules for Students

✔ Always use ./gradlew
✔ Do NOT install Java or Gradle locally
✔ Do NOT modify Docker files
✔ Always work inside VS Code Dev Container

📁 Repository Structure
concurrency-course/
│
├─ .devcontainer/
├─ tools/
├─ scripts/
├─ labs/
│   └─ java-concurrency/
│       └─ week-01-threads/
└─ README.md

✅ Final Check (Before Every Lab)
cd labs/java-concurrency/week-01-threads
./gradlew clean run


🎓 You are ready for the course.
