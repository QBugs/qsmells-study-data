# Experiments

The `experiments` directory provide all scripts required to run [QSmell](https://github.com/jose/qsmell) on a single program or on all programs at once, and also provide [R](https://www.r-project.org) scripts to process and analyze the data generate by [QSmell](https://github.com/jose/qsmell).

## Scripts

- [`scripts/run-qsmell.sh`](scripts/run-qsmell.sh) runs [QSmell](https://github.com/jose/qsmell) on a single program (i.e., quantum circuit matrix, previous generated by the [`../subjects/scripts/get-quantum-circuit-as-a-matrix.sh`](../subjects/scripts/get-quantum-circuit-as-a-matrix.sh) script) and compute a single smell metric.

Usage

```bash
bash run-qsmell.sh
  --input_file_path <path, e.g., ../../subjects/data/generated/quantum-circuit-as-matrix/grover.csv or ../../tools/qiskit-terra/qiskit/algorithms/amplitude_amplifiers/grover.py>
  --smell_metric <str, name of the smell metric to compute: CG, ROC, NC, LC, IM, IdQ, IQ, AQ, LPQ>
  --output_file_path <path>
  [help]
```

for example, to run [QSmell](https://github.com/jose/qsmell) on `adapt_vqe` and compute `ROC` metric run

```bash
bash run-qsmell.sh \
  --input_file_path ../../subjects/data/generated/transpiled-quantum-circuit-as-matrix/grover.csv \
  --smell_metric "ROC" \
  --output_file_path ../data/generated/qsmell-metrics/ROC/grover/data.csv
```

which will generated the file `data/generated/qsmell-metrics/ROC/grover/data.csv` with the following content

```
name,runtime,metric,value
grover,1,ROC,1
```

Note: to ease the execution of [QSmell](https://github.com/jose/qsmell) on all programs and on all smell metrics, one could use the [`scripts/run-qsmell-on-all-subjects-all-metrics.sh`](scripts/run-qsmell-on-all-subjects-all-metrics.sh) script instead, which runs QSmell on all programs and computes all smell metrics, in parallel.

Usage

```bash
bash run-qsmell-on-all-subjects-all-metrics.sh
  [--subjects_file_path <path, e.g., ../../subjects/data/subjects.csv>]
  [--matrices_dir_path <path, e.g., ../../subjects/data/generated/quantum-circuit-as-matrix]
  [--transpiled_matrices_dir_path <path, e.g., ../../subjects/data/generated/transpiled-quantum-circuit-as-matrix]
  [--output_dir_path <path, e.g., ../data/generated/qsmell-metrics>]
  [help]
```

for example

```bash
bash run-qsmell-on-all-subjects-all-metrics.sh \
  --subjects_file_path ../../subjects/data/subjects.csv \
  --matrices_dir_path ../../subjects/data/generated/quantum-circuit-as-matrix \
  --transpiled_matrices_dir_path ../../subjects/data/generated/transpiled-quantum-circuit-as-matrix \
  --output_dir_path ../data/generated/qsmell-metrics
```

## Data

- [`data/peer-evaluation-subjects.csv`](data/peer-evaluation-subjects.csv), file automatically generated by the command
```bash
tail -n +2 ../subjects/data/subjects.csv | shuf | head -n2 | cut -f2 -d','
```
which lists the subjects (i.e., quantum programs) two authors of the associated paper got to manually compute each smell metric.

- [`data/generated/qsmell-metrics/data.csv`](data/generated/qsmell-metrics/data.csv), file automatically generated by the [`scripts/run-qsmell-on-all-subjects-all-metrics.sh`](scripts/run-qsmell-on-all-subjects-all-metrics.sh) script.  Note: this file aggregates all `data.csv` files under `data/generated/qsmell-metrics/<metric>/<name>/data.csv`, which are automatically generated by the [scripts/run-qsmell.sh](scripts/run-qsmell.sh) script.

- [`data/peer-evaluation-of-qsmell-v0.csv`](data/peer-evaluation-of-qsmell-v0.csv) and [`data/peer-evaluation-of-qsmell-v1.csv`](data/peer-evaluation-of-qsmell-v1.csv), files manually created by two authors (i.e., raters) of the associated paper.  The [`peer-evaluation-of-qsmell-v0.csv`](peer-evaluation-of-qsmell-v0.csv) file contains the first iteraction's data per author while computing the metric of each smell.  The [`peer-evaluation-of-qsmell-v1.csv`](peer-evaluation-of-qsmell-v1.csv) file contains the second iteraction's data, per author, after both met and reviewed all computed metrics.

## Statistics

- [`statistics/rater-a-vs-rater-b-inter-rater-reliability.R`](statistics/rater-a-vs-rater-b-inter-rater-reliability.R) computes the inter-rater reliability Cohen's Kappa (k) of Rater A vs. Rater B.  (See Section V.B.1 in the associated paper.)

- [`statistics/raters-vs-qsmell-metrics-as-table.R`](statistics/raters-vs-qsmell-metrics-as-table.R) prints out a Latex table with Rater A/B vs. QSmell data.  (See Section V.B.2 and Table IV in the associated paper.)

- [`statistics/raters-vs-qsmell-inter-rater-reliability-as-table.R`](`statistics/raters-vs-qsmell-inter-rater-reliability-as-table.R) performances inter-rater reliability Cohen's Kappa (k) of Rater A vs. QSmell and prints out it as a Latex table.  Note: although the generated table is not reported in the associated paper, some of the numbers in the table are (see Section V.B.2 in the associated paper).

- [`statistics/smell-metrics-as-table.R`](statistics/smell-metrics-as-table.R) prints out a Latex table with smell metrics info per program and per smell metric.  (See Table V in the associated paper.)
