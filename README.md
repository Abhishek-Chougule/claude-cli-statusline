# Claude CLI Statusline HUD

A **minimal, high-signal terminal HUD** for **Claude CLI** that displays
real-time token usage, context window status, cost, execution time, and
code diff stats.

Built for developers who want **instant telemetry about Claude usage
directly in the terminal status line**.

------------------------------------------------------------------------

# Preview

<img width="1224" height="107" alt="image" src="https://github.com/user-attachments/assets/349409e9-4c73-4bcf-b6f7-adb7c8919394" />

    ◆ Claude │ █████░░░░░░ 42% │ ↓12.4k ↑1.1k │ cache r:2.1k/w:500 │ Σ 20k/5k │ +120/-30 │ ⚡350ms ⏱4s │ $0.0123

------------------------------------------------------------------------

# What It Shows

  Field         Meaning
  ------------- ---------------------------------
  Model         Claude model name
  Context Bar   Context window usage visual bar
  ↓ Input       Tokens sent to model
  ↑ Output      Tokens generated
  Cache         Cache read / write tokens
  Σ Totals      Total tokens used
  \+ / -        Lines added / removed
  ⚡ API        API response latency
  ⏱ Duration    Total runtime
  \$ Cost       Estimated USD cost

------------------------------------------------------------------------

# Features

## Real-Time Claude Telemetry

Displays:

-   Model name
-   Context window usage
-   Token usage
-   Cache utilization
-   Runtime duration
-   API latency
-   Cost tracking
-   Code diff stats

------------------------------------------------------------------------

## Visual Context Window Indicator

    ██████░░░░░░ 50%

Color coded:

  Color    Meaning
  -------- --------------
  Green    Safe
  Yellow   Getting full
  Red      Nearly full

------------------------------------------------------------------------

## Token Metrics

Shows both **current request tokens and totals**.

    ↓12.4k ↑1.1k
    Σ 20k/5k

Where:

-   ↓ = input tokens
-   ↑ = output tokens
-   Σ = session totals

------------------------------------------------------------------------

## Cache Metrics

Displays Claude prompt caching stats.

    cache r:2.1k / w:500

  Metric   Meaning
  -------- --------------------
  r        Cache read tokens
  w        Cache write tokens

------------------------------------------------------------------------

## Cost Indicator

    $0.0123

Color coded:

  Cost               Color
  ------------------ --------
  \< \$0.10          Green
  \$0.10 -- \$0.50   Yellow
  \> \$0.50          Red

------------------------------------------------------------------------

## Performance Metrics

    ⚡350ms ⏱4s

  Symbol   Meaning
  -------- ----------------------
  ⚡       API response latency
  ⏱        Total runtime

------------------------------------------------------------------------

## Code Diff Stats

    +120 / -30

  Symbol   Meaning
  -------- ---------------
  \+       Lines added
  \-       Lines removed

Useful for tracking **Claude-generated code changes**.

------------------------------------------------------------------------

# Installation

## 1 Clone Repository

``` bash
git clone https://github.com/Abhishek-Chougule/claude-cli-statusline.git
cd claude-cli-statusline
```

------------------------------------------------------------------------

# Cross Platform Setup (Linux + Windows)

## Linux / macOS

### Make Script Executable

``` bash
chmod +x statusline.sh
```

### Configure Claude CLI

``` bash
claude config set statusline ./statusline.sh
```

------------------------------------------------------------------------

## Windows Setup

Windows cannot run `.sh` directly. Use **bash explicitly**.

### Configure Claude CLI

``` bash
claude config set statusline "bash ./statusline.sh"
```

Or with absolute path:

``` bash
claude config set statusline "bash C:/path/to/claude-cli-statusline/statusline.sh"
```

This works with:

-   Git Bash
-   WSL
-   Linux terminals
-   macOS terminals

No `chmod` required on Windows.

------------------------------------------------------------------------

# Verify Configuration

Check Claude configuration:

``` bash
claude config get statusline
```

Expected output:

    bash ./statusline.sh

------------------------------------------------------------------------

# Manual Testing

The script expects JSON input from **stdin**.

Test locally using:

``` bash
echo '{}' | bash statusline.sh
```

Example payload test:

``` bash
echo '{"model":{"display_name":"Claude"},"context_window":{"used_percentage":42}}' | bash statusline.sh
```

------------------------------------------------------------------------

# Requirements

-   Bash
-   Python 3
-   Claude CLI

Check Python:

``` bash
python3 --version
```

------------------------------------------------------------------------

# How It Works

Claude CLI sends a **JSON payload** to the statusline script through
`stdin`.

Example payload:

``` json
{
  "model": {
    "display_name": "Claude 3.5 Sonnet"
  },
  "context_window": {
    "used_percentage": 42,
    "remaining_percentage": 58,
    "current_usage": {
      "input_tokens": 12400,
      "output_tokens": 1100
    }
  },
  "cost": {
    "total_cost_usd": 0.0123
  }
}
```

The script:

1.  Reads JSON from `stdin`
2.  Parses data using Python
3.  Extracts metrics
4.  Formats values
5.  Renders colored terminal output

------------------------------------------------------------------------

# Script Architecture

    statusline.sh
    ├── ANSI color configuration
    ├── JSON parsing (Python)
    ├── Number formatting
    ├── Duration formatting
    ├── Context progress bar
    ├── Threshold color logic
    └── Terminal rendering

------------------------------------------------------------------------

# Customization

## Change Bar Length

Edit:

    BAR_LEN=12

Example:

    BAR_LEN=20

------------------------------------------------------------------------

## Change Colors

ANSI colors are defined at the top of the script.

    GR = green
    YL = yellow
    RD = red
    CY = cyan
    BL = blue
    MG = magenta

------------------------------------------------------------------------

# Example Output

    ◆ Claude 3.5 Sonnet │ ██████░░░░░░ 48% │ ↓15.3k ↑2.4k │ cache r:3.1k/w:900 │ Σ 40k/7k │ +230/-40 │ ⚡420ms ⏱6s │ $0.0231

------------------------------------------------------------------------

# Use Cases

This HUD helps with:

-   Monitoring token usage
-   Tracking Claude API cost
-   Understanding context limits
-   Debugging AI performance
-   Observing code changes generated by AI

All **directly in the terminal**.

------------------------------------------------------------------------

# License

MIT License

------------------------------------------------------------------------

# Author

**Abhishek Chougule**

GitHub\
https://github.com/Abhishek-Chougule
