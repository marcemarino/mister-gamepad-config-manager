# Gamepad Config Manager (GCM)

Gerencia, salva e carrega várias configurações de gamepad/controle por CORE no **MiSTer FPGA**.

## Instalação

Para instalar o script, basta copiá-lo para a pasta `Scripts` do seu **MiSTer FPGA**.

Para executá-lo, acesse o menu **Scripts** e selecione `gamepad_config_manager`.

Na primeira execução, o diretório `gcm` será criado dentro da pasta `/media/fat/Scripts`.

Todos os arquivos necessários para o funcionamento do script serão armazenados nessa pasta. Eles serão criados automaticamente na primeira execução e durante a execução do script.

## Como usar

---

# GCM - Gamepad Config Manager

*@MM 2026.09.15*

---

Script para gerenciar configurações de gamepads no `MiSTer FPGA`.

As configurações são salvas em SLOTS que podem ser carregados posteriormente, permitindo múltiplas configurações por gamepad e CORE.

O script é usado principalmente via gamepad.

O teclado é necessário apenas para tarefas de edição e configuração (explicadas neste HELP).

Gamepad refere-se a qualquer controlador (joystick, gamepad, teclado, etc.). Qualquer dispositivo usado como controle pode ser gerenciado.

Neste tutorial, sempre que nos referirmos às pastas `/media/fat/config/inputs` ou `smb://IP/sdcard/config/inputs`, usaremos simplesmente `inputs`. Da mesma forma, para `/media/fat/Scripts` ou `smb://IP/sdcard/Scripts`, usaremos apenas `Scripts`.

Local do arquivo HELP: `Scripts/gcm/data/HELP_pt.txt`

---

## ÍNDICE

---

## 1) Arquivos do MiSTer

## 2) O Script GCM

## 3) Guia de Uso do Script

## 4) Funções do Script

## 5) Guia Rápido

## 6) Informações Importantes

## 7) Fluxograma de Uso - Guia Super-Rápido

---

## 1) Arquivos do MiSTer

---

No MiSTer, os arquivos de configuração de gamepads ficam na pasta `inputs`.

Quando um gamepad é conectado via USB, Bluetooth ou 2.4G e configurado, um arquivo é gerado.

Este arquivo utiliza o prefixo 'input' seguido por um identificador único do gamepad (exemplo: 1234_abcd), o sufixo `v3` para configurações feitas no menu `Define joystick buttons`, ou `jk` para remapeamentos tradicionais, ou ainda `advanced_input_*_v1` para remapeamentos avançados, e a extensão `.map`.

Exemplos:

1. input_1234_abcd_v3.map

2. Intellivision_input_1234_abcd_v3.map

3. MSX_input_1234_abcd_jk.map ou MSX_advanced_input_1234_abcd_v1.map

### Arquivo 1

Configuração feita no MiSTer em `Define joystick buttons`:

input - prefixo do arquivo 1234_abcd - ID do gamepad (hexadecimal) v3 - definição dos botões do joystick .map - extensão

### Arquivo 2

Configuração feita no menu CORE 'Intellivision' em `Define Intellivision buttons`:

A única diferença é o nome do CORE 'Intellivision', que aparece como prefixo, seguido de `input_1234_abcd_v3.map`.

O sufixo `v3` indica que é uma 'definição de botões do joystick' para o CORE 'Intellivision'.

### Arquivo 3

Configuração feita no menu CORE 'MSX' em `Button/Key remap`:

Neste caso, o prefixo será 'MSX' e o sufixo será `jk` ou 'v1' (este acompanhado por 'advanced_input'), indicando que é um `remapeamento de botões/teclas` para o CORE 'MSX'.

---

## 2) O script GCM

---

O MiSTer salva apenas uma configuração de gamepad por CORE.

O script GCM permite salvar essas configurações em SLOTS numerados, que podem ser carregados posteriormente.

Cada gamepad registrado pode ter múltiplos CORES associados, com configurações diferentes.

Funciona como um 'SAVE STATE' do gamepad, podendo incluir a 'definição de botões do joystick (v3)' e/ou o `mapeamento de botões/teclas (jk, advanced_input_*_v1, ou ambos)` para o CORE selecionado, tudo feito automaticamente pelo script.

```text
                            Estrutura em arvore:
               GAMEPAD_1                           GAMEPAD_2
                  |                                   |
       ___________|_________                          |
       |                   |                          |
     CORE_1              CORE_2                     CORE_1
       |                   |                          |
   ____|____       ________|________        __________|___________
   |       |       |       |       |        |      |      |      |
 SLOT_1  SLOT_2  SLOT_1  SLOT_2  SLOT_3  SLOT_1 SLOT_2 SLOT_3 SLOT_4

```

---

## 3) Guia de uso do script

---

Antes de qualquer coisa, você deve configurar pelo menos um gamepad no MiSTer.

Para que um gamepad possa ser adicionado ao script, é necessário possuir pelo menos uma configuração feita através de `Define joystick buttons` no menu do MiSTer. Ao salvar essa configuração, um arquivo contendo a ID do gamepad será criado na pasta `inputs`. Esse arquivo permite que o gamepad seja identificado e fique disponível para registro no script.

Já para adicionar um CORE ao script, é necessário possuir pelo menos uma configuração feita através de 'Define CoreName buttons' e/ou `Button/Key remap` no menu do CORE. Após uma dessas configurações ser salva, um arquivo com o nome do CORE será gerado e identificado pelo script, permitindo que esse CORE seja adicionado pelo menu ADD/EASY. Essa é a maneira mais fácil de adicionar um CORE ao gamepad.

Outra forma de adicionar um CORE é utilizando o menu ADD/EXPERT. Nesse caso, não é necessário possuir uma configuração prévia feita no CORE, mas é necessário conhecer o nome real do CORE, que deverá ser digitado quando solicitado. O script realizará uma busca nas pastas configuradas no menu FOLDERS e, caso o CORE seja encontrado e validado, ele será adicionado ao gamepad.

Devido à sua complexidade, a pasta Arcade não pode ser utilizada nesse modo. Para adicionar CORES de Arcade, utilize o menu EASY. Para isso, basta possuir uma configuração de gamepad já criada para o CORE desejado.

No exemplo a seguir, assumimos que o gamepad foi configurado no MiSTer e também no CORE do Intellivision.

### PASSOS

1. Configure o gamepad no MiSTer em `Define joystick buttons`.

2. Ainda no MiSTer, configure este mesmo gamepad no menu do CORE.

Por exemplo, para 'Intellivision', clique em `Define Intellivision buttons`.

3. Abra este script GCM.

4. No script, clique em 'MANAGE(GAMEPADS)' e `REGISTER`. Registre

o gamepad.

5. No `MENU` inicial, clique em `ADD - ADICIONAR CORE / EASY`.

Selecione o nome do CORE, neste caso, 'Intellivision'.

6. Com o CORE já adicionado, clique no menu `CORES` e selecione o

CORE 'Intellivision'.

7. No `CORE MENU`, clique em 'SAVE CONFIG - CORE --> NOVO SLOT'.

A configuração atual para o gamepad 1234_abcd no 'CORE Intellivision' será salva no 'SLOT 1'. No nosso caso a configuração identificada pelo script foi apenas 'definição de botões do joystick' (v3)' e ela será identificada pela letra J.

Essa configuração de SLOT inclui dois arquivos adicionais que podem ser editados para ajudar na identificação. A edição é opcional.

  a. O primeiro é o 'LAYOUTS - MAPA DE BOTOES', onde você pode especificar a relação entre os botões do gamepad e os controles no CORE.

A primeira linha pode ser editada usando a configuração de botões, enquanto a segunda linha serve como referência padrão.

INFO: 'O controle do 'Intellivision' inclui também um teclado numérico, além do direcional e botões de ação.'

**Exemplo:**

Tela de edição 'LAYOUTS - [EDITAR] MAPA DE BOTÕES (SLOT 1)':

```text
┌───────────────────────────────────────────────────────────┐
│                                                           │
│ ← ↓ ↑ → L U R  3 4 5  1  2        EN CL    A B C = Acao   │
│ ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL |---- OUTROS ----|│
│                                                           │
└───────────────────────────────────────────────────────────┘
```

**Obs.:**

Nos exemplos, estaremos usando um controle 8BitDo M30 e a TAG `Mega/Saturn`, que possui um LAYOUT adequado a esse controle.

TAG do controle do Mega/Saturn: ← ↓ ↑ → A B C X Y Z L1 R1 EXT ST SL (Você pode escolher a TAG que mais se adequa ao seu gamepad.)

Nas TAGs, ST = Start e SL = Select.

Você pode editar a sua própria TAG e usar os símbolos que preferir.

EN = ENTER no controle do Intellivision CL = CLEAR no controle do Intellivision

  b. O segundo é o 'GAMES - LISTA DE JOGOS', onde você pode editar os jogos associados à configuração do 'SLOT 1'.

Cada nome de jogo deve estar em uma linha separada.

**Exemplo:**

Tela de edição 'GAMES - [EDITAR] LISTA DE JOGOS (SLOT 1)':

```text
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│ Burgertime                                                    │
│ Bump'n'Jump                                                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

8. Em seguida, no MiSTer, você pode reconfigurar o gamepad para

outro jogo que necessite de uma configuração de botões diferente.

Basta repetir o PASSO 7, e a nova configuração será salva em um novo SLOT.

É possível visualizar o 'MAPA DE BOTÕES' e a 'LISTA DE JOGOS' nos menus `LAYOUTS` e `GAMES`.

Exemplo com '3 SLOTS' de 'Intellivision':

  a. `MENU` / `LAYOUTS`

**Exemplo:**

Tela da tela de visualização 'LAYOUTS - [VER] MAPA DE BOTÕES':

```text
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  SLOT  ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL       OUTROS      │
│  ----  --------------------------------------- ------------------│
│J   1)  ← ↓ ↑ → L U R  3 4 5  1  2        EN CL    A B C = Acao   │
│J   2)  ← ↓ ↑ → 7 8 9  1 2 3  4  6        5  CL   Sem Botoes Acao │
│J   3)  ← ↓ ↑ → U 0 R  4 5 6  7  9        1  3       A C = Acao   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

Repare na letra J indicando que as configurações salvas nos SLOTs são referentes às 'definição de botões do joystick' para cada jogo.

  b. `MENU` / `GAMES`

**Exemplo:**

Tela de visualização 'GAMES - [VER] LISTA DE JOGOS':

```text
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│ Atlantis - 3                                                  │
│ Bump'n'Jump - 1                                               │
│ Burgertime - 1                                                │
│ Tron - 2                                                      │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

Essa lista, mostrada acima, é organizada em ordem alfabética pelo nome dos jogos.

Note que o 'mapa de botões' e a 'lista de jogos' indicam o SLOT, facilitando o próximo PASSO.

Nota: O exemplo utilizou o CORE Intellivision, mas o mesmo procedimento pode ser seguido para configurar qualquer outro CORE desejado. Basta seguir os mesmos passos com o CORE que você deseja configurar.

Outro exemplo:

CORE Apple-II - Jogos Lode Runner e Karateka

  a. `MENU` / `LAYOUTS`

**Exemplo:**

Tela de visualização 'LAYOUTS - [VER] MAPA DE BOTÕES':

```text
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  SLOT  ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL       OUTROS      │
│  ----  --------------------------------------- ------------------│
│R   1)  J K I L U O                       CT       CTL+k=teclado  │
│A   2)  ← ↓ ↑ → X S W  Z A S  B  SP       EN    DP=setas SP=espaco│
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Obs.:**

EN = ENTER no teclado CT = CONTROL no teclado SP = ESPAÇO no teclado

DP = DPad no gamepad / setas = direções, setas no teclado

Repare na letra R indicando que a configuração salva no SLOT 1 é referente ao `mapeamento de botões/teclas` feita para o jogo Lode Runner.

Já o segundo SLOT é identificado pela letra A indicando que nesse SLOT foram salvas ambas as configurações,'definição de botões do joystick' e `mapeamento de botões/teclas` para o jogo Karateka.

Essa classificação J, R ou A é recorrente das configurações identificadas no momento do SAVE.

Você pode memorizá-las assim: J = Joystick/Gamepad (v3) R = Remapeamento de Botões/Teclas (jk / advanced_input_*_v1) A = Ambas (J + R)

  b. `MENU` / `GAMES`

**Exemplo:**

Tela de visualização 'GAMES - [VER] LISTA DE JOGOS':

```text
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│ Karateka - 2                                                  │
│ Lode Runner - 1                                               │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

Obs.: Nos menus de seleção e visualização de LAYOUTS e GAMES, o símbolo ⇒ indica o último SLOT selecionado e atualmente ativo.

9. `MENU` / `LOAD`: Clique em 'LOAD - SLOT --> CORE' e escolha um

SLOT para carregar a configuração salva e sobrescrever a configuração do CORE.

Os únicos arquivos no MiSTer que são alterados são os `v3` e/ou `jk` ou `advanced_input_*_v1` do CORE, que serão substituídos quando o comando `LOAD` for executado.

  - Se o SLOT estiver identificado como J:

arquivos substituídos: `CORE_input_ID_v3.map`.

**Exemplo:**

Intellivision_input_1234_abcd_v3.map

  - Se for R (Remap):

arquivos substituídos: `CORE_input_ID_jk.map` e/ou `CORE_advanced_input_ID_v1.map`.

Exemplos:

ZX81_input_1234_abcd_jk.map ZX81_advanced_input_1234_abcd_v1.map

  - Se for A (Ambas):

arquivos substituídos: `CORE_input_ID_v3.map` e os arquivos de remapeamento `CORE_input_ID_jk.map` e/ou `CORE_advanced_input_ID_v1.map`.

Exemplos:

MSX_input_1234_abcd_v3.map, MSX_input_1234_abcd_jk.map e/ou MSX_advanced_input_1234_abcd_v1.map

---

## 4) Funções do Script

---

O script GCM inclui as seguintes funções:

  - Gerenciar CORES:

  - CORES - selecionar um dos CORES previamente adicionados ao GCM

  - ADD - Adicionar um CORE:

    - EASY - selecionar em uma lista um CORE já configurado no MiSTer

    - EXPERT - digitar o nome real do CORE

    - FOLDERS - configurar as pastas para procurar CORES no menu EXPERT

    - LIST - listar os CORES instalados nas pastas configuradas

  - VIEW - visualizar names.txt - nomes reais dos CORES e nomes do menu

  - RENAME - renomear um CORE já adicionado ao GCM:

    - RENAME - digite o novo nome para o CORE

    - LIST - mostrar lista de CORES renomeados

  - DELETE - remover um CORE do GCM

  - Gerenciar SLOTS no CORE selecionado (CORE MENU):

  - LOAD - sobrescrever a configuração atual do CORE no MiSTer com uma salva no SLOT selecionado

  - LAYOUTS - visualizar o 'mapa de botões'

  - GAMES - visualizar a 'lista de jogos'

  - SAVE CONFIG - salvar a configuração atual do CORE no MiSTer em um novo SLOT

  - EDIT LAYOUT - editar o 'mapa de botões'

  - EDIT GAMES - editar a 'lista de jogos'

  - MOVE - mover a posição de um SLOT

  - SWITCH - trocar as posições entre dois SLOTS

  - DELETE - remover um SLOT

  - OVERWRITE - sobrescrever a configuração de um SLOT com a do CORE

  - COPY - Copiar SLOT para um novo SLOT

  - NOTES - escrever anotações para um determinado gamepad/CORE

  - Gerenciar GAMEPADS:

  - SELECT - selecionar um dos gamepads registrados

  - LIST - mostrar uma lista com todos os gamepads registrados

  - RENAME - renomear um gamepad registrado no GCM

  - DELETE - remover um gamepad registrado no GCM

  - EDIT TAG - editar etiqueta do menu `LAYOUTS` e `EDIT LAYOUT`

  - REGISTER - registrar um novo gamepad no GCM

  - CLONE - clonar as configurações de um gamepad para outro no GCM

  - Personalizações, Configurações e Backup:

  - SETTINGS:

    - COLOR SCHEMES - escolher um esquema de cores para os menus

    - COLOR STYLE - escolher um estilo de cor para seleções e botões

    - LANGUAGE - escolher o idioma: inglês ou português

    - TEXT CASE - define letras maiúsculas/minúsculas nos menus

    - TEXT ACCENTS - ativar/desativar acentos nos textos

    - FONT SIZE - define o tamanho da fonte dos menu

    - TIPS - ativar ou desativar indicações visuais nos menus

  - ADVANCED - SETTINGS:

    - DELETE - definições de joystick & remapeamento de botões/teclas

      - JOYSTICK - apagar as definições de joystick (v3)

      - REMAP - apagar remapeamento de botões/teclas (v1/jk)

    - RESET - resetar as configurações, mantendo as pastas dos gamepads

    - BACKUP:

      - SAVE - salvar as configurações do GCM e/ou MiSTer em um arquivo

      - RESTORE - restaurar as configurações a partir de um backup

      - DELETE - excluir um arquivo de backup da pasta `Scripts/gcm`

    - UNINSTALL - remover o script e a pasta do programa

As únicas funções que modificam arquivos do MiSTer são:

1 - LOAD Reescreve a configuração atual do gamepad/CORE com uma versão previamente salva.

2 - RESTORE Restaura um backup e sobrescreve as configurações, caso seja um backup do tipo `full`. Consulte o tópico 6, seção III.

3 - DELETE (ADVANCED - SETTINGS) Apaga arquivos de definições de joystick e remapeamentos (v3/v1/jk) da pasta `inputs` do MiSTer e dos SLOTS do GCM. Os SLOTS que ficarem sem ao menos uma configuração serão deletados e não poderão ser recuperados.

Todas as demais funções criam e manipulam arquivos apenas dentro da pasta `Scripts/gcm`. Os arquivos de backup ficam armazenados no diretório raiz do cartão SD.

---

## 5) Guia Rápido

---

Aqui está um guia rápido das funções principais.

Primeiro, configure o gamepad no MiSTer e no CORE desejado.

Estas são as quatro funções essenciais no `MENU`, executadas em ordem:

  1. `GAMEPADS / REGISTER`: Registrar um novo gamepad.

  2. `ADD`: Adicionar um CORE a um gamepad já registrado.

  3. `CORES`: Selecione o CORE escolhido.

  4. SAVE CONFIG: Salvar a configuração do gamepad/CORE em um SLOT.

(exemplo: SLOT 1)

Você pode criar outra configuração para o mesmo gamepad no menu do CORE em 'Define CoreName buttons' e/ou `Button/Key remap`, e repetir os passos 1 a 4, salvando a configuração em outro SLOT. (exemplo: SLOT 2)

  5. `LOAD`: Carregar um SLOT e sobrescrever a configuração do CORE.

Funções úteis, mas opcionais:

  6. `EDIT LAYOUT` and `EDIT GAMES`: Editar as representações

visuais das configurações salvas nos SLOTS (o teclado é requerido).

  7. `LAYOUTS` e `GAMES`: Visualizar as representações visuais.

Com essas seis funções, você já tem tudo necessário para usar o script. As outras funções servem principalmente para organizar SLOTS, CORES, GAMEPADS, e para personalizações ou backups.

DICA: Após tudo configurado, o script pode ser usado totalmente com o gamepad, utilizando os botões 'Selecionar' e 'Retornar' do MiSTer para acessar os menus LOAD, LAYOUTS e GAMES - as principais funções do menu do GCM. Para finalizar, clique em EXIT para voltar ao menu do MiSTer.

---

## 6) Informações Importantes

---

### I. Pasta GCM

- O script armazena todas as configurações na pasta `Scripts/gcm`.

- Dentro desta pasta, você encontrará:

  - Pasta 'configs'      - arquivos de configuração do script

  - Pasta 'data'         - arquivos de idioma

  - Pasta 'fonts'        - arquivos de fontes `.psf.gz`

  - Pasta 'tmp'          - arquivos temporários do script

  - Pasta 'gamepads'     - possui as pastas dos gamepads registrados:

```text
     exemplo: '1234_abcd' - o nome é a ID do gamepad
```

  - Dentro de cada pasta de gamepad registrado, temos as pastas dos`CORES`:

```text
     MSX, Intellivision, Apple-II, etc.

      Exemplos de caminhos completos:

       Scripts/gcm/gamepads/1234_abcd/MSX Scripts/gcm/gamepads/1234_abcd/Intellivision Scripts/gcm/gamepads/1234_abcd/Apple-II
```

### II. Menu ADD - Adicionar CORES

- O script GCM procura por CORES que tenha sido previamente configurados. Qualquer CORE com uma configuração válida pode ser adicionado e estará disponível acessando o menu ADD.

### III. Backup

### Tipos de Arquivo de Backup

- Arquivos de backup .zip têm os seguintes nomes:

```text
  Backup-GCM-MiSTer-26_09_15-12_30.zip Backup-GCM-MiSTer-full-26_09_15-12_35.zip
```
  
- O prefixo `Backup-GCM-MiSTer` identifica o arquivo de backup GCM.

- Backups com `full` no nome incluem também os arquivos .map da pasta `inputs` do MiSTer.

- Os backups são criados na raiz do cartão SD (/media/fat). Eles podem ser movidos para um computador ou copiados de volta para a mesma pasta.

- Todos os arquivos de backup em `/media/fat` podem ser restaurados.

- A restauração da pasta `Scripts/gcm` não é incremental. Contém uma cópia completa de todos os arquivos do script.

- Restaurar arquivos .map de `inputs` (em um backup `full`) sobrescreverá apenas os arquivos presentes na pasta e no backup. Outros arquivos não são deletados ou alterados.

### Backup dos Arquivos do Script GCM

Exemplo: Backup-GCM-MiSTer-26_09_15-12_30.zip

- As opções 'SAVE' e `RESTORE` no menu `BACKUP` permitem salvar e restaurar `Scripts/gcm`, que contém configurações de GAMEPADs, CORES e SLOTS usados pelo script.

- Obs.: arquivos .map de `inputs` não são incluídos.

- Após restaurar um backup, certifique-se de que os arquivos joystick (.v3) e/ou remap (.jk / advanced_input_*_v1) estão configurados no MiSTer se ainda não existirem:

   1. Vá em `Define joystick buttons` no MiSTer e configure o gamepad.

   2. No menu do CORE, configure os botões do joystick (Define CoreName buttons) e o remapeamento do teclado (Button/Key remap) se necessário.

- Para copiar os backups do GCM, use FTP ou Samba para acessar a pasta `/media/fat`. Você pode transferi-los entre o MiSTer e o seu PC.

### Backup com 'full' no nome do arquivo

Exemplo: Backup-GCM-MiSTer-full-26_09_15-12_35.zip

- Inclui arquivos do script + arquivos .map com configurações de controle.

- Restaurar um backup `full` sobrescreverá as configurações atuais do MiSTer se presentes.

### Restaurar backup em uma instalação nova do MiSTer

- Na primeira execução, se um backup for encontrado na raiz do cartão SD (/media/fat), ele poderá ser restaurado automaticamente mediante confirmação.

- Atenção! Coloque apenas um arquivo de backup na raiz do cartão SD (/media/fat) se pretende restaurar os arquivos na primeira execução.

- Se o arquivo for um backup `full`, os arquivos do MiSTer também serão restaurados.

### IV. Desinstalação

- Para desinstalar, use o menu UNINSTALL ou delete `Scripts/gcm` e o script 'gamepad_config_manager.sh' da pasta `Scripts`.

### V. Tamanho da fonte

- Você pode escolher entre 4 tamanhos de fonte: pequeno, médio, grande e enorme, dependendo do tamanho da tela e do tipo de TV que você usa. O tamanho pequeno é adequado para TVs CRT, enquanto os tamanhos médio, grande e enorme são mais adequados para TVs modernas.

- Se você selecionar um tamanho de fonte que ultrapasse o tamanho da tela e algum botão ficar inacessível, não se preocupe. Basta desligar o MiSTer enquanto o GCM ainda estiver aberto. Na próxima vez que você executar o GCM, o tamanho da fonte será redefinido para pequeno. Sempre que o script não for fechado usando o botão EXIT no menu, o tamanho da fonte será redefinido para pequeno.

---

## 7) Fluxograma de Uso - Guia Super-Rápido

---

```text
         Já possui um gamepad configurado no MiSTer?
                           |
         Não               |                    Sim
          _________________|______________________
          |                                       |
          |                             Já possui uma configuração
 Feche o GCM e configure                de gamepad no CORE do MiSTer
 o gamepad no MiSTer antes              que pretende usar?
 de abrir o GCM novamente.                        |
                           Sim                    |          Não
                           _______________________|___________
                           |                                  |
                           |<--------------   Abra o CORE no MiSTer
                           |               |  e configure o gamepad.
                   Já possui um Gamepad    |
                   cadastrado no GCM ?     |___________
                           |                           |
                           |  Não                      |
                           |-----> Cadastre um gamepad_|
                           |
                       Sim |
                           |
                           |
                     Selecione um Gamepad
                           |
                           |<-------------------------------
                           |                                |
                    Já adicionou um CORE                    |
                    ao gamepad selecionado?                 |
                           |                                |
                           | Não                            |
                           |-------------> Adicione um CORE |
                           |               ao gamepad_______|
                       Sim |
                           |
                    Selecione um CORE
                           |
                           |
                   O que deseja fazer?
          _________________|_______________________
          |                                       |
 1- Carregar uma configuração          2- Salvar uma configuração do
    salva em um SLOT do GCM               MiSTer em um SLOT do GCM.
    para o CORE do MiSTer.                        |
          |                                       |
          |<------------------------      Deseja criar um novo SLOT
          |                         |   com as configurações do CORE
  Deseja visualizar o LAYOUT        |     salvas no MiSTer ou apenas
  e a LISTA DE JOGOS antes de       |___  atualizar as configurações
  carregar o SLOT?                      |   de um SLOT já existente?
          |                             |         |
          | Sim                         |         |
          |------- Selecione [VIEW]     |         |
          |        LAYOUT ou GAMES______|         |
      Não |                                       |
          |                                       |
    Selecione um SLOT                _____________|________
    com o menu LOAD.                 |                     |
          |                    Criar Novo SLOT       Atualizar SLOT
          |                          |                     |
   Configuração carregada!           |                     |
  Saia do GCM e boa diversão.   Use a função SAVE     Use a função
                                 para criar um       OVERWRITE para
                                  novo SLOT.         sobrescrever a
                                     |              configuração de
                        Use a função EDIT LAYOUT   um SLOT existente.
                        e EDIT GAMES para criar     As configurações
                        informações visuais que     LAYOUT e GAMES
                        facilitam a identificação   são preservadas
                            do SLOT criado.
```

--- FIM ---

