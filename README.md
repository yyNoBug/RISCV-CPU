# RISCV-CPU

A RISCV CPU with 5-stage pipeline.



## Test performance (Icahe Version on FPGA)

|      Name      | Passed |
| :------------: | :----: |
|  array_test1   |   P    |
|  array_test2   |   P    |
|   basicopt1    |   P    |
|   bulgarian    |   P*   |
|      expr      |   P    |
|      gcd       |   P    |
|     hanoi      |   P*   |
|    lvalue2     |   P    |
|     magic      |   P*   |
| manyarguments  |   P    |
|   multiarray   |   P    |
|       pi       |   P    |
|     qsort      |   P*   |
|     queens     |   P    |
| statement_test |   P*   |
|   superloop    |   P    |
|      tak       |   P    |



## Test performance (Dcahe Version on FPGA)

|      Name      | Passed |
| :------------: | :----: |
|  array_test1   |   F    |
|  array_test2   |   F    |
|   basicopt1    |   U    |
|   bulgarian    |   U    |
|      expr      |   U    |
|      gcd       |   U    |
|     hanoi      |   F    |
|    lvalue2     |   U    |
|     magic      |   P    |
| manyarguments  |   F    |
|   multiarray   |   F    |
|       pi       |   P    |
|     qsort      |   F    |
|     queens     |   U    |
| statement_test |   F    |
|   superloop    |   F    |
|      tak       |   F    |



## Test performance (Pred Version not on FPGA)

|      Name      | Passed |
| :------------: | :----: |
|  array_test1   |   U    |
|  array_test2   |   U    |
|   basicopt1    |   P    |
|   bulgarian    |   P    |
|      expr      |   P    |
|      gcd       |   P    |
|     hanoi      |   U    |
|    lvalue2     |   U    |
|     magic      |   P    |
| manyarguments  |   U    |
|   multiarray   |   U    |
|       pi       |   U    |
|     qsort      |   F    |
|     queens     |   P    |
| statement_test |   U    |
|   superloop    |   U    |
|      tak       |   U    |