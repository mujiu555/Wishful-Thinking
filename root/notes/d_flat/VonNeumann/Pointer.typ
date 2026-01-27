#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Pointer Specification]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann.typ")

A pointer in this virtual machine is a 64-bit unsigned integer that stored in the capture section of function unit.

The pointer uses 46 bits to address and 6 bits to identify the type of pointer, rest 12 bits are reserved for future use.
Address can be divided to two part: Pointer Base Address (PBA) and Segment.

```txt
0x
              00              08              10              18              20
                                                                              40
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
            => 3 3 3 3 3 3 3 3|4 4 4 4 4 4 4 4|4 4 5 5 5 5 5 5|5 5 5 5 6 6 6 6|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
            => 2 3 4 5 6 7 8 9|0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|
--------------------------------------------------------------------------------
              00                              10                              20
                                              30              38              40
Default       | Pointer Base Address                                          |
            =>  PBA(c.)       | Segment   | Type      |                       |
* VF <- VIF; VP <- VIP
```

Type field defines the type of pointer, following are all defined pointer types:
- Heap Pointer: type code `0x00`, point to heap allocated memory block.
- Stack Pointer: type code `0x01`, point to global data stack location.
- Function Pointer: type code `0x02`, point to function unit entry point.
- Text Pointer: type code `0x03`, point to text vector.
- Data Pointer: type code `0x04`, point to data section in function unit.
- Constant Pointer: type code `0x05`, point to constant section in function unit.
