**cmake_minimum_required**

> comando nativo do CMake, não precisa de include

O `cmake_minimum_required` define a versão mínima do CMake que o projeto exige e faz o CMake se comportar como aquela versão, sendo sempre a primeira linha do `CMakeLists.txt` raiz

```cmake
cmake_minimum_required(VERSION <mínima>[...<máxima>])
```

- `mínima`: a menor versão aceita, como `3.20`. Um CMake mais antigo para o configure com erro
- `máxima`: opcional, a versão mais nova que o projeto conhece. Os comportamentos novos até ela são ativados

- Cada mudança de comportamento do CMake (uma `policy`) só é ativada quando a versão mínima é igual ou maior que a versão em que ela surgiu. Por isso o mesmo projeto se comporta igual em um CMake novo
- A partir do CMake 4.0, uma versão mínima abaixo de `3.5` faz o configure falhar
- Escolha a versão pelos recursos que o projeto usa, e não pela versão instalada na sua máquina

```cmake
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)
```

> Sem ele, o CMake avisa no configure e usa o comportamento de versões muito antigas. O `3.20` é um bom mínimo: está disponível em quase todas as distros atuais e já tem tudo que estas notas usam
