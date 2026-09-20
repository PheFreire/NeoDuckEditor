**llseek**

O `llseek` move o cursor de posição do objeto I/O, só fazendo sentido para recursos que possuem uma noção de posição, como arquivos

```c
loff_t llseek(struct file *file, loff_t offset, int whence);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `offset`: quantos bytes mover o cursor a partir do ponto de referência definido em `whence`
- `whence`: o ponto de referência de onde `offset` é contado (`SEEK_SET`, `SEEK_CUR` ou `SEEK_END`, os mesmos usados pelo `fseek` em userspace)

- Corresponde à chamada de sistema `lseek(fd, offset, whence)`, sendo o `lseek()` no comentário do código-fonte
- Retorna a nova posição do cursor após o movimento

```c
lseek(fd, 0, SEEK_END); // chamada feita em userspace
```

