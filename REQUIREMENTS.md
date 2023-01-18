# Requirements

This markdown file focus on the requirements of any software or script available or used in the artifact (i.e., repository).

1. A Unix-based machine

Any bash command, tool, or script available or used in this repository has been tested on a Unix-based machine and therefore might not work on other operating systems, e.g., Windows.

2. [GIT](https://git-scm.com) and [GNU wget](https://www.gnu.org/software/wget)

To be able to automatically get the required artefacts, e.g., to get Qiskit's repositories with the quantum subjects source code, [GIT](https://git-scm.com) and [GNU wget](https://www.gnu.org/software/wget) must be installed and available on your machine.  To assess whether both programs are installed and available, please run the following commands

```bash
(git  --version > /dev/null 2>&1 && echo "git is installed and available")  || echo "ERROR: git is not installed or available" # (< 1 second)
(wget --version > /dev/null 2>&1 && echo "wget is installed and available") || echo "ERROR: wget is not installed or available" # (< 1 second)
```

In case either [GIT](https://git-scm.com) or [GNU wget](https://www.gnu.org/software/wget) is not installed, please visit the its' official webpage and follow the installation instructions.

3. [Perl](https://www.perl.org)

<!-- TODO. -->  To assess whether it is installed and available, please run the following command

```bash
(perl --version > /dev/null 2>&1 && echo "perl is installed and available") || echo "ERROR: perl is not installed or available" # (< 1 second)
```

In case either [Perl](https://www.perl.org) is not installed, please visit the it's official webpage and follow the installation instructions.

4. [GNU Parallel](https://www.gnu.org/software/parallel)

<!-- TODO. --> to parallelize experiments.  To assess whether it is installed and available, please run the following command

```bash
(parallel --version > /dev/null 2>&1 && echo "parallel is installed and available") || echo "ERROR: parallel is not installed or available" # (< 1 second)
```

In case either [GNU Parallel](https://www.gnu.org/software/parallel) is not installed, please visit the it's official webpage and follow the installation instructions.

5. [R](https://www.r-project.org)

To be able to automatically run any statistical analysis, [R](https://www.r-project.org) must be installed and available on your machine.  To assess whether it is installed and available, please run the following command

```bash
(Rscript --version > /dev/null 2>&1 && echo "R is installed and available") || echo "ERROR: R is not installed or available" # (< 1 second)
```

In case either [R](https://www.r-project.org) is not installed, please visit the it's official webpage and follow the installation instructions.
