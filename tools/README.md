# Tools required to run experiments and/or data analysis

- The [`get-tools.sh`](get-tools.sh) script is responsible for automatically
  - Assessing whether the requirements described in [REQUIREMENTS.md](REQUIREMENTS.md) are fulfilled.
  - Cloning Qiskit's repositories to the top-level directory [`tools/`](tools/):
    * [terra (v0.21.0)](https://github.com/Qiskit/qiskit-terra.git)
    * [machine-learning (v0.4.0)](https://github.com/Qiskit/qiskit-machine-learning.git)
    * [nature (v0.4.3)](https://github.com/Qiskit/qiskit-nature.git)
  - Installing a specific version of Python (i.e., v3.7.8) in the top-level directory [`tools/`](tools/).
  - Configuring an isolated Python environment, in the top-level directory [`tools/`](tools/), to run any Python code, e.g., the [QSmell](https://github.com/jose/qsmell) tool.  We achieve this with a combination of [Simple Python Version Management: pyenv](https://github.com/pyenv/pyenv) and [Virtualenv](https://virtualenv.pypa.io).
  - Cloning and installing [QSmell v0.0.1](https://github.com/jose/qsmell) in the isolated Python environment.
  - Installing the following [R](https://www.r-project.org)'s packages under user's R's library directory through the [`get-libraries.R`](get-libraries.R) script:
    * [data.table: Extension of 'data.frame'](https://cran.r-project.org/web/packages/data.table/index.html)
    * [stringr: Simple, Consistent Wrappers for Common String Operations](https://cran.r-project.org/web/packages/stringr/index.html)
    * [irr: Various Coefficients of Interrater Reliability and Agreement](https://cran.r-project.org/web/packages/irr/index.html)
    * [caret: Classification and Regression Training](https://cran.r-project.org/web/packages/caret/index.html)

and it can be executed as

```bash
bash get-tools.sh # (~10 minutes)
```

In case the execution does not finished successfully, the script will print out a message informing the user of the error.  One should follow the instructions to fix the error and re-run the script.  In case the execution of the script finished successfully, one should see the message `DONE! All tools have been successfully installed and configured.` on the stdout.

- QSmell's source code lives in the [`qsmell`](qsmell/) directory.
