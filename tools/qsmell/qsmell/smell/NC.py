""" Non-parameterized circuit (NC) """

import sys
import ast
import pandas as pd
from .ISmell import *

class NC(ISmell):

    def __init__(self):
        super().__init__("NC")

    def compute_metric(self, tree: ast.Module, output_file_path: str) -> None:
        # Are there any loops in the program?  If so, where are they?
        loops_lines = []
        for node in ast.walk(tree):
            if isinstance(node, ast.For) or isinstance(node, ast.While):
                loop_start = node.lineno
                # Body attribute is a list of nodes, one for each line in the loop
                # the lineno of the last node gives the ending line
                loop_end = node.body[-1].lineno
                # Keep track of all lines between starting and ending lines for current loop
                loops_lines.extend(range(loop_start, loop_end+1))

        num_executions = 0

        for node in ast.walk(tree):
            print(ast.dump(node)) # debug

            if isinstance(node, ast.Call):
                # Call(func=Name(id='execute', ctx=Load()), args=[Name(id='qc', ctx=Load()), Name(id='backend', ctx=Load())], keywords=[])
                func = node.func
                args = node.args

                if isinstance(func, ast.Name):
                    id = func.id
                    if id == 'execute' and len(args) >= 2:
                        print(ast.dump(node)) # debug
                        print('  Found a function call at line %d' %(node.lineno))
                        num_executions += 1
                        if node.lineno in loops_lines: # Is the call to the execute method within a loop?
                            num_executions += 1 # This assumes lines in a loop are executed at least twice
            elif isinstance(node, ast.Expr):
                # Expr(value=Call(func=Attribute(value=Name(id='backend', ctx=Load()), attr='run', ctx=Load()), args=[Name(id='qc', ctx=Load())], keywords=[]))
                value = node.value

                if isinstance(value, ast.Call):
                    func = value.func
                    args = value.args

                    if isinstance(func, ast.Attribute):
                        attr = func.attr
                        if attr == 'run' and len(args) >= 1:
                            print('  Found a expression call at line %d' %(node.lineno))
                            num_executions += 1
                            if node.lineno in loops_lines: # Is the call to the run method within a loop?
                                num_executions += 1 # This assumes lines in a loop are executed at least twice

        metrics = {
            'metric': self._name,
            'value': num_executions
        }

        out_df = pd.DataFrame.from_dict([metrics])
        sys.stdout.write(str(out_df) + '\n')
        out_df.to_csv(output_file_path, header=True, index=False, mode='w')
