from qiskit import QuantumCircuit

qc = QuantumCircuit(3)
qc.ccx(0, 1, 2)

# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='cg-fixed.txt', justify='left')
qc.draw(output='latex_source', filename='cg-fixed.tex', justify='left')
qc.draw(output='mpl', filename='cg-fixed.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='cg-fixed-folded.pdf', justify='left')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'cg-fixed.csv')
