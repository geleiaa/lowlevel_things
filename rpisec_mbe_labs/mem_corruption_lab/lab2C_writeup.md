### Solving lab2C "02/13 | --[ Memory Corruption Lab" (https://github.com/RPISEC/MBE/blob/master/src/lab02/lab2C.c)

### This lab is a simple buffer-overflow. The intention of this lab was to explore bof and get a shell from the lab machine and then get the flag. But here we won't have the shell part.

#### First we go get the source code and compile following the instruction that is commented in the code.

(code img)

```
gcc -O0 -fno-stack-protector lab2C.c -o lab2C
```


