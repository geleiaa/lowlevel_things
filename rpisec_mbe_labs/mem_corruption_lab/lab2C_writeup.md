### Solving lab2C "02/13 | --[ Memory Corruption Lab" (https://github.com/RPISEC/MBE/blob/master/src/lab02/lab2C.c)

### This lab is a simple buffer-overflow. The intention of this lab was to explore bof and get a shell from the lab machine and then get the flag. But here we won't have the shell part.

* #### First we go get the source code and compile following the instruction that is commented in the code.

![comp](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/compilelab2ccode.png)

```
gcc -O0 -fno-stack-protector lab2C.c -o lab2C
```

* #### Running the binary we see how to use it

![usg](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/binusage.png)


* #### Running with a string the binary shows that we are not "authenticated" and set_me is 0. It seems that the binary needs a specific string/password.

![auth](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/notauth.png)


* #### Looking at the binary disassemble we see that the strcpy function is called before comparing a memory address with the "0xdeadbeef" bytes. And if this comparison is not true, the flow jumps to the end, prints something and ends the execution. But if the comparison is true a "shell" function is called. This appears to be the expected execution flow.

```
$ objdump -dM intel lab2C | grep -A40 "<main>:"
```

![disas](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/jmp.png)


* #### Now we go debug the binary to see what is do with the input data...

