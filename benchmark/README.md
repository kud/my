# Shell Startup Performance Benchmarking

This benchmarking suite measures and compares shell startup performance (`.zshrc` loading times) between different branches of the 'my' project.

## 🚀 Quick Start

To benchmark shell optimizations against the master branch:

```bash
cd benchmark
./run-shell-benchmarks
```

This will automatically:

1. Benchmark the master branch shell startup (baseline)
2. Benchmark the current branch shell startup (optimizations)
3. Generate a detailed comparison report

## 📁 Scripts

### `run-shell-benchmarks` ⭐

Master script that orchestrates the entire benchmarking process.

### `shell-startup-benchmark`

Runs shell startup benchmarks on the current branch.

```bash
./shell-startup-benchmark [branch_name]
```

### `compare-shell-results`

Compares two shell benchmark result files.

```bash
./compare-shell-results baseline.json test.json
```

## ⚡ What Gets Measured

### Shell Startup Performance

- **Basic zsh startup** (no config files)
- **System rc files only**
- **Full zsh startup with .zshrc** ⭐ (main metric)
- **Login shell startup**
- **Command execution after startup**
- **Environment variable loading**

### Configuration Components

- Powerlevel10k instant prompt (if detected)
- Prezto framework loading (if detected)
- Custom helper functions loading

## 📊 Output Files

All results are stored in the `benchmark/results/` directory:

- `shell_startup_<branch>_<timestamp>.json` - Raw benchmark data
- `shell_comparison_<timestamp>.log` - Detailed comparison report
- `*_shell_benchmark_*.log` - Execution logs

## 📈 Understanding Results

The comparison report shows:

- **🟢 FASTER**: Test runs faster than baseline
- **🔴 SLOWER**: Test runs slower than baseline
- **⚪ UNCHANGED**: No significant difference (< 1ms)

### Key Metric: Full Shell Startup Time

This is the main performance indicator - how long it takes to start an interactive zsh session with full configuration.

**Performance categories:**

- **< 100ms**: 🚀 Excellent
- **< 300ms**: ✅ Good
- **< 500ms**: ⚠️ Acceptable
- **> 500ms**: 🐌 Needs optimization

## 🛠️ Requirements

- `jq` - JSON processing
- `bc` - Arithmetic calculations
- Git repository in clean state

## 💡 Optimization Tips

If shell startup is slow (> 300ms), consider:

- **Lazy loading**: Load heavy tools only when needed
- **Async plugins**: Use async loading where possible
- **Profile with**: `zsh -xvs` to find bottlenecks
- **Reduce plugins**: Remove unused zsh plugins
- **Optimize .zshrc**: Move expensive operations to background

## 📝 Example Usage

```bash
# Full shell optimization benchmarking
./run-shell-benchmarks

# Benchmark just the current branch
./shell-startup-benchmark

# Compare two specific results
./compare-shell-results results/shell_startup_master_*.json results/shell_startup_feat_optimising_*.json
```

## 🎯 Workflow

1. **Make optimizations** to .zshrc, dotfiles, etc.
2. **Run benchmarks**: `cd benchmark && ./run-shell-benchmarks`
3. **Check results**: Look for improvements in shell startup time
4. **Iterate**: Make more optimizations based on results
