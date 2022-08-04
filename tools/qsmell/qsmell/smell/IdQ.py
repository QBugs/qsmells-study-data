""" Idle qubits (IdQ) """

import sys
import pandas as pd
from .ISmell import *

class IdQ(ISmell):

    def __init__(self):
        super().__init__("IdQ")

    def compute_metric(self, df: pd.DataFrame, output_file_path: str) -> None:
        qubits = [bit for bit in df.index if bit.startswith('q-')]
        stamps = df.columns

        metrics = {
            'qubit': [],
            'max_num_ops_idle': []
        }

        for qubit in qubits:
            max_num_ops_in_between = 0
            count = -1
            for stamp in stamps:
                op = df.loc[qubit][stamp]
                if op == 'barrier()':
                    op = ''

                if op == '' and count == -1:
                    # The first operation on qubit has not been found yet
                    pass
                elif op != '' and count == -1:
                    # Found the first operation on qubit
                    count = 0
                elif op != '' and count != -1:
                    # Found the second, or third, ... operation on qubit
                    max_num_ops_in_between = max(max_num_ops_in_between, count)
                    count = 0 # Reset counter
                elif op == '' and count != -1:
                    # Empty operation in between
                    count += 1

            metrics['qubit'].append(qubit)
            metrics['max_num_ops_idle'].append(max_num_ops_in_between)

        out_df = pd.DataFrame.from_dict(metrics)
        sys.stdout.write(str(out_df) + '\n')
        out_df.to_csv(output_file_path, header=True, index=False, mode='w')
