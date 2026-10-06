**Loader**

> do `./app` até o `main`, e do `return` até o fim do processo

O loader é a parte do sistema operacional que transforma um arquivo executável em um processo rodando: ele mapeia o arquivo na memória, carrega as bibliotecas dinâmicas, aplica as relocations, roda os inicializadores e só então chama o seu `main`. O trabalho é dividido entre o **kernel** e o **dynamic loader** (`ld-linux.so` no Linux, `dyld` no macOS), que é um programa comum em espaço de usuário

```bash
strace -f ./app 2>&1 | head -40   # Linux: execve, mmap e open de cada biblioteca
LD_SHOW_AUXV=1 ./app              # Linux: informações que o kernel passou ao processo
/lib64/ld-linux-x86-64.so.2 --list ./app   # Linux: como o ldd, sem executar o programa
```

---

**Linux, passo a passo**

```text
shell: fork() + execve("./app", argv, envp)
   │
   ▼
kernel
   ├─ lê o ELF header e os program headers (ver elf.md)
   ├─ mapeia os segments LOAD com suas permissões (ASLR escolhe a base se for PIE)
   ├─ zera o .bss, cria a pilha com argc, argv, envp e o auxiliary vector
   ├─ tem INTERP?  não → pula para e_entry (_start) do programa  [binário estático]
   └─ sim → mapeia /lib64/ld-linux-x86-64.so.2 e pula para a entrada dele
   │
   ▼
ld-linux.so (dynamic loader)
   ├─ lê DT_NEEDED e carrega cada biblioteca, recursivamente (libc.so.6, ...)
   ├─ aplica as relocations dinâmicas (ver relocations.md)
   ├─ ativa RELRO (GOT somente leitura) se houver
   ├─ roda os inicializadores das bibliotecas (.init_array)
   └─ pula para _start do programa
   │
   ▼
_start (crt1.o) → __libc_start_main
   ├─ inicializa a libc (stdio, TLS, atexit)
   ├─ roda os inicializadores do programa (__attribute__((constructor)))
   ├─ status = main(argc, argv, envp)
   └─ exit(status)
          ├─ funções registradas com atexit, em ordem inversa
          ├─ destrutores (.fini_array) do programa e das bibliotecas
          ├─ fflush de todos os streams abertos (ver ../../io/fflush.md)
          └─ _exit(status) → syscall: o kernel libera a memória e fecha os fds
```

---

**A pilha inicial**

```text
endereço alto
  strings de argv e envp
  auxv: AT_PHDR, AT_ENTRY, AT_BASE, AT_RANDOM, AT_PAGESZ ...
  NULL
  envp[0..n]
  NULL
  argv[0..argc-1]
  argc                 ← rsp ao entrar no _start
endereço baixo
```

- É daí que vêm o `argc`/`argv` do `main`, o `environ` e o `getauxval()`
- O `AT_RANDOM` fornece bytes aleatórios do kernel, usados, por exemplo, para o stack canary (`-fstack-protector`)

---

**macOS, passo a passo**

```text
execve("./app")
   │
   ▼
kernel (XNU)
   ├─ lê o Mach-O e os load commands (ver mach-o.md)
   ├─ confere a assinatura de código (obrigatória em ARM64)
   ├─ mapeia os segments (com __PAGEZERO cobrindo os primeiros 4 GB)
   └─ mapeia /usr/lib/dyld (LC_LOAD_DYLINKER) e pula para ele
   │
   ▼
dyld
   ├─ mapeia o dyld shared cache (libSystem e as bibliotecas do sistema)
   ├─ carrega as dylibs de LC_LOAD_DYLIB, resolvendo @rpath
   ├─ aplica rebase e bind (chained fixups)
   ├─ roda os inicializadores (constructors) das dylibs e do programa
   └─ chama main diretamente (LC_MAIN), sem _start/crt1.o
   │
   ▼
main retorna → exit(status) → atexit, destrutores, flush → syscall de saída
```

---

**Comportamentos que vêm daqui**

- `return 0;` no `main` equivale a `exit(0)`. `_exit(0)` encerra **sem** rodar `atexit` nem esvaziar os buffers de `stdio`, então dados em um `printf` sem `\n` podem se perder
- Um programa que falha antes do `main` (`error while loading shared libraries`, `dyld: Library not loaded`) falhou no loader: o código nem começou a rodar (ver `../common-errors.md`)
- Inicializadores (`__attribute__((constructor))`) rodam antes do `main`, mas a ordem entre bibliotecas diferentes só é garantida pela dependência: uma biblioteca é inicializada depois das que ela usa
- O próprio loader pode rodar um programa: `/lib64/ld-linux-x86-64.so.2 ./app` executa `app` mesmo sem permissão de execução, útil para depurar o carregamento

> `ldd ./app` funciona, na glibc, executando o loader com uma variável especial, e em alguns casos pode acabar executando código do binário. Não use `ldd` em executáveis não confiáveis. `readelf -d app | grep NEEDED` ou `objdump -p app | grep NEEDED` leem o arquivo sem executá-lo (mas só mostram as dependências diretas)
