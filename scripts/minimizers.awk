# minimizers.awk
# Calculate minimizers for a string using the alphabetic order. It can take different k-mer lengths and window length as variables k and w.
# As output it prints "position<TAB>kmer" for each window
# Usage: echo "ACGTCGATGAC" | awk -v k=3 -v w=4 -f minimizers.awk
# Written for the course Genomica Computazionale 2025/2026 at the University of Trieste, Fabrizio Mafessoni.

NR == 1 {
    seq = $1
    n = length(seq)

    n_kmer = n - k + 1
    if (n_kmer <= 0 || w <= 0 || w > n_kmer) {
        exit
    }

    # 1) Precompute all k-mers (1-based indices in awk)
    for (i = 1; i <= n_kmer; i++) {
        kmer[i] = substr(seq, i, k)
    }

    # 2) Slide window of size w over k-mers
    num_windows = n_kmer - w + 1
    for (start = 1; start <= num_windows; start++) {

        # Initialize min with first k-mer in window
        min_kmer = kmer[start]
        min_pos  = start

        # Look at the rest of the window
        for (j = start + 1; j <= start + w - 1; j++) {
            if (kmer[j] < min_kmer) {
                min_kmer = kmer[j]
                min_pos  = j
            }
        }

        # min_pos is 1-based index of the first base of the minimizer in seq
        printf "%d\t%s\n", min_pos, min_kmer
    }
}

