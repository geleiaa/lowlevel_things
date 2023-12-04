### Solving lab2C "02/13 | --[ Memory Corruption Lab" (https://github.com/RPISEC/MBE/blob/master/src/lab02/lab2C.c)

### This lab is a simple buffer-overflow. The intention of this lab was to explore bof and get a shell from the lab machine and then get the flag. But here we won't have the shell part.

First we go get the source code and compile following the instruction that is commented in the code:

![comp](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/compilelab2ccode.png)

```
gcc -O0 -fno-stack-protector lab2C.c -o lab2C
```

Running the binary we see how to use it:

![usg](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/binusage.png)


Running with a string the binary shows that we are not "authenticated" and set_me is 0. It seems that the binary needs a specific string/password:

![auth](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/notauth.png)


Looking at the binary disassemble we see that the strcpy function is called before comparing a memory address with the "0xdeadbeef" bytes. And if this comparison is not true, the flow jumps to the end, prints something and ends the execution. But if the comparison is true a "shell" function is called. This appears to be the expected execution flow:

```
$ objdump -dM intel lab2C | grep -A40 "<main>:"
```

![disas](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/jmp.png)


Now we go debug the binary to see what is do with the input data...


Looking at the disassembly with gdb + peda we can better see the execution flow of the binary main function:

![gdbdisas](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/gdbdisas.png)


Running the binary in gdb without passing any input string the flow is diverted to a printf that shows the usage and then a jump throws the flow to the end of the execution:

* check input
![withoutarg1](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/withoutarg1.png)

* if not have input print the usage
![withoutarg2](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/withoutarg2.png)

* jump to the end
![withoutarg3](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/withoutarg3.png)



Since the binary needs an input let's set a breakpoint in the main and run binary with an input string...

```
gdb-peda$ b main
(breakpoint)
```

```
gdb-peda$ r GELEIA
(run with GELEIA string)
```

Now running with a input the exec flow throws us to another place.

![witharg1](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/witharg1.png)


After some steps we arrive at the strcpy function that we saw before. We can see that the input is moved through the registers until it reaches the strcpy function, then it is copied to some variable and compared with the "0xdeadbeef" bytes.


![witharg2](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/witharg2.png)


After comparing, If input is equal to "0xdeadbeef" the flow jump to "shell" function. If not equal the flow jump to the printf with a message "Not authenticated. set_me was 0" and terminete execution.


![witharg3](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/witharg3.png)

![witharg4](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/witharg4.png)



### Now is the Buffer Overflow

...
