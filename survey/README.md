# Survey

The questions of the survey conducted in Section IV.E, in the associated paper, are listed in the [`survey-doc.pdf`](survey-doc.pdf) file.

The survey comprised 16 questions, a mix of multiple-choice and open-ended questions.  The survey included demographic questions and participant experiences with quantum programming.  Then, we showed the participants a quantum code snippet and its circuit draw and asked them to assess whether the snippet was affected by a specific code smell.  We asked one question per code smell (a total of eight), and at the end, we asked about participants' perceptions of the severity of these code smells.  Note that we did not ask participants for additional smells as that would require additional interviews and surveys to understand and validate the new smells, which was out of scope of the associated paper.

## Data

- The responses to survey's questions are reported in the [`data/responses.csv`](data/responses.csv) file.  The [`data/FILE-SPECS.md`](`data/FILE-SPECS.md`) defines the format of each column.

# Statistics

- [`statistics/results-per-smell-as-table.R`](statistics/results-per-smell-as-table.R) prints out a Latex table with the survey's results per smell metric, i.e., whether a user agreed, disagreed, did not know a snippet had a smell.  (Table II in the associated paper.)

Usage example:

```bash
Rscript results-per-smell-as-table.R \
  ../data/responses.csv \
  results-per-smell.tex
```

- [`statistics/severity-per-smell-as-table.R`](statistics/severity-per-smell-as-table.R) print out a Latex table with the average and median severity of each smell metric.  (Table III in the associated paper.)

Usage example:

```bash
Rscript severity-per-smell-as-table.R \
  ../data/responses.csv \
  severity-per-smell.tex
```
