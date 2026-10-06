**Atributos do terminal e bitmasks**

> `struct termios` e como manipular suas flags

A `struct termios` guarda toda a configuração de um terminal. Quatro dos seus campos (`c_iflag`, `c_oflag`, `c_cflag`, `c_lflag`) são **bitmasks**: um único inteiro em que cada bit liga ou desliga uma opção diferente. O quinto (`c_cc`) é um array de caracteres. Entender as operações de bits é o que transforma o código de `termios` de "receita" em algo legível

```c
struct termios {
  tcflag_t c_iflag;     // bitmask: modos de entrada
  tcflag_t c_oflag;     // bitmask: modos de saída
  tcflag_t c_cflag;     // bitmask (+ campos de vários bits): modos de controle
  tcflag_t c_lflag;     // bitmask: modos locais
  cc_t     c_cc[NCCS];  // array: caracteres de controle e VMIN/VTIME
};
```

- `c_iflag`: o que fazer com cada byte que chega (ver `input-flags.md`)
- `c_oflag`: o que fazer com cada byte que sai (ver `output-flags.md`)
- `c_cflag`: formato do caractere no hardware. Tem campos de **vários bits**, como `CSIZE` (ver `control-flags.md`)
- `c_lflag`: echo, modo canônico, sinais (ver `local-flags.md`)
- `c_cc`: indexado por constantes como `VINTR`, `VEOF`, `VMIN`. Cada posição guarda um byte (ver `control-characters.md`)
- `NCCS` é o tamanho do array: 32 no Linux (glibc), 20 no macOS

**O que é uma flag**

Cada constante é um número com **exatamente um bit** ligado (ou, em campos como `CSIZE`, um grupo de bits):

```text
ECHO    = 0b0000_0000_1000   (valor 8 no Linux)
ICANON  = 0b0000_0000_0010   (valor 2 no Linux)

c_lflag = 0b1000_1010_1011   ← vários bits ligados ao mesmo tempo
                     ↑   ↑
                  ECHO  ICANON
```

- Os valores numéricos variam entre sistemas (no macOS, `ICANON` vale `0x100`). Use sempre os nomes, nunca os números
- Um `tcflag_t` de 32 ou 64 bits guarda dezenas de opções independentes em uma única variável. É por isso que APIs de sistema (`termios`, `open()` com `O_RDONLY | O_CREAT`, `mmap()` com `PROT_READ | PROT_WRITE`) usam bitmasks: compacto, rápido de testar e fácil de combinar várias opções em um único argumento

**Os três operadores**

```text
       |  (OR)                &  (AND)               ~  (NOT)
  bit:  0|0=0 0|1=1 1|1=1     0&0=0 0&1=0 1&1=1      ~0=1 ~1=0
  uso:  ligar bits            testar / manter bits   inverter todos os bits
```

**Ligando uma flag**: `|=`

```c
term.c_lflag |= ECHO;
```

```text
c_lflag  0b0000_0010   (só ICANON)
ECHO     0b0000_1000
         ─────────── |
result.  0b0000_1010   ECHO ligado, ICANON intacto
```

- O OR copia para o resultado todo bit que estiver ligado em **qualquer** um dos lados. Os bits que já estavam ligados continuam, e só o bit de `ECHO` é forçado para 1

**Desligando uma flag**: `&= ~`

```c
term.c_lflag &= ~ECHO;
```

```text
ECHO     0b0000_1000
~ECHO    0b1111_0111   ← todos os bits ligados, exceto o de ECHO

c_lflag  0b0000_1010
~ECHO    0b1111_0111
         ─────────── &
result.  0b0000_0010   ECHO desligado, ICANON intacto
```

- `~ECHO` cria uma máscara com **todos** os bits ligados, menos o de `ECHO`
- O AND só mantém um bit se ele estiver ligado nos **dois** lados: onde a máscara tem 1, o bit original é preservado. Onde tem 0 (a posição de `ECHO`), o resultado é 0
- `term.c_lflag = ~ECHO` (sem o `&`) seria um erro grave: ligaria todas as outras flags

**Várias flags de uma vez**

```c
term.c_lflag &= ~(ICANON | ECHO);
```

1. `ICANON | ECHO`: junta as duas flags em uma máscara com os dois bits ligados
2. `~(...)`: inverte, gerando uma máscara com todos os bits ligados exceto esses dois
3. `&=`: zera exatamente esses dois bits em `c_lflag` e mantém todos os outros

**Testando uma flag**: `&`

```c
if (term.c_lflag & ECHO) {
  // ECHO está ligado: o resultado é ECHO (diferente de 0)
}
```

**Campos de vários bits**

```c
term.c_cflag &= ~CSIZE;   // zera os 2 bits do campo de tamanho
term.c_cflag |= CS8;      // escreve o valor "8 bits" nesse campo
```

- `CSIZE` é uma máscara de **dois** bits que guarda um valor (`CS5`, `CS6`, `CS7` ou `CS8`), e não quatro flags independentes. Fazer só `|= CS7` sobre um campo que já tinha `CS8` daria `CS8 | CS7 = CS8` em vez de `CS7`. Sempre limpe o campo antes de escrever um novo valor. O mesmo vale para `NLDLY`, `CRDLY`, `TABDLY` em `c_oflag`

> Mudar a `struct` não muda nada no terminal: ela é só uma cópia em memória do seu programa. A configuração só é aplicada quando a `struct` é passada para `tcsetattr()` (ver `tcgetattr-tcsetattr.md`)
