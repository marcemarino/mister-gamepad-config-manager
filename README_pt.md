# MiSTer - Gamepad Config Manager (GCM)
Gerencie, salve e carregue múltiplas configurações de controles por 'CORE' do 'MiSTer FPGA'.

## Instalação

Para instalar o script, basta copiá-lo para a pasta 'Scripts' do 'MiSTer FPGA'.   
Para executá-lo, acesse o menu Scripts e clique em 'gamepad-config-manager'.  

Na primeira execução, o diretório 'gcm' será criado dentro da pasta 'config/inputs'.    
Todos os arquivos necessários para o funcionamento do script estarão dentro dessa pasta  
e serão criados automaticamente na primeira execução e durante o uso do programa.  

## Como usar

         *** GCM - Gamepad Config Manager ***  @MM 2025.12.12

         **Esta ajuda pode ser acessada diretamente em:**
              'config/inputs/gcm/data/HELP_pt.txt'.

                           --- x ---

                  **1) Arquivos do 'MiSTer'**

 No MiSTer, os arquivos de configuração dos controles estão
localizados na pasta 'config/inputs'. Quando você conecta o
controle por USB, Bluetooth ou 2.4g e realiza a configuração, um
arquivo é gerado. Esse arquivo tem o prefixo 'input', seguido de um
identificador único do controle (exemplo 1234_abcd), o sufixo 'v3'
para configurações feitas no menu "Define joystick buttons" ou 'jk'
se feitas no menu "Button/Key remap", e a extensão ".map".
 Exemplo:

 1) input_1234_abcd-v3.map  
 2) Intellivision_input_1234_abcd_v3.map  
 3) MSX_input_123_abcd_jk.map  

 `**Arquivo 1**`  
 Configuração feita no MiSTer em 'Define joystick buttons':

 input - prefixo do arquivo  
 1234_abcd - ID do controle  
 v3 - definição de botões  
 .map - extensão  

 `**Arquivo 2**`  
 Configuração feita no Menu do Core 'Intellivision' em
'Define Intellivision buttons':
A única diferença é o nome do Core 'Intellivision' como prefixo
seguido de input_1234_abcd-v3.map. O sufixo 'v3' indica que é
uma configuração dos 'botões do controle'.

 `**Arquivo 3**`  
Configuração feita no Menu do Core 'MSX' em 'Button/Key remap':
Nesse caso, o prefixo será 'MSX' e o sufixo será 'jk', indicando
que é uma configuração de 'teclado para os botões do controle'.

                           --- x ---

                     **2) O Script 'GCM'**

 No script, usaremos o termo gamepad para nos referir aos controles
conectados ao MiSTer.

 O MiSTer salva apenas uma configuração por modelo de controle
em cada 'CORE'. O Script 'GCM' permite que você salve essas
configurações em 'SLOTS', que podem ser carregados mais tarde.
Para cada gamepad cadastrado no script, podemos associar vários
'CORES' com quantas configurações diferentes do gamepad precisarmos.
Cada configuração é salva em um 'SLOT' numerado que pode ser carregada
posteriormente. Funciona como um 'SAVE STATE', mas o que será salvo
é a configuração do controle para determinado 'CORE', que pode ser
a configuração dos 'botões do gamepad' (v3) e/ou o 'mapeamento do
teclado para os botões do gamepad' (jk).

 Passos:
 1) Configure um controle no MiSTer em 'Define joystick buttons'.

 2) Ainda no MiSTer, configure esse mesmo controle no menu
do 'CORE'. Por exemplo, para 'Intellivision', clique em
'Define Intellivision buttons'.

 3) Abra este script 'GCM'.

 4) No script, clique em 'GAMEPADS' e 'REGISTER'. Cadastre o controle!

 5) No 'MENU' inicial, clique em "ADD - Adicionar 'CORE'".
Selecione ou digite o nome do 'CORE', nesse exemplo, 'Intellivision'.

 6) Agora com o 'CORE' adicionado ao 'MENU', clique em 'Intellivision'.

 7) No 'CORE Menu', clique em 'SAVE CONFIG - CORE => SLOT'.
A configuração atual do gamepad 1234_abcd para o 'CORE Intellivision'
será salva no 'SLOT 1'. Essa configuração salva no 'SLOT' possui 2
arquivos que podem ser editados e que ajudam na sua identificação.
A edição desses arquivos não é obrigatória!

 a) O primeiro é o 'GAMES - Lista de Jogos' onde indicamos os
jogos que usam a configuração do 'SLOT 1'. Podemos editar esse arquivo
colocando o nome de um jogo por linha. Exemplo:

`  Burgertime`  
`  Bump'n'Jump`  

 b) O segundo é o 'LAYOUTS - Mapa de Botões', onde indicamos a
relação entre os botões do nosso gamepad e os controles no 'CORE'.
O 'Intellivision' possui, além do direcional e dos botões de ação,
um teclado numérico.

 A primeira linha é a referência padrão, a segunda é a linha
que pode ser editada com a configuração dos botões:

`  ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL ------ Outros -------`  
`  ← ↓ ↑ → L U R 3 4 5 1 2             ENT CLR ACTION BUTTONS: L U R`  

 8) No MiSTer, podemos reconfigurar o nosso controle para outro jogo
que exige uma configuração de botões diferentes. Basta repetir o
"PASSO 7" e teremos outra configuração salva em um novo 'SLOT'.

 Podemos visualizar as 'Listas de Jogos' e os 'Mapas de Botões' nos
menus 'GAMES' e 'LAYOUT'. Exemplo para '3 SLOTS' do 'Intellivision':

 a) 'MENU' / 'GAMES':

 A lista é organizada alfabeticamente, com os jogos e seus
respectivos 'SLOTS', tudo feito pelo script:

`  Atlantis - 3`  
`  Bump'n'Jump - 1`  
`  Burgertime - 1`  
`  Tron - 2`  

 b) 'MENU' / 'LAYOUTS':

` Lyts ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL        Outros        `  
` ---- ------------------------------------------- --------------------- `  
` 1)  ← ↓ ↑ → L U R 3 4 5 1 2             ENT CLR ACTION BUTTONS: L U R`  
` 2)  ← ↓ ↑ → 7 8 9 1 2 3 4 6              5  CLR  NO ACTION BUTTONS`  
` 3)  ← ↓ ↑ → U 0 R 4 5 6 7 9              1   3  ACTION BUTTONS: U R`  

 Note que a 'Lista de Jogos' e o 'Mapa de Botões' têm a indicação do
'SLOT', facilitando o próximo PASSO.

 Exemplo: 'CORE' Apple-II - 'Button/Key remap' - Jogo Load Runner:

 a) 'MENU' / 'GAMES':
 
`  Load Runner - 1`  

 b) 'MENU' / 'LAYOUTS':  
 
` Lyts ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL        Outros`  
` ---- ------------------------------------------- ---------------------`  
`  1)  J K I L U O                         CTL        CTL+k=keyboard`  

 9) 'MENU' / 'LOAD' - Basta clicar em 'LOAD - SLOT => CORE' e escolher
um 'SLOT' para carregar a configuração salva e sobrescrever a
configuração do 'CORE'. O único arquivo do MiSTer que é alterado é o
arquivo 'v3' e/ou 'jk' do 'CORE' que é substituído quando o comando
'LOAD' é executado. (Ex.: config/input/MSX_input_1234_abcd_v3.map)

  * Se a opção escolhida for "Somente Botões para gamepad
    (v3)", os arquivos substituídos serão do tipo
    'CORE-NAME_input_ID_v3.map'.
  * Se a opção escolhida for "Somente Teclado para gamepad
    (jk)", os arquivos substituídos serão do tipo
    'CORE-NAME_input_ID_jk.map'.
  * Se a opção escolhida for "Teclado e Botões para gamepad
    (v3 e jk)", os arquivos substituídos serão do tipo
    'CORE-NAME_input_ID_v3.map' e 'CORE-NAME_input_ID_jk.map'.

                           --- x ---

                      **3) Guia Rápido**

 Aqui vai um guia rápido com as funções principais:

 - Primeiro, configure o gamepad no MiSTer e no 'CORE'.

 Essas são as 4 funções essenciais do 'MENU,' que podem ser
executadas nessa ordem:

 1) 'REGISTER': cadastrar um novo gamepad  
 2) 'ADD': Adicionar um CORE ao gamepad já cadastrado  
 3) 'SAVE CONFIG': Salvar a configuração do 'gamepad e CORE' em um
 'SLOT' numerado  
 4) 'LOAD': Carregar o 'SLOT' e sobrescrever a configuração 'CORE'  

 Funções úteis, mas não obrigatórias:  
 
 5) 'EDIT GAMES' e 'EDIT LAYOUT': Para editar as configurações
visuais das configurações salvas nos 'SLOTS' (precisa de um
teclado conectado ao MiSTer)  
 6) 'GAMES' e 'LAYOUTS': Para abrir as indicações visuais  

 Com essas 6 funções, você já tem tudo o que precisa para usar o
script. As outras funções são mais voltadas para organização
dos 'SLOTS', 'CORES' e 'GAMEPADS', além de personalizações e backups.  

                           --- x ---

                  **4) Funções do Script:**

 O script possui funções para:
 - Cadastrar os gamepads:
   SELECT, LIST, RENAME, REGISTER, REMOVE, COPY.
 - Gerenciar os Cores no Script:
   ADD, VIEW, EXCLUDE.
 - Gerenciar as configurações dos gamepads nos Cores:
   LOAD, GAMES, LAYOUTS, SAVE CONFIG, EDIT GAMES, EDIT LAYOUT
   MOVE, SWITCH, CLONE, OVERWRITE, DELETE.
 - Personalizações:
   COLOR SCHEMES, LANGUAGE, TIPS.
 - Backup:
  SAVE, RESTORE, DELETE.
 - Anotar informações:
   NOTES.

                           --- x ---

                 **5) Informações importantes**
I)
 - O programa salva todas as suas configurações na pasta:
  'config/inputs/gcm'.
  Dentro dessa pasta, você vai encontrar:
  * Pasta 'config' - arquivos de configuração do script
  * Pasta 'tmp' - arquivos temporários do script
  * Pasta 'gamepad-1234_abcd' (gamepad cadastrado no programa)
  * Pastas dos 'CORES' dentro de 'gamepad-1234_abcd'
    Exemplo para o MSX: 'MSX-1234_abcd'

II)
 - Após restaurar um backup:
 Para que as configurações de SLOTS dos CORES e o uso de um gamepad
funcionem corretamente, é necessário primeiro:
 * Configurar o controle no MiSTer em 'Define joystick buttons'.
 * Configurar o mesmo controle no menu do CORE, exatamente
 como descrito anteriormente neste tutorial.
 
 Isso acontece porque, ao criar o backup, essas configurações
específicas do controle não são salvas. Portanto, somente após
realizar essas etapas elas estarão disponíveis.

III)
 - Para desinstalar este script, apague a pasta 'config/inputs/gcm'
e também o script 'gamepad_config_manager.sh' da pasta 'Scripts'.

                          --- FIM ---
