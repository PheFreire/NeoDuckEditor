**Static linking em detalhe**

> como o linker processa `.o` e `.a`, e o que é um binário estático

Static linking é o processo de juntar código compilado **dentro** do executável na hora do link. Acontece sempre com os seus `.o` e com bibliotecas `.a`. Um binário "totalmente estático" é aquele em que até a libc foi copiada para dentro, sem depender de nenhuma biblioteca dinâmica para rodar. Este arquivo aprofunda `../linking.md` e `../libraries.md`

```bash
gcc main.o fila.o -L. -lestruturas -o app   # seus .o + membros necessários de libestruturas.a
gcc -static main.c -o app                   # Linux: tudo estático, inclusive a libc
file app                                    # ... statically linked
```

---

**Como o linker processa os argumentos**

```text
gcc main.o -la -lb

estado: indefinidos = {}

main.o          → sempre entra inteiro       indefinidos = {f, g}
liba.a          → membro x.o define f → entra, x.o usa h  indefinidos = {g, h}
                  (membros que não resolvem nada são ignorados)
libb.a          → membro y.o define g, z.o define h → entram  indefinidos = {}
```

- `.o` passados diretamente sempre entram por inteiro, mesmo que nada deles seja usado
- De um `.a`, entram apenas os **membros** (`.o` internos) que definem algum símbolo indefinido **naquele momento**. O índice criado pelo `ar s` permite fazer essa busca sem abrir cada membro
- Um membro extraído pode criar novos indefinidos, e o linker volta a varrer **o mesmo** `.a` até ele não fornecer mais nada, mas não volta aos `.a` anteriores. Daí a regra de ordem: quem usa vem antes de quem define
- Granularidade: um membro entra inteiro. Se `utils.o` tiver 50 funções e você usar uma, as 50 vão para o executável. Bibliotecas como a libc colocam cada função em um `.o` separado por isso

---

**Removendo código não usado**

```bash
gcc -ffunction-sections -fdata-sections -c *.c   # cada função/variável em sua própria section
gcc -Wl,--gc-sections *.o -o app                 # Linux: descarta sections não referenciadas
gcc -Wl,-dead_strip *.o -o app                   # macOS: equivalente
gcc -Wl,--print-gc-sections ...                  # mostra o que foi removido
```

---

**Forçando a inclusão de um .a inteiro**

Se um `.o` dentro do `.a` não é referenciado por nome (por exemplo, ele só tem um `__attribute__((constructor))` que se registra sozinho), o linker nunca o extrai:

```bash
gcc main.o -Wl,--whole-archive -lplugins -Wl,--no-whole-archive -o app   # Linux
gcc main.o -Wl,-force_load,libplugins.a -o app                           # macOS
```

---

**Binário totalmente estático**

- **Linux**: `-static` usa a versão `.a` de todas as bibliotecas, incluindo `libc.a`. O resultado não tem `INTERP` nem `DYNAMIC`. O kernel pula direto para o `_start` (ver `loader.md`)
	- Vantagens: roda em qualquer Linux da mesma arquitetura, sem "library not found". Inicia um pouco mais rápido
	- Desvantagens: binário maior. Correções de segurança da libc exigem relinkar. Com glibc, funções que usam NSS (`getpwnam`, `getaddrinfo`) ainda tentam carregar `.so` em tempo de execução e emitem um warning no link. A `musl` (`musl-gcc`) é a escolha comum para binários realmente estáticos
	- `-static-pie`: estático e ainda assim PIE, mantendo ASLR
- **macOS**: não suportado para executáveis. A `libSystem` (libc, libm, pthreads) só existe como dynamic library no `dyld shared cache`, e a ABI estável da Apple é a da `libSystem`, não a das syscalls. Você ainda pode linkar estaticamente as suas próprias `.a`
- Meio-termo, linkando estaticamente só algumas bibliotecas:

```bash
gcc main.o -Wl,-Bstatic -lfila -Wl,-Bdynamic -o app   # Linux: libfila.a, o resto dinâmico
gcc main.o ./libfila.a -o app                         # qualquer sistema: caminho direto do .a
gcc -static-libgcc main.c -o app                      # só a libgcc estática
```

---

**Armadilhas**

- Símbolo duplicado entre duas `.a`: **não** gera `multiple definition` se o primeiro membro já resolveu o símbolo, porque o segundo membro nem é extraído. A versão usada depende da ordem dos `-l`, silenciosamente
- Mudar uma `.a` não atualiza os executáveis que já foram linkados com ela. É preciso relinkar
- LTO (`-flto`) com `.a`: use `gcc-ar` em vez de `ar` para criar o arquivo, para que o índice entenda os objetos LTO

> O linker script define onde cada section vai e qual é o endereço inicial. `gcc -Wl,--verbose` mostra o script padrão (Linux). Raramente é preciso mexer nele em programas comuns, mas ele é central em kernels, bootloaders e firmware de microcontroladores, onde o executável é totalmente estático e precisa ficar em endereços fixos
