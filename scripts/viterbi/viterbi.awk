BEGIN {
    # STATES
    states[1] = "A"
    states[2] = "B"

    # INITIAL PROBABILITIES
    pi["A"] = 0.5
    pi["B"] = 0.5

    # TRANSITIONS
    a["A","A"] = 0.9;  a["A","B"] = 0.1
    a["B","A"] = 0.5;  a["B","B"] = 0.5

    # EMISSIONS
    e["A","X"] = 0.02; e["A","Y"] = 0.98
    e["B","X"] = 0.8;  e["B","Y"] = 0.2
}

# Read observation sequence
{
    T++
    obs[T] = $1
}

END {
    if (T == 0) {
        print "No observations!"
        exit 1
    }

    # INITIALIZATION
    for (i in states) {
        s = states[i]
        dp[1,s]   = pi[s] * e[s,obs[1]]
        back[1,s] = "START"
    }

    # RECURSION
    for (t = 2; t <= T; t++) {
        o = obs[t]
        for (i in states) {
            curr = states[i]
            bestP = -1
            bestPrev = ""
            for (j in states) {
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

    # TERMINATION
    bestFinal = -1
    bestState = ""
    for (i in states) {
        s = states[i]
        if (dp[T,s] > bestFinal) {
            bestFinal = dp[T,s]
            bestState = s
        }
    }

    # BACKTRACK
    path[T] = bestState
    for (t = T-1; t >= 1; t--) {
        path[t] = back[t+1, path[t+1]]
    }

    # OUTPUT
    for (t = 1; t <= T; t++) {
        printf "%s\t%s\n", obs[t], path[t]
    }
}
