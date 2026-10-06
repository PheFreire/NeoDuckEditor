**Tabela de símbolos**

> `.symtab` / `.dynsym` no ELF, `LC_SYMTAB` no Mach-O

A tabela de símbolos é a estrutura dentro de um arquivo objeto, executável ou biblioteca que lista cada símbolo com nome, endereço, tamanho, tipo e visibilidade. O `nm` mostra uma versão resumida dela (ver `../symbols.md`). Aqui está o que cada campo significa e como o linker e o loader usam essas informações

```bash
readelf -s main.o       # Linux: tabela completa (.symtab)
readelf --dyn-syms app  # Linux: só os símbolos dinâmicos (.dynsym)
nm -m main.o            # macOS: nm com detalhes de section e tipo
dyld_info -exports libfila.dylib   # macOS: símbolos exportados de uma dylib
```

---

**Uma entrada no ELF**

```text
readelf -s main.o
  Num:    Value          Size Type    Bind   Vis      Ndx Name
    0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
    1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 .text
    3: 0000000000000000     4 OBJECT  LOCAL  DEFAULT    4 interno
    4: 0000000000000000    11 FUNC    LOCAL  DEFAULT    1 auxiliar
    5: 0000000000000000     4 OBJECT  GLOBAL DEFAULT    3 contador
    6: 0000000000000010    35 FUNC    GLOBAL DEFAULT    1 main
    7: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND soma
```

- `Name`: não fica na entrada. Ela guarda só um offset para a string correspondente em `.strtab`
- `Value`: em um `.o`, o offset dentro da section. No executável, o endereço virtual
- `Size`: tamanho em bytes da função ou variável
- `Type`: `FUNC` (função), `OBJECT` (variável), `SECTION`, `FILE` (nome do fonte), `TLS` (`_Thread_local`), `NOTYPE` (desconhecido, comum em indefinidos)
- `Bind`:
	- `LOCAL`: visível só dentro do arquivo (`static`). Não participa da resolução entre arquivos
	- `GLOBAL`: visível para todos. Deve haver uma única definição
	- `WEAK`: global, mas pode ser substituído por uma definição `GLOBAL`, e pode ficar sem definição (vale `0`)
- `Vis` (visibilidade, importante em `.so`): `DEFAULT` (exportado), `HIDDEN` (global entre os `.o` da mesma biblioteca, mas não exportado), `PROTECTED`
- `Ndx`: índice da section onde o símbolo está definido. `UND` = indefinido, `ABS` = valor absoluto, `COM` = common symbol

---

**.symtab vs .dynsym**

| | `.symtab` | `.dynsym` |
|---|---|---|
| Contém | todos os símbolos, inclusive locais | só os necessários em tempo de execução: importados e exportados |
| Usado por | linker, debuggers, `nm`, profilers | dynamic loader |
| Carregado na memória | não | sim |
| Removido pelo `strip` | sim | não (o programa precisa dele para rodar) |

- `nm -D libfila.so` mostra o `.dynsym`: é a "API binária" que a biblioteca exporta

---

**Mach-O**

- O load command `LC_SYMTAB` aponta para um array de entradas `nlist_64` e uma string table, ambas no `__LINKEDIT`
- O campo `n_type` combina flags: `N_EXT` (externo/global), `N_UNDF` (indefinido), `N_SECT` (definido em uma section), `N_PEXT` (private extern, equivalente ao `HIDDEN`)
- `LC_DYSYMTAB` divide a tabela em três faixas: locais, definidos externos e indefinidos
- Entradas de debug do tipo `N_OSO` formam o "debug map" que aponta para os `.o` com o DWARF (ver `../debugging.md`)

---

**Como o linker usa a tabela**

- **Estático** (ver `static-linking.md`): para cada `UND`, procura uma definição `GLOBAL` ou `WEAK`. Duas `GLOBAL` = `multiple definition`. Uma `GLOBAL` e uma `WEAK` = vence a `GLOBAL`, sem erro
- **Dinâmico** (ver `dynamic-linking.md`): no Linux, o loader procura cada símbolo indefinido do `.dynsym` nas bibliotecas carregadas, **em ordem**, e usa a primeira que exporta aquele nome. É o que permite o `LD_PRELOAD` substituir o `malloc`. No macOS, o símbolo está amarrado a uma dylib específica (two-level namespace)

---

**Weak e visibilidade em C**

```c
__attribute__((weak)) void log_hook(const char *msg) { }   // implementação padrão substituível

__attribute__((visibility("hidden"))) int helper(void);     // não exportado pela .so
```

```bash
gcc -fPIC -shared -fvisibility=hidden fila.c -o libfila.so  # tudo hidden por padrão
# e marcar a API pública com __attribute__((visibility("default")))
```

- Exportar só a API pública deixa a biblioteca menor, mais rápida de carregar (menos símbolos para resolver) e permite ao compilador otimizar chamadas internas

> Um executável strippado ainda roda e ainda tem nomes no `.dynsym` (funções importadas como `printf`), mas as funções internas viram só endereços em backtraces. Para manter os símbolos fora do binário de produção sem perdê-los, separe o debug info: `objcopy --only-keep-debug app app.debug` e `strip app` (Linux), ou o `.dSYM` (macOS)
