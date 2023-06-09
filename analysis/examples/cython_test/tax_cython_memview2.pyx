cimport cython


cdef double calculate_tax(double income):
    cdef double tax, tax_income

    # Personfradrag, http://www.skatteetaten.no/no/Tabeller-og-satser/Personfradrag/
    # Minstefradrag, http://www.skatteetaten.no/no/Tabeller-og-satser/Minstefradrag/
    tax_income = income - 53_150 - 31_800
    if tax_income < 0:
        tax_income = 0

    # Alminnelig inntekt, http://www.skatteetaten.no/no/Tabeller-og-satser/Alminnelig-inntekt/
    tax = 0.24 * tax_income

    # Trinnskatt, http://www.skatteetaten.no/no/Tabeller-og-satser/trinnskatt/
    if tax_income >= 934_050:
        tax += 0.1452 * (tax_income - 934_050) + 49_761.155
    elif tax_income >= 580_650:
        tax += 0.1152 * (tax_income - 580_650) + 9_049.475
    elif tax_income >= 230_950:
        tax += 0.0241 * (tax_income - 230_950) + 621.705
    elif tax_income >= 164_100:
        tax += 0.0093 * (tax_income - 164_100)

    return tax


@cython.boundscheck(False)
@cython.wraparound(False)
cdef double[:] calculate_pop_tax_cy(double[:] income_np):
    cdef int num_pop = income_np.shape[0]
    cdef double[:] taxes = income_np
    cdef int i

    for i in range(num_pop):
        taxes[i] = calculate_tax(income_np[i])

    return taxes


def calculate_pop_tax(income_np):
    return calculate_pop_tax_cy(income_np)