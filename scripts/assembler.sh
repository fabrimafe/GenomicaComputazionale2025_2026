#!/usr/bin/env bash
# Tiny Greedy Assembler (toy demo)
# Usage: ./tiny_assembler.sh reads.txt [MIN_OVERLAP]
# - reads.txt: one read per line (FASTA headers '>' are ignored)
# - MIN_OVERLAP: minimal suffix-prefix overlap (default 1)
# Assumptions: no sequencing errors; all reads belong to one contig; no reverse-complements.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 reads.txt [MIN_OVERLAP]" >&2
  exit 1
fi

READS_FILE="$1"
MINOV="${2:-1}"

# Read sequences: skip empty lines and FASTA headers, strip whitespace
mapfile -t seqs < <(grep -v '^[[:space:]]*$' "$READS_FILE" \
                    | sed 's/[[:space:]]//g' \
                    | grep -v '^>')

if ((${#seqs[@]} == 0)); then
  echo "No reads found." >&2
  exit 1
fi

# Return max suffix-prefix overlap length between a and b (>= MINOV), else 0
overlap_len() {
  local a="$1" b="$2"
  local la=${#a} lb=${#b}
  local max=$(( la < lb ? la : lb ))
  local k
  for ((k=max; k>=MINOV; k--)); do
    if [[ "${a: -k}" == "${b:0:k}" ]]; then
      echo "$k"
      return
    fi
  done
  echo 0
}

# Greedy merge loop: while more than one sequence remains
while ((${#seqs[@]} > 1)); do
  local_best=0
  best_i=-1
  best_j=-1

  # Find ordered pair (i->j) with the largest overlap
  for ((i=0; i<${#seqs[@]}; i++)); do
    for ((j=0; j<${#seqs[@]}; j++)); do
      (( i == j )) && continue
      ol=$(overlap_len "${seqs[i]}" "${seqs[j]}")
      if (( ol > local_best )); then
        local_best=$ol
        best_i=$i
        best_j=$j
      fi
    done
  done

  # If no overlap >= MINOV, just concatenate first two to make progress
  if (( best_i == -1 )); then
    best_i=0; best_j=1; local_best=0
  fi

  # Merge best_i -> best_j
  a="${seqs[best_i]}"
  b="${seqs[best_j]}"
  merged="${a}${b:local_best}"

  # Replace i with merged, remove j (careful: delete higher index first)
  if (( best_i < best_j )); then
    seqs[$best_i]="$merged"
    seqs=("${seqs[@]:0:best_j}" "${seqs[@]:best_j+1}")
  else
    seqs[$best_j]="$merged"
    seqs=("${seqs[@]:0:best_i}" "${seqs[@]:best_i+1}")
  fi
done

# Output final contig
echo "${seqs[0]}"

