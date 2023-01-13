
# Clique size (CHANGE THIS)
d = 3


def generate_partitions(lower, upper, total):
    """
    Generator function that generates all partitions of the form
        lower <= s_1 < t_1 <= ... <= t_n < s_n <= upper
    such that (t_1 - s_1) + ... + (t_n - s_n).
    """

    # Impossible case: yield no partitions
    if upper - lower < total:
        return

    # Base case: yield empty partition
    if total == 0:
        yield []

    # Chooses s_1, t_1 such that lower <= s_1 < t_1 <= upper and t_1 - s_1 <= total.
    # Then uses recursion to choose remaining s_i and t_i.
    for s_1 in range(lower, upper - total + 1):
        for t_1 in range(s_1 + 1, min(s_1 + total + 1, upper + 1)):
            partitions = generate_partitions(
                t_1, upper, total - (t_1 - s_1))
            for partition in partitions:
                yield [(s_1, t_1)] + partition


if __name__ == '__main__':
    # Variables
    z = var('z')
    l = [var('l_' + str(i)) for i in range(0, d)]
    l.append(0)  # l[d] = 0

    # N_{m, k}
    N = {}
    for m in range(1, d + 1):
        N[(m, m)] = 1
        N[(m, m - 1)] = l[m - 1] - l[m] - 1
        for k in range(0, m - 1):
            N[(m, k)] = prod([l[j] for j in range(k + 1, m)]) * sum([
                binomial(m - k, j - k) * ((-1) ^ (j - k)) * l[j]
                for j in range(k, m + 1)
            ])

    # M_{i, j}
    M = {}
    for i in range(0, d + 1):
        for j in range(0, i + 1):
            M[(i, j)] = 0

            partitions = generate_partitions(j, d, i - j)
            for partition in partitions:
                n = len(partition)
                M[(i, j)] += (-1) ** n * prod([
                    binomial(t, s) for (s, t) in partition
                ]) * prod([
                    N[(t, s)] for (s, t) in partition
                ])

    # Geodesic growth
    numerator = sum([
        sum([
            prod(l[:j]) * M[(i, j)]
            for j in range(0, i + 1)
        ]) * (z ** i)
        for i in range(0, d + 1)
    ])
    numerator = numerator.expand().collect(z)  # Simplify
    denominator = sum([
        M[(i, 0)] * (z ** i)
        for i in range(0, d + 1)
    ])
    denominator = denominator.expand().collect(z)  # Simplify

    print('Numerator: ' + str(numerator))
    print('Denominator: ' + str(denominator))
