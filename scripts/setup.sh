#!/bin/bash
set -e

echo "Setting up Concurrency Course Environment"

mkdir -p /workspace/labs/{java-concurrency,python-contrast,distributed-systems}
mkdir -p /workspace/data/{kafka,logs}
mkdir -p /home/vscode/.local/bin

cat > /home/vscode/.local/bin/diag << 'EOF'
#!/bin/bash
echo "=== Environment Diagnostics ==="
echo "Java:   $(java -version 2>&1 | head -1)"
echo "Python: $(python3 --version 2>&1)"
echo "Docker: $(docker --version 2>&1 | head -1)"
echo ""
echo "Running services:"
docker ps --format "table {{.Names}}\t{{.Status}}" | head -20
echo ""
echo "Disk usage in /workspace:"
du -sh /workspace 2>/dev/null | cut -f1 || echo "N/A"
EOF
chmod +x /home/vscode/.local/bin/diag

cat > /home/vscode/.local/bin/labcheck << 'EOF'
#!/bin/bash
echo "=== Lab Environment Check ==="
echo "Current directory: $(pwd)"
echo ""
if [ -f "build.gradle" ]; then
  echo "Java project detected"
  ./gradlew --version 2>&1 | head -3
elif [ -f "requirements.txt" ]; then
  echo "Python project detected"
  python3 --version
else
  echo "No build.gradle or requirements.txt found"
  echo "Navigate to a lab directory first"
fi
EOF
chmod +x /home/vscode/.local/bin/labcheck

cat > /home/vscode/.local/bin/threaddump << 'EOF'
#!/bin/bash
echo "=== Thread Dump Helper ==="
echo "Java processes:"
jps -l || true
echo ""
echo "Commands:"
echo "  jcmd <PID> Thread.print"
echo "  jstack <PID>"
echo "  jcmd <PID> GC.heap_info"
echo "  jcmd <PID> VM.native_memory"
EOF
chmod +x /home/vscode/.local/bin/threaddump

echo "Setup complete."
echo "Quick commands: diag | labcheck | threaddump"
echo "Start Kafka: ./scripts/kafka-quickstart.sh start"
