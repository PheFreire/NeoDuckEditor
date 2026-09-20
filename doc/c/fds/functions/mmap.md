**mmap**

Pelo grau de complexidade, o `mmap` recebe uma explicação mais detalhada que as demais operações

O `mmap` cria um mapeamento de memória entre o objeto I/O e o espaço de endereçamento do processo, permitindo que o processo acesse aquele recurso diretamente como se fosse memória, sem precisar de chamadas explícitas de `read`/`write`

```c
int mmap(struct file *file, struct vm_area_struct *vma);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `vma`: a área de memória virtual do processo que vai ser mapeada para aquele recurso; é essa estrutura que o driver/sistema de arquivos configura para associar endereços de memória às páginas do objeto I/O

Em userspace, esse mapeamento é solicitado através da própria chamada de sistema `mmap`:

```c
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
```

- `addr`: um endereço sugerido para o mapeamento, geralmente `NULL` para deixar o kernel escolher
- `length`: o tamanho, em bytes, da região a ser mapeada
- `prot`: as permissões de acesso à região mapeada, como `PROT_READ` e `PROT_WRITE`
- `flags`: como o mapeamento se comporta, por exemplo `MAP_SHARED` para que as alterações sejam refletidas de volta no objeto original
- `fd`: o file descriptor do objeto que será mapeado
- `offset`: a partir de que byte do objeto o mapeamento deve começar

```c
void *ptr = mmap(NULL, tamanho, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
```

> Sem `mmap`, o processo chama `read()` e o kernel copia dados do objeto para um buffer em userspace. Com `mmap`, o processo usa o `fd` para pedir ao kernel um mapeamento de memória, e o retorno é um ponteiro para uma região da memória virtual do processo associada diretamente ao objeto, sem essa cópia intermediária


