# Subjects

To select representative quantum projects, we started by doing a keyword search using the GitHub search API.  We searched for the projects with a description or a topic that contains the word "quantum computing".

We scoped our search to analyze projects written in Python and that use the Qiskit library for two main reasons.  First, Qiskit is one of the most popular quantum computation libraries.  Second, our tool QSmell only supports Qiskit's API.  To do so, we searched for projects with the word `qiskit` and `import qiskit`.  This resulted in identifying 628 unique quantum projects.

Next, we filtered the projects following the guidelines proposed by others.  Specifically, we selected projects based on their number of commits in 2022, their total number of commits, and their number of contributors.  These three criteria ensure that we identify the most active projects, remove the abandoned projects, and filter out the quantum computing projects related to documentation, lecture notes, and student assignments.  We keep projects with at least 100 commits to ensure that they have sufficient development activity and to avoid student assignments.  Next, we selected projects with at least 17 commits in 2022 to remove the abandoned and inactive projects.  We retained projects with more than one contributor to avoid selecting toy projects.  This procedure resulted in 21 projects:

- Qiskit/qiskit-terra
- PennyLaneAI/pennylane
- Qiskit/qiskit-metal
- Qiskit/qiskit-aqua
- Qiskit/qiskit-nature
- Qiskit/qiskit-experiments
- Qiskit/qiskit-dynamics
- Qiskit/qiskit-ibmq-provider
- Qiskit/qiskit-ibm-runtime
- Qiskit/qiskit-optimization
- qiskit-community/qiskit-qec
- Qiskit/qiskit-ibm-provider
- unitaryfund/mitiq
- Qiskit/qiskit-ignis
- Qiskit/qiskit-machine-learning
- QuTech-Delft/quantuminspire
- Qiskit/qiskit-ibm-experiment
- PennyLaneAI/pennylane-qiskit
- Qiskit-Partners/qiskit-dell-runtime
- Qiskit/qiskit-finance
- Qiskit-Partners/qiskit-ionq

Next, we manually inspected the remaining projects and discarded projects related to documentation, lecture notes, and hardware platforms.  Finally, we ended up with a total of 3 projects:
- [qiskit-machine-learning](https://github.com/Qiskit/qiskit-machine-learning)
- [qiskit-terra](https://github.com/Qiskit/qiskit-terra)
- [qiskit-nature](https://github.com/Qiskit/qiskit-nature).
We then collected all quantum programs, also known as quantum algorithms, available in each project.  The `[data/subjects.csv](data/subjects.csv)` file lists all quantum programs selected for the study.

| Name | # LOC | # Qubits | # Clbits | # Operations |
|:-----|------:|---------:|---------:|-------------:|
| (qiskit-machine-learning) qgan | 293 | 2 | 0 | 4 |
| (qiskit-machine-learning) qsvc | 40 | 2 | 0 | 10 |
| (qiskit-machine-learning) vqc | 105 | 2 | 0 | 13 |
| (qiskit-nature) adapt_vqe | 238 | 4 | 0 | 128 |
| (qiskit-nature) qeom | 371 | 4 | 0 | 50 |
| (qiskit-terra) ae | 290 | 6 | 5 | 868 |
| (qiskit-terra) fae | 173 | 2 | 2 | 33 |
| (qiskit-terra) grover | 145 | 2 | 0 | 21 |
| (qiskit-terra) hhl | 278 | 2 | 0 | 4 |
| (qiskit-terra) iae | 298 | 1 | 1 | 43 |
| (qiskit-terra) ipe | 91 | 1 | 0 | 1 |
| (qiskit-terra) mlae | 297 | 1 | 1 | 131 |
| (qiskit-terra) phase_estimation | 104 | 1 | 0 | 1 |
| (qiskit-terra) qaoa | 60 | 2 | 0 | 3 |
| (qiskit-terra) shor | 291 | 18 | 8 | 17887 |
| (qiskit-terra) vqd | 430 | 2 | 0 | 5 |
| (qiskit-terra) vqe | 381 | 2 | 0 | 5 |
| *Median* | 278.00 | 2.00 | 0.00 | 13.00 |
| *Average* | 228.53 | 3.18 | 1.00 | 1129.82 |

## Scripts

- [`scripts/get-locs.sh`](scripts/get-locs.sh), collects the number lines of code in quantum programs.

```bash
bash get-locs.sh
  [--subjects_file_path <path, e.g., ../data/subjects.csv>]
  [--output_file_path <path, e.g., ../data/generated/subjects-locs.csv>]
  [help]
```

for example

```bash
bash get-locs.sh \
  --subjects_file_path ../data/subjects.csv \
  --output_file_path ../data/generated/subjects-locs.csv
```

- [`scripts/get-quantum-circuit-as-a-draw.sh`](scripts/get-quantum-circuit-as-a-draw.sh)

```bash
bash get-quantum-circuit-as-a-draw.sh
  --wrapper_name <name of the wrapper program to load and analyze, e.g., grover>
  [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-draw>]
  [help]
```

for example

```bash
bash get-quantum-circuit-as-a-draw.sh \
  --wrapper_name grover \
  --output_dir_path <path, e.g., ../data/generated/transpiled-quantum-circuit-as-draw
```

- [`scripts/get-quantum-circuit-as-a-matrix.sh`](scripts/get-quantum-circuit-as-a-matrix.sh) processes a quantum circuit and produces a matrix where each row represents a quantum or a classic bit, each column represents a timestamp in the circuit, and each cell represents a quantum operation performed in th circuit.

```bash
bash get-quantum-circuit-as-a-matrix.sh
  --wrapper_name <name of the wrapper program to load and analyze, e.g., grover>
  [--transpile <bool, false by default>]
  [--output_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>]
  [help]
```

for example

```bash
bash get-quantum-circuit-as-a-matrix.sh \
  --wrapper_name grover \
  --transpile "true" \
  --output_dir_path ../data/generated/transpiled-quantum-circuit-as-matrix
```

- [`scripts/get-matrices-data.sh`](scripts/get-matrices-data.sh) parses all quantum matrices (previous generated by the `get-quantum-circuit-as-a-matrix.sh` script) and collects the following information of each matrix: number of qubits, number of clbits, number of operations performed in the circuit.

```bash
bash get-matrices-data.sh
  [--subjects_file_path <path, e.g., ../data/subjects.csv>]
  [--matrices_dir_path <path, e.g., ../data/generated/quantum-circuit-as-matrix>]
  [--output_file_path <path, e.g., ../data/generated/matrices-data.csv>]
  [help]
```

for example

```bash
bash get-matrices-data.sh
  --subjects_file_path ../data/subjects.csv \
  --matrices_dir_path ../data/generated/quantum-circuit-as-matrix \
  --output_file_path ../data/generated/matrices-data.csv
```

## Data

- [`data/subjects.csv`](data/subjects.csv), set of quantum programs / algorithms from the [Qiskit framework](https://github.com/Qiskit).

- [`data/generated/subjects-locs.csv`](data/generated/subjects-locs.csv), file automatically generated by the [`scripts/get-locs.sh`](scripts/get-locs.sh) script.

- [`data/generated/matrices-data.csv`](data/generated/matrices-data.csv) and [`data/generated/transpiled-matrices-data.csv`](data/generated/transpiled-matrices-data.csv), files automatically generated by the [`scripts/get-matrices-data.sh`](scripts/get-matrices-data.sh) script.

- [`data/generated/quantum-circuit-as-matrix`](data/generated/quantum-circuit-as-matrix) and [`data/generated/transpiled-quantum-circuit-as-matrix`](data/generated/transpiled-quantum-circuit-as-matrix) directories automatically generated by the [`scripts/get-quantum-circuit-as-a-matrix.sh`](scripts/get-quantum-circuit-as-a-matrix.sh) script.

- [`data/generated/transpiled-quantum-circuit-as-draw`](data/generated/transpiled-quantum-circuit-as-draw) directory automatically generated by the [`scripts/get-quantum-circuit-as-a-draw.sh`](scripts/get-quantum-circuit-as-a-draw.sh) script.

## Statistics

- [`statistics/subjects-as-table.R`](statistics/subjects-as-table.R) prints out a Latex table with info of each software under test (i.e., quantum program) used in the experiments.

Usage example

```bash
Rscript subjects-as-table.R subjects.tex
```

which generates the following Latex table

```
\begin{tabular}{@{\extracolsep{\fill}} l rrrr} \toprule
Name & \# LOC & \# Qubits & \# Clbits & \# Operations \\
\midrule
(qiskit-machine-learning) qgan & 293 & 2 & 0 & 4 \\
(qiskit-machine-learning) qsvc & 40 & 2 & 0 & 10 \\
(qiskit-machine-learning) vqc & 105 & 2 & 0 & 13 \\
(qiskit-nature) adapt\_vqe & 238 & 4 & 0 & 128 \\
(qiskit-nature) qeom & 371 & 4 & 0 & 50 \\
(qiskit-terra) ae & 290 & 6 & 5 & 868 \\
(qiskit-terra) fae & 173 & 2 & 2 & 33 \\
(qiskit-terra) grover & 145 & 2 & 0 & 21 \\
(qiskit-terra) hhl & 278 & 2 & 0 & 4 \\
(qiskit-terra) iae & 298 & 1 & 1 & 43 \\
(qiskit-terra) ipe & 91 & 1 & 0 & 1 \\
(qiskit-terra) mlae & 297 & 1 & 1 & 131 \\
(qiskit-terra) phase\_estimation & 104 & 1 & 0 & 1 \\
(qiskit-terra) qaoa & 60 & 2 & 0 & 3 \\
(qiskit-terra) shor & 291 & 18 & 8 & 17887 \\
(qiskit-terra) vqd & 430 & 2 & 0 & 5 \\
(qiskit-terra) vqe & 381 & 2 & 0 & 5 \\
\midrule
\textit{Median} & 278.00 & 2.00 & 0.00 & 13.00 \\
\textit{Average} & 228.53 & 3.18 & 1.00 & 1129.82 \\
\bottomrule
\end{tabular}
```
