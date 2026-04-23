════════════════════════════════════════════════  
MiSTer - Gamepad Config Manager (GCM)  
════════════════════════════════════════════════  
  
Gerencie, salve e carregue múltiplas configurações de controles  
por 'CORE' do 'MiSTer FPGA'.  
  
Instalação  
──────────  
  
Para instalar o script, basta copiá-lo para a pasta 'Scripts' do  
'MiSTer FPGA'.  
  
Para executá-lo, acesse o menu Scripts e clique em  
'gamepad_config_manager'.  
  
Neste tutorial, ao nos referirmos à pasta '/media/fat/config/inputs' ou  
'smb://IP/sdcard/config/inputs', usaremos simplesmente 'config/inputs'.  
  
Na primeira execução, o diretório 'gcm' será criado dentro da pasta  
'config/inputs'.  
  
Todos os arquivos necessários para o funcionamento do script estarão  
dentro dessa pasta e serão criados automaticamente na primeira execução  
e durante o uso do script.  
  
Como usar  
─────────  
  
═════════════════════════════════════════════════════════════════════════  
GCM - Gamepad Config Manager  
@MM 2026.04.23  
═════════════════════════════════════════════════════════════════════════  
  
Script para gerenciar configurações de gamepads no 'MiSTer FPGA'.  
  
As configurações são salvas em SLOTS que podem ser carregados  
posteriormente, permitindo múltiplas configurações por gamepad e CORE.  
  
O script é usado principalmente via gamepad.  
  
O teclado é necessário apenas para tarefas de edição e configuração  
(explicadas neste HELP).  
  
Gamepad refere-se a qualquer controlador (joystick, gamepad, etc.)  
conectado ao MiSTer.  
  
Local do arquivo HELP: config/inputs/gcm/data/HELP_pt.txt  
  
═════════════════════════════════════════════════════════════════════════  
ÍNDICE  
═════════════════════════════════════════════════════════════════════════  
  
1\) Arquivos do MiSTer  
2\) O Script GCM  
3\) Guia de uso do script  
4\) Funções do Script  
5\) Guia Rápido  
6\) Informações Importantes  
  
═════════════════════════════════════════════════════════════════════════  
1\) Arquivos do MiSTer  
═════════════════════════════════════════════════════════════════════════  
  
No MiSTer, os arquivos de configuração de gamepads ficam na pasta  
'config/inputs'.  
  
Quando um gamepad é conectado via USB, Bluetooth ou 2.4G e configurado,  
um arquivo é gerado.  
  
Este arquivo utiliza o prefixo 'input' seguido por um identificador  
único do gamepad (exemplo: 1234_abcd), o sufixo 'v3' para configurações  
feitas no menu 'Define joystick buttons', ou 'jk' se feitas no menu  
'Button/Key remap', e a extensão '.map'.  
  
Exemplos:  
  
  1. input_1234_abcd_v3.map  
  2. Intellivision_input_1234_abcd_v3.map  
  3. MSX_input_123_abcd_jk.map  
  
Arquivo 1  
─────────  
  
Configuração feita no MiSTer em 'Define joystick buttons':  
  
  input     - prefixo do arquivo  
  1234_abcd - ID do gamepad (hexadecimal)  
  v3        - definição dos botões do joystick  
  .map      - extensão  
  
Arquivo 2  
─────────  
  
Configuração feita no menu CORE 'Intellivision' em 'Define Intellivision  
buttons':  
  
  A única diferença é o nome do CORE 'Intellivision', que aparece  como  
  prefixo, seguido de 'input_1234_abcd_v3.map'.  
  
  O sufixo 'v3' indica que é uma 'definição de botões do joystick' para  
  o CORE 'Intellivision'.  
  
Arquivo 3  
─────────  
  
Configuração feita no menu CORE 'MSX' em 'Button/Key remap':  
  
  Neste caso, o prefixo será 'MSX' e o sufixo será 'jk', indicando que é  
  um 'remapeamento de botões/teclas' para o CORE 'MSX'.  
  
═════════════════════════════════════════════════════════════════════════  
2\) O script GCM  
═════════════════════════════════════════════════════════════════════════  
  
O MiSTer salva apenas uma configuração de gamepad por CORE.  
  
O script GCM permite salvar essas configurações em SLOTS numerados, que  
podem ser carregados posteriormente.  
  
Cada gamepad registrado pode ter múltiplos CORES associados, com  
configurações diferentes.  
  
Funciona como um 'SAVE STATE' do gamepad, podendo incluir a 'definição de  
botões do joystick (v3)' e/ou o 'mapeamento de botões/teclas (jk)' para o  
CORE selecionado, tudo feito automaticamente pelo script.  
  
═════════════════════════════════════════════════════════════════════════  
3\) Guia de uso do script  
═════════════════════════════════════════════════════════════════════════  
  
Antes de tudo, você precisa configurar ao menos um gamepad no MiSTer e no  
CORE desejado.  
  
Essa configuração no menu do CORE do MiSTer pode ser feita em 'Define  
'CoreName' buttons' e/ou em 'Button/Key remap'.  
  
No exemplo a seguir, vamos imaginar que o gamepad foi configurado no  
MiSTer e também no CORE Intellivision.  
  
PASSOS  
──────  
  
1. Configure o gamepad no MiSTer em 'Define joystick buttons'.  
  
2. Ainda no MiSTer, configure este mesmo gamepad no menu do CORE. Por  
exemplo, para 'Intellivision', clique em 'Define Intellivision buttons'.  
  
3. Abra este script GCM.  
  
4. No script, clique em 'MANAGE(GAMEPADS)' e 'REGISTER'. Registre o  
gamepad.  
  
5. No 'MENU' inicial, clique em 'ADD - ADICIONAR CORE'. Selecione o  
nome do CORE, neste caso, 'Intellivision'.  
  
6. Com o CORE já adicionado, clique no menu 'CORES' e selecione o CORE  
'Intellivision'.  
  
7. No 'CORE MENU', clique em 'SAVE CONFIG - CORE ==> NOVO SLOT'.  
  
  A configuração atual para o gamepad 1234_abcd no 'CORE Intellivision'  
  será salva no 'SLOT 1'. No nosso caso a configuração identificada  
  pelo script foi apenas 'definição de botões do joystick' (v3)' e ela  
  será identificada pela letra J.  
  
  Essa configuração de SLOT inclui dois arquivos adicionais que podem  
  ser editados para ajudar na identificação. A edição é opcional.  
  
  a) O primeiro é o 'LAYOUTS - MAPA DE BOTÕES', onde você pode  
    especificar a relação entre os botões do gamepad e os controles no  
    CORE.  
  
    A primeira linha pode ser editada usando a configuração de botões,  
    enquanto a segunda linha serve como referência padrão.  
  
    INFO: 'O controle do 'Intellivision' inclui também um teclado  
          numérico, além do direcional e botões de ação.'  
  
 Exemplo de tela de edição 'LAYOUTS - [EDITAR] MAPA DE BOTÕES (SLOT 1)':  
`┌────────────────────────────────────────────────────────────────┐`  
`│                                                                │`  
`│ ← ↓ ↑ → L U R 3 4 5 1  2           ENT CLR     A B C = Ação    │`  
`│ ← ↓ ↑ → A B C X Y Z L1 R1 L2 R2 Z2 STR SEL |----- OUTROS -----|│`  
`│                                                                │`  
`└────────────────────────────────────────────────────────────────┘`  
  
  b) O segundo é o 'GAMES - LISTA DE JOGOS', onde você pode editar os  
    jogos associados à configuração do 'SLOT 1'.  
  
    Cada nome de jogo deve estar em uma linha separada.  
  
 Exemplo de tela de edição 'GAMES - [EDITAR] LISTA DE JOGOS (SLOT 1)':  
`┌───────────────────────────────────────────────────────────────┐`  
`│                                                               │`  
`│ Burgertime                                                    │`  
`│ Bump'n'Jump                                                   │`  
`│                                                               │`  
`└───────────────────────────────────────────────────────────────┘`  
  
8. Em seguida, no MiSTer, você pode reconfigurar o gamepad para outro  
jogo que necessite de uma configuração de botões diferente.  
  
  Basta repetir o PASSO 7, e a nova configuração será salva em um  
  novo SLOT.  
  
  É possível visualizar o 'MAPA DE BOTÕES' e a 'LISTA DE JOGOS' nos  
  menus 'LAYOUTS' e 'GAMES'.  
  
  Exemplo com '3 SLOTS' de 'Intellivision':  
  
  a) 'MENU' / 'LAYOUTS'  
  
 Exemplo da tela de visualização 'LAYOUTS - [VER] MAPA DE BOTÕES':  
`┌───────────────────────────────────────────────────────────────────────┐`  
`│                                                                       │`  
`│  SLOT  ← ↓ ↑ → A B C X Y Z L1 R1 L2 R2 Z2 STR SEL        OUTROS       │`  
`│  ----  ------------------------------------------ --------------------│`  
`│J   1)  ← ↓ ↑ → L U R 3 4 5 1  2           ENT CLR     A B C = Ação    │`  
`│J   2)  ← ↓ ↑ → 7 8 9 1 2 3 4  6            5  CLR  Sem Botões de Ação │`  
`│J   3)  ← ↓ ↑ → U 0 R 4 5 6 7  9            1   3       A C = Ação     │`  
`│                                                                       │`  
`└───────────────────────────────────────────────────────────────────────┘`  
  
  Repare na letra J indicando que as configurações salvas nos SLOTs são  
  referentes às 'definição de botões do joystick' para cada jogo.  
  
  b) 'MENU' / 'GAMES'  
  
 Exemplo da tela de visualização 'GAMES - [VER] LISTA DE JOGOS':  
`┌───────────────────────────────────────────────────────────────┐`  
`│                                                               │`  
`│ Atlantis - 3                                                  │`  
`│ Bump'n'Jump - 1                                               │`  
`│ Burgertime - 1                                                │`  
`│ Tron - 2                                                      │`  
`│                                                               │`  
`└───────────────────────────────────────────────────────────────┘`  
  
  Essa lista, mostrada acima, é organizada em ordem alfabética pelo nome  
  dos jogos.  
  
  Note que o 'mapa de botões' e a 'lista de jogos' indicam o SLOT,  
  facilitando o próximo PASSO.  
  
  Nota: O exemplo utilizou o CORE Intellivision, mas o mesmo procedimento  
  pode ser seguido para configurar qualquer outro CORE desejado. Basta  
  seguir os mesmos passos com o CORE que você deseja configurar.  
  
  Outro exemplo:  
  
  CORE Apple-II - Jogos Lode Runner e Karateka  
  
  a) 'MENU' / 'LAYOUTS'  
  
 Exemplo da tela de visualização 'LAYOUTS - [VER] MAPA DE BOTÕES':  
`┌───────────────────────────────────────────────────────────────────────┐`  
`│                                                                       │`  
`│  SLOT  ← ↓ ↑ → A B C X Y Z L1 R1 L2 R2 Z2 STR SEL        OUTROS       │`  
`│  ----  ------------------------------------------ --------------------│`  
`│R   1)  J K I L U O                        CTL         CTL+k=teclado   │`  
`│A   2)  ← ↓ ↑ → X S W Z A S B  SP          ENT     DPAD=setas SP=espaço│`  
`│                                                                       │`  
`└───────────────────────────────────────────────────────────────────────┘`  
  
  Repare na letra R indicando que a configuração salva no SLOT 1 é  
  referente ao 'mapeamento de botões/teclas' feita para o jogo  
  Lode Runner.  
  
  Já o segundo SLOT é identificado pela letra A indicando que nesse SLOT  
  foram  salvas ambas as configurações, 'definição de botões do joystick'  
  e 'mapeamento de botões/teclas' para o jogo Karateka.  
  
  Essa classificação J, R ou A é recorrente das configurações  
  identificadas no momento do SAVE.  
  
  Você pode memorizá-las assim:  
    J = Joystick/Gamepad  
    R = Remapeamento de Botões/Teclas  
    A = Ambas  
  
  b) 'MENU' / 'GAMES'  
  
 Exemplo da tela de visualização 'GAMES - [VER] LISTA DE JOGOS':  
`┌───────────────────────────────────────────────────────────────┐`  
`│                                                               │`  
`│ Karateka - 2                                                  │`  
`│ Lode Runner - 1                                               │`  
`│                                                               │`  
`└───────────────────────────────────────────────────────────────┘`  
  
9. 'MENU' / 'LOAD': Clique em 'LOAD - SLOT => CORE' e escolha um SLOT  
para carregar a configuração salva e sobrescrever a configuração do  
CORE.  
  
  Os únicos arquivos no MiSTer que são alterados são os 'v3' e/ou 'jk'  
  do CORE, que serão substituídos quando o comando 'LOAD' for executado.  
  
   * Se o SLOT estiver identificado como J:  
       arquivos substituídos:  
         'CORE_input_ID_v3.map'.  
  
         Exemplo:  
  
           Intellivision_input_1234_abcd_v3.map  
  
   * Se for R (Remap):  
       arquivos substituídos:  
         'CORE_input_ID_jk.map'.  
  
         Exemplo:  
  
           ZX81_input_1234_abcd_jk.map  
  
   * Se for A (Ambas):  
       arquivos substituídos:  
         'CORE_input_ID_v3.map' e 'CORE_input_ID_jk.map'.  
  
         Exemplo:  
  
           MSX_input_1234_abcd_v3.map e MSX_input_1234_abcd_jk.map  
  
═════════════════════════════════════════════════════════════════════════  
4\) Funções do Script  
═════════════════════════════════════════════════════════════════════════  
  
O script inclui as seguintes funções:  
  
  - Gerenciar GAMEPADS:  
    GAMEPADS (selecionar gamepad registrado)  
    MANAGE:  
      LIST, RENAME, DELETE, EDIT TAG, REGISTER, CLONE  
  
  - Gerenciar CORES:  
    CORES (selecionar CORE previamente adicionado -> abrir CORE MENU):  
    ADD, VIEW, RENAME, DELETE  
  
  - Gerenciar SLOTS no CORE selecionado (CORE MENU):  
    LOAD, LAYOUTS, GAMES  
    SAVE CONFIG, EDIT LAYOUT, EDIT GAMES  
    MOVE, SWITCH, DELETE  
    NOTES (add notes for gamepad/CORE)  
  
  - Personalizações, Configurações e Backup:  
    SETTINGS:  
      COLOR SCHEMES, LANGUAGE, TIPS  
      RESET  
      BACKUP:  
        SAVE, RESTORE, DELETE  
      UNINSTALL  
  
═════════════════════════════════════════════════════════════════════════  
5\) Guia Rápido  
═════════════════════════════════════════════════════════════════════════  
  
Aqui está um guia rápido das funções principais.  
  
Primeiro, configure o gamepad no MiSTer e no CORE desejado.  
  
Estas são as quatro funções essenciais no 'MENU', executadas em ordem:  
  
  1. 'MANAGE / REGISTER': Registrar um novo gamepad.  
  2. 'ADD': Adicionar um CORE a um gamepad já registrado.  
  3. 'CORES': Selecione o CORE escolhido.  
  4. SAVE CONFIG: Salvar a configuração do 'gamepad/CORE' em um SLOT.  
  (exemplo: SLOT 1)  
  
   Você pode criar outra configuração para o mesmo gamepad no menu do  
   CORE em 'Define CoreName buttons' e/ou 'Button/Key remap', e repetir  
   os passos 1 a 4, salvando a configuração em outro SLOT.  
   (exemplo: SLOT 2)  
  
  5. 'LOAD': Carregar um SLOT e sobrescrever a configuração do CORE.  
  
Funções úteis, mas opcionais:  
  
  6. 'EDIT LAYOUT' e 'EDIT GAMES': Editar as representações visuais das  
  configurações salvas nos SLOTS (teclado necessário).  
  7. 'LAYOUTS' e 'GAMES': Visualizar os indicadores visuais.  
  
Com essas seis funções, você já tem tudo necessário para usar o script.  
As outras funções servem principalmente para organizar SLOTS, CORES,  
GAMEPADS, e para personalizações ou backups.  
  
DICA: Após tudo configurado, o script pode ser usado totalmente com o  
gamepad, utilizando os botões 'Selecionar' e 'Retornar' do MiSTer para  
acessar os menus LOAD, LAYOUTS e GAMES - as principais funções do menu do  
GCM. Para finalizar, clique em EXIT para voltar ao menu do MiSTer.  
  
═════════════════════════════════════════════════════════════════════════  
6\) Informações Importantes  
═════════════════════════════════════════════════════════════════════════  
  
I. Pasta GCM  
  
- O script armazena todas as configurações na pasta:  
  'config/inputs/gcm'.  
  
- Dentro desta pasta, você encontrará:  
  
  * Pasta 'config'       - arquivos de configuração do script  
  * Pasta 'data'         - arquivos de idioma  
  * Pasta 'tmp'          - arquivos temporários do script  
  * Pasta 'gamepads'     - possui as pastas dos gamepads registrados:  
    exemplo: '1234_abcd' - o nome é a ID do gamepad  
  
    * Dentro de cada pasta de gamepad registrado, temos as pastas dos  
      'CORES':  
  
      MSX, Intellivision, Apple-II, etc.  
  
      Exemplos de caminhos completos:  
  
      config/inputs/gcm/gamepads/1234_abcd/MSX  
      config/inputs/gcm/gamepads/1234_abcd/Intellivision  
      config/inputs/gcm/gamepads/1234_abcd/Apple-II  
  
II. Menu ADD - Adicionar CORES  
  
- O script GCM procura por CORES que tenha sido previamente configurados.  
  Qualquer CORE com uma configuração válida pode ser adicionado e estará  
  disponível acessando o menu ADD.  
  
III. Backup  
  
Tipos de Arquivo de Backup  
──────────────────────────  
  
- Arquivos de backup .zip têm os seguintes nomes:  
    Backup-GCM-MiSTer-26_04_10-12_30.zip  
    Backup-GCM-MiSTer-full-26_04_10-12_35.zip  
  
- O prefixo 'Backup-GCM-MiSTer' identifica o arquivo de backup GCM.  
  
- Backups com 'full' no nome incluem também os arquivos .map da pasta  
  'config/inputs' do MiSTer.  
  
- Backup são criados em 'config/inputs/gcm'. Podem ser movidos para um  
  computador ou copiados de volta para a mesma pasta.  
  
- Todos os arquivos de backup em 'config/inputs/gcm' podem ser  
  restaurados.  
  
- A restauração da pasta 'config/inputs/gcm' não é incremental. Contém  
  uma cópia completa de todos os arquivos do script.  
  
- Restaurar arquivos .map de 'config/inputs' (em um backup 'full')  
  sobrescreverá apenas os arquivos presentes na pasta e no backup. Outros  
  arquivos não são deletados ou alterados.  
  
- Backup não inclui arquivos .zip de outros backups.  
  
Backup dos Arquivos do Script GCM  
─────────────────────────────────  
  
Exemplo: Backup-GCM-MiSTer-26_04_10-12_30.zip  
  
- As opções 'SAVE' e 'RESTORE' no menu 'BACKUP' permitem salvar e  
  restaurar '/config/inputs/gcm', que contém configurações de GAMEPADs,  
  CORES e SLOTS usados pelo script.  
  
- Observação: arquivos .map de 'config/inputs' não são incluídos.  
  
- Após restaurar um backup, certifique-se de que os arquivos joystick  
  (.v3) e/ou remap (.jk) estão configurados no MiSTer se ainda não  
  existirem:  
  
    1. Vá em 'Define joystick buttons' no MiSTer e configure o gamepad.  
  
    2. No menu do CORE, configure os botões do joystick (Define CoreName  
       buttons) e o remapeamento do teclado (Button/Key remap) se  
       necessário.  
  
- Para copiar os backups do GCM, use FTP ou Samba para acessar  
  'config/inputs'. Você pode transferi-los entre o MiSTer e o seu PC.  
  
Backup com 'full' no nome  
─────────────────────────  
  
Exemplo: Backup-GCM-MiSTer-full-26_04_10-12_35.zip  
  
- Inclui arquivos do script + arquivos .map com configurações de  
  controle.  
  
- Restaurar um backup 'full' sobrescreverá as configurações atuais do  
  MiSTer se presentes.  
  
Restaurar backup em uma instalação nova do MiSTer  
─────────────────────────────────────────────────  
  
- Na primeira execução, se um backup for encontrado em 'config/inputs',  
  ele pode ser restaurado automaticamente com confirmação.  
  
- Atenção! Coloque apenas um arquivo de backup em 'config/inputs'.  
  
- Se o arquivo for um backup 'full', os arquivos do MiSTer também serão  
  restaurados.  
  
- Na primeira execução, o arquivo de backup sempre será movido para  
  'config/inputs/gcm', independentemente da confirmação de restauração.  
  
IV. Desinstalação  
  
- Para desinstalar, use o menu UNINSTALL ou delete 'config/inputs/gcm'  
  e o script 'gamepad_config_manager.sh' da pasta 'Scripts'.  
  
--- FIM ---  
  
  
                ## Tutorial  
  
          I) Primeira Inicialização  
![Tutorial 01](./screenshots/TUTORIAL_01.png)  
<br>  
![Tutorial 02](./screenshots/TUTORIAL_02.png)  
<br>  
![Tutorial 03](./screenshots/TUTORIAL_03.png)  
<br>  
![Tutorial 04](./screenshots/TUTORIAL_04.png)  
<br>  
![Tutorial 05](./screenshots/TUTORIAL_05.png)  
<br>  
  
           II) Registrar gamepad  
![Tutorial 06](./screenshots/TUTORIAL_06.png)  
<br>  
![Tutorial 07](./screenshots/TUTORIAL_07.png)  
<br>  
![Tutorial 08](./screenshots/TUTORIAL_08.png)  
<br>  
![Tutorial 09](./screenshots/TUTORIAL_09.png)  
<br>  
![Tutorial 10](./screenshots/TUTORIAL_10.png)  
<br>  
  
                 III) AJUDA  
![Tutorial 11](./screenshots/TUTORIAL_11.png)  
<br>  
![Tutorial 12](./screenshots/TUTORIAL_12.png)  
<br>  
  
               IV) ADD CORE  
![Tutorial 13](./screenshots/TUTORIAL_13.png)  
<br>  
![Tutorial 14](./screenshots/TUTORIAL_14.png)  
<br>  
![Tutorial 15](./screenshots/TUTORIAL_15.png)  
<br>  
![Tutorial 16](./screenshots/TUTORIAL_16.png)  
<br>  
  
     V) Abrir CORE, SAVE e EDIT  
![Tutorial 17](./screenshots/TUTORIAL_17.png)  
<br>  
![Tutorial 18](./screenshots/TUTORIAL_18.png)  
<br>  
![Tutorial 19](./screenshots/TUTORIAL_19.png)  
<br>  
![Tutorial 20](./screenshots/TUTORIAL_20.png)  
<br>  
![Tutorial 21](./screenshots/TUTORIAL_21.png)  
<br>  
![Tutorial 22](./screenshots/TUTORIAL_22.png)  
<br>  
![Tutorial 23](./screenshots/TUTORIAL_23.png)  
<br>  
![Tutorial 24](./screenshots/TUTORIAL_24.png)  
<br>  
![Tutorial 25](./screenshots/TUTORIAL_25.png)  
<br>  
![Tutorial 26](./screenshots/TUTORIAL_26.png)  
<br>  
![Tutorial 27](./screenshots/TUTORIAL_27.png)  
<br>  
![Tutorial 28](./screenshots/TUTORIAL_28.png)  
<br>  
![Tutorial 29](./screenshots/TUTORIAL_29.png)  
<br>  
![Tutorial 30](./screenshots/TUTORIAL_30.png)  
<br>  
![Tutorial 31](./screenshots/TUTORIAL_31.png)  
<br>  
![Tutorial 32](./screenshots/TUTORIAL_32.png)  
<br>  
![Tutorial 33](./screenshots/TUTORIAL_33.png)  
<br>  
![Tutorial 34](./screenshots/TUTORIAL_34.png)  
<br>  
  
         VI) Ver LAYOUTS e GAMES  
![Tutorial 35](./screenshots/TUTORIAL_35.png)  
<br>  
![Tutorial 36](./screenshots/TUTORIAL_36.png)  
<br>  
![Tutorial 37](./screenshots/TUTORIAL_37.png)  
<br>  
![Tutorial 38](./screenshots/TUTORIAL_38.png)  
<br>  
  
          VII) LOAD SLOT => MiSTer  
![Tutorial 39](./screenshots/TUTORIAL_39.png)  
<br>  
![Tutorial 40](./screenshots/TUTORIAL_40.png)  
<br>  
![Tutorial 41](./screenshots/TUTORIAL_41.png)  
<br>  
![Tutorial 42](./screenshots/TUTORIAL_42.png)  
<br>  
![Tutorial 43](./screenshots/TUTORIAL_43.png)  
<br>  
  
              VIII) GAMEPADS  
![Tutorial 44](./screenshots/TUTORIAL_44.png)  
<br>  
![Tutorial 45](./screenshots/TUTORIAL_45.png)  
<br>  
![Tutorial 46](./screenshots/TUTORIAL_46.png)  
<br>  
![Tutorial 47](./screenshots/TUTORIAL_47.png)  
<br>  
![Tutorial 48](./screenshots/TUTORIAL_48.png)  
<br>  
![Tutorial 49](./screenshots/TUTORIAL_49.png)  
<br>  
![Tutorial 50](./screenshots/TUTORIAL_50.png)  
<br>  
![Tutorial 51](./screenshots/TUTORIAL_51.png)  
<br>  
![Tutorial 52](./screenshots/TUTORIAL_52.png)  
<br>  
![Tutorial 53](./screenshots/TUTORIAL_53.png)  
<br>  
  
          IX) RENAME CORE e GAMEPAD  
![Tutorial 54](./screenshots/TUTORIAL_54.png)  
<br>  
![Tutorial 55](./screenshots/TUTORIAL_55.png)  
<br>  
![Tutorial 56](./screenshots/TUTORIAL_56.png)  
<br>  
![Tutorial 57](./screenshots/TUTORIAL_57.png)  
<br>  
![Tutorial 58](./screenshots/TUTORIAL_58.png)  
<br>  
![Tutorial 59](./screenshots/TUTORIAL_59.png)  
<br>  
![Tutorial 60](./screenshots/TUTORIAL_60.png)  
<br>  
![Tutorial 61](./screenshots/TUTORIAL_61.png)  
<br>  
![Tutorial 62](./screenshots/TUTORIAL_62.png)  
<br>  
![Tutorial 63](./screenshots/TUTORIAL_63.png)  
<br>  
  
            X) SELECT GAMEPAD  
![Tutorial 64](./screenshots/TUTORIAL_64.png)  
<br>  
![Tutorial 65](./screenshots/TUTORIAL_65.png)  
<br>  
![Tutorial 66](./screenshots/TUTORIAL_66.png)  
<br>  
  
              XI) SETTINGS  
![Tutorial 67](./screenshots/TUTORIAL_67.png)  
<br>  
![Tutorial 68](./screenshots/TUTORIAL_68.png)  
<br>  
![Tutorial 69](./screenshots/TUTORIAL_69.png)  
<br>  
![Tutorial 70](./screenshots/TUTORIAL_70.png)  
<br>  
![Tutorial 71](./screenshots/TUTORIAL_71.png)  
<br>  
![Tutorial 72](./screenshots/TUTORIAL_72.png)  
<br>  
![Tutorial 73](./screenshots/TUTORIAL_73.png)  
<br>  
![Tutorial 74](./screenshots/TUTORIAL_74.png)  
<br>  
![Tutorial 75](./screenshots/TUTORIAL_75.png)  
<br>  
  
               XII) BACKUPS  
![Tutorial 76](./screenshots/TUTORIAL_76.png)  
<br>  
![Tutorial 77](./screenshots/TUTORIAL_77.png)  
<br>  
![Tutorial 78](./screenshots/TUTORIAL_78.png)  
<br>  
![Tutorial 79](./screenshots/TUTORIAL_79.png)  
<br>  
![Tutorial 80](./screenshots/TUTORIAL_80.png)  
<br>  
![Tutorial 81](./screenshots/TUTORIAL_81.png)  
<br>  
![Tutorial 82](./screenshots/TUTORIAL_82.png)  
<br>  
  
          XIII) Desinstalação  
![Tutorial 83](./screenshots/TUTORIAL_83.png)  
<br>  
![Tutorial 84](./screenshots/TUTORIAL_84.png)  
<br>  
![Tutorial 85](./screenshots/TUTORIAL_85.png)  
<br>  
![Tutorial 86](./screenshots/TUTORIAL_86.png)  
<br>  
![Tutorial 87](./screenshots/TUTORIAL_87.png)  
<br>  
  
    XIV) Primeira Inicialização com BACKUP  
![Tutorial 88](./screenshots/TUTORIAL_88.png)  
<br>  
![Tutorial 89](./screenshots/TUTORIAL_89.png)  
<br>  
![Tutorial 90](./screenshots/TUTORIAL_90.png)  
<br>  
![Tutorial 92](./screenshots/TUTORIAL_91.png)  
<br>  
![Tutorial 92](./screenshots/TUTORIAL_92.png)  
<br>  
![Tutorial 93](./screenshots/TUTORIAL_93.png)  
<br>  
  
          XV) GAMEPADS - EDIT TAG  
![Tutorial 94](./screenshots/TUTORIAL_94.png)  
<br>  
![Tutorial 95](./screenshots/TUTORIAL_95.png)  
<br>  
![Tutorial 96](./screenshots/TUTORIAL_96.png)  
<br>  
![Tutorial 97](./screenshots/TUTORIAL_97.png)  
<br>  
![Tutorial 98](./screenshots/TUTORIAL_98.png)  
<br>  
![Tutorial 99](./screenshots/TUTORIAL_99.png)  
<br>  
![Tutorial 110](./screenshots/TUTORIAL_100.png)  
<br>  
![Tutorial 101](./screenshots/TUTORIAL_101.png)  
<br>  
![Tutorial 102](./screenshots/TUTORIAL_102.png)  
<br>  
![Tutorial 103](./screenshots/TUTORIAL_103.png)  
<br>  
![Tutorial 104](./screenshots/TUTORIAL_104.png)  
<br>  
![Tutorial 105](./screenshots/TUTORIAL_105.png)  
<br>  
![Tutorial 106](./screenshots/TUTORIAL_106.png)  
<br>  
