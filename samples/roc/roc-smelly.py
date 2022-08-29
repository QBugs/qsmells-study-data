from qiskit import QuantumCircuit

qc = QuantumCircuit(3, 3) # 3 Quantum and 3 Classical registers

hadamard = QuantumCircuit(1, name='H')
hadamard.h(0)

measureQubit = QuantumCircuit(1, 1, name='M')
measureQubit.measure(0, 0)

for i in range(4):
  for j in range(3):
      qc.append(hadamard, [j])
  for j in range(3):
      qc.append(measureQubit, [j], [j])
  qc.barrier()



# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='roc-smelly.txt', justify='left')
qc.draw(output='latex_source', filename='roc-smelly.tex', justify='left')
qc.draw(output='mpl', filename='roc-smelly.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='roc-smelly-folded.pdf', justify='left')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'roc-smelly.csv')
