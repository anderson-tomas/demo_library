# demo_library
To demo how to use a static library and dynamic library

# [Record] How to build and use static library and dynamic library in linux
###### tags: `static library`,`dynamic library`, `.so`, `compile`, `link`

[toc]

## Preface
Here, we are going to demo how to build or create a static library and a dynamic library, and how to use them with our application.

Asume we want to access a register by reading or writing it.
First, we implement the library which includes a get and set function. The get function will read a value from a file, and the set function will set a value to the file. The value of a register is stored in a file. Second, we implement the application to call API from this library.

Finally, we compile both the library and application and link them them together.

## Source code
### File tree
The library is named regapi with a c file and a header as shown below. And the application is named main.c.
![](https://hackmd.io/_uploads/H1QnXYMfT.png)

### Library
We declare a global and two functions which are get and set.
```c 
Tomas# cat regapi/include/regapi.h

#ifndef __REGAPI_H__
#define __REGAPI_H__
#include <stdio.h>
#include <stdlib.h>

#define REG_FILE "reg.txt"

int regget();
void regset(int x);
#endif


Tomas# cat cat regapi/src/regapi.c

#include "regapi.h"

int regget() {
    FILE *file = fopen(REG_FILE, "r"); // Open the file for writing
    char buffer[1024];

    if (file == NULL) {
        perror("Error opening the file");
        printf("Call %s to get the default reg value 666\n", __func__);
        return 1;
    }
    // Read the string from the file
    if (fgets(buffer, sizeof(buffer), file) != NULL) {
        printf("Call %s to get reg value %s\n", __func__, buffer);
    }
    // Close the file
    fclose(file);
    return atoi(buffer);
}

void regset(int val) {
    FILE *file = fopen(REG_FILE, "w"); // Open the file for writing

    if (file == NULL) {
        perror("Error opening the file");
        return;
    }
    printf("Call %s to set reg value %d\n", __func__, val);
    // Write the string to the file
    fprintf(file, "%d", val);
}
```

### Application
```c
Tomas# cat main.c

#include <stdio.h>
#include <stdlib.h> // Include for atoi
#include <string.h> // Include for strcmp
#include "regapi.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s [get | set <value>]\n", argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "get") == 0) {
        printf("get reg value: %d\n", regget());
    } else if (strcmp(argv[1], "set") == 0) {
        if (argc < 3) {
            printf("Usage: %s set <value>\n", argv[0]);
            return 1;
        }
        int value = atoi(argv[2]);
        printf("set reg value to %d\n", value);
        regset(value);
    } else {
        printf("Invalid command. Usage: %s [get | set <value>]\n", argv[0]);
        return 1;
    }

    return 0;
}
```

## Static library
1. Compile the regapi.c to an object by gcc.
```shell 
Tomas# gcc -c regapi/src/regapi.c -Iregapi/include/

Tomas# ls -al regapi.o
-rw-rw-r--  1 tomas tomas 3088  十  22 19:53 regapi.o
```
![](https://hackmd.io/_uploads/ByNraFzGT.png)

2. Create a static library and replace the object by ar. 
```shell 
Tomas# ar rcs libregapi.a regapi.o

Tomas# ls -al libregapi.a
-rw-rw-r-- 1 tomas tomas 3242  十  22 19:55 libregapi.a
```

3. Check symbols in library by nm
```shell 
Tomas# nm libregapi.a
regapi.o:
                 U atoi
                 U fclose
                 U fgets
                 U fopen
                 U fprintf
0000000000000091 r __func__.2837
0000000000000098 r __func__.2842
                 U _GLOBAL_OFFSET_TABLE_
                 U perror
                 U printf
0000000000000000 T regget
00000000000000e3 T regset
                 U __stack_chk_fail
```

:::spoiler
ar --h
Usage: ar [emulation options] [-]{dmpqrstx}[abcDfilMNoOPsSTuvV] [--plugin <name>] [member-name] [count] archive-file file...
       ar -M [<mri-script]
 commands:
  d            - delete file(s) from the archive
  m[ab]        - move file(s) in the archive
  p            - print file(s) found in the archive
  q[f]         - quick append file(s) to the archive
  r[ab][f][u]  - replace existing or insert new file(s) into the archive
  s            - act as ranlib
  t[O][v]      - display contents of the archive
  x[o]         - extract file(s) from the archive
 command specific modifiers:
  [a]          - put file(s) after [member-name]
  [b]          - put file(s) before [member-name] (same as [i])
  [D]          - use zero for timestamps and uids/gids (default)
  [U]          - use actual timestamps and uids/gids
  [N]          - use instance [count] of name
  [f]          - truncate inserted file names
  [P]          - use full path names when matching
  [o]          - preserve original dates
  [O]          - display offsets of files in the archive
  [u]          - only replace files that are newer than current archive contents
 generic modifiers:
  [c]          - do not warn if the library had to be created
  [s]          - create an archive index (cf. ranlib)
  [S]          - do not build a symbol table
  [T]          - make a thin archive
  [v]          - be verbose
  [V]          - display the version number
  @<file>      - read options from <file>
  --target=BFDNAME - specify the target object format as BFDNAME
  --output=DIRNAME - specify the output directory for extraction operations
 optional:
  --plugin <p> - load the specified plugin
 emulation options:
  No emulation specific options
ar: supported targets: elf64-x86-64 elf32-i386 elf32-iamcu elf32-x86-64 pei-i386 pei-x86-64 elf64-l1om elf64-k1om elf64-little elf64-big elf32-little elf32-big pe-x86-64 pe-bigobj-x86-64 pe-i386 srec symbolsrec verilog tekhex binary ihex plugin
Report bugs to <http://www.sourceware.org/bugzilla/>
:::


### Build the application and link it with a static library

1. Compile the application as hello and link it with libregapi.a

```shell
Tomas# gcc main.c libregapi.a -o hello -Iregapi/include

Tomas# ls -al hello
-rwxrwxr-x  1 tomas tomas 17208  十  22 20:06 hello
-rw-rw-r--  1 tomas tomas  3242  十  22 19:55 libregapi.a
-rw-rw-r--  1 tomas tomas   741  十  22 19:35 main.c
drwxrwxr-x  4 tomas tomas  4096  十  22 17:25 regapi
-rw-rw-r--  1 tomas tomas  3088  十  22 19:53 regapi.o
-rw-rw-r--  1 tomas tomas     1  十  22 20:07 reg.txt
```
![](https://hackmd.io/_uploads/SJB-x5zGa.png)

2. Execute it
    
```shell
Tomas# ./hello
Usage: ./hello [get | set <value>]

Tomas#./hello set 5
set reg value to 5
Call regset to set reg value 5
    
Tomas# ./hello get
Call regget to get reg value 5
get reg value: 5
```

3. Check symbols by nm
    
```bash 
Tomas# nm hello

0000000000003d80 d __do_global_dtors_aux_fini_array_entry
0000000000004008 D __dso_handle
0000000000003d88 d _DYNAMIC
0000000000004010 D _edata
0000000000004018 B _end
                 U fclose@@GLIBC_2.2.5
                 U fgets@@GLIBC_2.2.5
0000000000001548 T _fini
                 U fopen@@GLIBC_2.2.5
                 U fprintf@@GLIBC_2.2.5
0000000000001240 t frame_dummy
0000000000003d78 d __frame_dummy_init_array_entry
00000000000022dc r __FRAME_END__
0000000000002131 r __func__.2837
0000000000002138 r __func__.2842
0000000000003f78 d _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
0000000000002140 r __GNU_EH_FRAME_HDR
0000000000001000 t _init
0000000000003d80 d __init_array_end
0000000000003d78 d __init_array_start
0000000000002000 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
0000000000001540 T __libc_csu_fini
00000000000014d0 T __libc_csu_init
                 U __libc_start_main@@GLIBC_2.2.5
0000000000001249 T main
                 U perror@@GLIBC_2.2.5
                 U printf@@GLIBC_2.2.5
000000000000136e T regget
00000000000011c0 t register_tm_clones
0000000000001451 T regset
                 U __stack_chk_fail@@GLIBC_2.4
0000000000001160 T _start
                 U strcmp@@GLIBC_2.2.5
0000000000004010 D __TMC_END__
```

:::spoiler
```shell 
Tomas# readelf -a libregapi.a

File: libregapi.a(regapi.o)
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          2192 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         14
  Section header string table index: 13

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000000000  00000040
       0000000000000158  0000000000000000  AX       0     0     1
  [ 2] .rela.text        RELA             0000000000000000  00000590
       0000000000000258  0000000000000018   I      11     1     8
  [ 3] .data             PROGBITS         0000000000000000  00000198
       0000000000000000  0000000000000000  WA       0     0     1
  [ 4] .bss              NOBITS           0000000000000000  00000198
       0000000000000000  0000000000000000  WA       0     0     1
  [ 5] .rodata           PROGBITS         0000000000000000  00000198
  [ 8] .note.gnu.propert NOTE             0000000000000000  00000268
       0000000000000020  0000000000000000   A       0     0     8
  [ 9] .eh_frame         PROGBITS         0000000000000000  00000288
       0000000000000058  0000000000000000   A       0     0     8
  [10] .rela.eh_frame    RELA             0000000000000000  000007e8
       0000000000000030  0000000000000018   I      11     9     8
  [11] .symtab           SYMTAB           0000000000000000  000002e0
       0000000000000228  0000000000000018          12    12     8
  [12] .strtab           STRTAB           0000000000000000  00000508
       0000000000000082  0000000000000000           0     0     1
  [13] .shstrtab         STRTAB           0000000000000000  00000818
       0000000000000074  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

There are no program headers in this file.

There is no dynamic section in this file.

Relocation section '.rela.text' at offset 0x590 contains 25 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000000021  000500000002 R_X86_64_PC32     0000000000000000 .rodata - 4
000000000028  000500000002 R_X86_64_PC32     0000000000000000 .rodata - 2
00000000002d  000e00000004 R_X86_64_PLT32    0000000000000000 fopen - 4
000000000045  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 6
00000000004a  000f00000004 R_X86_64_PLT32    0000000000000000 perror - 4
000000000051  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 8d
000000000058  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 24
000000000062  001000000004 R_X86_64_PLT32    0000000000000000 printf - 4
000000000084  001100000004 R_X86_64_PLT32    0000000000000000 fgets - 4
00000000009a  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 8d
0000000000a1  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 4e
0000000000ab  001000000004 R_X86_64_PLT32    0000000000000000 printf - 4
0000000000ba  001200000004 R_X86_64_PLT32    0000000000000000 fclose - 4
0000000000c9  001300000004 R_X86_64_PLT32    0000000000000000 atoi - 4
0000000000dd  001400000004 R_X86_64_PLT32    0000000000000000 __stack_chk_fail - 4
0000000000f5  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 6b
0000000000fc  000500000002 R_X86_64_PC32     0000000000000000 .rodata - 2
000000000101  000e00000004 R_X86_64_PLT32    0000000000000000 fopen - 4
000000000113  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 6
000000000118  000f00000004 R_X86_64_PLT32    0000000000000000 perror - 4
000000000126  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 94
00000000012d  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 6d
000000000137  001000000004 R_X86_64_PLT32    0000000000000000 printf - 4
000000000145  000500000002 R_X86_64_PC32     0000000000000000 .rodata + 8a
000000000152  001600000004 R_X86_64_PLT32    0000000000000000 fprintf - 4

Relocation section '.rela.eh_frame' at offset 0x7e8 contains 2 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000000020  000200000002 R_X86_64_PC32     0000000000000000 .text + 0
000000000040  000200000002 R_X86_64_PC32     0000000000000000 .text + e3

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.symtab' contains 23 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS regapi.c
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    3
     4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4
     5: 0000000000000000     0 SECTION LOCAL  DEFAULT    5
     6: 0000000000000091     7 OBJECT  LOCAL  DEFAULT    5 __func__.2837
     7: 0000000000000098     7 OBJECT  LOCAL  DEFAULT    5 __func__.2842
     8: 0000000000000000     0 SECTION LOCAL  DEFAULT    7
     9: 0000000000000000     0 SECTION LOCAL  DEFAULT    8
    10: 0000000000000000     0 SECTION LOCAL  DEFAULT    9
    11: 0000000000000000     0 SECTION LOCAL  DEFAULT    6
    12: 0000000000000000   227 FUNC    GLOBAL DEFAULT    1 regget
    13: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND _GLOBAL_OFFSET_TABLE_
    14: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND fopen
    15: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND perror
    16: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND printf
    17: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND fgets
    18: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND fclose
    19: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND atoi
    20: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND __stack_chk_fail
    21: 00000000000000e3   117 FUNC    GLOBAL DEFAULT    1 regset
    22: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND fprintf

No version information found in this file.

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT, SHSTK
:::
    
:::spoiler
Tomas# readelf -a hello
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x1160
  Start of program headers:          64 (bytes into file)
  Start of section headers:          15224 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         13
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000000000318  00000318
       000000000000001c  0000000000000000   A       0     0     1
  [ 2] .note.gnu.propert NOTE             0000000000000338  00000338
       0000000000000020  0000000000000000   A       0     0     8
  [ 3] .note.gnu.build-i NOTE             0000000000000358  00000358
       0000000000000024  0000000000000000   A       0     0     4

       000000000000000d  0000000000000000  AX       0     0     4
  [18] .rodata           PROGBITS         0000000000002000  00002000
       000000000000013f  0000000000000000   A       0     0     8
  [19] .eh_frame_hdr     PROGBITS         0000000000002140  00002140
       0000000000000054  0000000000000000   A       0     0     4
  [20] .eh_frame         PROGBITS         0000000000002198  00002198
       0000000000000148  0000000000000000   A       0     0     8
  [21] .init_array       INIT_ARRAY       0000000000003d78  00002d78
       0000000000000008  0000000000000008  WA       0     0     8
  [22] .fini_array       FINI_ARRAY       0000000000003d80  00002d80
       0000000000000008  0000000000000008  WA       0     0     8
  [23] .dynamic          DYNAMIC          0000000000003d88  00002d88
       00000000000001f0  0000000000000010  WA       7     0     8
  [24] .got              PROGBITS         0000000000003f78  00002f78
       0000000000000088  0000000000000008  WA       0     0     8
  [25] .data             PROGBITS         0000000000004000  00003000
       0000000000000010  0000000000000000  WA       0     0     8
  [26] .bss              NOBITS           0000000000004010  00003010
       0000000000000008  0000000000000000  WA       0     0     1
  [27] .comment          PROGBITS         0000000000000000  00003010
       000000000000002b  0000000000000001  MS       0     0     1
  [28] .symtab           SYMTAB           0000000000000000  00003040
       0000000000000750  0000000000000018          29    49     8
  [29] .strtab           STRTAB           0000000000000000  00003790
       00000000000002c8  0000000000000000           0     0     1
  [30] .shstrtab         STRTAB           0000000000000000  00003a58
       000000000000011a  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

Program Headers:
  Type           Offset             VirtAddr           PhysAddr

on_r .rela.dyn .rela.plt
   03     .init .plt .plt.got .plt.sec .text .fini
   04     .rodata .eh_frame_hdr .eh_frame
   05     .init_array .fini_array .dynamic .got .data .bss
   06     .dynamic
   07     .note.gnu.property
   08     .note.gnu.build-id .note.ABI-tag
   09     .note.gnu.property
   10     .eh_frame_hdr
   11
   12     .init_array .fini_array .dynamic .got

Dynamic section at offset 0x2d88 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x1548
 0x0000000000000019 (INIT_ARRAY)         0x3d78
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3d80
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x3a0
 0x0000000000000005 (STRTAB)             0x530
 0x0000000000000006 (SYMTAB)             0x3c8
 0x000000000000000a (STRSZ)              198 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000003 (PLTGOT)             0x3f78
 0x0000000000000002 (PLTRELSZ)           216 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x708
 0x0000000000000007 (RELA)               0x648
 0x0000000000000008 (RELASZ)             192 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000006ffffffb (FLAGS_1)            Flags: NOW PIE
 0x000000006ffffffe (VERNEED)            0x618

Relocation section '.rela.dyn' at offset 0x648 contains 8 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000003d78  000000000008 R_X86_64_RELATIVE                    1240
000000003d80  000000000008 R_X86_64_RELATIVE                    1200
000000004008  000000000008 R_X86_64_RELATIVE                    4008
000000003fd8  000100000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_deregisterTMClone + 0
000000003fe0  000500000006 R_X86_64_GLOB_DAT 0000000000000000 __libc_start_main@GLIBC_2.2.5 + 0
000000003fe8  000900000006 R_X86_64_GLOB_DAT 0000000000000000 __gmon_start__ + 0
000000003ff0  000d00000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_registerTMCloneTa + 0
000000003ff8  000e00000006 R_X86_64_GLOB_DAT 0000000000000000 __cxa_finalize@GLIBC_2.2.5 + 0

Relocation section '.rela.plt' at offset 0x708 contains 9 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000003f90  000200000007 R_X86_64_JUMP_SLO 0000000000000000 fclose@GLIBC_2.2.5 + 0
000000003f98  000300000007 R_X86_64_JUMP_SLO 0000000000000000 __stack_chk_fail@GLIBC_2.4 + 0
000000003fa0  000400000007 R_X86_64_JUMP_SLO 0000000000000000 printf@GLIBC_2.2.5 + 0
000000003fa8  000600000007 R_X86_64_JUMP_SLO 0000000000000000 fgets@GLIBC_2.2.5 + 0
000000003fb0  000700000007 R_X86_64_JUMP_SLO 0000000000000000 strcmp@GLIBC_2.2.5 + 0
000000003fb8  000800000007 R_X86_64_JUMP_SLO 0000000000000000 fprintf@GLIBC_2.2.5 + 0
000000003fc0  000a00000007 R_X86_64_JUMP_SLO 0000000000000000 fopen@GLIBC_2.2.5 + 0
000000003fc8  000b00000007 R_X86_64_JUMP_SLO 0000000000000000 perror@GLIBC_2.2.5 + 0
000000003fd0  000c00000007 R_X86_64_JUMP_SLO 0000000000000000 atoi@GLIBC_2.2.5 + 0

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.dynsym' contains 15 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterTMCloneTab
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fclose@GLIBC_2.2.5 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __stack_chk_fail@GLIBC_2.4 (3)
     4: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@GLIBC_2.2.5 (2)
     5: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@GLIBC_2.2.5 (2)
     6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fgets@GLIBC_2.2.5 (2)
     7: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strcmp@GLIBC_2.2.5 (2)
     8: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fprintf@GLIBC_2.2.5 (2)
     9: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__

     4: 000000000000037c     0 SECTION LOCAL  DEFAULT    4
     5: 00000000000003a0     0 SECTION LOCAL  DEFAULT    5
     6: 00000000000003c8     0 SECTION LOCAL  DEFAULT    6
     7: 0000000000000530     0 SECTION LOCAL  DEFAULT    7
     8: 00000000000005f6     0 SECTION LOCAL  DEFAULT    8
     9: 0000000000000618     0 SECTION LOCAL  DEFAULT    9
    10: 0000000000000648     0 SECTION LOCAL  DEFAULT   10
    11: 0000000000000708     0 SECTION LOCAL  DEFAULT   11
    12: 0000000000001000     0 SECTION LOCAL  DEFAULT   12
    13: 0000000000001020     0 SECTION LOCAL  DEFAULT   13
    14: 00000000000010c0     0 SECTION LOCAL  DEFAULT   14
    15: 00000000000010d0     0 SECTION LOCAL  DEFAULT   15
    16: 0000000000001160     0 SECTION LOCAL  DEFAULT   16
    17: 0000000000001548     0 SECTION LOCAL  DEFAULT   17
    18: 0000000000002000     0 SECTION LOCAL  DEFAULT   18
    19: 0000000000002140     0 SECTION LOCAL  DEFAULT   19
    20: 0000000000002198     0 SECTION LOCAL  DEFAULT   20
    21: 0000000000003d78     0 SECTION LOCAL  DEFAULT   21
    22: 0000000000003d80     0 SECTION LOCAL  DEFAULT   22
    23: 0000000000003d88     0 SECTION LOCAL  DEFAULT   23
    24: 0000000000003f78     0 SECTION LOCAL  DEFAULT   24
    25: 0000000000004000     0 SECTION LOCAL  DEFAULT   25
    26: 0000000000004010     0 SECTION LOCAL  DEFAULT   26
    27: 0000000000000000     0 SECTION LOCAL  DEFAULT   27
    28: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c
    29: 0000000000001190     0 FUNC    LOCAL  DEFAULT   16 deregister_tm_clones
    30: 00000000000011c0     0 FUNC    LOCAL  DEFAULT   16 register_tm_clones
    31: 0000000000001200     0 FUNC    LOCAL  DEFAULT   16 __do_global_dtors_aux
    32: 0000000000004010     1 OBJECT  LOCAL  DEFAULT   26 completed.8061
    33: 0000000000003d80     0 OBJECT  LOCAL  DEFAULT   22 __do_global_dtors_aux_fin
    34: 0000000000001240     0 FUNC    LOCAL  DEFAULT   16 frame_dummy
    35: 0000000000003d78     0 OBJECT  LOCAL  DEFAULT   21 __frame_dummy_init_array_
    36: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    37: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS regapi.c
    38: 0000000000002131     7 OBJECT  LOCAL  DEFAULT   18 __func__.2837
    39: 0000000000002138     7 OBJECT  LOCAL  DEFAULT   18 __func__.2842
    40: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c

    54: 0000000000001548     0 FUNC    GLOBAL HIDDEN    17 _fini
    55: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __stack_chk_fail@@GLIBC_2
    56: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@@GLIBC_2.2.5
    57: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@@GLIBC_
    58: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fgets@@GLIBC_2.2.5
    59: 0000000000004000     0 NOTYPE  GLOBAL DEFAULT   25 __data_start
    60: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strcmp@@GLIBC_2.2.5
    61: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fprintf@@GLIBC_2.2.5
    62: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
    63: 0000000000004008     0 OBJECT  GLOBAL HIDDEN    25 __dso_handle
    64: 0000000000002000     4 OBJECT  GLOBAL DEFAULT   18 _IO_stdin_used
    65: 00000000000014d0   101 FUNC    GLOBAL DEFAULT   16 __libc_csu_init
    66: 0000000000004018     0 NOTYPE  GLOBAL DEFAULT   26 _end
    67: 0000000000001160    47 FUNC    GLOBAL DEFAULT   16 _start
    68: 0000000000004010     0 NOTYPE  GLOBAL DEFAULT   26 __bss_start
    69: 0000000000001249   293 FUNC    GLOBAL DEFAULT   16 main
    70: 0000000000001451   117 FUNC    GLOBAL DEFAULT   16 regset
    71: 000000000000136e   227 FUNC    GLOBAL DEFAULT   16 regget
    72: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fopen@@GLIBC_2.2.5
    73: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND perror@@GLIBC_2.2.5
    74: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND atoi@@GLIBC_2.2.5
    75: 0000000000004010     0 OBJECT  GLOBAL HIDDEN    25 __TMC_END__
    76: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMCloneTable
    77: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND __cxa_finalize@@GLIBC_2.2

Histogram for `.gnu.hash' bucket list length (total of 2 buckets):
 Length  Number     % of total  Coverage
      0  1          ( 50.0%)
      1  1          ( 50.0%)    100.0%

Version symbols section '.gnu.version' contains 15 entries:
 Addr: 0x00000000000005f6  Offset: 0x0005f6  Link: 6 (.dynsym)
  000:   0 (*local*)       0 (*local*)       2 (GLIBC_2.2.5)   3 (GLIBC_2.4)
  004:   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)
  008:   2 (GLIBC_2.2.5)   0 (*local*)       2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)
  00c:   2 (GLIBC_2.2.5)   0 (*local*)       2 (GLIBC_2.2.5)

Version needs section '.gnu.version_r' contains 1 entry:
 Addr: 0x0000000000000618  Offset: 0x000618  Link: 7 (.dynstr)
  000000: Version: 1  File: libc.so.6  Cnt: 2
  0x0010:   Name: GLIBC_2.4  Flags: none  Version: 3
  0x0020:   Name: GLIBC_2.2.5  Flags: none  Version: 2

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT, SHSTK

Displaying notes found in: .note.gnu.build-id
  Owner                Data size        Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: 353ed780fae95a5ba1e16889cafbc321fe205f40

Displaying notes found in: .note.ABI-tag
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 3.2.0
:::

### Write the Makefile and build it
![](https://hackmd.io/_uploads/SkGGt9GGp.png)

```shell 
Tomas # ls -al
-rw-rw-r--  1 tomas tomas  741  十  22 19:35 main.c
-rw-rw-r--  1 tomas tomas  603  十  22 20:44 Makefile
drwxrwxr-x  4 tomas tomas 4096  十  22 17:25 regapi

Tomas# cat Makefile
# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -Iregapi/include
LDFLAGS = -L. -lregapi

# Source files and objects
SRC = main.c
LIB_SRC = regapi/src/regapi.c
OBJ = $(SRC:.c=.o) regapi.o

# Target executable
TARGET = hello

.PHONY: all clean

all: $(TARGET)

# Build the static library
libregapi.a: regapi.o
        ar rcs $@ $^

# Compile the library source file
regapi.o: $(LIB_SRC)
        $(CC) $(CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.a
        $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Compile source files
%.o: %.c
        $(CC) $(CFLAGS) -c $<

clean:
        rm -f $(TARGET) $(OBJ) libregapi.a
```
---
    
##  Dynamic library
1. Compile the regapi.c to an object by gcc.
```shell 
Tomas# gcc -fPIC -c regapi/src/regapi.c -Iregapi/include
    
Tomas# ls -al regapi.o
-rw-rw-r--  1 tomas tomas  3088  十  22 20:48 regapi.o
```
2. Create the shared library
```shell
Tomas# gcc -s -shared -o libregapi.so regapi.o
    
Tomas# ls -al
-rwxrwxr-x  1 tomas tomas 14472  十  22 20:49 libregapi.so
-rw-rw-r--  1 tomas tomas   741  十  22 19:35 main.c
-rw-rw-r--  1 tomas tomas   603  十  22 20:44 Makefile
drwxrwxr-x  4 tomas tomas  4096  十  22 17:25 regapi
-rw-rw-r--  1 tomas tomas  3088  十  22 20:48 regapi.o
```
![](https://hackmd.io/_uploads/ry5Kccff6.png)
    
3. Check the library dependency by ldd
```shell
Tomas# ldd libregapi.so
linux-vdso.so.1 (0x00007ffd05254000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f4652994000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f4652b9f000)
```

### Build the application and link it with shared library
```
Tomas# gcc -o hello main.c -Wl,-rpath=. -L. -Iregapi/include -lregapi

Tomas# ls -al
-rwxrwxr-x  1 tomas tomas 16848  十  22 20:56 hello
-rwxrwxr-x  1 tomas tomas 14472  十  22 20:53 libregapi.so
-rw-rw-r--  1 tomas tomas   741  十  22 19:35 main.c
-rw-rw-r--  1 tomas tomas   603  十  22 20:44 Makefile
drwxrwxr-x  4 tomas tomas  4096  十  22 17:25 regapi
```

Execute it.

```shell 
Tomas# ./hello set 88
set reg value to 88
Call regset to set reg value 88

Tomas# ./hello get
Call regget to get reg value 88
reg value: 88
```
    
Check the symbols.

```
Tomas# nm hello
                 U atoi@@GLIBC_2.2.5
0000000000004010 B __bss_start
0000000000004010 b completed.8061
                 w __cxa_finalize@@GLIBC_2.2.5
0000000000004000 D __data_start
0000000000004000 W data_start
0000000000001110 t deregister_tm_clones
0000000000001180 t __do_global_dtors_aux
0000000000003d80 d __do_global_dtors_aux_fini_array_entry
0000000000004008 D __dso_handle
0000000000003d88 d _DYNAMIC
0000000000004010 D _edata
0000000000004018 B _end
0000000000001368 T _fini
00000000000011c0 t frame_dummy
0000000000003d78 d __frame_dummy_init_array_entry
00000000000021ec r __FRAME_END__
0000000000003f98 d _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
00000000000020a0 r __GNU_EH_FRAME_HDR
0000000000001000 t _init
0000000000003d80 d __init_array_end
0000000000003d78 d __init_array_start
0000000000002000 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
0000000000001360 T __libc_csu_fini
00000000000012f0 T __libc_csu_init
                 U __libc_start_main@@GLIBC_2.2.5
00000000000011c9 T main
                 U printf@@GLIBC_2.2.5
                 U regget
0000000000001140 t register_tm_clones
                 U regset
00000000000010e0 T _start
                 U strcmp@@GLIBC_2.2.5
0000000000004010 D __TMC_END__
```
:::spoiler
```shell 
Tomas# readelf -a libregapi.so
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x1140
  Start of program headers:          64 (bytes into file)
  Start of section headers:          12680 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         11
  Size of section headers:           64 (bytes)
  Number of section headers:         28
  Section header string table index: 27

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .note.gnu.propert NOTE             00000000000002a8  000002a8
       0000000000000020  0000000000000000   A       0     0     8
  [ 2] .note.gnu.build-i NOTE             00000000000002c8  000002c8
       0000000000000024  0000000000000000   A       0     0     4
  [ 3] .gnu.hash         GNU_HASH         00000000000002f0  000002f0
       0000000000000028  0000000000000000   A       4     0     8

  [15] .fini             PROGBITS         0000000000001354  00001354
       000000000000000d  0000000000000000  AX       0     0     4
  [16] .rodata           PROGBITS         0000000000002000  00002000
       000000000000009f  0000000000000000   A       0     0     8
  [17] .eh_frame_hdr     PROGBITS         00000000000020a0  000020a0
       0000000000000034  0000000000000000   A       0     0     4
  [18] .eh_frame         PROGBITS         00000000000020d8  000020d8
       00000000000000b4  0000000000000000   A       0     0     8
  [19] .init_array       INIT_ARRAY       0000000000003e10  00002e10
       0000000000000008  0000000000000008  WA       0     0     8
  [20] .fini_array       FINI_ARRAY       0000000000003e18  00002e18
       0000000000000008  0000000000000008  WA       0     0     8
  [21] .dynamic          DYNAMIC          0000000000003e20  00002e20
       00000000000001c0  0000000000000010  WA       5     0     8
  [22] .got              PROGBITS         0000000000003fe0  00002fe0
       0000000000000020  0000000000000008  WA       0     0     8
  [23] .got.plt          PROGBITS         0000000000004000  00003000
       0000000000000058  0000000000000008  WA       0     0     8
  [24] .data             PROGBITS         0000000000004058  00003058
       0000000000000008  0000000000000000  WA       0     0     8
  [25] .bss              NOBITS           0000000000004060  00003060
       0000000000000008  0000000000000000  WA       0     0     1
  [26] .comment          PROGBITS         0000000000000000  00003060
       000000000000002b  0000000000000001  MS       0     0     1
  [27] .shstrtab         STRTAB           0000000000000000  0000308b
       00000000000000fd  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x00000000000006f8 0x00000000000006f8  R      0x1000
  LOAD           0x0000000000001000 0x0000000000001000 0x0000000000001000
                 0x0000000000000361 0x0000000000000361  R E    0x1000
  LOAD           0x0000000000002000 0x00000000000020

Dynamic section at offset 0x2e20 contains 24 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x1354
 0x0000000000000019 (INIT_ARRAY)         0x3e10
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3e18
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x2f0
 0x0000000000000005 (STRTAB)             0x480
 0x0000000000000006 (SYMTAB)             0x318
 0x000000000000000a (STRSZ)              187 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x4000
 0x0000000000000002 (PLTRELSZ)           192 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x638
 0x0000000000000007 (RELA)               0x590
 0x0000000000000008 (RELASZ)             168 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffffe (VERNEED)            0x560
 0x000000006fffffff (VERNEEDNUM)         1
 0x000000006ffffff0 (VERSYM)             0x53c
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000000 (NULL)               0x0

Relocation section '.rela.dyn' at offset 0x590 contains 7 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000003e10  000000000008 R_X86_64_RELATIVE                    11f0
000000003e18  000000000008 R_X86_64_RELATIVE                    11b0
000000004058  000000000008 R_X86_64_RELATIVE                    4058
000000003fe0  000100000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_deregisterTMClone + 0
000000003fe8  000700000006 R_X86_64_GLOB_DAT 0000000000000000 __gmon_start__ + 0
000000003ff0  000b00000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_registerTMCloneTa + 0
000000003ff8  000c00000006 R_X86_64_GLOB_DAT 0000000000000000 __cxa_finalize@GLIBC_2.2.5 + 0

Relocation section '.rela.plt' at offset 0x638 contains 8 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000004018  000200000007 R_X86_64_JUMP_SLO 0000000000000000 fclose@GLIBC_2.2.5 + 0
000000004020  000300000007 R_X86_6
The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.dynsym' contains 15 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterTMCloneTab
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fclose@GLIBC_2.2.5 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __stack_chk_fail@GLIBC_2.4 (3)
     4: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@GLIBC_2.2.5 (2)
     5: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fgets@GLIBC_2.2.5 (2)
     6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fprintf@GLIBC_2.2.5 (2)
     7: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
     8: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fopen@GLIBC_2.2.5 (2)
     9: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND perror@GLIBC_2.2.5 (2)
    10: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND atoi@GLIBC_2.2.5 (2)
    11: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMCloneTable
    12: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND __cxa_finalize@GLIBC_2.2.5 (2)
    13: 00000000000012dc   117 FUNC    GLOBAL DEFAULT   14 regset
    14: 00000000000011f9   227 FUNC    GLOBAL DEFAULT   14 regget

Histogram for `.gnu.hash' bucket list length (total of 2 buckets):
 Length  Number     % of total  Coverage
      0  1          ( 50.0%)
      1  0          (  0.0%)      0.0%
      2  1          ( 50.0%)    100.0%

Version symbols section '.gnu.version' contains 15 entries:
 Addr: 0x000000000000053c  Offset: 0x00053c  Link: 4 (.dynsym)
  000:   0 (*local*)       0 (*local*)       2 (GLIBC_2.2.5)   3 (GLIBC_2.4)
  004:   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   0 (*local*)
  008:   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   0 (*local*)
  00c:   2 (GLIBC_2.2.5)   1 (*global*)      1 (*global*)

Version needs section '.gnu.version_r' contains 1 entry:
 Addr: 0x0000000000000560  Offset: 0x000560  Link: 5 (.dynstr)
  000000: Version: 1  File: libc.so.6  Cnt: 2
  0x0010:   Name: GLIBC_2.4  Flags: none  Version: 3
  0x0020:   Name: GLIBC_2.2.5  Flags: none  Version: 2

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT, SHSTK

Displaying notes found in: .note.gnu.build-id
  Owner                Data size        Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: c172a62c7d23fe26fa3127ba7d4ceaeb6fce920e
```
:::
    
:::spoiler
Tomas# readelf -a hello
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x10e0
  Start of program headers:          64 (bytes into file)
  Start of section headers:          14864 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         13
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000000000318  00000318

       0000000000000016  0000000000000002   A       6     0     2
  [ 9] .gnu.version_r    VERNEED          0000000000000598  00000598
       0000000000000020  0000000000000000   A       7     1     8
  [10] .rela.dyn         RELA             00000000000005b8  000005b8
       00000000000000c0  0000000000000018   A       6     0     8
  [11] .rela.plt         RELA             0000000000000678  00000678
       0000000000000078  0000000000000018  AI       6    24     8
  [12] .init             PROGBITS         0000000000001000  00001000
       000000000000001b  0000000000000000  AX       0     0     4
  [13] .plt              PROGBITS         0000000000001020  00001020
       0000000000000060  0000000000000010  AX       0     0     16
  [14] .plt.got          PROGBITS         0000000000001080  00001080
       0000000000000010  0000000000000010  AX       0     0     16
  [15] .plt.sec          PROGBITS         0000000000001090  00001090
       0000000000000050  0000000000000010  AX       0     0     16
  [16] .text             PROGBITS         00000000000010e0  000010e0
       0000000000000285  0000000000000000  AX       0     0     16
  [17] .fini             PROGBITS         0000000000001368  00001368
       000000000000000d  0000000000000000  AX       0     0     4
  [18] .rodata           PROGBITS         0000000000002000  00002000
       00000000000000a0  0000000000000000   A       0     0     8
  [19] .eh_frame_hdr     PROGBITS         00000000000020a0  000020a0
       0000000000000044  0000000000000000   A       0     0     4
  [20] .eh_frame         PROGBITS         00000000000020e8  000020e8
       0000000000000108  0000000000000000   A       0     0     8
  [21] .init_array       INIT_ARRAY       0000000000003d78  00002d78
       0000000000000008  0000000000000008  WA       0     0     8
  [22] .fini_array       FINI_ARRAY       0000000000003d80  00002d80
       0000000000000008  0000000000000008  WA       0     0     8
  [23] .dynamic          DYNAMIC          0000000000003d88  00002d88
       0000000000000210  0000000000000010  WA       7     0     8
  [24] .got              PROGBITS         0000000000003f98  00002f98
       0000000000000068  0000000000000008  WA       0     0     8
  [25] .data             PROGBITS         0000000000004000  00003000
       0000000000000010  0000000000000000  WA       0     0     8
  [26] .bss              NOBITS           0000000000004010  00003010
       0000000000000008  0000000000000000  WA       0     0     1
  [27] .comment          PROGBITS         0000000000000000  00003010
       000000000000002b  0000000000000001  MS       0     0     1
  [28] .symtab           SYMTAB           0000000000000000  00003040
       0000000000000678  0000000000000018          29    46     8

                 0x0000000000000044 0x0000000000000044  R      0x4
  GNU_PROPERTY   0x0000000000000338 0x0000000000000338 0x0000000000000338
                 0x0000000000000020 0x0000000000000020  R      0x8
  GNU_EH_FRAME   0x00000000000020a0 0x00000000000020a0 0x00000000000020a0
                 0x0000000000000044 0x0000000000000044  R      0x4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
  GNU_RELRO      0x0000000000002d78 0x0000000000003d78 0x0000000000003d78
                 0x0000000000000288 0x0000000000000288  R      0x1

 Section to Segment mapping:
  Segment Sections...
   00
   01     .interp
   02     .interp .note.gnu.property .note.gnu.build-id .note.ABI-tag .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt
   03     .init .plt .plt.got .plt.sec .text .fini
   04     .rodata .eh_frame_hdr .eh_frame
   05     .init_array .fini_array .dynamic .got .data .bss
   06     .dynamic
   07     .note.gnu.property
   08     .note.gnu.build-id .note.ABI-tag
   09     .note.gnu.property
   10     .eh_frame_hdr
   11
   12     .init_array .fini_array .dynamic .got

Dynamic section at offset 0x2d88 contains 29 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libregapi.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [.]
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x1368
 0x0000000000000019 (INIT_ARRAY)         0x3d78
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3d80
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x3a0
 0x0000000000000005 (STRTAB)             0x4d0
 0x0000000000000006 (SYMTAB)             0x3c8
 0x000000000000000a (STRSZ)              173 (bytes)
 0x000000006ffffff0 (VERSYM)             0x57e
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000000 (NULL)               0x0

Relocation section '.rela.dyn' at offset 0x5b8 contains 8 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000003d78  000000000008 R_X86_64_RELATIVE                    11c0
000000003d80  000000000008 R_X86_64_RELATIVE                    1180
000000004008  000000000008 R_X86_64_RELATIVE                    4008
000000003fd8  000100000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_deregisterTMClone + 0
000000003fe0  000300000006 R_X86_64_GLOB_DAT 0000000000000000 __libc_start_main@GLIBC_2.2.5 + 0
000000003fe8  000500000006 R_X86_64_GLOB_DAT 0000000000000000 __gmon_start__ + 0
000000003ff0  000900000006 R_X86_64_GLOB_DAT 0000000000000000 _ITM_registerTMCloneTa + 0
000000003ff8  000a00000006 R_X86_64_GLOB_DAT 0000000000000000 __cxa_finalize@GLIBC_2.2.5 + 0

Relocation section '.rela.plt' at offset 0x678 contains 5 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000003fb0  000200000007 R_X86_64_JUMP_SLO 0000000000000000 printf@GLIBC_2.2.5 + 0
000000003fb8  000400000007 R_X86_64_JUMP_SLO 0000000000000000 strcmp@GLIBC_2.2.5 + 0
000000003fc0  000600000007 R_X86_64_JUMP_SLO 0000000000000000 regset + 0
000000003fc8  000700000007 R_X86_64_JUMP_SLO 0000000000000000 regget + 0
000000003fd0  000800000007 R_X86_64_JUMP_SLO 0000000000000000 atoi@GLIBC_2.2.5 + 0

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.dynsym' contains 11 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterTMCloneTab
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@GLIBC_2.2.5 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@GLIBC_2.2.5 (2)
     4: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND strcmp@GLIBC_2.2.5 (2)
     5: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
     6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND regset
     7: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND regget
     8: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND atoi@GLIBC_2.2.5 (2)
     9: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMCloneTable
    10: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND __cxa_finalize@GLIBC_2.2.5 (2)

Symbol table '.symtab' contains 69 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name

    10: 00000000000005b8     0 SECTION LOCAL  DEFAULT   10
    11: 0000000000000678     0 SECTION LOCAL  DEFAULT   11
    12: 0000000000001000     0 SECTION LOCAL  DEFAULT   12
    13: 0000000000001020     0 SECTION LOCAL  DEFAULT   13
    14: 0000000000001080     0 SECTION LOCAL  DEFAULT   14
    15: 0000000000001090     0 SECTION LOCAL  DEFAULT   15
    16: 00000000000010e0     0 SECTION LOCAL  DEFAULT   16
    17: 0000000000001368     0 SECTION LOCAL  DEFAULT   17
    18: 0000000000002000     0 SECTION LOCAL  DEFAULT   18
    19: 00000000000020a0     0 SECTION LOCAL  DEFAULT   19
    20: 00000000000020e8     0 SECTION LOCAL  DEFAULT   20
    21: 0000000000003d78     0 SECTION LOCAL  DEFAULT   21
    22: 0000000000003d80     0 SECTION LOCAL  DEFAULT   22
    23: 0000000000003d88     0 SECTION LOCAL  DEFAULT   23
    24: 0000000000003f98     0 SECTION LOCAL  DEFAULT   24
    25: 0000000000004000     0 SECTION LOCAL  DEFAULT   25
    26: 0000000000004010     0 SECTION LOCAL  DEFAULT   26
    27: 0000000000000000     0 SECTION LOCAL  DEFAULT   27
    28: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c
    29: 0000000000001110     0 FUNC    LOCAL  DEFAULT   16 deregister_tm_clones
    30: 0000000000001140     0 FUNC    LOCAL  DEFAULT   16 register_tm_clones
    31: 0000000000001180     0 FUNC    LOCAL  DEFAULT   16 __do_global_dtors_aux
    32: 0000000000004010     1 OBJECT  LOCAL  DEFAULT   26 completed.8061
    33: 0000000000003d80     0 OBJECT  LOCAL  DEFAULT   22 __do_global_dtors_aux_fin
    34: 00000000000011c0     0 FUNC    LOCAL  DEFAULT   16 frame_dummy
    35: 0000000000003d78     0 OBJECT  LOCAL  DEFAULT   21 __frame_dummy_init_array_
    36: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    37: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS crtstuff.c
    38: 00000000000021ec     0 OBJECT  LOCAL  DEFAULT   20 __FRAME_END__
    39: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS
    40: 0000000000003d80     0 NOTYPE  LOCAL  DEFAULT   21 __init_array_end
    41: 0000000000003d88     0 OBJECT  LOCAL  DEFAULT   23 _DYNAMIC
    42: 0000000000003d78     0 NOTYPE  LOCAL  DEFAULT   21 __init_array_start
    43: 00000000000020a0     0 NOTYPE  LOCAL  DEFAULT   19 __GNU_EH_FRAME_HDR
    44: 0000000000003f98     0 OBJECT  LOCAL  DEFAULT   24 _GLOBAL_OFFSET_TABLE_
    45: 0000000000001000     0 FUNC    LOCAL  DEFAULT   12 _init
    46: 0000000000001360     5 FUNC    GLOBAL DEFAULT   16 __libc_csu_fini
    47: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterTMCloneTab
    48: 0000000000004000     0 NOTYPE  WEAK   DEFAULT   25 data_start
    49: 0000000000004010     0 NOTYPE  GLOBAL DEFAULT   25 _edata
    50: 0000000000001368     0 FUNC    GLOBAL HIDDEN    17 _fini

    59: 0000000000004018     0 NOTYPE  GLOBAL DEFAULT   26 _end
    60: 00000000000010e0    47 FUNC    GLOBAL DEFAULT   16 _start
    61: 0000000000004010     0 NOTYPE  GLOBAL DEFAULT   26 __bss_start
    62: 00000000000011c9   293 FUNC    GLOBAL DEFAULT   16 main
    63: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND regset
    64: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND regget
    65: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND atoi@@GLIBC_2.2.5
    66: 0000000000004010     0 OBJECT  GLOBAL HIDDEN    25 __TMC_END__
    67: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMCloneTable
    68: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND __cxa_finalize@@GLIBC_2.2

Histogram for `.gnu.hash' bucket list length (total of 2 buckets):
 Length  Number     % of total  Coverage
      0  1          ( 50.0%)
      1  1          ( 50.0%)    100.0%

Version symbols section '.gnu.version' contains 11 entries:
 Addr: 0x000000000000057e  Offset: 0x00057e  Link: 6 (.dynsym)
  000:   0 (*local*)       0 (*local*)       2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)
  004:   2 (GLIBC_2.2.5)   0 (*local*)       0 (*local*)       0 (*local*)
  008:   2 (GLIBC_2.2.5)   0 (*local*)       2 (GLIBC_2.2.5)

Version needs section '.gnu.version_r' contains 1 entry:
 Addr: 0x0000000000000598  Offset: 0x000598  Link: 7 (.dynstr)
  000000: Version: 1  File: libc.so.6  Cnt: 1
  0x0010:   Name: GLIBC_2.2.5  Flags: none  Version: 2

Displaying notes found in: .note.gnu.property
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_PROPERTY_TYPE_0
      Properties: x86 feature: IBT, SHSTK

Displaying notes found in: .note.gnu.build-id
  Owner                Data size        Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: e77046db6ef702a971f1bcda6ee429513c6ad762

Displaying notes found in: .note.ABI-tag
  Owner                Data size        Description
  GNU                  0x00000010       NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 3.2.0
:::
    
### Write the Makefile and build it
```shell
Tomas# cat Makefile
# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -Iregapi/include
LIB_CFLAGS = -Wall -Wextra -Iregapi/include -fPIC
LDFLAGS = -L. -lregapi

# Source files and objects
SRC = main.c
LIB_SRC = regapi/src/regapi.c
OBJ = $(SRC:.c=.o) regapi.o

# Target executable
TARGET = hello

.PHONY: all clean

all: $(TARGET)

# Build the static library
libregapi.a: regapi.o
        ar rcs $@ $^

# Build the static library
libregapi.so: regapi.o
        $(CC) -s -shared -o $@ $^

# Compile the library source file
#regapi.o: $(LIB_SRC)
#       $(CC) $(CFLAGS) -c $<

regapi.o: $(LIB_SRC)
        $(CC) $(LIB_CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.so
#$(TARGET): $(OBJ) libregapi.a
        $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Compile source files
%.o: %.c
        $(CC) $(CFLAGS) -c $<

clean:
        rm -f $(TARGET) $(OBJ) libregapi.a libregapi.so
```

## Summary
### Comparision

| Item | Type | File name | Size |
|-| -------- | -------- | -------- |
|1 |Static library  | libregapi.a  | 3242  |
|2 |Dynamic library | libregapi.so | 14472 |
|3 |Application w/ static library | hello | 16944 |
|4 |Appliaction w/ dynamic library | hello| 17208 |

From the table above, it is obvious to see 
1. the size of the static library is smaller than the dynamic one.
2. the size of the main application with static library is 184 bytes larger than the one with dynamic library.

### Pros and cons

| | Static library | Dynamic library |
| -------- | -------- | -------- |
| App size     | larger     | smaller    |
| Library size     | smaller     | larger|
| Version control     | No     | Yes     |
| Easy to develop App     | Yes     | No |
|Reusable | No| Yes |


## Appendix
### Common Makefile
We write a Makefile to build the application with a static library and a dynamic library by setting the flag SHARED_LIB:
- if SHARED_LIB = 1, hello with libregapi.so
- if SHARED_LIB = 0, hello with libregapi.a
- default, SHARED_LIB = 0

```shell 
#
# 'make SHARED_LIB=0' build executable file with libregapi.a
# 'make SHARED_LIB=1' build executable file with libregapi.so
# 'make clean'  removes all .o, .a, .so and executable files
#

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -Iregapi/include
LIB_CFLAGS = -Wall -Wextra -Iregapi/include -fPIC
LDFLAGS = -L. -lregapi

# Source files and objects
SRC = main.c
LIB_SRC = regapi/src/regapi.c
OBJ = $(SRC:.c=.o) regapi.o

# Target executable
TARGET = hello

.PHONY: all clean

all: $(TARGET)

# Build the static library
libregapi.so: regapi.o
        $(CC) -s -shared -o $@ $^

ifeq ($(SHARED_LIB),1)
# Compile the library source file
regapi.o: $(LIB_SRC)
        $(CC) $(LIB_CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.so
        $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
TARGET = hello

.PHONY: all clean

all: $(TARGET)

# Build the static library
libregapi.a: regapi.o
        ar rcs $@ $^

# Build the static library
libregapi.so: regapi.o
        $(CC) -s -shared -o $@ $^

ifeq ($(SHARED_LIB),1)
# Compile the library source file
regapi.o: $(LIB_SRC)
        $(CC) $(LIB_CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.so
        $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

else
# Compile the library source file
regapi.o: $(LIB_SRC)
        $(CC) $(CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.a
        $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

endif

# Compile source files
%.o: %.c
        $(CC) $(CFLAGS) -c $<

clean:
        rm -f $(TARGET) $(OBJ) libregapi.a libregapi.so
```
Example,
```shell
Tomas# make SHARED_LIB=1
gcc -Wall -Wextra -Iregapi/include -c main.c
gcc -Wall -Wextra -Iregapi/include -fPIC -c regapi/src/regapi.c
gcc -s -shared -o libregapi.so regapi.o
gcc -Wall -Wextra -Iregapi/include -o hello main.o regapi.o libregapi.so -L. -lregapi

Tomas# ls -al
-rwxrwxr-x  1 tomas tomas 17208  十  22 22:08 hello
-rwxrwxr-x  1 tomas tomas 14472  十  22 22:08 libregapi.so
-rw-rw-r--  1 tomas tomas   741  十  22 19:35 main.c
-rw-rw-r--  1 tomas tomas  2576  十  22 22:08 main.o
-rw-rw-r--  1 tomas tomas  1148  十  22 22:07 Makefile
-rw-rw-r--  1 tomas tomas   603  十  22 21:19 Makefile.static
drwxrwxr-x  4 tomas tomas  4096  十  22 17:25 regapi
-rw-rw-r--  1 tomas tomas  3088  十  22 22:08 regapi.o
-rw-rw-r--  1 tomas tomas     2  十  22 21:09 reg.txt

Tomas# make
gcc -Wall -Wextra -Iregapi/include -c main.c
gcc -Wall -Wextra -Iregapi/include -c regapi/src/regapi.c
ar rcs libregapi.a regapi.o
gcc -Wall -Wextra -Iregapi/include -o hello main.o regapi.o libregapi.a -L. -lregapi

Tomas# ls -al
-rwxrwxr-x  1 tomas tomas 17208  十  22 22:08 hello
-rw-rw-r--  1 tomas tomas  3242  十  22 22:08 libregapi.a
-rw-rw-r--  1 tomas tomas   741  十  22 19:35 main.c
-rw-rw-r--  1 tomas tomas  2576  十  22 22:08 main.o
-rw-rw-r--  1 tomas tomas  1148  十  22 22:07 Makefile
-rw-rw-r--  1 tomas tomas   603  十  22 21:19 Makefile.static
drwxrwxr-x  4 tomas tomas  4096  十  22 17:25 regapi
-rw-rw-r--  1 tomas tomas  3088  十  22 22:08 regapi.o
-rw-rw-r--  1 tomas tomas     2  十  22 21:09 reg.txt
```

## Reference
https://hackmd.io/@TomasZheng/ByLACT1Wp
https://www.linkedin.com/pulse/differences-between-static-dynamic-libraries-juan-david-tuta-botero
https://bryceknowhow.blogspot.com/2014/11/linux-static-library-dynamic-library.html
https://hackmd.io/@TomasZheng/Sy6ly6JWa
https://blog.gtwang.org/programming/howto-create-library-using-gcc/
https://stackoverflow.com/questions/6562403/i-dont-understand-wl-rpath-wl
