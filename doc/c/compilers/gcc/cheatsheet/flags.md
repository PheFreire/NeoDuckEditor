**Flags do GCC**

> referência rápida das opções mais usadas

As flags controlam em qual etapa o pipeline para, onde procurar arquivos, quais macros existem, quais avisos aparecem e quanto o compilador otimiza. A maioria é idêntica no Clang

```bash
gcc -std=c17 -g3 -Og -Wall -Wextra -Iinclude -DDEBUG -c src/main.c -o build/main.o
gcc build/main.o build/lista.o -Llib -lm -pthread -o app
```

---

**Saída e etapas** (ver `compilation-pipeline.md`)

- `-o arquivo`: nome da saída. Sem ele: `a.out`, `main.o`, `main.s` ou `stdout`, conforme a etapa
- `-c`: compila e monta, mas **não linka**. Gera um `.o` por `.c`. Usado para compilar arquivos separadamente e linkar depois
- `-S`: para depois de gerar o assembly (`.s`)
- `-E`: para depois do preprocessor e escreve o resultado no `stdout`
- `-save-temps`: guarda todos os intermediários (`.i`, `.s`, `.o`)
- `-v` / `-###`: mostra (ou apenas lista) os programas chamados pelo driver, inclusive os diretórios de busca de headers e bibliotecas

---

**Preprocessor** (ver `preprocessor.md`)

- `-I dir`: adiciona `dir` à lista de diretórios onde procurar headers de `#include`. Procurado **antes** dos diretórios do sistema
- `-D NOME` / `-D NOME=valor`: define uma macro, como se houvesse `#define NOME 1` (ou `valor`) no topo de cada arquivo. Muito usado para `-DDEBUG` ou `-DNDEBUG` (que desliga os `assert`)
- `-U NOME`: remove a definição de uma macro, inclusive as predefinidas pelo compilador
- `-include arquivo.h`: inclui um header no início de todo arquivo, sem precisar de `#include`

---

**Linker** (ver `linking.md` e `libraries.md`)

- `-L dir`: adiciona `dir` à lista de diretórios onde procurar bibliotecas passadas com `-l`
- `-l nome`: linka a biblioteca `libnome.so` ou `libnome.a` (`.dylib`/`.tbd` no macOS). `-lm` → `libm`. Deve vir **depois** dos arquivos que a usam
- `-Wl,opção`: repassa `opção` diretamente ao linker, ex: `-Wl,-rpath,/opt/lib` ou `-Wl,--verbose`
- `-static`: linka tudo estaticamente, sem dependências de bibliotecas compartilhadas (não suportado para executáveis no macOS)
- `-shared` / `-fPIC`: gera uma biblioteca compartilhada / gera código independente de posição, necessário para ela
- `-pthread`: habilita threads POSIX tanto na compilação (define `_REENTRANT`) quanto no link (adiciona a biblioteca de threads). Prefira-o a `-lpthread`, que só faz a parte do link. Precisa estar nas duas etapas

---

**Linguagem**

- `-std=c17`, `-std=gnu17`, `-std=c23`...: escolhe o padrão de C. `c` = ISO puro, `gnu` = com extensões GNU (ver `gcc.md`)
- `-x c`: força a linguagem, ignorando a extensão do arquivo (útil com `-` para ler do `stdin`)

---

**Debug** (ver `debugging.md`)

- `-g`: adiciona informações de debug (DWARF) que permitem ao debugger relacionar cada instrução de máquina ao arquivo, linha, variável e tipo do código-fonte. Não muda o código gerado, só acrescenta metadados
- `-g3`: o mesmo que `-g`, incluindo também as definições de macros, permitindo usá-las dentro do GDB/LLDB
- `-fno-omit-frame-pointer`: mantém o frame pointer, deixando os stack traces de profilers e sanitizers mais confiáveis

---

**Otimização** (ver `optimization.md`)

- `-O0` (padrão), `-Og`, `-O1`, `-O2`, `-O3`, `-Os`: o quanto o compilador transforma o código para ficar mais rápido ou menor
- `-march=native`: gera instruções específicas da CPU atual (AVX, etc). O binário pode não rodar em outras máquinas

---

**Warnings** (ver `warnings.md`)

- `-Wall -Wextra`: liga os avisos mais úteis
- `-Wpedantic`: avisa sobre código fora do padrão ISO definido em `-std`
- `-Werror`: transforma todo warning em erro
- `-Wnome` liga um warning específico, `-Wno-nome` desliga

---

**Instrumentação** (ver `sanitizers.md`)

- `-fsanitize=address,undefined`: detecta erros de memória e comportamento indefinido em tempo de execução. Precisa ser passada na compilação **e** no link

> A ordem das flags quase nunca importa, com uma exceção importante: arquivos e bibliotecas (`-l`) são processados pelo linker da esquerda para a direita, então `-lm` deve vir depois dos `.c`/`.o` que usam funções de `math.h`. Na dúvida, coloque todas as `-l` no final do comando
