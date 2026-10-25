**Erros comuns no Clang**

> como as mensagens do Clang aparecem e o que é diferente do GCC

As causas dos erros de compilação e de linking são as mesmas nos dois compiladores, e a explicação de cada uma (significado, etapa, como investigar e corrigir) está em `gcc/cheatsheet/common-errors.md`. Esta nota mostra como o Clang escreve cada erro, para reconhecê-lo pela mensagem, e os erros que só aparecem no Clang

```text
fatal error: 'x.h' file not found              → preprocessor
main.c:10:5: error: ...                        → frontend
Undefined symbols / ld: ... / duplicate symbol → linker
clang: error: linker command failed            → driver avisando que o linker falhou
clang: error: unknown argument / unsupported   → driver: problema na linha de comando
```

---

**linker command failed with exit code 1**

```text
Undefined symbols for architecture arm64:
  "_soma", referenced from:
      _main in main-8d880f.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

1. **Significado**: a última linha só diz que o linker falhou. O erro de verdade está **acima** dela
2. **Etapa**: linking
3. **Causas**: as mesmas do `undefined reference` do GCC, como faltar o `.c` que define `soma` ou a `-l` da biblioteca
4. **Investigar**:
    - Ler as linhas antes do `clang: error`
    - `clang -v ...` mostra o comando completo passado ao `ld`
    - No macOS, os nomes aparecem com `_` na frente (`_soma`), que é como o Mach-O guarda os símbolos de C
5. **Corrigir**: igual ao GCC. O `main-8d880f.o` é um `.o` temporário que o driver criou ao compilar e linkar em um único comando

No Linux, com o GNU ld ou o lld, a primeira parte é a mensagem do próprio linker:

```text
/usr/bin/ld: /tmp/main-1a2b3c.o: in function `main': main.c:(.text+0x1f): undefined reference to `soma'
ld.lld: error: undefined symbol: soma
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

---

**call to undeclared function**

```text
impl.c:1:24: error: call to undeclared function 'soma'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
```

1. **Significado**: a função foi chamada sem declaração visível antes. É o `implicit declaration` do GCC
2. **Etapa**: frontend
3. **Diferença**: no Clang 16+ é **erro** por padrão a partir do C99. No GCC, só a partir do GCC 14. Código antigo que compilava com warnings pode parar de compilar ao trocar de compilador
4. **Corrigir**: incluir o header certo (`man 3 nome_da_funcao`) ou declarar a função antes do uso

---

**incompatible integer to pointer conversion**

```text
ic.c:1:33: error: incompatible integer to pointer conversion initializing 'int *' with an expression of type 'int'; take the address with & [-Wint-conversion]
```

1. **Significado**: um `int` foi usado onde se esperava um ponteiro, como `int *p = x` em vez de `int *p = &x`
2. **Etapa**: frontend
3. **Diferença**: erro por padrão a partir do Clang 15. A própria mensagem sugere a correção (`take the address with &`)
4. **Corrigir**: quase sempre falta um `&`, ou a função devolve `int` porque foi chamada sem declaração (o caso acima)

O caso parecido entre dois tipos de ponteiro continua sendo só warning no Clang, mas é erro no GCC 14+:

```text
ipt.c:1:34: warning: incompatible pointer types initializing 'long *' with an expression of type 'int *' [-Wincompatible-pointer-types]
```

---

**expected `;`**

```text
semi.c:1:26: error: expected ';' at end of declaration
    1 | int main(void){ int x = 1
      |                          ^
      |                          ;
```

- O Clang aponta o fim da linha onde o `;` falta, e não o começo da próxima, como faz o GCC em alguns casos
- A linha abaixo do `^` é o fix-it, com o `;` no lugar exato (ver `diagnostics.md`)

---

**file not found**

```text
hn.c:1:10: fatal error: 'lista.h' file not found
    1 | #include "lista.h"
      |          ^~~~~~~~~
```

1. **Significado**: o preprocessor não encontrou o header. É o `No such file or directory` do GCC
2. **Investigar**: `clang -xc -E -v - < /dev/null` lista os diretórios de busca
3. **Quando só o editor mostra o erro**: o compilador encontra o header pelo `-I` do build, mas o `clangd` não sabe desse `-I`. Falta o `compile_commands.json` (ver `tooling.md`)

---

**library not found**

```text
ld: library 'fila' not found
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

- No macOS a mensagem é do `ld64`. No Linux é `/usr/bin/ld: cannot find -lfila` ou `ld.lld: error: unable to find library -lfila`
- `clang -Wl,-v ...` faz o `ld64` listar os diretórios onde ele procura as bibliotecas

---

**duplicate symbol**

```c
// a.c
int contador = 2;

// b.c
int contador = 1;
int main(void) { return contador; }
```

```text
duplicate symbol '_contador' in:
    /var/folders/.../T/b-4618c6.o
    /var/folders/.../T/a-dcf7e7.o
ld: 1 duplicate symbols
```

- É o `multiple definition` do GCC, com o mesmo significado e a mesma correção (`extern` no header e uma definição só)
- **Cuidado com `-fcommon`**: se um dos arquivos tiver só `int contador;` (sem `=`), o Apple Clang linka sem erro, pois usa `-fcommon` por padrão e junta as duas variáveis em uma. O Clang do LLVM (desde o Clang 11) e o GCC (desde o GCC 10) usam `-fno-common` e dão erro. O mesmo código pode linkar no macOS e falhar no Linux

---

**Erros do driver**

```text
clang: error: unknown argument: '-fipa-pta'
clang: error: unsupported option '-fsanitize=memory' for target 'arm64-apple-darwin24.0.0'
clang: error: invalid linker name in argument '-fuse-ld=lld'
error: unable to create target: 'No available targets are compatible with triple "wasm32"'
```

- `unknown argument`: uma flag do GCC que o Clang não tem (ver `flags.md`)
- `unsupported option ... for target`: a flag existe, mas não para esta plataforma, como os sanitizers que o Apple Clang não tem (ver `sanitizers.md`)
- `invalid linker name`: o linker pedido com `-fuse-ld` não está instalado (ver `linkers.md`)
- `No available targets`: este `clang` foi compilado sem o backend dessa arquitetura (ver `cross-compilation.md`)

> No Clang, a regra de ler o **primeiro** erro continua valendo, com um detalhe: a última linha de um erro de link é sempre o genérico `linker command failed`. Procure a primeira linha que começa com `ld:`, `Undefined symbols`, `duplicate symbol` ou `ld.lld:`. Para limitar a cascata de erros de compilação, use `-ferror-limit=1` (o equivalente ao `-Wfatal-errors` do GCC, que o Clang também aceita)
