BEGIN {
    # ----- STATES -----
    states[1] = "A"
    states[2] = "B"

    # ----- INITIAL PROBABILITIES π -----
    pi["A"] = 0.5
    pi["B"] = 0.5

    # ----- TRANSITIONS a(i→j) -----
    a["A","A"] = 0.9;  a["A","B"] = 0.1
    a["B","A"] = 0.5;  a["B","B"] = 0.5

    # ----- EMISSIONS e(state, symbol) -----
    e["A","X"] = 0.02; e["A","Y"] = 0.98
    e["B","X"] = 0.8;  e["B","Y"] = 0.2
}

# Read one symbol per line (X or Y)
{
    T++
    obs[T] = $1
}

function fmt(x) {
    # readable scientific-ish formatting
    return sprintf("%.6g", x)
}

END {
    if (T == 0) {
        print "No observations!"
        exit 1
    }

    # ----- INITIALIZATION -----
    for (i = 1; i <= 2; i++) {
        s = states[i]
        dp[1,s]   = pi[s] * e[s, obs[1]]
        back[1,s] = "START"
    }

    # ----- RECURSION -----
    for (t = 2; t <= T; t++) {
        o = obs[t]
        for (i = 1; i <= 2; i++) {
            curr = states[i]
            bestP = -1
            bestPrev = ""

            for (j = 1; j <= 2; j++) {
                prev = states[j]
                cand = dp[t-1,prev] * a[prev,curr]
                if (cand > bestP) {
                    bestP = cand
                    bestPrev = prev
                }
            }
            dp[t,curr]   = bestP * e[curr,o]
            back[t,curr] = bestPrev
        }
    }

    # ----- PRINT DP TABLE -----
    print "=== Observations ==="
    for (t = 1; t <= T; t++) printf "%s%s", obs[t], (t<T ? " " : "\n")

    print "\n=== DP table (Viterbi scores) ==="
    printf "%-6s %-6s %-6s\n", "t", "A", "B"
    for (t = 1; t <= T; t++) {
        printf "%-6d %-6s %-6s\n", t, fmt(dp[t,"A"]), fmt(dp[t,"B"])
    }

    # ----- PRINT BACKPOINTER TABLE -----
    print "\n=== Backpointer table (argmax prev state) ==="
    printf "%-6s %-6s %-6s\n", "t", "A", "B"
    for (t = 1; t <= T; t++) {
        printf "%-6d %-6s %-6s\n", t, back[t,"A"], back[t,"B"]
    }

    # ----- TERMINATION -----
    bestFinal = dp[T,"A"]
    bestState = "A"
    if (dp[T,"B"] > bestFinal) {
        bestFinal = dp[T,"B"]
        bestState = "B"
    }

    # ----- BACKTRACK PATH -----
    path[T] = bestState
    for (t = T-1; t >= 1; t--) {
        path[t] = back[t+1, path[t+1]]
    }

    # ----- PRINT PATH -----
    print "\n=== Viterbi path ==="
    for (t = 1; t <= T; t++) {
        printf "t=%d  obs=%s  state=%s\n", t, obs[t], path[t]
    }

    print "\nFinal best state:", bestState, "  (score:", fmt(bestFinal) ")"
}
