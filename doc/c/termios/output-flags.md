**Output flags**

> campo `c_oflag` de `struct termios`

O `c_oflag` controla o processamento dos bytes **escritos** pelo programa antes de chegarem ao terminal. A transformação mais importante, e quase a única que importa hoje, é converter o `\n` do Unix em `\r\n`, a sequência que um terminal precisa para voltar à coluna 0 e descer uma linha

```text
write(STDOUT_FILENO, "oi\n", 3)
          │
          ▼
       c_oflag   OPOST ligado + ONLCR:  "oi\n" → "oi\r\n"
          │
          ▼
  PTY master → terminal emulator desenha
```

---

**OPOST**

- Chave geral do processamento de saída. **Ligada por padrão**
- Ligada: as outras flags de `c_oflag` (como `ONLCR`) são aplicadas
- Desligada: todos os bytes saem **exatamente** como foram escritos, e o resto de `c_oflag` é ignorado
- É desligada em raw mode para que o programa tenha controle total sobre o que vai para a tela (escape sequences, posicionamento do cursor)

---

**Por que \n precisa virar \r\n**

Para o terminal, `\r` e `\n` são dois movimentos diferentes do cursor:

```text
\r (carriage return): volta para a coluna 0, na mesma linha
\n (line feed):       desce uma linha, na mesma coluna
```

Sem a conversão, cada linha começa na coluna onde a anterior terminou:

```c
printf("linha 1\nlinha 2\nlinha 3\n");
```

```text
OPOST ligado (padrão)       OPOST desligado (raw mode)
linha 1                     linha 1
linha 2                            linha 2
linha 3                                   linha 3
```

- Em raw mode, escreva `\r\n` explicitamente: `write(STDOUT_FILENO, "linha 1\r\n", 9)`
- Alternativa: desligar o raw mode completo, mas manter `OPOST` (não desligar o `c_oflag`) quando só a entrada precisa ser crua

---

**Flags dependentes de OPOST**

- `ONLCR`: converte `\n` em `\r\n`. **Ligada por padrão**. É a que causa todo o comportamento descrito acima (XSI, presente no Linux e no macOS)
- `OCRNL`: converte `\r` em `\n`
- `ONOCR`: não envia `\r` se o cursor já estiver na coluna 0
- `ONLRET`: o terminal faz o `\n` também voltar à coluna 0, então o driver ajusta a contagem de coluna
- `TABDLY` com `TAB3` (também `XTABS` no Linux e `OXTABS` no macOS): expande `\t` em espaços
- `NLDLY`, `CRDLY`, `BSDLY`, `VTDLY`, `FFDLY`: atrasos (ou caracteres de preenchimento) depois de certos caracteres, para terminais mecânicos lentos. São campos de vários bits (limpe com a máscara antes de escrever, como em `terminal-attributes.md`). Sem uso em hardware atual

---

**Quando o c_oflag importa**

- Terminal interativo em modo normal: nunca é preciso mexer. `OPOST | ONLCR` faz `printf("\n")` funcionar
- Raw mode: desligar `OPOST` é o padrão (`cfmakeraw` faz isso) e exige `\r\n` no código
- Saída redirecionada para arquivo ou pipe: o `c_oflag` não se aplica (não há terminal no caminho), e o arquivo recebe só `\n`. Por isso o mesmo programa gera arquivos corretos com `./app > saida.txt`
- Porta serial com um dispositivo que espera `\r\n` ou só `\r`: ajuste `ONLCR`/`OCRNL`, ou desligue `OPOST` e envie o terminador exato

---

**Relação com o echo**

O echo de `ECHO` (ver `local-flags.md`) também passa pelo processamento de saída. Em raw mode sem `OPOST`, se o programa ecoar manualmente um Enter recebido (`\r`), o cursor só volta para a coluna 0, sem descer. Ecoe `\r\n`

> O `c_oflag` age na **saída do terminal**, e não no `FILE *` do `stdio`. O buffer do `printf` acontece antes, dentro do seu processo. Só quando ele chama `write()` os bytes entram no kernel e passam por `OPOST`. Em raw mode, lembre também do `fflush(stdout)`, pois sem `\n` o `stdout` pode não ser enviado ao terminal
