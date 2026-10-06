**Input flags**

> campo `c_iflag` de `struct termios`

O `c_iflag` controla o pré-processamento dos bytes **recebidos** pelo terminal, antes que a parte de `c_lflag` (modo canônico, echo, sinais) os veja. Ele decide conversões entre `\r` e `\n`, controle de fluxo por software e o tratamento de erros de transmissão (break, paridade). Parte das flags é essencial para terminais interativos. Outra parte só faz sentido em comunicação serial, onde a linha física pode ter ruído

```text
byte recebido ──► c_iflag ──► c_lflag / c_cc ──► fila de leitura ──► read()
                  IGNBRK/BRKINT  (quebra)
                  INPCK/PARMRK   (paridade)
                  ISTRIP         (7 bits)
                  INLCR/IGNCR/ICRNL (\r e \n)
                  IXON/IXOFF     (controle de fluxo)
```

**Conversões de fim de linha** (terminal interativo)

O Enter do teclado envia `\r` (carriage return, 13), herança dos terminais físicos. O Unix usa `\n` (line feed, 10) como fim de linha. Estas flags fazem a ponte:

- `ICRNL`: converte `\r` recebido em `\n`. **Ligada por padrão**
	- Ligada: o Enter chega como `\n`, termina a linha no modo canônico e é o que `fgets`/`scanf` esperam
	- Desligada: o Enter chega como `\r` (13). `Ctrl+M` (também 13) e `Ctrl+J` (`\n`, 10) passam a ser teclas diferentes. É desligada em raw mode para que o programa veja o byte real
	- Em modo canônico com `ICRNL` desligada, o Enter não termina mais a linha: é a causa de terminais "travados" depois de um programa em raw mode sair sem restaurar (use `Ctrl+J` para enviar `\n`)
- `INLCR`: converte `\n` recebido em `\r`. Raro. Usado com dispositivos que esperam o contrário
- `IGNCR`: descarta todo `\r` recebido. Útil para dispositivos que enviam `\r\n`, para não ficar com um `\r` sobrando antes de cada `\n`
- Se `IGNCR` estiver ligada, `ICRNL` não tem efeito

**Controle de fluxo por software** (terminal e serial)

- `IXON`: liga o controle de fluxo da **saída**. **Ligada por padrão**
	- Ligada: `Ctrl+S` (`VSTOP`, byte 19) pausa toda a saída do terminal, e `Ctrl+Q` (`VSTART`, byte 17) a retoma. Os dois bytes são consumidos e nunca chegam ao programa
	- Desligada: `Ctrl+S` e `Ctrl+Q` chegam ao `read()` como bytes comuns. Editores desligam para usar `Ctrl+S` como "salvar"
	- Com `IXON` ligada, um `Ctrl+S` acidental faz o terminal parecer **congelado**: o programa continua rodando, mas toda escrita fica bloqueada. `Ctrl+Q` resolve
- `IXANY`: com `IXON`, qualquer tecla (e não só `Ctrl+Q`) retoma a saída. Não é POSIX base, mas existe no Linux e no macOS
- `IXOFF`: controle de fluxo da **entrada**: quando a fila de entrada está quase cheia, o terminal **envia** `VSTOP` para o outro lado parar de transmitir, e `VSTART` quando houver espaço. Relevante em serial com dispositivos que respeitam XON/XOFF. Desligada por padrão

**Break** (principalmente serial)

Uma "condição de break" é a linha serial mantida em nível zero por mais tempo que um caractere inteiro. Terminais antigos tinham uma tecla Break que fazia isso:

- `IGNBRK`: ignora o break completamente
- `BRKINT`: se `IGNBRK` estiver desligada, o break descarta as filas e envia `SIGINT` ao grupo em foreground, como um `Ctrl+C`
- Com as duas desligadas, o break chega ao programa como um byte `\0` (ou como `\377 \0 \0`, com `PARMRK`)
- Em PTYs, não existe break físico. O emulator raramente gera um. Por isso essas flags quase não importam em terminais interativos, mas são desligadas em raw mode por segurança

**Paridade e bits** (serial)

- `INPCK`: liga a **verificação** de paridade na entrada. Só faz sentido se `PARENB` estiver ligada em `c_cflag` (ver `control-flags.md`)
- `IGNPAR`: bytes com erro de paridade ou de framing são descartados
- `PARMRK`: bytes com erro são entregues marcados com o prefixo `\377 \0`. Um byte `\377` legítimo chega duplicado (`\377 \377`). Permite ao programa detectar o erro, mas complica a leitura
- `ISTRIP`: zera o 8º bit de cada byte, deixando só 7 bits. Herança de linhas de 7 bits. Ligada, ela **corrompe** UTF-8 e qualquer dado binário. Desligada por padrão nos sistemas modernos e em raw mode

**Outras**

- `IUTF8` (Linux, não POSIX): faz o Backspace em modo canônico apagar um caractere UTF-8 inteiro (vários bytes), e não só o último byte
- `IMAXBEL` (não POSIX): toca o sino quando o buffer de linha está cheio

> Para um terminal interativo, as flags de `c_iflag` que realmente importam são `ICRNL` e `IXON`. O resto é desligado em raw mode mais por garantia do que por efeito visível. Em uma porta serial, `INPCK`, `IGNPAR`, `PARMRK`, `ISTRIP`, `IXOFF` e as de break definem como o programa lida com erros de transmissão
