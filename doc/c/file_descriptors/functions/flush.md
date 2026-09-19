**flush**

O `flush` é chamado no caminho de fechamento do fd, antes do `release`, para limpar ou finalizar qualquer estado pendente daquela abertura específica

```c
int flush(struct file *file, fl_owner_t id);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `id`: identifica o dono daquela abertura, usado para distinguir entre diferentes processos que compartilham o mesmo fd

- Diferente do `release`, que só roda quando a última referência é fechada, o `flush` roda toda vez que um fd é fechado, mesmo que existam outras referências à mesma abertura
- Muito usado para garantir que erros pendentes de operações anteriores sejam reportados no `close`

> O `flush` não é chamado diretamente por uma função de userspace, ele roda internamente como parte do `close(fd)`

