**fsync**

O `fsync` força os dados pendentes daquele objeto a serem sincronizados com o armazenamento/dispositivo real, garantindo que eles não fiquem apenas em cache

```c
int fsync(struct file *file, loff_t start, loff_t end, int datasync);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `start` e `end`: o intervalo de bytes do objeto que deve ser sincronizado
- `datasync`: quando diferente de `0`, sincroniza apenas os dados, sem esperar por metadados que não afetam a próxima leitura

- Corresponde à chamada de sistema `fsync(fd)` feita em userspace
- Necessário porque, por padrão, escritas em arquivo costumam ficar em cache na memória (page cache) antes de serem gravadas fisicamente no disco

```c
fsync(fd); // chamada feita em userspace
```

