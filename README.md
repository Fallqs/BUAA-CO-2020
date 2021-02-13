This project attempts to simplify CPU structure with no performance decline. It achieved a 30%+ code decrease formulating a typical MIPS Pipeline CPU compared to the recommended method in BUAA CO Lab 2020 at the very first version.

The main idea is to accomplish everything with address instead of explicitly defined multiplexers. 

- Bit extender, IFU(instruction fetch unit) instruction, and write-back PC(program counter) are merged into GRF(general register file) for approaches using address.
- The data path is assembled by an independent unit PM(path manager), which takes over almost every plugin of the other components. The memory-like inside makes simplicity and high efficiency.
- More details available in the source code and design note of every sub project.

