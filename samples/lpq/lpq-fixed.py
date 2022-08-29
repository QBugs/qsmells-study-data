from qiskit import QuantumCircuit, transpile
from qiskit.providers.fake_provider import FakeVigo
backend = FakeVigo()

qc = QuantumCircuit(3, 3)
qc.h(0)
qc.cx(0,range(1,3))
qc.barrier()
qc.measure(range(3), range(3))
qc = transpile(qc, backend, initial_layout=[3, 4, 2])

# ------------------------------------------------------------------------------

# Draw
qc.draw(output='text', filename='lpq-fixed.txt', justify='left')
qc.draw(output='latex_source', filename='lpq-fixed.tex', justify='left')
qc.draw(output='mpl', filename='lpq-fixed.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='lpq-fixed-folded.pdf', justify='left')

from qiskit.visualization import plot_circuit_layout
fig = plot_circuit_layout(qc, backend, view='virtual')
fig.savefig('lpq-fixed-virtual-circuit.pdf')
fig = plot_circuit_layout(qc, backend, view='physical')
fig.savefig('lpq-fixed-physical-circuit.pdf')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'lpq-fixed.csv')
