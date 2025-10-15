# Print a lighthearted message when leaving interactive shells.
[[ -o INTERACTIVE && -t 2 ]] && {

SAYINGS=(
    "So long and thanks for all the fish.\n  -- Douglas Adams"
    "Good morning! And in case I don't see ya, good afternoon, good evening and goodnight.\n  --Truman Burbank"
    "Now you're thinking with portals.\n  -- GLaDOS"
    "Stay hungry. Stay foolish.\n  -- Steve Jobs"
    "Live long and prosper.\n  -- Spock"
    "Never half-ass two things. Whole-ass one thing.\n  -- Ron Swanson"
)

# Print a randomly-chosen message:
echo $SAYINGS[$(($RANDOM % ${#SAYINGS} + 1))]

} >&2
