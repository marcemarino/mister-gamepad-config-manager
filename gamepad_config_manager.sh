#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2025 Marcelo Marino

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Script  : gamepad_config_manager.sh                           #
# Function: Swiss army knife to manage gamepad configs          #
# Lines   : 3506                                                #
#           PRIMARY FUNCTIONS starts on line 807                #
#           SECONDARY FUNCTIONS at 2754                         #
#           SCRIPT at 3479                                      #
# Author  : Marcelo Marino                                      #
# Date    : 2025/12/12 17:43 v1.0                               #
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

clear

###  DEBUG or HELP ###

OPTIONS="$1"

if [ "$OPTIONS" = "--debug" ] || [ "$OPTIONS" = "-d" ];then
    DEBUG=1
elif [ "$OPTIONS" = "--help" ] || [ "$OPTIONS" = "-h" ]; then

    MSG="
  USAGE:

  - Show help options:
     $0 -h
     $0 --help

  - Execute script in Linux for DEBUG: 
     $0 -d
     $0 --debug
"
    echo "$MSG"

    exit 0
fi

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
#                                 Configuration files start here.                           #

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Folders and Temp Files

if [ "$DEBUG" != 1 ]; then
    # MiSTer Folders
    MISTER_ROOT=/media/fat
    INPUTS=/media/fat/config/inputs/gcm
    INPUT_MISTER=/media/fat/config/inputs
    CORES_COMPUTER=/media/fat/_Computer
    CORES_CONSOLE=/media/fat/_Console
    CORES_OTHER=/media/fat/_Other
    CORES_UNSTABLE=/media/fat/_Unstable
else
    # for DEBUG (USED for testing on Linux PC):###
    BACKUP_MISTER="/mnt/Backup_MiSTer" # link to backup
    MISTER_ROOT=/tmp/gcm_debug
    INPUTS=/tmp/gcm_debug/inputs/gcm
    INPUT_MISTER=/tmp/gcm_debug/inputs
    CORES_COMPUTER="$BACKUP_MISTER"/_Computer
    CORES_CONSOLE="$BACKUP_MISTER"/_Console
    CORES_OTHER="$BACKUP_MISTER"/_Other
    CORES_UNSTABLE="$BACKUP_MISTER"/_Unstable
fi

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# List of 'Core Profiles'
menu_file="$INPUTS"/tmp/menu.txt
# Temporary file used by dynamically generated Menus
tmp_file_menu="$INPUTS"/tmp/menu.temp
# Temporary file with dynamically generated lists
tmp_message="$INPUTS"/tmp/message.temp
# Temporary file to sort lists alphabetically
tmp_order="$INPUTS"/tmp/order.temp
# Temporary IDs of GAMEPADS
tmp_IDs="$INPUTS"/tmp/ids.temp
# Temporary file used for editing lists
tmp_dialog="$INPUTS"/tmp/dialog.temp

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# List of 'Core Profiles'
menu_file=$INPUTS/tmp/menu.txt
# Temporary file used by dynamically generated Menus
tmp_file_menu=$INPUTS/tmp/menu.temp
# Temporary file with dynamically generated lists
tmp_message=$INPUTS/tmp/message.temp
# Temporary file to sort lists alphabetically
tmp_order=$INPUTS/tmp/order.temp
# Temporary IDs of GAMEPADS
tmp_IDs=$INPUTS/tmp/ids.temp
# Temporary file used for editing lists
tmp_dialog=$INPUTS/tmp/dialog.temp

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Test $INPUTS
if [ ! -d "$INPUTS" ]; then
    first_run=1
fi

if [ ! -d "$INPUTS"/configs ]; then
    mkdir -p "$INPUTS"/configs 2>/dev/null
fi

if [ ! -d "$INPUTS"/tmp ]; then
    mkdir -p "$INPUTS"/tmp 2>/dev/null
fi

if [ ! -d "$INPUTS"/data ]; then
    mkdir -p "$INPUTS"/data 2>/dev/null
fi

if [ ! -f "$INPUTS"/configs/gcm.cfg ]; then
    cat << EOF >> "$INPUTS"/configs/gcm.cfg
dialogrc_color-scheme=BLUE
language=en
tips=1
help_tips=1
EOF
fi

# Flag that enables help tips next to the menus
tips_flag=$(grep -o '^[[:space:]]*tips=[^[:space:]]*' "$INPUTS"/configs/gcm.cfg | cut -d'=' -f2 2>/dev/null)
# Flag that enables HELP menu hint
help_flag=$(grep -o '^[[:space:]]*help_tips=[^[:space:]]*' "$INPUTS"/configs/gcm.cfg | cut -d'=' -f2 2>/dev/null)

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
 # Update the visual settings of the dialog
definitionsDIALOGRC(){
    # DIALOG DEFINITIONS - base64
    DIALOGRC_CONFIG_BLUE="UEsDBBQAAAAIAGJgN1tsewVUcAMAAFQLAAAIABwARElBTE9HUkNVVAkAA6i20mh+t9JodXgLAAEE
6AMAAAToAwAAnVbbbtswDH33Vwjpywo4wZDHYRekW4MVyxJgSzHsKZBtxhaqSIYuzQLs40dJdiw7
lxYL0MS8HB5SosneJDfkhxVjw3ZAcim2rLSKGiYF2TIOZCsVKRjlskxu0HVmjdyhOaecH0gJAtAZ
CpIdyCi4kfE4V4DKscrJexfj48hBEbw+1KCJ3JJnyi3od165tLsMFHGfMSHvhRc/ouGnUUyUrWGk
vYihyJ2UHKhoEavl39V87hAzgz6ZNeANbzB1KJW0okgzmj81jxUrK45/5tNt4ljAEKpryM04lD1J
gkg+kLetg4aaohWPwgUlO8sNq/Fw9qwowWBJ1tTW3E6SxhE2wYIxRqM2iKHZmIMoTRWiGPhjMvnH
6/Hgn0FppMcgqNigY5vAd/oE3sko6pwo95eSV5A/caZNSsDkk5QwkXNboGsFxOknyTPTzGyYgZ3G
YHhIPpWKFnLf3CnBBEB/IuuKaUK5lsRYJbAggb3ApZokVsNGB8gxxBp9gp1oW9dSGbJaEpSc3QG8
zXMuPSU2BDSIRHshuKDHm19fH9b36Zf7+exxsU5Xy9soyQbhhQ7R+t4tZp+/pcjpIV+OBTWwUOGQ
6G7xeJ/K7XaIMcxwaJD++RTo2ZZDYCZVgf0bkEHooJ7NfzXAWW7YMxBsUiNFEn421CuvEj4IGiNb
uoBn4lIER9ycT4+ZPMGhHwMVJ3n8vl8sVr+uJ3I20H8kxGkGvB/Jq4ZJXUj3XGoXQ74qvQeBr3TU
TszJKL4S1GuLI3bQH3GLhjFBVV5FpNorXmKNYHEbd+B+Q0fSAN1LuoMPso5FF2Du9kQtcda4rcFE
gdvBzcrg0Bo2R8OlRL6DsFHtOxTjyoeHdXTvZd2iXsj5AYdiezn42B3vvkI5zXA/HafET+C4D3DJ
sQFIN4YOfQDO5R7huG9SHOZ+WtKynSu0G0cda4/C9JxPCM7QthTdi+iQ7v0Y1NSbfD3CU+jrKvvs
VlB0Y34lXWnuhjI/CzuhPDMcXZjHmlCljsvBeuH6sJZ70cMUfUwc4tgbFfB67FZ0dOFON5jtgW4w
0nA970iEdXJbh1O/VOL8HL4HjMnbK/0BuCYF/lfm6aNe9XDfOapxee1uK6kt22ninztgaITee3Ky
FKe9rTi9Ch5Ozun50Xk9yMkom16YZdfDDCbL9OxouRLiH1BLAQIeAxQAAAAIAGJgN1tsewVUcAMA
AFQLAAAIABgAAAAAAAEAAAC0gQAAAABESUFMT0dSQ1VUBQADqLbSaHV4CwABBOgDAAAE6AMAAFBL
BQYAAAAAAQABAE4AAACyAwAAAAA="

    DIALOGRC_CONFIG_YELLOW="UEsDBBQAAAAIAAehN1uVdGnqagMAAHYLAAAIABwARElBTE9HUkNVVAkAA10o02iqK9NodXgLAAEE
6AMAAAToAwAAnVbbitswEH33VwzZly44oeSx9ELabujSbQJtSulTkO2JLVaRjCRvGujHdyTL8SXe
ZGkgxKOZc85IGs/kJrqB75WcWr5HSJXc8bzSzHIlYccFwk5pyDgTKo9uKHRRWbUnd8qEOEKOEikY
M0iOMKnDYDpNNdLiVKfw1nG8nzgogTfHEg2oHTwxUaF54xdX1T5BDe4zBXgrvfmeHD+s5jJvHBPj
TaKCj0oJZLJBrFd/18ulQywsxSSVRe94RaljrlUlszhh6WN4LHheCPraD7eRU0ELzJSY2mm97VlU
m/AOXjcBBktGXjoKRwr7Slhe0uEceJajpS1Vtqzs7SwKgbitPcQxmTQkliVTgTK3Rc1i8Y9N1B+/
Tgf/hNqQPJHQwpYCmwS+sUf0QVYzF8SEv5S0wPRRcGNjQJvOYuAyFVVGoQWCW59FT9xwu+UW94bI
6JB8KgXL1CHcKVACaD7ApuAGmDAKbKUlbUhSLQilZ1FlcGtqyIliQzG1H0xVlkpbWK+ALOd3AO/z
misvSQWBAREZb9QhFPHq15f7zV38+W65+Pmwider206SAeGNFtHEfnxYfPoak6aHfD5tKMDqHbaw
Q0EnEf++e3hY/4rVbjdEWW4FBqx/HuYY9FZDYKJ0RhVcI2ujhQa98BPAi9TyJwQqVatkVP9smV+8
KHovWRfZSNZ4LscZGulwTj1teMRjn4UWzjIJDBdTGSX6r5QES1D0ufzSMK1nEh5L7lnKFyZ4L+n1
7pQWdzaZL4b1SuSEHtRKt2DrpsF0WnRkjV+4rtsBdou6hffLu2MN0L20W/gg767pCJZubpSKeo+b
IlxmNC1c76wDGsf25HgukW8oq87u92R29z48rlN4L+sGdSXne2qSzfXQ47BrHFEIdTh1jR8oaELQ
2OMDmAmOFh+QiaAJFFN79/2T5U2fYW2DanV7ErYXfCYwIttItK+kQ7r35HIv7Emeg1+2t09uLHVu
zY+pCyUeJNNR2JnkSKt0ND9LYFqfBkbljcvtWx1kD5P1MV2KU30UKMqpG9udK3drZ52yFhy0Nxra
e+ignd3sxC1f2+RyDN8D9uWba/2OND4l/VvzCXQq1hP4+tEh5KUTL2dV3nQV/3zlfTkblvPetJxf
gQ/76Hy8kV6jOWts82c62zWiQaeZj7aaiyT/AFBLAQIeAxQAAAAIAAehN1uVdGnqagMAAHYLAAAI
ABgAAAAAAAEAAAC0gQAAAABESUFMT0dSQ1VUBQADXSjTaHV4CwABBOgDAAAE6AMAAFBLBQYAAAAA
AQABAE4AAACsAwAAAAA="

    DIALOGRC_CONFIG_MAGENTA="UEsDBBQAAAAIAGKhN1v+l/b8cgMAAIcLAAAIABwARElBTE9HUkNVVAkAAwcp02jqK9NodXgLAAEE
6AMAAAToAwAAnVbbjtowEH3PV1jsS1cKqOKx6kW0XdpVd0Fqqao+IScZEmuNHfmyFKkf37ET50YW
UJEQGc+cc8b2ZIab6IZ8t2Jq2B5IKsWO5VZRw6QgO8aB7KQiGaNc5tENhi6skXt0p5TzI8lBAAZD
RpIjmVRhZDpNFeDiVKXkreN4P3FQBG+OJWgid+SZcgv6jV9c2X0CirjPlJC3wpvv0fHDKCby4Jho
byIV+SglByoCYr36u14uHWJhMCaxBrzjFaYOuZJWZHFC06f6sWB5wfFrPtxGTgUMobqE1Eyrbc+i
yiTvyOsQoKGk6MWjcKRkb7lhJR7OgWU5GNySNaU1t7OoDoRt5UGOySSQGJpMOYjcFBWLgT8mkX/8
Oh78MyiN8kiCC1sMDAk80ifwQUZRF0S5v5S0gPSJM21iAiadxYSJlNsMQwsgbn0WPTPNzJYZ2Gsk
w0PyqRQ0k4f6TgkmAPoD2RRME8q1JMYqgRsSWAtcqllkNWx1BWkoNhhT+Ym2ZSmVIesVQcv5HcD7
vObKS2JBQI2ItDeqEIx49evr/eYu/ny3XPx82MTr1W0nyRrhjRYRYj8+LD59i1HTQz43G6ph1Q5b
2KHAk4gfF1/uVptFLHe7Icwww6EG++dhkrXgaghMpMqwhCtkZbTQIBh+a/giNewZCFarkSKqfrbU
L56VvRe0iwyiFZ6JcYZGuz6rnjh5gmOfBhdOUvl99/Cw/nU+l1Gi/8uJ0wR4n8wvDfN6IeOx7F6k
vDbDe4EveafAmLPRvB7XK5QGPqiYbt1WvYOqtOjoar9whXAH2a3tFt+v8o41QPfybuGDxLumI1i6
+VFK7EFumjCR4dRwPbQKCI5t43gpkUcQtrP9PZrdzQ/PqwnvZR1QF3K+x2YZ7gcfh91jT3HkGdp0
jx/AcVTg/GMDnK4dLcEROJeHOOE4imLs876R0jz0G9p2qla4J2F6wScCI7JBon0vHdK9KxeaYk/z
FH3d5j65AdW5Nz+wzlR5LZmOwk4kRzqmo/lZEqpUMzqsN873cXkQPUzWx3QpmgopgJdTN8A7d+7W
Ttt+pThocji/96QDd3bYilu+tMvlGL4HHOiHi/0OOEoF/nPzGXSK1jP4ElJ1yLXDL6c2D53FP196
Z04G57w3OeeX8MN2Oh/vpxd5Tvrb/IUGd5Fp0HHmoy3nPMs/UEsBAh4DFAAAAAgAYqE3W/6X9vxy
AwAAhwsAAAgAGAAAAAAAAQAAALSBAAAAAERJQUxPR1JDVVQFAAMHKdNodXgLAAEE6AMAAAToAwAA
UEsFBgAAAAABAAEATgAAALQDAAAAAA=="

    DIALOGRC_CONFIG_NEON_GREEN="UEsDBBQAAAAIAF2yN1sBwalOTQMAAKULAAAIABwARElBTE9HUkNVVAkAAwFH02iwR9NodXgLAAEE
6AMAAAToAwAAnVXbbts4EH3XVwySPjSA7XVcdB+M7hbZxmkN7DpA6qCPBi1NJCIUKZCUkwD9+B1S
l1CKEqsNHEBzOWeGw+HMKbxbJ0swgsX3D0zjTMeTA5zPzuewmJ8v/qDf/Bzm8+WHP5cfP4JVOawe
C3gXncKBC1zGSt7lKkGSb0o5tTxHcDqelppZriTckRvcKQ0JZ0KlE8iZjTM08L2JSQBBdkPaHGfR
KXFtnwryUHdwYKJEs/TKTZnvUYP7mwJ8kl78mwzfreYybQwnxosnZPhHKYFMNojrzc/rqyuHuLDk
sy8tesN7Sg9TrUqZTPaUVP2Z8TQT9G8/n0UuClpgpsDYTqujzaJKhL9g3jgYLBhZ6TiOFPJSWF5Q
AR54kqKlI5W2KO3ZLKodcVdZiOPkpCGxbD8VKFObVSwWH+1ePXo9FfeA2lB4IiHFjhybBP5j9+id
rGbOiQlfeKprfC+4sRNAG88mwGUsyoRcMwSnn0UHbrjdcYu5ITIqkk8lY4l6qO8NKAE0n2GbcQNM
GAW21JIOJKvrm0WlwZ2pIC3Flnya6y2LQmkL1xsgydkdwNt8zI0PGWvEGhEZL1Qu5PH+681qtZlc
rq4ubv/dTq43Z0GSNcILRxCX7XlqVHXA8SjLraibNvLf46F7pRNq4QpbCUfAF7HlBwTqVduUOqqE
HfOmZ/yPb+vtanKzumywa8leR3PZx4+If49PXRZS9PMYyG4omUGq30pKsD2KLpdX/WZir9KNTG4t
6YUH7cWdTOJoWKdJWnSvW0KxmhtMx1kQ1njF8bgBMGzsZ/iYFg9IOtk/s4xq9iu3KwpFs8htDi4T
HvtZWpE1hl1r6F/tyxbyYxFlGRQmJzEsS/j8O+6dkzSoI9ewphHa3Bx9Hi2boP2BCfAezNSGNx73
lqXNDGLHhlcbx3ZAI6M8v1QHcjX+hWgvwSOifnEbK7gyv8HGRo0HwS+jDrLcFsC0bhdK6YVj8109
yA4q6aJCkrZHMhTF1C324NqdrkWFuyyYebTQcwhwTm5GmlO3+O7Y8a9rCNrBDJ/vBikTKZ6q2EGr
egLfr7p2Gb8JU1amzazx37+6RBedLbp49Tn35+pieLAuek96MThauxT96fYGR2+oLAanymv4/wFQ
SwECHgMUAAAACABdsjdbAcGpTk0DAAClCwAACAAYAAAAAAABAAAAtIEAAAAARElBTE9HUkNVVAUA
AwFH02h1eAsAAQToAwAABOgDAABQSwUGAAAAAAEAAQBOAAAAjwMAAAAA"

    DIALOGRC_CONFIG_NEON_YELLOW="UEsDBBQAAAAIACKyN1u9YHqOUAMAALoLAAAIABwARElBTE9HUkNVVAkAA5BG02hzR9NodXgLAAEE
6AMAAAToAwAAnVXbbts4EH3XVwySPjSA7XW8aB+MdovsxsEayNpA6iDok0FLE4kIRQkk5SRAP36H
1CWUItdyAwfQXM6Z4XA4cw4fltEctGDh0zNTOFHhaA+Xk8spzKaXsz/oN72E6XT+5+f5p09gshQW
Lzl8CM5hzwXOw0w+plmEJN8Vcmx4imB1PC4UMzyT8Ehu8JgpiDgTWTyClJkwQQ3f65gEEGTXpE1x
EpwT1+Y1J4/sEfZMFKjnTrkq0h0qsH9jgC/SiX+R4btRXMa14Uw78YwMf2eZQCZrxHr1c31zYxFX
hnx2hUFn+EjpYayyQkajHSVVfSY8TgT9m28XgY2CBpjOMTTj8miToBThK0xrB405Iysdx5JCWgjD
cyrAM49iNHSkwuSFuZgElSNuSwtxnJ3VJIbtxgJlbJKSxeCL2WUvTk/F3aPSFJ5ISLElxzqB/9gT
OiejmHViwhWe6ho+Ca7NCNCEkxFwGYoiItcEweonwZ5rbrbcYKqJjIrkUklYlD1X9waUAOpvsEm4
BiZ0BqZQkg4ky+ubBIXGrS4hDcWGfOrrLfI8UwbWKyDJ2i3A2VzMlQsZKsQKEWgnlC7k8fHH4vZ2
/TC6Xtxc3d9uRuvVhZdlBXHCMch1c6IKVh7xBJjhRlR9G7jvE7C7TEXUxiW4FI6hr0LD9wjUsKau
d1AKW+ZMbwQP/y43i9Hd4rrGLiU7jOayix+SwBO+tmlI0U2kJ72+bHqpfi8rwXYo2mRO9ZuZHaQb
mt1S0kv3moxbmcThuFanNPBOy/hiOUCYChMvrnaKAYE9pN/fb/hBne6xtPJ/oxnW8zd2b+QZzSW7
RbiMeOjmaslWG7aNoXu/7xvJjUiUhVeblES/Mv4gaLm3jlKjjtzEksZpfXn0ebxwgpYJRsA7OF0Z
fvHINyyupxE7OseaQKaFGhjm7cVakK3yKeHeoweE/ccuMO/W3EIbHDbsRb8P209znwNTqlkwhROO
TvvsWbZgURvmszSdkqDIx3bVe3dvdQ3KX27e+KMVn4KHs3I93ay6wbcHkHtjfdAW5sAB75BSkeK1
DO41rGNwXasqlxM2Y8yKuJ467vvkrTprrdXZwXfdnbGz/iE767ztWe+YbVN059wvODrTZdY7Xg7h
/wdQSwECHgMUAAAACAAisjdbvWB6jlADAAC6CwAACAAYAAAAAAABAAAAtIEAAAAARElBTE9HUkNV
VAUAA5BG02h1eAsAAQToAwAABOgDAABQSwUGAAAAAAEAAQBOAAAAkgMAAAAA"

    DIALOGRC_CONFIG_NEON_WHITE="UEsDBBQAAAAIAAW1N1tsEaGzmwMAADsNAAAIABwARElBTE9HUkNVVAkAA/pL02gRTNNodXgLAAEE
6AMAAAToAwAApVbJbtswEL3zKwbNxQKcoMi9KLKiRdMFbYoeDUqa2Exo0uGSpJ8T9NBTT/0E/1iH
pCxLluwo6cWyyJk3b0az7bE9ODK3XtxpKBEKra7E1Bu+/L38pWHBDYdScKmnMDo2XBUaEL4YdDpj
eyzoOnHHDekZtMxbnBRaamPhDXz+FO6/oQOLAcdpA6Mr+pl76cRCItyLcorOgvZu4V12wCpBnKQb
Ann1agXieL4vUU3dLKE4fHC5fojnxPoOjRVaEQgdTEiQlF8H3Y/8BqOQMzwIcQlBvZhhcSOFdWNA
VxyMQahCeoqAmyGE8wN2J6xwE+FwHt05P49UZrzU96uYEAG0b+FyJixwaTU4bxQ5pCCG4SBGxCaV
GuKEzJOhK69KijknTyRntjCIKkWPREfHF0cnH8ZwenZ+9P3ickzRzGpdDlbPc/oyo4KTTbQOrzl4
ywNguspYsroGrJF+vHt/eTYOZJqIBRcPPNAqxfKRXNMU5Ugwj199HONNCZE+fXJ/DV5hVqRb0BST
5R/npd5ipYE7hqbJjDnhJG410gyIpS9hwqPfRsU6yKAZyDrXLlQAd6EydrHMvXNaTXhBkl22X89O
21xrZKEGY5NoP3ofdYrAjDK968MuCzf4c7AHXQO1K0+ZeJYjGszyb8qctisrRMlzlJu0tzi0E7Xi
38Z9btBXaYeKOg0djISirhZaRAb7sLWYWBQjqYF2YqL3GVwDbeR5s1j7CC/QUv+31IOQm2LWolJx
6OsZ/YXdA9Yu48bbTq96gDb8ar42WAlVioJ6X2yyC21FGmUjrehdQ+GNpTtqmsvHjIV7J2KJBS2a
UU8QrfnNUXkWfprx2hLqrnct7UF+WaBJRLNF6ai8s22EmTWsxFaoFiUWFAcejmoTCbUykey1TEQt
h+WAnmFpBk8tjNCJW4+O24zM2GjH0shez5I1947ymiRPOh37PayaKLFv2RowYoRGMajyOupdPgHr
GTFZpwMtJuKK8i+mKou7yeDybek2OVU4HUI9A6u5WtDHSXtfIeaceW5Mc43YMYQbqjmR06xs6zah
ml0k5hU5wq99qJJVTsYUm6FcDF0zIk4aRPRKSx4tmstHIzQL/1f+BrFBoaiZ9WC1QHbTCl5sYIQd
jZo27ZkoaGHkCTPmrkGqQCW3p2Qr4DlFNDVLo6e0gNMyOJpyP8WMxcdzR0oXr9qZDv93OMHh5nh6
OeRqMhDm5mx4OWhseIcbLXk33D9QSwECHgMUAAAACAAFtTdbbBGhs5sDAAA7DQAACAAYAAAAAAAB
AAAAtIEAAAAARElBTE9HUkNVVAUAA/pL02h1eAsAAQToAwAABOgDAABQSwUGAAAAAAEAAQBOAAAA
3QMAAAAA"

    DIALOGRC_CONFIG_DEFAULT="UEsDBBQAAAAIAJalN1tZZZqOaQMAAEkLAAAIABwARElBTE9HUkNVVAkAA+ww02hjMdNodXgLAAEE
6AMAAAToAwAAjVbfT+MwDH7vXxGNF5C26bTHE8c0YLtDB5sEQ4inKWu9NlqWVPkBTLo//py03dJ2
BZBAtf19tuM4NmfRGXm0YmDYDkgsxYalVlHDpCAbxoFspCIJo1ym0RlCJ9bIHZpjyvmepCAAwZCQ
9Z70ChgZDGIFqByomFw6H1c9R0Xycp+DJnJD3ii3oH965dzu1qCI+xkQcim8eIWGJ6OYSCtDT3sR
XZFrKTlQUTEW83+L2cwxJgYxa2vAG84xdUiVtCLpr2m8LT8zlmYcf824jyIozgSM+wreQGkYX0Qu
MhhCdQ6xGRSlGEaFSH6RHxVAQ07RiuVxgcjOcsNyLNg7S1IweExrcmsuhlEJhFVhQR+9XuXE0PWA
g0hNVngx8GHW8sPr8TJcThgenaBihcAqgQe6BQ8yijoQ5f6i4gziLWfa9AmYeNgnTMTcJgjNgDj9
MHpjmpkVM7DT6AwL51PJaCLfy3smmADoMVlmTBPKtSTGKoEHEtgfXKphZDWsdEFBF3PnYYmQwky0
zXOpDBoISi6Cw3ubPuCfsEegZETaCwUEEec3r5N5//r+edpfzC+C/Eq0F47o6/vJzd9+8bfE3x4O
UnKKkzU5L3/ulhhjNmuSDDMcSqr/DpmYVklsBVtLhR1VEgvhyCxINeokNuwNCLasqaobFcKKelOT
HRblTtBuOhMNB2EF2qG3sK/zUdFM4URip9I46aqVzvnj9LZR/3pGnK6B1x15Vaswr9P7+8XLp5Xp
9NVOq9YYlTd8x0EvMSej2FnaI6HWDwdeozGa9CegKs6CgNorPosYUMLWPRLrTRxIDXYt4SO9kXEo
OgcztyhyiYPFrQ0mElwPbjAWgMqwOhi6EnkAYYNz71D87NQHeC3rivVFznc4AauLwc9PSstx8OOG
Yw2CLg1fvY8lTatJQtPuKyijmBq6K0b7JVSRjq/P8d3Ta1Dbr7EVv+2jlYd/vuGTu3GbJ7g7v4m+
Lmp8kvbd0j7nhCp1WAzWC8ccfz9Op/PGrJbvosZJ6pzQxaFLMuD5wG3m4Pqdrj2c/QqqjzNcyzsS
kJ1cHcSpvzrj7BS/Riyj+6VZHvMRcEUK/AfNRw8617N9+6oS0ti6XZstpTatxor/7urk1jYc1dbh
6NtTc3R6bHY7aI2xUccc63bRmCijkyOlg/4fUEsBAh4DFAAAAAgAlqU3W1llmo5pAwAASQsAAAgA
GAAAAAAAAQAAALSBAAAAAERJQUxPR1JDVVQFAAPsMNNodXgLAAEE6AMAAAToAwAAUEsFBgAAAAAB
AAEATgAAAKsDAAAAAA=="

    SCHEME=$(grep -o '^[[:space:]]*dialogrc_color-scheme=[^[:space:]]*' "$INPUTS"/configs/gcm.cfg | cut -d'=' -f2 2>/dev/null)
    eval "DIALOGRC_CONFIG_SCHEME=\${DIALOGRC_CONFIG_${SCHEME}}"


    # ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
    # Generate DIALOGRC
    if [ ! -f "$INPUTS"/configs/DIALOGRC ]; then
        echo "$DIALOGRC_CONFIG_SCHEME" | \
            base64 --decode > "$INPUTS"/configs/DIALOGRC.zip 2> /dev/null && \
            unzip -d "$INPUTS/configs" "$INPUTS"/configs/DIALOGRC.zip  > /dev/null 2>&1 && \
            rm -f "$INPUTS"/configs/DIALOGRC.zip 2>/dev/null
    fi
    # Export DIALOG config
    export DIALOGRC="$INPUTS"/configs/DIALOGRC
}

definitionsDIALOGRC # Update the visual settings of the dialog

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# updateDictionary - Update the language and the messages displayed in the Menus
updateDictionary(){
    # LANGUAGE_en base64
    LANGUAGE_en="UEsDBBQAAAAIAAVUi1sFAI+OjBEAACc5AAAPAAAATEFOR1VBR0VfZW4udHh0zTvbcptKtu/+io7n
QdlV296xnExNXNtnF5KwjC2BAsiy9KJCgCViBAoXO8oHzBfMF86XzFrdDXQDkpM55+HkwRKi1+p1
v3Xnb2Sk6ENlqBI/Ojkh/N/fSN8Yjw29/EGxbVW3NUO/PlWyzI+yII7enZav+4Zpqn37+lRLSZAR
N04S383+qhbMjenyVnlQl5Y6goXq4Pp0Hudk47z4JPVDWOx71Wp7PilWZPud+AbxyCia0H1Dv9HM
scLI7cfRU5BsnRrF6qNmL8eqPr0+xa/VC0UHxE4k4GP7LY0JIrSuTy26I3EiEu8QK1n5Yfx6VQHo
xnKojNWJApj0mKydrb9zPJL46yDN/MT33jWQKxVEgb6AExePDNta6oa9vDGmOsPewR87IMkU6PAj
koJIPbL3MwHuRhupS3Wg2Zo+vD69CUKfqF6QBdG6TghKFR7Ozs6IxQWLD9Uy4/761HgWFKKCROZ+
KnKPdAnqUPS+OgJFOJHrh7IGQPjfg+xUNDzUSfk4Vi0LbJOrfAlmpi4H6o0yHQEoriQFnSSOfBI/
kWzjkw6uszpMLyROQFUx/J5wfQmaasNvaxOrRI4Cxl87xPE8UBypK/+qZlIT0xiayphZFf35jPTD
OPUpZambBLtMMLbBoOIHHgiHUDwPfUqVVzLKWpYR8ueff9Inh5MrKP9BU2fVJvhUkIVSIjpYWVpb
zTZqX8r2mnKGOqbvhPRFR5J+RxRLfzQdqCgR+gXxDUCKmV9jkXuAVRFb/AIQYydy1gARR1kSh6Gf
pC2AjO6jUJT6jpU5SQYGsiduGLjP4AgE7MOX/NJGb0F3599QDHmaxdvgBw0mKRiBR3qO+5zvBGJu
1dGk4gCfuAx7Thq4xM6zOAmcsAbAKD+4mgkdhe2hWT/FCdgS8kBdWPAeMA7JZFDCYDJgGXW1UFtn
dk/j5MDJHMgBWbIn29jzBbu+MY3x0lYf0VsjiF9UyxGo/JDGKcBIs+wymLU451MSb+kPIQTFCnam
gBMx2JkDqQRYLVeRLAbmyS6JXT9NpTDaH2n9+yUGp+IH1CvpGPcdhKKyOhdiFJiIyPxPktmI9Jpu
qSaPG4jzuIQEwP6tYVhqFfSHPEfQbLXOE2phjeVfpqolEYy4XWbc+FmBkj2kxtcg3SD3eSqq886Y
LzHBLi+uTzu9PMvQlOMo3HeosIts9f7l8rcWoC4A3fv7VewkXhvU1+c2qEsRiroN27cBTF9KO9Ns
p+mFKVcB2f8OGkmByWxTyluIl28WLJARH8HOwO3sUkPECRPwsT1HXgfom6oCKRIlZ7fYvbQGBPUK
OTnNXTTWpzwM9yyHCGYIFmZTGOalYNn+SxDnKSxlafwpDj3MW2hFQVoQ2cCb+BCXkhpqe2rqS9tY
avpkCt40gUUpAZmoJtqET+20SIwou/P/tcyFkFKvzqQ4IcQrnhMaCdk2FetWMnNOAbVrJ6KxwKNZ
5KqWaiymdIiQuDbN+RcZqDVuWVigQgLHcgnMYhBLgM++vxMpeYIyKm2kuUJmgk2VpZn/3Q1zT4pb
JRTfE8EoYlYaUzBGsQgFylU0/TjUs7/DElCQNebz8nFqsYgF0EUuj2h6pyFOrJD0abGQ5f8goqvH
gWWD5Yz9KBckeGvMeFXd4Qt4HH1PsZ9n37PfasvR0GrLyfsy/MZ55L2rg9yqykA1AYivCmPXQSOr
SEPjZs6TCvYx1S1b6UEtXCC4vr7mO04jyBErKIzhJ4F7zbIg9zMBULen0ZR541MeuRhWfoeqC6VP
BeiRklECaxL/Wx6AZxKHWXESx9kh9BAxeLqwBsSFSHkOhYrvJO4G6xMMjCPwPvxe8A38cl5vGK+d
c0njRelSNVa0zMC/pPx3RtQIOf9jEKRUAnYg1jPUAFqqIVT80ZJIzHbGyDAtbhj0gVj9WxWYRgyb
GMtjBxJYyJK9GFOwO51iRGDAxWNBegkcOtE6h1qvguwp/fvp5PqUfVbc8pqwUbjxiNkVSncOYfpZ
nkQYA5CIU7lNLjmrt3TsldDPMf5SFxmsC2fZG00havTC3K+/maujkTHDJiuUPJO9HYMwdFuBhgWY
ijKn/l5XDX05NFUVYqLuQ2EwTCA6tK4qNqLL2nej62a3mq3yZbNNkDUoLqvfgf/k5KHc30kKrcus
eClIrVCsILEJprM4yfJ17qfC7sijGq2hUttIW6K9Sy7AjUnDHOiAD78woxe2UKAwfCh6QeYfNb8Y
qNKaduehm6k6xpwBC9MZvBeitE9Ri7Gdggw06zCMx7by5OjOzLxm/ZxR2eSvahmvcBR8wB+hpca9
aL/qZxhwJC9hJUsBxJ+pl9Ai5ADcABRsV2DsUWgFHbKi1ElTFM4Ez3JYT3hx1MmYLJxoz2FY7pPF
IXBWl8mwD+05TzdnBJ5ouyVvXtQhmg7tSEm0XBDs/ASqV9YdMEL+qkcfTG6adYuKZDtAgb/d1dN5
OYWoaMZco1RZ5fhaCFlljeFC/cpSYRp4vMxhncEfQbTLs/SPtbvt8NwoZwtZtXVOirecgLaeiQmB
lxAoIV6XXjXEMlN0uyHPRDCgujHIRFTiLCrfd42lbOxU+lCHAXQ4BGuSsJB26VgqbEOBVKJwlRC6
qzxJIL7yMqsoyNk8B+phWAGdafziJ69JgP2G1DpAI6JjeK8xjJ1bEOX+X5IaJE+pk8Rf1pVQiYzZ
zNEqWUbFp6U/VzEj8gOIuJxFKkqjrCpYgc9iTFPLAVhi4Cch1WzPEWanRbcolAh0WoB/6eMZLZOg
kwtboKRIxjp29klYoqdN+/HtTHVsPFA4/ORw2/jlbbghkKiaPGEUjxScQQGCyH8t22Ec+dBBFUdb
HwrQyuzQ7IuXZzq6p0AVzoWPzTBLIssc/iadhwhqTvE4TUe3Z11rNYIlpFmBUcmwAQ/8wibINQzy
kLgNieifkzmWpZM5X9iPd/vaOOV9zyb//ue/oG3q0c/u+cc1+d3P3PPfahU32m59MimOmnjFKoTN
wjSruEnHVYJYCjQlV2XZW9gKAvkg0xR8jdZcV7XQzpTYckSxLFV+wVJs5PsUH0uyGQl9J2VhvqHw
NixdPoIr5OfjmEjoGNvyHiv+Dp6AsOTAbK9FKsrIhHZuXpJQhKICGqN8MddpPYOp89CGoDZvacHy
M0dcor6b+6vjiT3HrSGzFHt7sZ9WJY/oyjilDWsHPQWmsTHAIxc2jHTYKJJNUivUV+S9krgOFAlg
1L+Tpi2zwFiLl5WWeLAc1rmhWbMIro0UT2GOS0G3zXlzmgoBR2DjCHzpayURP+NyjLIW6+Jsl2my
D3FLa2Hkr0OgNWMqkyJD4UmWVS/IMMM03IX93HAXgZaazDE5XTUUxLJYQ0E0k7UKeALVl2oKIzKM
GIeGZHL4FKom/xhCCB6lz2+cqrBiZLXLGPk4LGMKJ3gIL1aqCqo2O3PCND4EW9JbaOKiffS2gxrT
TwD2nNgxcah66Vzj9yO4gPXCuSU3Jc7aCaLz2tRhMi8fDX00Xxo6muhkLs2o6ARyMu8Ik6p9FeBP
D2DAAC7H/m7lL62Rr2CBgh8zS3Z+48a7wPdaTmEHeLqhCyhmm8DdVGE4oCWd6wfcQgHRvm7XhRBo
Dm8142oZcAoUtS4qYviSFQdtlwwAAVieOTM1u7SEou8FUz+4FA8Gmv3COal3l3jKJZk8xVM1lJTD
pyAK0o18FIbL+sZ4IlTlzEJfQW9c+u8aZ+50bl1NIfDUBhsX04A8Yu93fsP1rk+/xvs0gyqsenWv
znuGYsK7Z37aIw47H1XhxR9NaPmiBR+k8yH6gdqxcSLHohqvzOm/M3ptglz/D5nEaSCX0NZMs/t4
zkA/pfV/AgB+EdykUOH1afmVFKfjiN/KV9gQgmJlQBZzqqEH24UPPuSl/RH4IegWPxr065AD5eUj
A/WAf5vcyofr9HKCbQhXXiqIQ4XxkI396Ue5GPM97bDEGS3UPniQxr/wleyMj4wdaahj05ME/ChR
6nEmnqTQ0UZZ6tKpFM2+Q0HUTVFQKNY4iCAtMEToH/DUXxDSQGNlqNC94G+Ei+CMXptpE4EAyWeG
R8AYARB3orb9uRBrFLBfC1RtopWABSIOQTIqcGAvUCIOasGqDpTqUnDnDUdxEamozxpH3jzJV5VU
e3XM0BxsEuaqhReMtKo24H2PSEpZ6jIizg9i47QsFT4kYizQep+ev4q12eHGpcDSK05Z2eEqLacK
z6INED0rk2bhVFuViFQTRMR9lBh4NJsSIob2MbxDT2PvhDdTE6pNe6npNwYLCPIxa2meknPTO2FC
v8X5x+NhtJUgAwmWVtupFccWv6YxpKeCzB3qW9YZ7E1tGwrzsYLnMi02XAiWAivYSeLsLQwizF5c
306exXidz3WwFeOjJTxb9cWbVRImUAwfXyWslX1XXmBi599sB+wTyToPPL85S64imDor6tVG9Zuy
Jg17lVZvEPRFbwlUiITj4lrlzBAIEXQ67uHRZWWk/NSz4TisH4cyQLFghwnWcoUI2JQYNc7n4NKm
nWrXtxTKnn/Gjip1d65a5p31g4JSMuIVAIb26HCTg7cOmMWj/5qw5LlqecHj+Cpx7t464pTaNwgR
ll3wtWR1ynHman2bpUKgGRzGsOPlDYK+0sq5jgw0IeCDamBiWBobS2HF2SiPZlhqWsvWTrHsE+tC
EoCK4TlzMrrQ6ghNHT+3FyOr8aDKvVkBVbVXtC07J7ULLW+EWlbhNVoeYeTVLbda5RllFa83sX0v
znmRhKfvwhbSHVtRvWVhWamHed4vq7kFU+qDu3o/gYqrokBRj1avQeZuJNNJywtrTBT1SllWzSEo
QVdsj7pflOVzs7bmyc/0d6Hj+tVNIxoc5etxAnUVeOkdtRMSMSgJnVd9h1r4bcpSaAIapzm842yN
49xo6s4i8i0afRuK6oyPtnBvoyz7ej7ZFey5lp+OQncbrFbSC7LjApSPtmhbI/c6TYWVs21JYW4I
aZvyzPIrvhMvUYzY/IIVYs25FAVvFZcMWY0EqiR+YK1wD7ClhxNWScezJRsiLYKIaGckt0tQzNsj
eg1PapNw6L3k/RReDGZUy2tozuZraPkvrBFTO7SDcqco/x+Kg0eD/vcgk1WsjPBCbFF7MN1C77GC
2uPvH8t1bauWUbx8ubw+fRhudu6+N1hd3oXacLOB78Fi9pBrQ/1ltV3sFpcP+8Xsy3r+OF7fg4l9
iR4+eMPPOaybrLbfP93te9vVpbZedG+yk8Vjb7PoK7H3dbyDxbmmPq/n3c8Xq6GZ311+WS+2Yb7o
9zba8O7CuzVfVkHveTFb7Fbb8IMz+5xr/U13vH+GdZ/3J9qtGTuw690H/cXdTqNR0OvNu3roXo7X
3nATan2PUg0UZIvZpwutH38zhw9bZ/apfGdvb7KF5a5P5iXZ8TdteINUfF11P8Fi7wKQM4RDb7Oa
PbzOZ1/y/hovpr0pwa/Pvy5Bq/vwab79vHG3X9ar7afUB/qQYdz+hO+/vh/uknsr/gZM3yEib/b9
eRV4H7QhSguQWb1k8RgGq+7NHniBDS427m0P3rkctrc9Qb14AnU/I8FCv6MPWehbHDH8fvJ/KrX/
yvREwc1nn541lVtRNI6AvMWLG/Si+ewidIc3z2BK35x9b4PC+lVzPKnbIwryZyReCVyJvnQ/78H0
8hNNvfk67z78APY+OMNpac/a8CJcRVNgbacyJyjePRjIBWgl8B7NDyDwH0A9ZRm1kLrdfyBQn738
+IJy0W7vwtXs5rVYKMnQYhujizIP/Xj/lpYwef1/UxIY5OzuZf5494zcniC77hBe7pXY2aY7jhxY
DX9Ulv1x/WWmf1086j8wniysUjFrMNrcs5Rv9893FydM/Z9Hi8fnNSggmz/Ci4BRBtTkQEXkPYII
KJKKg9E6ftPiqSx/NVLcfRDYZa7XL6wBY+5JEXSLmAsiYAK/nf+4tz6uLQt89fIhXQw/Rl6/h2ER
EKnrIhJqQzNE2TqPJhh89+P6ngK2G/Gv2PDJW0b8tm3+B1BLAQI/AxQAAAAIAAVUi1sFAI+OjBEA
ACc5AAAPAAAAAAAAAAAAAACkgQAAAABMQU5HVUFHRV9lbi50eHRQSwUGAAAAAAEAAQA9AAAAuREA
AAAA"

    # LANGUAGE_pt base64
    LANGUAGE_pt="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"

    if [ ! -f "$INPUTS"/data/LANGUAGE_en.txt ]; then
        echo "$LANGUAGE_en" | base64 --decode > "$INPUTS"/data/LANGUAGE_en.zip 2> /dev/null && \
            unzip -d "$INPUTS/data" "$INPUTS"/data/LANGUAGE_en.zip  > /dev/null 2>&1 && \
            rm -f "$INPUTS"/data/LANGUAGE_en.zip 2>/dev/null
    fi

    if [ ! -f "$INPUTS"/data/LANGUAGE_pt.txt ]; then
        echo "$LANGUAGE_pt" | base64 --decode > "$INPUTS"/data/LANGUAGE_pt.zip 2> /dev/null && \
            unzip -d "$INPUTS/data" "$INPUTS"/data/LANGUAGE_pt.zip  > /dev/null 2>&1 && \
            rm -f "$INPUTS"/data/LANGUAGE_pt.zip 2>/dev/null
    fi

    SLOGAN="MiSTer GCM"
    SLOGAN_OR_CORE="MiSTer GCM"

    # LANGUAGE 'pt' or 'en' - Select Language
    LANGUAGE=$(grep -o '^[[:space:]]*language=[^[:space:]]*' "$INPUTS"/configs/gcm.cfg | \
        cut -d'=' -f2 2>/dev/null)

    if [ "$LANGUAGE" = "en" ]; then
        source "$INPUTS"/data/LANGUAGE_en.txt
    else
        source "$INPUTS"/data/LANGUAGE_pt.txt

    fi
}

updateDictionary # Update the language and the messages displayed in the Menus

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# Check and generate the configuration files for GCM                                        #
generateFiles(){
    # HELP MESSAGES en - base64
    HELP_MESSAGE_en="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"

    # HELP MESSAGES pt - base64
    HELP_MESSAGE_pt="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
DQAAAAA="

    # ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
    # Generate HELP TXT
    if [ ! -f "$INPUTS"/data/HELP_en.txt ]; then
       echo "$HELP_MESSAGE_en" | base64 --decode > "$INPUTS"/data/HELP_en.txt.zip 2> /dev/null && \
           unzip -d "$INPUTS/data" "$INPUTS"/data/HELP_en.txt.zip  > /dev/null 2>&1 && \
           rm -f "$INPUTS"/data/HELP_en.txt.zip 2>/dev/null
    fi

    if [ ! -f "$INPUTS"/data/HELP_pt.txt ]; then
        echo "$HELP_MESSAGE_pt" | base64 --decode > "$INPUTS"/data/HELP_pt.txt.zip 2> /dev/null && \
            unzip -d "$INPUTS/data" "$INPUTS"/data/HELP_pt.txt.zip  > /dev/null 2>&1 && \
            rm -f "$INPUTS"/data/HELP_pt.txt.zip 2>/dev/null
    fi

    eval "HELP_MESSAGE=\${HELP_MESSAGE_${LANGUAGE}}"

    # NO GAMEPAD en - base64
    NO_GAMEPAD_en="Ck5vIHJlZ2lzdGVyZWQgZ2FtZXBhZCBmb3VuZC4KClRvIHVzZSB0aGUgZnVuY3Rpb25zIG9mIHRo
aXMgcHJvZ3JhbSwgeW91IG11c3QgcmVnaXN0ZXIgYSBnYW1lcGFkLiBUbwpkbyB0aGlzLCB0aGUg
Z2FtZXBhZCBuZWVkcyB0byBiZSBjb25maWd1cmVkIGZpcnN0IGluICdNaVNUZXIgRlBHQScuCgpB
bHNvLCBkb24ndCBmb3JnZXQgdG8gYWNjZXNzIHRoZSBIZWxwIG1lbnUgZm9yIGltcG9ydGFudCBp
bmZvcm1hdGlvbgpvbiBob3cgdG8gY29uZmlndXJlIGFuZCB1c2UgdGhpcyBzY3JpcHQuCgpDbGlj
ayAnRXhpdCcgdG8gY29udGludWUuCg=="

    # NO GAMEPAD pt - base64
    NO_GAMEPAD_pt="Ck5lbmh1bSBnYW1lcGFkIHJlZ2lzdHJhZG8gZm9pIGVuY29udHJhZG8uCgpQYXJhIHV0aWxpemFy
IGFzIGZ1bsOnw7VlcyBkZXN0ZSBwcm9ncmFtYSwgw6kgbmVjZXNzw6FyaW8gcmVnaXN0cmFyIHVt
CmdhbWVwYWQuIFBhcmEgZmF6ZXIgaXNzbywgbyBnYW1lcGFkIHByZWNpc2Egc2VyIGNvbmZpZ3Vy
YWRvIHByZXZpYW1lbnRlCm5vICdNaVNUZXIgRlBHQScuCgpBbMOpbSBkaXNzbywgbsOjbyBzZSBl
c3F1ZcOnYSBkZSBhY2Vzc2FyIG8gbWVudSBBanVkYSBwYXJhIG9idGVyCmluZm9ybWHDp8O1ZXMg
aW1wb3J0YW50ZXMgc29icmUgY29tbyBjb25maWd1cmFyIGUgdXNhciBlc3RlIHNjcmlwdC4KCkNs
aXF1ZSBlbSAnU2FpcicgcGFyYSBjb250aW51YXIuCg=="

    # ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
    # Generate NO_GAMEPAD TXT
    if [ ! -f "$INPUTS/data/NO_GAMEPAD_en.txt" ]; then
        echo "$NO_GAMEPAD_pt" | base64 --decode > "$INPUTS/data/NO_GAMEPAD_en.txt" \
            2>/dev/null
    fi

    if [ ! -f "$INPUTS/data/NO_GAMEPAD_pt.txt" ]; then
        echo "$NO_GAMEPAD_en" | base64 --decode > "$INPUTS/data/NO_GAMEPAD_pt.txt" \
            2>/dev/null
    fi

    # LIST CONTROLLER IDS - base64
    LIST_CONTROLLER_IDS="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"

    if [ ! -f "$INPUTS/configs/LIST_CONTROLLER_IDS.txt" ]; then
        echo "$LIST_CONTROLLER_IDS" | \
            base64 --decode > "$INPUTS"/configs/LIST_CONTROLLER_IDS.txt.zip 2> /dev/null && \
            unzip -d "$INPUTS/configs" "$INPUTS"/configs/LIST_CONTROLLER_IDS.txt.zip  > /dev/null 2>&1 && \
            rm -f "$INPUTS"/configs/LIST_CONTROLLER_IDS.txt.zip 2>/dev/null
    fi

    if [ ! -f "$INPUTS/configs/registered_gamepads.cfg" ]; then
        touch "$INPUTS/configs/registered_gamepads.cfg" 2>/dev/null
    fi
}

# PRIMARY FUNCTIONS - Main functions responsible for the menus and key actions of the program

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# mainMENU - Menu for Cores and Other Configuration Options
mainMENU(){
    clear

    controllerID # Check the ID and MODEL of the registered controller
    checkGamepadDIR # Check if the gamepad-$ID directory exists
    countGamepads # Count the number of registered gamepads
    tipsFlags # check tips status

    SLOGAN_OR_CORE="$SLOGAN"
    increase=17
    linesGenerate # Generate the lines - List of Cores
    MESSAGE_MENU="$MESSAGE_SELECT_CORE"
    param_1=67
    param_2=4
    extra_options="--no-cancel"
    generateHeader # Generate the header of the dialog menu
    generateCoresMENU # Insert the cores into the MENU from linesGenerate
    DIALOG+="
- -------------------- \\
X \"$EXIT_PROGRAM\" \\
- -------------------- \\
A \"$ADD\" \\
V \"$VIEW\" \\
E \"$EXCLUDE\" \\
- -------------------- \\
G \"$GAMEPADS\" \\
S \"$SETTINGS\" \\
- -------------------- \\
H \"$HELP\""

runDIALOG # Execute the dialog menu that was generated

    case "$choice" in
        "X")
            exitProgram
            ;;
        "A")
            addCORE
            ;;
        "V")
            viewCORES
            ;;
        "E")
            excludeCORE
            ;;
        "G")
            gamepadsMENU
            ;;
        "S")
            settingsMENU
            ;;
        "H")
            helpMENU
            ;;
        "-")
            mainMENU
            ;;
        *)
            coreMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ADD - Add Core
addCORE(){
    clear

    testGamepads # Check if any gamepad is registered

    DIALOG="dialog --ok-label "$OK" --cancel-label "$CANCEL" --clear --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$CORE_SELECTION\" 9 67 4 \
        L \"$FROM_LIST\" \
        T \"$FROM_TEXT\""
    
    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated
    
    if [ "$status_message" = 1 ]; then
        mainMENU
    fi

    select_option="$choice"

    selectINPUT(){
        if [ "$select_option" = "L" ]; then

            title=$(printf "%s" "$ATTENTION")
            message_ln1=$(printf "%s" "$WAIT_LIST")
            message_ln2=$(printf "%s" "$CLICK_OK")
            messageDIALOG

            clear
    
            MESSAGE_MENU="$NAME_SELECTION"
            param_1=67
            param_2=4
            lines_menu=28
            extra_options=""
            generateHeader # Generate the header of the dialog menu

            generateCoresList # Generates a list of found cores, removes duplicates, and sorts

            DIR_TARGET="$tmp_message" # DIR_TARGET to the linesArray
            linesArray # Generate the lines for the menu
            rm -f "$tmp_message" 2>/dev/null

            for ((i = 1; i < counter; i++)); do
                output=${lines_array[((i-1))]}
                output_menu=$(echo "$output" | cut -c1-60 2>/dev/null)
                if [ "$i" != "$((counter - 1))" ]; then
                    DIALOG+="$i \"$output_menu\" \\
"
                else
                    DIALOG+="$i \"$output_menu\""
                fi
            done
    
            runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

            if [ "$status_message" = 1 ]; then
                mainMENU
            fi

            CORE="${lines_array[((choice-1))]}"
            CHECK_SELECTION="$CORE_SELECTED"

        else
            title=$(printf "%s" "$ADD_CORE")
            message_ln1=$(printf "%s" "$INSERT_CORE_NAME")
            inputDIALOG

            if [ "$status_message" = 1 ]; then
                mainMENU
            fi

            CORE="$TMP_INPUT"

            if [ "$CORE" = "" ]; then
                addCORE
            fi

            CHECK_SELECTION="$TYPED"
        fi
    }
    selectINPUT

    checkCORE # Checks if the Core exists or has already been added to the list

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'." "$CHECK_SELECTION" "$CORE")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        mainMENU
    fi    
    
    if [ -d "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"-STORED ]; then
        mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"-STORED "$INPUTS"/gamepad-"$ID"/"$CORE-$ID" 2>/dev/null
            
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$RESTORE_CORE")
        messageDIALOG
        mainMENU
    fi

    title=$(printf "%s" "$CHOOSE_GAMEPAD")
    message_ln1=$(printf "%s" "$CHOOSE_QUESTION")

    sizeAdjust # Adjust the menu formatting proportionally to the text

    DIALOG="dialog --ok-label "$OK" --cancel-label "$CANCEL" --no-tags --stdout \
            --title \"$title\" \
            --menu \"$message_ln1\" 10 "$size_dialog" 2 \
            1 \"$JOY_TYPE_1\" \
            2 \"$JOY_TYPE_2\" \
            3 \"$JOY_TYPE_3\""
        
    runDIALOG NO_CORE_CHOICE  # Execute the dialog menu that was generated

    if [ "$status_message" = 1  ]; then
        mainMENU
    fi
    JOY_TYPE="$choice"

    NAME="JOY_TYPE_${choice}"
    OUTPUT="${!NAME}"

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s: \"%s\"." "$YOU_SELECTED" "$OUTPUT")
    message_ln2=$(printf "%s" "$CORRECT")        
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        mainMENU
    fi   

    mkdir "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" 2>/dev/null
    if [ "$TIPS" = 1 ]; then
        touch "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games 2>/dev/null
        touch "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts 2>/dev/null
    fi

    if [ "$JOY_TYPE" = 1 ]; then
        echo "v3" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/TYPE_"$ID".cfg 2>/dev/null
    elif [ "$JOY_TYPE" = 2 ]; then
        echo "jk" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/TYPE_"$ID".cfg 2>/dev/null
    else
        echo "jk_v3" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/TYPE_"$ID".cfg 2>/dev/null
    fi
    title=$(printf "%s" "$SLOGAN")
    message_ln1=$(printf "%s '%s' %s" "$CORE_CREATED_1" "$CORE" "$CORE_CREATED_2")
    messageDIALOG
    mainMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# excludeCORE - Exclude Core
excludeCORE(){
    clear

    counter=$(find "$INPUTS"/gamepad-"$ID" -type d -name "*-$ID" | sed "s|-$ID||g" | sed "s|$INPUTS\/||g" | wc -l 2>/dev/null)
    if [ "$counter" = 0 ]; then
        mainMENU
    fi
    testGamepads # Check if any gamepad is registered
    increase=8
    linesGenerate # Generate the lines - List of Cores
    MESSAGE_MENU="$MESSAGE_TRASH"
    param_1=60
    param_2=4
    extra_options="--no-cancel"
    generateHeader # Generate the header of the dialog menu
    DIALOG+="
X \"$EXIT_MENU\" \\
- \"-------------\" \\"
    generateCoresMENU EXCLUDE_SYMBOL # Insert the cores into the MENU from linesGenerate

    runDIALOG # Execute the dialog menu that was generated
    
    case "$choice" in
        "X")
            mainMENU
            ;;
        "-")
            excludeCORE
            ;;
    esac

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'?" "$EXCLUSION" "$CORE")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG

    if [ "$status_message" = 0 ]; then
        title=$(printf "%s" "$CONFIRMATION")
        message_ln1=$(printf "%s '%s'?" "$SAVE_PROFILES" "$CORE")
        yesnoDIALOG
        if [ "$status_message" = 1 ]; then
            if [ -z "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" ] || [ "$INPUTS" == "/" ] || [ -z "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" ]; then
                mainMENU
            fi    
            rm -rf "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" 2>/dev/null
            title=$(printf "%s" "$EXCLUDED_CORE")
            message_ln1=$(printf "%s" "$EXCLUDED_FILES")
            messageDIALOG
        else
            mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"-STORED 2>/dev/null
            title=$(printf "%s" "$EXCLUDED_CORE")
            message_ln1=$(printf "%s" "$RETAINED_FILES")
            messageDIALOG
        fi
    fi    
    mainMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# viewCORES - Display List of Cores from MiSTer (names.txt - Fix .mgl names)
viewCORES() {
    clear

    if [ ! -f "$MISTER_ROOT/names.txt" ]; then
        title=$(printf "%s" "$SHOW_MENU")
        message_ln1=$(printf "%s" "$MISSING_NAMES_1")
        message_ln2=$(printf "%s" "$MISSING_NAMES_2")
        messageDIALOG
        generateCoresList HEADERS
        SHOW_TITLE="$SHOW_FIND"
    else
        cp "$MISTER_ROOT/names.txt" "$tmp_message" 2>/dev/null

        check_cores=("$CORES_COMPUTER" "$CORES_CONSOLE" "$CORES_OTHER" "$CORES_UNSTABLE")

        MEM_MSG="$USE_NAMES|$MENU_NAMES"
        echo "$MEM_MSG" > "${tmp_message}.tmp"
        while IFS= read -r line; do
            first_col="${line%%:*}"
            second_col="${line:20}"
            setname_found=""
            for dir in "${check_cores[@]}"; do
                filepath="$dir/$first_col.mgl"
                if [ -f "$filepath" ]; then
                    setname_found=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath")
                    break
                fi
            done

            if [ -n "$setname_found" ]; then
                first_col="$setname_found"
                len=${#first_col}
                if [ $len -ge 20 ]; then
                    printf "%s%s\n" "$first_col" "$second_col"
                else
                    pad=$((20 - len - 1))
                    printf "%s:%*s%s\n" "$first_col" "$pad" "" "$second_col"
                fi
            else
                echo "$line"
            fi
        done < "$tmp_message" >> "${tmp_message}.tmp"

        mv "${tmp_message}.tmp" "$tmp_message"

        SHOW_TITLE="$SHOW_MENU"
    fi

    dialog --exit-label "$EXIT" --title "$SHOW_TITLE" --textbox "$tmp_message" 28 51

    rm -f "$tmp_message" 2>/dev/null
    mainMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# helpMENU - Display Help Text for Script Functionality
helpMENU(){
    clear

    sed -i "s/^help_tips=[^ ]*/help_tips=0/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
    help_flag=0 # Flag that enables HELP menu hint
    if [ -f "$INPUTS"/data/HELP_"$LANGUAGE".txt ]; then
        dialog --exit-label "$EXIT" --title "$SLOGAN" --textbox "$INPUTS"/data/HELP_"$LANGUAGE".txt 28 75
    fi
    mainMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# settingsMENU - General Configuration Menu
settingsMENU(){
    clear
   
    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$MENU_SETTINGS\" 14 67 4 \
        X \"$RETURN_2\" \
        - ----------------------------- \
        C \"$COLORS_MENU\" \
        L \"$LANGUAGE_MENU\" \
        T \"$TIPS\" \
        - ----------------------------- \
        B \"$BACKUP\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "X" | "x")
            mainMENU
            ;;
        "C")
            colorsMENU
            ;;
        "L")
            languageMENU
            ;;
        "T")
            tipsMENU
            ;;
        "B")
            backupMENU
            ;;
        "-")
            settingsMENU
            ;;
        *)
            mainMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# COLORS_MENU - Adjust Color Theme
colorsMENU(){
    clear
   
    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$SELECT_COLORS\" 16 67 4 \
        X \"$EXIT_MENU\" \
        - ----------------------------- \
        B \"$COLOR_BLUE\" \
        Y \"$COLOR_YELLOW\" \
        M \"$COLOR_MAGENTA\" \
        G \"$COLOR_NEON_GREEN\" \
        N \"$COLOR_NEON_YELLOW\" \
        W \"$COLOR_NEON_WHITE\" \
        D \"$COLOR_DEFAULT\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "X")
            settingsMENU
            ;;
        "-")
            colorsMENU
            ;;
        "B" | "Y" | "M" | "G" | "N" | "W" | "D")
            
            rm -f "$INPUTS"/configs/DIALOGRC 2>/dev/null
            case "$choice" in
                "B") COLOR_SELECTED="BLUE" ;;
                "Y") COLOR_SELECTED="YELLOW" ;;
                "M") COLOR_SELECTED="MAGENTA" ;;
                "G") COLOR_SELECTED="NEON_GREEN" ;;
                "N") COLOR_SELECTED="NEON_YELLOW" ;;
                "W") COLOR_SELECTED="NEON_WHITE" ;;
                "D") COLOR_SELECTED="DEFAULT" ;;
            esac

            sed -i "s/^dialogrc_color-scheme=[^ ]*/dialogrc_color-scheme=$COLOR_SELECTED/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
            definitionsDIALOGRC # Update the visual settings of the dialog
            colorsMENU
            ;;
        *)
            colorsMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
## languageMENU - Select Language (en for English, pt for Portuguese)
languageMENU(){
    clear

    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \" $SELECT_LANGUAGE\" 11 67 4 \
        X \"$EXIT_MENU\" \
        - \"------------------------------\" \
        E \"$EN\" \
        P \"$PT\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    # Run multiple functions to update the language
    updateLanguage(){
        updateDictionary # Update the language and the messages displayed in the Menus
        updateNoGamepadMessage # Update the NO_GAMEPAD message in the selected language
        controllerID # Check the ID and MODEL of the registered controller
        languageMENU
    }

    case "$choice" in
        "X")
            settingsMENU
            ;;
        "-")
            languageMENU
            ;;
        "E")
            sed -i "s/^language=[^ ]*/language=en/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
            updateLanguage
            ;;
        "P")
            sed -i "s/^language=[^ ]*/language=pt/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
            updateLanguage
            ;;
        *)
            settingsMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
## tipsMENU - Interactive Tips
tipsMENU(){
    clear

    tipsCOMMAND(){
        sed -i "s/^tips=[^ ]*/tips=$tips_status/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
        sed -i "s/^help_tips=[^ ]*/help_tips=$tips_status/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
        tips_flag="$tips_status" # Flag that enables help tips next to the menus
        help_flag="$tips_status" # Flag that enables HELP menu hint
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$TIPS_MESSAGE")
        messageDIALOG
        settingsMENU
    }

    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$TIPS_MENU\" 11 67 4 \
        X \"$EXIT_MENU\" \
        - \"------------------------------\" \
        A \"$ACTIVE_TIPS\" \
        D \"$DEACTIVE_TIPS\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "-")
            tipsMENU
            ;;
        "X")
            settingsMENU
            ;;
        "A")
            tips_status="1"
            TIPS_MESSAGE="$TIPS_ENABLED"
            tipsCOMMAND
            ;;
        "D")
            tips_status="0"
            TIPS_MESSAGE="$TIPS_DISABLED"
            tipsCOMMAND
            ;;
        *)
            settingsMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# backupMENU - Backup routines for program and gamepad settings
backupMENU(){
    clear

    DIALOG="dialog  --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$BACKUP_MENU\" 12 67 4 \
        X \"$EXIT_MENU\" \
        - \"------------------------------\" \
        S \"$SAVE_BACKUP\" \
        R \"$RESTORE_BACKUP\" \
        D \"$DELETE_BACKUP\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "-")
            backupMENU
            ;;
        "X")
            settingsMENU
            ;;
        "S")
            saveBACKUP
            ;;
        "R")
            restoreBACKUP
            ;;
        "D")
            deleteBACKUP
            ;;
        *)
            settingsMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# saveBACKUP - Save backup routine
saveBACKUP(){
    clear

    title=$(printf "%s" "$BACKUP_GCM")
    message_ln1=$(printf "%s" "$MESSAGE_INIT_BACKUP")
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        backupMENU
    fi
    
    BKP_DIR="$INPUTS"/tmp/Backup-GCM-MiSTer
    DATE=$(date +"%y_%m_%d-%H_%M")
    mkdir -p "$BKP_DIR/Backup-GCM-MiSTer-"$DATE"" 2>/dev/null
    cp -R -f "$INPUTS"/gamepad-* "$BKP_DIR"/Backup-GCM-MiSTer-"$DATE" 2>/dev/null
    cp -R -f "$INPUTS"/configs "$BKP_DIR"/Backup-GCM-MiSTer-"$DATE" 2>/dev/null
    cp -R -f "$INPUTS"/data "$BKP_DIR"/Backup-GCM-MiSTer-"$DATE" 2>/dev/null
    cd "$BKP_DIR" || backupMENU
    zip -r "$INPUTS"/Backup-GCM-MiSTer-"$DATE".zip Backup-GCM-MiSTer-"$DATE"/* > /dev/null 2>&1
    if [ -z "$BKP_DIR" ] || [ "$BKP_DIR" == "/" ]; then
        mainMENU
    fi    
    rm -rf "$BKP_DIR"
    title=$(printf "%s" "$BACKUP_FINISHED")
    message_ln1=$(printf "%s 'Backup-GCM-MiSTer-%s.zip'" "$MESSAGE_SAVE_BACKUP_1" "$DATE")
    message_ln2=$(printf "%s" "$MESSAGE_SAVE_BACKUP_2")
    messageDIALOG
    backupMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# restoreBACKUP - Restore backup routine
restoreBACKUP() {
    clear

    BACKUP_MESSAGE="$BACKUP_RESTORE_MESSAGE"
    generateBackupMENU # Generate the menu from the backup files found on disk

    if [ "$choice" = "-" ]; then
        restoreBACKUP
    fi

    if [ "$choice" = "X" ]; then
        backupMENU
    fi

    selected_backup="${backups[$choice-1]}"

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'?" "$BACKUP_WANT" "$choice")
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$BACKUP_CANCELLED")
        messageDIALOG
        backupMENU
    fi

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s" "$BACKUP_WANT_2")
    message_ln2=$(printf "%s" "$CONTINUE")
    yesnoDIALOG

    if [ "$status_message" = 0 ]; then
        if [ -z "$INPUTS" ] || [ "$INPUTS" == "/" ]; then
            backupMENU

        fi
        rm -rf "${INPUTS:?}"/gamepad-* 2>/dev/null
        rm -rf "${INPUTS:?}"/configs 2>/dev/null
        rm -rf "${INPUTS:?}"/data 2>/dev/null
        BKP_DIR="$INPUTS"/tmp/Backup-GCM-MiSTer
        mkdir -p "$BKP_DIR" 2>/dev/null
        extraction_dir="$BKP_DIR/$(basename "$selected_backup" .zip)"

        if [ "$(echo "$extraction_dir" | grep Backup-GCM-MiSTer)" = "" ]; then
            backupMENU
        fi

        if [ -d "$extraction_dir" ] && [ "$extraction_dir" != "/" ]; then
            rm -rf "$extraction_dir" 2>/dev/null
        fi

        mkdir -p "$extraction_dir" 2>/dev/null
        unzip "$selected_backup" -d "$BKP_DIR" > /dev/null 2>&1
        mv "$extraction_dir"/* "$INPUTS/" 2>/dev/null

        if [ ! -z "$BKP_DIR" ] || [ "$BKP_DIR" != "/" ]; then
            rm -rf "$BKP_DIR" 2>/dev/null
        fi

        generateFiles # Check and generate the configuration files for GCM
        title=$(printf "%s" "$SLOGAN")
        message_ln1=$(printf "%s" "$BACKUP_RESTORED")
        messageDIALOG
    else
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$BACKUP_CANCELLED")
        messageDIALOG
        backupMENU
    fi

    backupMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# deleteBACKUP -delete backup routine
deleteBACKUP(){
    clear

    BACKUP_MESSAGE="$BACKUP_DELETE_MESSAGE"
    generateBackupMENU # Generate the menu from the backup files found on disk

    if [ "$choice" = "-" ]; then
        deleteBACKUP
    fi

    if [ "$choice" = "X" ]; then
        backupMENU
    fi

    selected_backup="${backups[$choice-1]}"
    output=$(basename "${backups[$choice-1]}")

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'?" "$BACKUP_DELETE_CONFIRM" "$output")
    message_ln2=$(printf "%s" "$CONTINUE")
    yesnoDIALOG

    if [ "$status_message" != 1 ]; then
        rm -f "$selected_backup" 2>/dev/null
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$BACKUP_DELETED")
        messageDIALOG
    fi
    backupMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# gamepadsMENU - Manage gamepad profiles and settings
gamepadsMENU(){
    clear

    countGamepads # Count the number of registered gamepads

    if [ "$lines_check" = 0 ] && [ "$tips_flag" = 1 ]; then
        REGISTER="$REGISTER_TIPS"
        MENU_GAMEPADS="$MENU_GAMEPADS_TIPS"
        SHOW_RETURN_TIPS="1"
    else
        REGISTER="$REGISTER_DEFAULT"
        MENU_GAMEPADS="$MENU_GAMEPADS_DEFAULT"
    fi
    if [ "$SHOW_RETURN_TIPS" = 1 ] && [ "$lines" != 0 ] && [ "$tips_flag" = 1 ]; then
        RETURN="$RETURN_TIPS"
    else
        RETURN="$RETURN_DEFAULT" 
    fi 

    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \" $MENU_GAMEPADS\" 16 67 4 \
        X \"$RETURN\" \
        - \"---------------------------------\" \
        S \"$SELECT\" \
        L \"$LIST\" \
        N \"$RENAME\" \
        D \"$REMOVE\" \
        R \"$REGISTER\" \
        - \"---------------------------------\" \
        C \"$COPY\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "X")
            mainMENU
            ;;
        "S")
            selectGamepad
            ;;
        "L")
            listGamepads
            ;;
        "N")
            renameGamepad
            ;;
        "D")
            removeGamepad
            ;;
        "R")
            registerGamepad
            ;;
        "C")
            copyGamepad
            ;;
        "-")
            gamepadsMENU
            ;;
        *)
            mainMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# selectGamepad - Select default gamepad
selectGamepad(){
    clear
  
    if [ "$display_init" = 1 ]; then
        DISPLAY_MESSAGE="$GAMEPAD_SELECTION"
    else
        DISPLAY_MESSAGE="$GAMEPAD_DEFAULT"
    fi

    makeGamepadMENU # Start generating the menu with the registered gamepads
    extra_options=""
    generateHeader # Generate the header of the dialog menu
    generateListRegisteredGamepads ID_MODEL # Generate gamepad list menu and run the dialog
    recordGamepadID # Register the gamepad and update SELECTED_GAMEPAD ID and MODEL
    controllerID # Check the ID and MODEL of the registered controller
    if [ "$display_init" = 1 ]; then
        display_init=0  # Disable an indication in the menu to register a gamepad
        mainMENU
    else
        gamepadsMENU
    fi
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# listGamepads - Display registered gamepads
listGamepads(){
    clear

    checkRegisteredGamepads # Check if there are any registered gamepads
    lines_menu=$((lines_check + 7))
    echo "-- ID: --   --- MODEL: ---" > "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    echo "" >> "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    cat "$INPUTS"/configs/registered_gamepads.cfg >> "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    dialog --exit-label "$EXIT" --title "$SLOGAN - $MODEL_CUT - $ID" --textbox "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp "$lines_menu" 75
    rm -f "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    gamepadsMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# registerGamepad - Register a new gamepad
registerGamepad(){
    clear

    if [ -z "$(ls "$INPUT_MISTER"/*v3.map 2>/dev/null)" ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$NO_GAMEPAD_REGISTER_1")
        message_ln2=$(printf "%s" "$NO_GAMEPAD_REGISTER_2")
        messageDIALOG
        exitProgram
    fi

    touch "$tmp_IDs" 2>/dev/null
    cd "$INPUT_MISTER" ||  exit 1
    declare -A extracted_ids

    for file in input*v3.map; do
        if [[ -f "$file" ]]; then
            id=$(echo "$file" | sed -E 's/.*_([a-f0-9]{4}_[a-f0-9]{4})_v3\.map/\1/' 2>/dev/null)
            if [[ -n "$id" && -z "${extracted_ids["$id"]}" ]]; then
                if ! grep -q "^$id " "$INPUTS"/configs/registered_gamepads.cfg; then
                    extracted_ids["$id"]=1
                    echo "$id" >> "$tmp_IDs" 2>/dev/null
                fi
            fi
        fi
    done
    
    DIR_TARGET="$tmp_IDs" # DIR_TARGET to the linesArray
    linesArray # Generate the lines for the menu

    lines_menu=$((counter + 8))
    MESSAGE_MENU="$MESSAGE_SELECT_GAMEPAD"
    param_1=67
    param_2=4
    extra_options=""
    generateHeader # Generate the header of the dialog menu
    DIALOG+="
X \"$EXIT_MENU\" \\
- \"--------------------\" \\"

    IDS_LIST="$INPUTS/configs/LIST_CONTROLLER_IDS.txt"

    model=()
    indice=()
    print_indice=()
    for ((i = 1 ; i < counter; i++)); do
        output=${lines_array[$((i-1))]}
        search=${output/_/:}
        name=$(grep -m 1 "$search" "$IDS_LIST" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            model+=("")
        else    
            model+=("$(echo "$name" | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)")
        fi
        indice+=("$output - ${model[$((i-1))]}")
        print_indice+=("${indice[$((i-1))]% - }")
        if [ "$i" -lt $((counter - 1)) ]; then
            DIALOG+="$i \"${print_indice[$((i-1))]}\" \\"
        else
            DIALOG+="$i \"${print_indice[$((i-1))]}\""
        fi
    done
    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    if [ "$status_message" = 1 ]; then
        rm -f "$tmp_IDs" 2>/dev/null
        gamepadsMENU
    fi 

    case "$choice" in
        "X")
            rm -f "$tmp_IDs" 2>/dev/null
            gamepadsMENU
            ;;
        "-")
            registerGamepad
            ;;
        *)
            ID_CHOICE=$(sed -n "${choice}p" "$tmp_IDs" 2>/dev/null)
            rm -f "$tmp_IDs" 2>/dev/null

            if grep -q "$ID_CHOICE" "$INPUTS"/configs/registered_gamepads.cfg; then
                title=$(printf "%s - %s - %s" "$SLOGAN" "$MODEL_CUT" "$ID")
                message_ln1=$(printf "%s" "$GAMEPAD_ALREADY_REGISTERED")
                messageDIALOG
                registerGamepad
            fi

            title=$(printf "%s" "$CONFIRMATION")
            message_ln1=$(printf "%s '%s'." "$YOU_HAVE_SELECTED" "${print_indice[$choice-1]}")
            message_ln2=$(printf "%s" "$CORRECT")
            yesnoDIALOG
       
            if [ "$status_message" = 1 ]; then
                gamepadsMENU
            fi

            if [ "${model[$((choice - 1))]}" = "" ]; then
                title=$(printf "%s" "$ATTENTION")
                message_ln1=$(printf "%s" "$GAMEPAD_EMPTY")
                message_ln2=$(printf "%s" "$GAMEPAD_MODEL")
                inputDIALOG

                if [ "$status_message" = 1 ]; then
                    gamepadsMENU
                fi
  
                MODEL_CHOICE="$TMP_INPUT"
                title=$(printf "%s" "$CONFIRMATION")
                message_ln1=$(printf "%s '%s'?" "$TYPED" "$MODEL_CHOICE")
                message_ln2=$(printf "%s" "$CORRECT")
                yesnoDIALOG

                if [ "$status_message" = 1 ]; then
                    gamepadsMENU
                fi
            else
                MODEL_CHOICE=${model[$choice-1]}
            fi

            ID_CHOICE_LIST=${ID_CHOICE/_/:}
            echo "$ID_CHOICE - $MODEL_CHOICE" >> "$INPUTS"/configs/registered_gamepads.cfg 2>/dev/null
            echo "(\"$ID_CHOICE_LIST\" \"$MODEL_CHOICE\")" >> "$INPUTS"/configs/LIST_CONTROLLER_IDS.txt 2>/dev/null
            mkdir "$INPUTS"/gamepad-"$ID_CHOICE" 2>/dev/null
            recordGamepadID # Register the gamepad and update SELECTED_GAMEPAD ID and MODEL
            cleanRegisteredFile
            controllerID # Check the ID and MODEL of the registered controller
            title=$(printf "%s - %s - %s" "$SLOGAN" "$MODEL_CHOICE" "$ID_CHOICE")
            message_ln1=$(printf "%s" "$GAMEPAD_REGISTERED")
            messageDIALOG
            gamepadsMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# renameGamepad - Rename a registered gamepad
renameGamepad(){
    clear

    DISPLAY_MESSAGE="$GAMEPAD_SELECTION_RENAME"
    makeGamepadMENU # Start generating the menu with the registered gamepads
    extra_options=""
    generateHeader # Generate the header of the dialog menu
    generateListRegisteredGamepads ID_MODEL # Generate gamepad list menu and run the dialog

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'?" "$WANT_RENAME" "$MODEL_CHOICE")
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        gamepadsMENU
    fi

    title=$(printf "%s" "$RENAME_GAMEPAD")
    message_ln1=$(printf "%s '%s':" "$GAMEPAD_ENTRY_NAME" "$MODEL_CHOICE") 
    inputDIALOG

    if [ "$status_message" = 1 ]; then
        gamepadsMENU
    fi

    NEW_MODEL_CHOICE="$TMP_INPUT"
    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'." "$TYPED" "$NEW_MODEL_CHOICE")
    message_ln2=$(printf "%s" "$GAMEPAD_RENAME_CONFIRM")
    yesnoDIALOG  

    if [ "$status_message" = 1 ]; then
        gamepadsMENU
    fi
  
    REPLACE_STRING_1=$(printf "%s - %s" "$ID_CHOICE" "$NEW_MODEL_CHOICE")
    ID_CHOICE_LIST=${ID_CHOICE/_/:}
    REPLACE_STRING_2=$(printf "(\"%s\" \"%s\")" "$ID_CHOICE_LIST" "$NEW_MODEL_CHOICE")
    sed -i "/$ID_CHOICE/c\\$REPLACE_STRING_1" "$INPUTS"/configs/registered_gamepads.cfg 2>/dev/null
    sed -i "/$ID_CHOICE_LIST/c\\$REPLACE_STRING_2" "$INPUTS"/configs/LIST_CONTROLLER_IDS.txt 2>/dev/null

    if [ "$choice" = 1 ]; then
        echo "$ID_CHOICE" > "$INPUTS"/configs/selected_gamepad_ID.cfg 2>/dev/null
        echo "$NEW_MODEL_CHOICE" > "$INPUTS"/configs/selected_gamepad_MODEL.cfg 2>/dev/null
    fi

    controllerID # Check the ID and MODEL of the registered controller
    title=$(printf "%s" "$RENAME_GAMEPAD")
    message_ln1=$(printf "%s" "$GAMEPAD_RENAMED")
    messageDIALOG
    gamepadsMENU  
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# removeGamepad - Remove a registered gamepad
removeGamepad(){
    clear

    DISPLAY_MESSAGE="$MESSAGE_REMOVE_GAMEPAD"
    makeGamepadMENU # Start generating the menu with the registered gamepads
    extra_options=""
    generateHeader # Generate the header of the dialog menu
    generateListRegisteredGamepads # Generate gamepad list menu and run the dialog
    gamepad_choice=${lines_array[$((choice - 1))]}
    ID_CHOICE=$(echo "$gamepad_choice" | cut -c1-9 2>/dev/null)
    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'?" "$WANT_REMOVE" "$gamepad_choice")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        gamepadsMENU
    fi

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s" "$PRESERVE_PROFILES_1")
    message_ln2=$(printf "%s" "$PRESERVE_PROFILES_2")        
    yesnoDIALOG

    if [ "$status_message" = 1 ]; then
        DELETE_FILES=1
    else
        DELETE_FILES=0
    fi

    TEST=$(cat "$INPUTS/configs/selected_gamepad_ID.cfg" 2>/dev/null)
    sed -i "/$ID_CHOICE/d" "$INPUTS"/configs/registered_gamepads.cfg 2>/dev/null
    cleanRegisteredFile

    if [ "$TEST" = "$ID_CHOICE" ]; then
        echo "" > "$INPUTS"/configs/selected_gamepad_ID.cfg 2>/dev/null
        if grep -q "_" "$INPUTS/configs/registered_gamepads.cfg"; then
            echo "$SELECT_A_GAMEPAD" > "$INPUTS"/configs/selected_gamepad_MODEL.cfg 2>/dev/null
        else
            echo "$NO_GAMEPAD" > "$INPUTS"/configs/selected_gamepad_MODEL.cfg 2>/dev/null
        fi
    fi

    controllerID # Check the ID and MODEL of the registered controller

    if [ "$DELETE_FILES" = 1 ]; then
        if [ -z "$INPUTS" ] || [ "$INPUTS" == "/" ] || [ -z "$ID_CHOICE" ]; then
            gamepadsMENU
        fi    
        rm -rf "$INPUTS"/gamepad-"$ID_CHOICE" 2>/dev/null
        title=$(printf "%s" "$GAMEPAD_REMOVED")
        message_ln1=$(printf "%s" "$DELETED_MESSAGE")
        messageDIALOG
    else
        title=$(printf "%s" "$GAMEPAD_REMOVED")
        message_ln1=$(printf "%s" "$PRESERVE_MESSAGE_1")
        message_ln2=$(printf "%s" "$PRESERVE_MESSAGE_2")        
        messageDIALOG
    fi

   gamepadsMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# copyGamepad - Copy all settings from one gamepad to another
copyGamepad(){
    clear

    countGamepads
    if [ "$lines_check" -lt 2 ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$ONLY_ONE_COPY_1")
        message_ln2=$(printf "%s" "$ONLY_ONE_COPY_2")
        messageDIALOG
        gamepadsMENU
    fi 

    DISPLAY_MESSAGE="$MESSAGE_COPY_GAMEPAD"
    makeGamepadMENU # Start generating the menu with the registered gamepads
    extra_options=""
    generateHeader # Generate the header of the dialog menu

    DIR_TARGET="$INPUTS"/configs/registered_gamepads.cfg # DIR_TARGET to the linesArray
    linesArray # Generate the lines for the menu

    GAMEPADS_REGISTEREDS=""
    for ((i = 1 ; i < counter; i++)); do
        output=${lines_array[$((i-1))]}
        if [ "$i" -lt $((counter - 1)) ]; then
            GAMEPADS_REGISTEREDS+="$i \"$output\" \\"
        else
            GAMEPADS_REGISTEREDS+="$i \"$output\""
        fi
    done
    DIALOG+="$GAMEPADS_REGISTEREDS"
    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    if [ "$status_message" = 1 ]; then
        gamepadsMENU
    fi

    gamepad_choice_1=${lines_array[$((choice - 1))]}
    ID_CHOICE_1=$(echo "$gamepad_choice_1" | cut -c1-9 2>/dev/null)
    selectSecondGamepad(){
        DISPLAY_MESSAGE="$MESSAGE_DESTINY_GAMEPAD"
        makeGamepadMENU # Start generating the menu with the registered gamepads
        extra_options=""
        generateHeader # Generate the header of the dialog menu
        DIALOG+="${GAMEPADS_REGISTEREDS//${lines_array[$((choice-1))]}/ <<< $SELECTED_COPY >>>}"
        runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated
    
        if [ "$status_message" = 1 ]; then
            gamepadsMENU
        fi

        gamepad_choice_2=${lines_array[$((choice - 1))]}
        ID_CHOICE_2=$(echo "$gamepad_choice_2" | cut -c1-9 2>/dev/null)

        if [ "$gamepad_choice_2" = "$gamepad_choice_1" ]; then
            selectSecondGamepad 
        fi
    }
    
    selectSecondGamepad

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'" "$WANT_COPY_1" "$gamepad_choice_1")
    message_ln2=$(printf "%s '%s'?" "$WANT_COPY_2" "$gamepad_choice_2")
    yesnoDIALOG

    if ls -d /"$INPUTS"/gamepad-"$ID_CHOICE_2" &>/dev/null; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s '%s'" "$COPY_OVERWRITE_1" "$gamepad_choice_2")
        message_ln2=$(printf "%s" "$COPY_OVERWRITE_2")
        yesnoDIALOG
        if [ "$status_message" = 1 ]; then
            gamepadsMENU
        else
            if [ -d "$INPUTS"/gamepad-"$ID_CHOICE_2" ]; then
                rm -rf /"$INPUTS"/gamepad-"$ID_CHOICE_2"/* 2>/dev/null
            else
                gamepadsMENU
            fi
        fi
    else
        mkdir /"$INPUTS"/gamepad-"$ID_CHOICE_2" 2>/dev/null
    fi

    for cores_dir in "$INPUTS"/gamepad-"$ID_CHOICE_1"/*"$ID_CHOICE_1"; do
        if [ -d "$cores_dir" ]; then
            new_cores_dir="${cores_dir/$ID_CHOICE_1/$ID_CHOICE_2}"
            cp -r "$cores_dir" "$new_cores_dir" 2>/dev/null
        
            for cores_dir_2 in "$INPUTS"/gamepad-"$ID_CHOICE_2"/*"$ID_CHOICE_1"; do
                new_cores_dir_2="${cores_dir_2/$ID_CHOICE_1/$ID_CHOICE_2}"
                mv "$cores_dir_2" "$new_cores_dir_2" 2>/dev/null
            done

            for files_cores in "$new_cores_dir_2"/*; do
                if [[ -f "$files_cores" && "$files_cores" == *$ID_CHOICE_1* ]]; then
                    new_files_cores="${files_cores/$ID_CHOICE_1/$ID_CHOICE_2}"
                    mv "$files_cores" "$new_files_cores" 2>/dev/null
                fi
            done
         fi
    done

    title=$(printf "%s" "$COPY_FINISHED")
    message_ln1=$(printf "%s" "$COPY_COMPLETED")
    messageDIALOG

    gamepadsMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# coreMENU - Show menu to access 'SLOTS' of the selected 'Core'
coreMENU(){
    clear

    counter=$(find "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" -type f -name "LAYOUT_*" | wc -l 2>/dev/null)

    if [ "$choice" = "" ]; then
        mainMENU
    fi

    if [ "$counter" = 0 ] && [ "$tips_flag" = 1 ]; then
        SAVE="$SAVE_TIPS"
    else
        SAVE="$SAVE_DEFAULT"
    fi
    if [ "$tips_flag" = 0 ] && [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games ]; then
        rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games 2>/dev/null
    fi
    if [ "$tips_flag" = 0 ] && [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts ]; then
        rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts 2>/dev/null
    fi
    if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games ] && [ "$tips_flag" = 1 ];then
        EDIT_GAMES="$EDIT_GAMES_TIPS"    
    else
        EDIT_GAMES="$EDIT_GAMES_DEFAULT"    
    fi
    if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts ] && [ "$tips_flag" = 1 ];then
        EDIT_LAYOUTS="$EDIT_LAYOUTS_TIPS"
    else
        EDIT_LAYOUTS="$EDIT_LAYOUTS_DEFAULT"
    fi

    SLOGAN_OR_CORE="$CORE"
    CHECK_1_SLOT=1 # Enables the check for 1 SLOT only
    TYPE=$(cat "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/TYPE_"$ID".cfg 2>/dev/null)

    # Display a message if the 'joystick' and/or 'Buttons/Key remap' configurations
    # from MiSTer are not found
    if [ "$TYPE" = "v3" ] && [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map ]; then
            EXT="no_v3"
            alertMisterDIALOG
    fi
    if [ "$TYPE" = "jk" ] && [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map ]; then 
            EXT="no_jk"
            alertMisterDIALOG
    fi
    
    if [ "$TYPE" = "jk_v3" ]; then
        if [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map ] && \
                [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map ]; then
            EXT="no_jk_v3"
            alertMisterDIALOG
        elif [ -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map ] && \
                [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map ]; then
            EXT="only_v3"
            alertMisterDIALOG
        elif [ ! -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map ] && \
                [ -f "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map ]; then
            EXT="only_jk"
            alertMisterDIALOG
        fi
    fi

    if [ "$TYPE" = "v3" ]; then
        TYPE_DISPLAY="$GAMEPAD"
    elif [ "$TYPE" = "jk" ]; then
        TYPE_DISPLAY="$KEYBOARD"
    else
        TYPE_DISPLAY="$MIXED"
    fi

    if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg ]; then
        CURRENT=$(cat "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null)
    else
        CURRENT="X"
        echo "X" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
    fi

    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout \
        --title \"$CORE - $TYPE_CONTROL:$TYPE_DISPLAY - $CURRENT_INFO:[$CURRENT]\" \
        --menu \" $SELECT_OPTIONS_CORE\" 24 67 4 \
        X \"$EXIT_TO_MENU\" \
        - \"-----------------------------\" \
        S \"$LOAD\" \
        G \"$GAMES\" \
        V \"$LAYOUTS\" \
        - \"-----------------------------\" \
        N \"$SAVE\" \
        L \"$EDIT_GAMES\" \
        E \"$EDIT_LAYOUTS\" \
        - \"-----------------------------\" \
        M \"$MOVE\" \
        C \"$SWITCH\" \
        K \"$CLONE\" \
        R \"$OVERWRITE\" \
        D \"$DELETE\" \
        - \"-----------------------------\" \
        P \"$NOTES\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case $choice in
        "S") loadSLOT ;;
        "G") gamesList ;;
        "V") layoutsList ;;
        "N") saveSLOT ;;
        "L") gamesEdit ;;
        "E") layoutsEdit ;;
        "M") moveSLOT ;;
        "C") switchSLOT ;;
        "K") cloneSLOT ;;
        "R") overwriteSLOT ;;
        "D") deleteSLOT ;;
        "P") notesMENU ;;
        "X" | "") mainMENU ;;
        "-") coreMENU ;;
        *) mainMENU ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# loadSLOT - Select 'SLOT' as default
loadSLOT(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    MESSAGE_MENU="$MESSAGE_SELECT '$CORE'"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    generateHeaderOnDisk # Generate the header of the dialog menu on disk
    generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
    prepareMENU # Delete the temporary files and store the selection
     case "$choice" in
        "-")
            loadSLOT
            ;;
        "")
            coreMENU
            ;;
        *)
            title=$(printf "%s" "$CONFIRMATION")
            message_ln1=$(printf "%s '%s'." "$PROFILE_CONFIRM" "$choice")
            message_ln2=$(printf "%s %s" "$MESSAGE_SELECT_YESNO" "$CORRECT")
            yesnoDIALOG
            if [ "$status_message" = 0 ]; then 
                if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
                    cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$choice".map \
                        "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map 2>/dev/null
                fi
                if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
                cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$choice".map \
                    "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map 2>/dev/null
                fi
                echo "$choice" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
                title=$(printf "%s - %s - %s:%s" "$CORE" "$MODEL" "$TYPE_CONTROL" "$TYPE_DISPLAY")
                message_ln1=$(printf "%s" "$MESSAGE_SELECT_CONFIRM_A")
                message_ln2=$(printf "%s '%s'." "$MESSAGE_SELECT_CONFIRM_B" "$CORE")
                messageDIALOG
                coreMENU
            else
                coreMENU
            fi
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# gamesList - Show the game list for each 'SLOT'
gamesList(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder

    if [ -f "$tmp_message" ]; then
        rm -f "$tmp_message" 2>/dev/null
    fi

    touch "$tmp_message" 2>/dev/null
    counter=$(ls "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_* | wc -l 2>/dev/null)

    for ((i=1 ; i <= counter; i++)); do
        while IFS= read -r line; do
            eval "OUTPUT=\"\$line\""
            echo "$OUTPUT - $i"  >> "$tmp_message" 2>/dev/null
        done < "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$i".cfg
    done

    touch "$tmp_order" 2>/dev/null
    sort "$tmp_message" >> "$tmp_order" 2>/dev/null
    echo "" > "$tmp_message" 2>/dev/null
    cat "$tmp_order" >> "$tmp_message" 2>/dev/null
    rm -f "$tmp_order" 2>/dev/null
    lines_text=$(wc -l <"$tmp_message" 2>/dev/null)
    lines=$((lines_text + 5))

    if [ "$lines" -gt 28 ]; then
        lines=28
    fi

    title="$(printf "%s - %s - %s" "$SLOGAN_OR_CORE" "$MODEL_CUT" "$ID")"
    dialog  --exit-label "$EXIT" --title "$title" --textbox "$tmp_message" "$lines" 70
    rm -f "$tmp_message" 2>/dev/null
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# layoutsList - Show the button configuration of each 'SLOT'
layoutsList(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    
    if [ -f "$tmp_message" ]; then
        rm -f "$tmp_message" 2>/dev/null
    fi

    touch "$tmp_message" 2>/dev/null
    echo "" >> "$tmp_message" 2>/dev/null
    echo "Lyts ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL        $COMMENTS">> "$tmp_message" 2>/dev/null
    echo "---- ------------------------------------------- ---------------------">> "$tmp_message" 2>/dev/null

    for ((i=1; i <= counter; i++)); do
        layouts_lines=$(< "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$i".cfg)
        indice=$(printf "%2d" $i)
        echo "$indice)  $layouts_lines" >> "$tmp_message" 2>/dev/null
    done

    lines=$((counter + 8))
    
    if [ "$lines" -gt 28 ]; then
        lines=28
    fi

    title="$(printf "%s - %s - %s" "$SLOGAN_OR_CORE" "$MODEL_CUT" "$ID")"
    dialog --exit-label "$EXIT" --title "$title" --textbox "$tmp_message" "$lines" 74
    rm -f "$tmp_message" 2>/dev/null
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# gamesEdit - Edit game list of each 'SLOT'
gamesEdit(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    MESSAGE_MENU="$GAME_EDIT"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    generateHeaderOnDisk # Generate the header of the dialog menu on disk
    generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
    prepareMENU # Delete the temporary files and store the selection

    case "$choice" in
        "-")
            gamesEdit
            ;;
        "")
            coreMENU
            ;;
        *)
            if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg ]; then
                cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".tmp 2>/dev/null
                dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE - $GAMES_LIST '$choice'" --editbox "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".tmp 20 60 \
                    2> "$tmp_dialog"
                if [ "$?" -eq 1 ]; then
                    rm -f "$tmp_dialog" 2>/dev/null
                    rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".tmp 2>/dev/null
                    coreMENU
                fi
                sed -i '/^[[:space:]]*$/d' "$tmp_dialog" 2>/dev/null
                cp "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".cfg 2>/dev/null
                rm -f "$tmp_dialog" 2>/dev/null
                rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".tmp 2>/dev/null
                    if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games ]; then
                        rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_games 2>/dev/null
                    fi
                coreMENU
            else
                title=$(printf "%s - %s %s" "$SLOGAN" "$MENU_PROFILE" "$MODEL")
                message_ln1=$(printf "%s" "$SLOTS_NOT_FOUND")
                messageDIALOG
                coreMENU
            fi
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# CREATE - Create new 'SLOT'
saveSLOT(){
    clear
    
    title="$(printf "%s - %s - %s" "$SLOGAN_OR_CORE" "$MODEL_CUT" "$ID")"
    message_ln1=$(printf "%s '%s'?" "$NEW_PROFILE" "$CORE")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG
    
    if [ "$status_message" = 1 ]; then
        coreMENU
    fi
    
    if [ "$TYPE" = "v3" ]; then
        TYPE_TEST="v3"
    else
        TYPE_TEST="jk"
    fi
    
    if test -n "$(ls "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_"$TYPE_TEST"-CONFIG_* 2>/dev/null)"; then
        counter=$(ls "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_"$TYPE_TEST"-CONFIG_* | wc -l 2>/dev/null)
        ((counter++))
        if test -n "$(ls "$INPUT_MISTER"/"$CORE"_input_"$ID"_"$TYPE_TEST".map 2>/dev/null)"; then
            createNewSLOT # Copy the MiSTer configurations to a new SLOT
        else
            messageNoConfigurationFound # Message if a MiSTer configuration is not found
        fi
    else
        counter=1
        if test -n "$(ls "$INPUT_MISTER"/"$CORE"_input_"$ID"_"$TYPE_TEST".map 2>/dev/null)"; then
            createNewSLOT # Copy the MiSTer configurations to a new SLOT
        else
            messageNoConfigurationFound # Message if a MiSTer configuration is not found
        fi
    fi
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# EDIT - Edit button visualization of each 'SLOT'
layoutsEdit(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    MESSAGE_MENU="$LAYOUT_EDIT"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    generateHeaderOnDisk # Generate the header of the dialog menu on disk
    generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
    prepareMENU # Delete the temporary files and store the selection

    case "$choice" in
        "-")
            layoutsEdit
            ;;
        "")
            coreMENU
            ;;
        *)
            if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg ]; then
                cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".tmp 2>/dev/null
                echo -e "← ↓ ↑ → \n← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL |----- $COMMENTS ------|\n\n$MESSAGE_EDIT_A\n$MESSAGE_EDIT_B" >> "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".tmp 2>/dev/null
                dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE - $BUTTON_MAP '$choice'" --editbox "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".tmp 20 72 2> "$tmp_dialog"
                if [ "$?" = 0 ]; then
                    cp "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg 2>/dev/null
                    rm -f "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".tmp 2>/dev/null
                    sed -i '2,$d' "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg 2>/dev/null
                    if [ -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts ]; then
                        rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/show_tips_edit_layouts 2>/dev/null
                    fi
                    coreMENU
                else
                    rm -f "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".tmp 2>/dev/null
                    coreMENU
                fi
            else
                title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
                message_ln1=$(printf "%s" "$SLOTS_NOT_FOUND")
                messageDIALOG
                coreMENU
            fi
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# deleteSLOT - Delete a 'SLOT'
deleteSLOT(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    MESSAGE_MENU="$DELETE_PROFILE"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    generateHeaderOnDisk # Generate the header of the dialog menu on disk
    generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
    prepareMENU # Delete the temporary files and store the selection

    case "$choice" in
        "-")
            loadSLOT
            ;;
        "")
            coreMENU
            ;;
        *)
            title=$(printf "%s" "$CONFIRMATION")
            message_ln1=$(printf "%s '%s'?" "$DELETE_WANT" "$choice")
            message_ln2=$(printf "$s" "$CORRECT")
            yesnoDIALOG

            if [ "$status_message" = 1 ]; then
                coreMENU
            fi

            rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg 2>/dev/null
            rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".cfg 2>/dev/null
            rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$choice".map 2>/dev/null

            if [ "$TYPE" = "jk" ]; then
                rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$choice".map 2>/dev/null
            fi
            first_profile="$choice"
            inc=1
            condition="i < counter"
            reorganizeProfilesOrder # Reorganize the order of the PROFILES
            
            if [ "$choice" = "$CURRENT" ]; then  # Update Current Profile Position
                echo "X" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
                CURRENT="X"
            elif [ "$choice" -lt "$CURRENT" ]; then
                UPDATE_CURRENT=$((CURRENT - 1 ))
                echo "$UPDATE_CURRENT" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
                CURRENT="$UPDATE_CURRENT"
            fi

            title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
            message_ln1=$(printf "%s '%s' %s" "$DELETE_MESSAGE_1" "$choice" "$DELETE_MESSAGE_2")
            messageDIALOG
            coreMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# moveSLOT - Move a 'SLOT'
moveSLOT(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    generateLayoutsMENU # Generate the menu with the LAYOUTS (Button Map)
    WINDOW_TITLE="$MOVE"
    MESSAGE_MENU="$FIRST_PROFILE_MOVE"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    selectFirst(){
        generateHeaderOnDisk # Generate the header of the dialog menu on disk
        generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
        prepareMENU # Delete the temporary files and store the selection
        first_profile="$choice"
        if [ "$choice" = "-" ]; then
            selectFirst
        fi
    }
    selectFirst
    MESSAGE_MENU="$SECOND_PROFILE_MOVE"
    selectSecond(){
        generateHeaderOnDisk # Generate the header of the dialog menu on disk
        generateLayoutExcludeInputMENU # Generate menu excluding selected LAYOUT
        prepareMENU # Delete the temporary files and store the selection
        destination_profile="$choice"
        if [ "$choice" = "-" ]; then
            selectSecond
        fi
        }
    selectSecond
    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s' %s '%s'?" "$WISHES_MOVE" "$first_profile" "$TO_POSITION" "$destination_profile")
    if [ "$counter" -gt 2 ]; then
        message_ln2=$(printf "%s %s" "$WISHES_MOVE_2" "$CORRECT")
    fi
    yesnoDIALOG

    if [ "$status_message" = 0 ]; then
        file_1="$first_profile"
        file_2="TEMP"
        moveProfile # Move the Profiles (Buttons Map)
        if [ "$first_profile" -gt "$destination_profile" ]; then
            inc=-1
            condition="i > destination_profile"
            reorganizeProfilesOrder # Reorganize the order of the PROFILES
        else
            inc=1
            condition="i < destination_profile"
            reorganizeProfilesOrder # Reorganize the order of the PROFILES
        fi
        file_1="TEMP"
        file_2="$destination_profile"
        moveProfile # Move the Profiles (Buttons Map)

        UPDATE_CURRENT="$CURRENT"  # Update Current Profile Position
        if [ "$destination_profile" = "$CURRENT" ]; then
            if [ "$first_profile" -gt "$destination_profile" ]; then
                UPDATE_CURRENT=$((CURRENT + 1))
            else
                UPDATE_CURRENT=$((CURRENT -1 ))
            fi
        elif [ "$destination_profile" -lt "$CURRENT" ] && [ "$first_profile" -gt "$CURRENT" ]; then
            UPDATE_CURRENT=$((CURRENT + 1))
        elif [ "$destination_profile" -gt "$CURRENT" ] && [ "$first_profile" -lt "$CURRENT" ]; then
            UPDATE_CURRENT=$((CURRENT -1 ))
        fi
        echo "$UPDATE_CURRENT" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
        CURRENT="$UPDATE_CURRENT"

        title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
        message_ln1=$(printf "%s." "$MOVE_MESSAGE")
        messageDIALOG
    fi
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# switchSLOT - Swap two 'SLOTS'
switchSLOT(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    generateLayoutsMENU # Generate the menu with the LAYOUTS (Button Map)
    WINDOW_TITLE="$SWITCH"
    MESSAGE_MENU="$FIRST_PROFILE_SWITCH"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    selectFirst(){
        generateHeaderOnDisk # Generate the header of the dialog menu on disk
        generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
        prepareMENU # Delete the temporary files and store the selection
        first_profile="$choice"
        if [ "$choice" = "-" ]; then
            selectFirst
        fi
    }
    selectFirst

    MESSAGE_MENU="$SECOND_PROFILE_SWITCH"
    selectSecond(){
        generateHeaderOnDisk # Generate the header of the dialog menu on disk
        generateLayoutExcludeInputMENU # Generate menu excluding selected LAYOUT
        prepareMENU # Delete the temporary files and store the selection
        second_profile="$choice"
        if [ "$choice" = "-" ]; then
            selectSecond
        fi
        }
    selectSecond

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s' %s '%s'?" "$WISHES_SWITCH" "$first_profile" "$AND" "$second_profile")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG

    destination_profile="$second_profile"

    if [ "$status_message" = 0 ]; then
        file_1="$first_profile"
        file_2="TEMP"
        moveProfile # Move the Profiles (Buttons Map)
        file_1="$second_profile"
        file_2="$first_profile"
        moveProfile     # Move the Profiles (Buttons Map)    
        file_1="TEMP"
        file_2="$second_profile"
        moveProfile # Move the Profiles (Buttons Map)

        UPDATE_CURRENT="$CURRENT" # Update Current Profile Position
        if [ "$first_profile" = "$CURRENT" ]; then
            UPDATE_CURRENT="$second_profile"
        elif [ "$second_profile" = "$CURRENT" ]; then
            UPDATE_CURRENT="$first_profile"
        fi
        echo "$UPDATE_CURRENT" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
        CURRENT="$UPDATE_CURRENT"

        title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
        message_ln1=$(printf "%s" "$SWITCH_MESSAGE")
        messageDIALOG
    fi
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# overwriteSLOT - Overwrite 'SLOT'
overwriteSLOT(){
    clear

    layoutTEST # Check if there are LAYOUT files in the Core folder
    WINDOW_TITLE="$OVERWRITE"
    CHECK_1_SLOT=0 # Disables the check for 1 SLOT only
    generateLayoutsMENU # Generate the menu with the Profiles (Button Map)
    overwriteProfile(){
        if [ "$counter" = 1 ]; then
            title=$(printf "%s - %s" "$CORE" "$OVERWRITE_MENU")
            message_ln1=$(printf "%s %s." "$OVERWRITE_ONLY_ONE_1" "$CORE")
            message_ln2=$(printf "%s" "$OVERWRITE_ONLY_ONE_2")
            yesnoDIALOG
            if [ "$status_message" = 1 ]; then
                coreMENU
            fi
            overwrite_profile="$counter"
        else
            WINDOW_TITLE="$OVERWRITE"
            MESSAGE_MENU="$OVERWRITE_PROFILE_MESSAGE"
            param_1=76
            param_2=4
            lines_menu=$((counter + 8))
            extra_options=""
            selectSLOT(){
                generateHeaderOnDisk # Generate the header of the dialog menu on disk
                generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)
                prepareMENU # Delete the temporary files and store the selection
                overwrite_profile="$choice"
                if [ "$choice" = "-" ]; then
                    selectSLOT
                fi
            }
            selectSLOT
        fi
       
        if [ "$overwrite_profile" -lt 1 ] || [ "$overwrite_profile" -gt "$counter" ] || \
               [ -z "$overwrite_profile" ]; then
            overwriteProfile
        fi    
    }

    overwriteProfile
    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s '%s'" "$WISHES_OVERWRITE" "$overwrite_profile")
    message_ln2=$(printf "%s" "$CORRECT")
    yesnoDIALOG

    if [ "$status_message" = 0 ]; then
        if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
            cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map \
                "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$overwrite_profile".map 2>/dev/null
        fi
        if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
            cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map \
                "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$overwrite_profile".map 2>/dev/null
        fi
        echo "$overwrite_profile" > "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/SELECTED_"$ID".cfg 2>/dev/null
         title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
        message_ln1=$(printf "%s '%s'." "$OVERWRITE_MESSAGE" "$overwrite_profile")
        messageDIALOG
        coreMENU
    else
        coreMENU
    fi
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# cloneSLOT - Clone 'SLOT'
cloneSLOT(){
    clear
 
    layoutTEST # Check if there are LAYOUT files in the Core folder
    DESTINATION=$((counter + 1))
    MESSAGE_MENU="$CLONE_PROFILE_MESSAGE"
    param_1=76
    param_2=4
    lines_menu=$((counter + 8))
    extra_options=""
    generateHeaderOnDisk # Generate the header of the dialog menu on disk
    generateLayoutsOnDisk # Generate the LAYOUT menu on disk (Button Map)

    prepareMENU # Delete the temporary files and store the selection

    case "$choice" in
        "-")
            cloneSLOT
            ;;
        "")
            coreMENU
            ;;
        *)
            title=$(printf "%s" "$CONFIRMATION")
            message_ln1=$(printf "%s '%s' %s '%s'?" "$CLONE_CONFIRM_1" "$choice" "$CLONE_CONFIRM_2" "$DESTINATION")
            message_ln2=$(printf "%s" "$CORRECT")
            yesnoDIALOG
            if [ "$status_message" = 1 ]; then
                coreMENU
            fi

        if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
            cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$choice".map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$DESTINATION".map 2>/dev/null
        fi
        if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
            cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$choice".map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$DESTINATION".map 2>/dev/null
        fi
        cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$choice".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$DESTINATION".cfg 2>/dev/null
        cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$choice".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$DESTINATION".cfg 2>/dev/null
            ;;
    esac

    title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
    message_ln1=$(printf "%s '%s' %s '%s'" "$CLONE_CONFIRMED_1" "$choice" "$CLONE_CONFIRMED_2" "$DESTINATION")
    messageDIALOG
    coreMENU
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# notesMENU - A page to store 'Core' notes
notesMENU(){
    clear

    if [ ! -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".txt ]; then
        touch "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".txt 2>/dev/null
    fi

    DIALOG="dialog --ok-label "$OK" --clear --no-cancel --no-tags --stdout\
        --title \"$CORE - $TYPE_CONTROL:$TYPE_DISPLAY - $CURRENT_INFO:[$CURRENT]\" \
        --menu \" $NOTES_TITLE - $SELECT_OPTIONS\" 10 70 4 \
        V \"$READ_NOTES\" \
        E \"$EDIT_NOTES\" \
        X \"$EXIT_MENU\""

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

    case "$choice" in
        "X")
            coreMENU
            ;;
        "V")
            dialog --exit-label "$EXIT" --title "$CORE - $TYPE_DISPLAY - $NOTES_TITLE" \
                   --textbox "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".txt 20 60
            notesMENU
            ;;
        "E")
            cp "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".txt "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".tmp 2>/dev/null
            dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$CORE - $TYPE_DISPLAY - $NOTES_TITLE" \
                   --editbox "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".tmp 20 60 2> "$tmp_dialog"

            if [ "$?" -eq 1 ]; then
                rm -f "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".tmp 2>/dev/null
                notesMENU
            else
                cp "$tmp_dialog" "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".txt 2>/dev/null
                rm -f "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/NOTES_"$ID".tmp "$tmp_dialog" 2>/dev/null
                notesMENU
            fi
            ;;
        *)
            notesMENU
            ;;
    esac
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# SECONDARY FUNCTIONS - Shared secondary functions in this script                           #

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Script executed on first launch to select language and visual help option
firstRUN(){

    setFlags(){
        sed -i "s/^tips=[^ ]*/tips=$tips_status/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
        sed -i "s/^help_tips=[^ ]*/help_tips=$tips_status/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
        tips_flag="$tips_status" # Flag that enables help tips next to the menus

    }

    if [ "$first_run" = 1 ]; then
        DIALOG="dialog --clear --no-cancel --no-tags --stdout \
            --title \"$SLOGAN\" \
            --menu \" $SELECT_LANGUAGE\" 9 35 4 \
            E \"$EN\" \
            P \"$PT"\"
    
        runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

        case $choice in
            "E") 
                sed -i "s/^language=[^ ]*/language=en/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
                updateDictionary # Update the language and the messages displayed in the Menus
                ;;
            "P") 
                sed -i "s/^language=[^ ]*/language=pt/" "$INPUTS"/configs/gcm.cfg 2>/dev/null
                updateDictionary # Update the language and the messages displayed in the Menus
                ;;
        esac

        clear
        DIALOG="dialog --clear --no-cancel --no-tags --stdout\
            --title \"$SLOGAN - $MODEL_CUT - $ID\" \
            --menu \"$TIPS_MENU:\" 9 35 4 \
            A \"$ACTIVE_TIPS\" \
            D \"$DEACTIVE_TIPS\""

        runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated

        case "$choice" in
            "A")
                tips_status=1
                setFlags
                ;;
            "D")
                tips_status=0
                setFlags
                ;;
        esac
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Check the ID and MODEL of the registered controller
controllerID(){
    if [ ! -f "$INPUTS/configs/selected_gamepad_ID.cfg" ]; then
        touch "$INPUTS/configs/selected_gamepad_ID.cfg" 2>/dev/null
    fi

    if [ ! -f "$INPUTS/configs/selected_gamepad_MODEL.cfg" ]; then
        echo "$NO_GAMEPAD" > "$INPUTS/configs/selected_gamepad_MODEL.cfg" 2>/dev/null
    fi

    ID=$(cat "$INPUTS/configs/selected_gamepad_ID.cfg" 2>/dev/null)
    MODEL=$(cat "$INPUTS/configs/selected_gamepad_MODEL.cfg" 2>/dev/null)
    MODEL_CUT=$(echo "$MODEL" | cut -c1-28 2>/dev/null)
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Tips flag verify
tipsFlags(){
    SHOW_RETURN_TIPS=0 # Disable the comment next to the MENU button
    counter=$(find "$INPUTS"/gamepad-"$ID" -mindepth 1 -type d -name "*-$ID" | sed "s|-$ID||g" | sed "s|$INPUTS/gamepad-$ID/||g" | wc -l 2>/dev/null)

    if [ "$counter" = 0 ] && [ "$tips_flag" = 1 ]; then
        ADD="$ADD_TIPS"
        VIEW="$VIEW_TIPS" 
        MESSAGE_SELECT_CORE="$MESSAGE_SELECT_CORE_TIPS"
    else
        ADD="$ADD_DEFAULT"
        VIEW="$VIEW_DEFAULT" 
        MESSAGE_SELECT_CORE="$MESSAGE_SELECT_CORE_DEFAULT"
    fi

    if [ "$lines_check" = 0 ] && [ "$tips_flag" = 1 ]; then
        GAMEPADS="$GAMEPADS_TIPS"
    else
        GAMEPADS="$GAMEPADS_DEFAULT"
    fi
    if [ "$help_flag" = 1 ] && [ "$tips_flag" = 1 ]; then
        HELP="$HELP_TIPS"
    else
        HELP="$HELP_DEFAULT"
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the header of the dialog menu
generateHeader(){
    title="$(printf "%s - %s - %s" "$SLOGAN_OR_CORE" "$MODEL_CUT" "$ID")"
    message="$(printf " %s" "$MESSAGE_MENU")"
    DIALOG="dialog --ok-label "$OK" --cancel-label "$CANCEL" --clear $extra_options --no-tags --stdout \\
        --title \"$title\" \\
        --menu \"$message\" $lines_menu $param_1 $param_2 \\"
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the header of the dialog menu on disk
generateHeaderOnDisk(){
    rm -f "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null

    {
        echo "#!/bin/bash" 2>/dev/null
        echo "tmp_file_menu=$tmp_file_menu" 2>/dev/null
        echo "title=\"$(printf "%s - %s - %s" "$SLOGAN_OR_CORE" "$MODEL_CUT" "$ID")"\" 2>/dev/null
        echo "message=\"$(printf " %s" "$MESSAGE_MENU")"\" 2>/dev/null
        echo "dialog --ok-label "$OK" --cancel-label "$CANCEL" --clear $extra_options --no-tags \\" 2>/dev/null
        echo "--title \"\$title\" \\" 2>/dev/null
        echo "--menu \"\$message\" $lines_menu $param_1 $param_2 \\" 2>/dev/null
    } > "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Insert the cores into the MENU from linesGenerate
generateCoresMENU(){
	EXCLUDE_SYMBOL="$1"  
    for ((i = 1; i < counter; i++)); do
        output=${lines_reader[((i-1))]}
        if [ "$EXCLUDE_SYMBOL" = "EXCLUDE_SYMBOL" ] && [ "$i" = "$((counter-1))" ]; then
            DIALOG+="$i \"$output\""
        else
            DIALOG+="$i \"$output\" \\"
        fi
    done
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
 
# Generate the LAYOUTS menu on disk (Button Map)
generateLayoutsOnDisk(){
    {
        echo "- \"     ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL ------ $COMMENTS -------\" \\" 2>/dev/null
        for ((i=1; i <= counter; i++)); do
            output=$(cat "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$i".cfg 2>/dev/null)
            indice=$(printf "%2d" $i)
            echo "$i \"$indice)  $output\" \\" 2>/dev/null
        done
    } >> "$INPUTS"/tmp/MENU_TEMP.sh

    echo "2>\"\$tmp_file_menu\"" >> "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null
    source "$INPUTS"/tmp/MENU_TEMP.sh
    menu_status="$?"
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
 
# Generate menu excluding selected LAYOUT
generateLayoutExcludeInputMENU(){
    {
        echo "- \"     ← ↓ ↑ → A B C X Y Z L R L2 R2 L3 R3 STR SEL ------ $COMMENTS -------\" \\" 2>/dev/null
        for ((i=1; i <= counter; i++)); do
            if [ "$i" != "$first_profile" ]; then
                output=$(cat "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$i".cfg 2>/dev/null)
                indice=$(printf "%2d" $i)
                echo "$i \"$indice)  $output\" \\" 2>/dev/null
            else
                indice=$(printf "%2d" $i)
                echo "- \"$indice)  $SELECTED\" \\" 2>/dev/null
            fi
        done
    } >> "$INPUTS"/tmp/MENU_TEMP.sh

    echo "2>\"\$tmp_file_menu\"" >> "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null
    source "$INPUTS"/tmp/MENU_TEMP.sh
    menu_status="$?"

}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the menu from the backup files found on disk
generateBackupMENU(){
    lines_check=$(find "$INPUTS" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' | wc -l 2>/dev/null)

    if [ "$lines_check" = 0 ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$NO_BACKUP_FILES")
        messageDIALOG
        backupMENU
    fi

    find "$INPUTS" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' > "$tmp_file_menu"
    
    backups=()
    while IFS= read -r line; do
        backups+=("$line")
    done < "$tmp_file_menu"

    rm "$tmp_file_menu"

    lines_menu=$((lines_check + 9))
    param_1=67
    param_2=4

    DIALOG="dialog --ok-label "$OK" --clear $extra_options --no-tags --stdout \\
            --title \"$SLOGAN - $MODEL_CUT - $ID\" \\
            --menu \"$BACKUP_MESSAGE\" $lines_menu $param_1 $param_2 \\
X \"$EXIT_MENU\" \\
- \"---------------------------------------\" \\"

    for ((i = 0; i < ${#backups[@]}; i++)); do
        output=$(basename "${backups[$i]}")
        if [ "$i" -lt $((${#backups[@]} - 1)) ]; then
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\" \\"
        else
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\""
        fi
    done

    runDIALOG NO_CORE_CHOICE # Execute the dialog menu that was generated
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Check if there are any registered gamepads
checkRegisteredGamepads(){
    lines_check=$(wc -l < "$INPUTS/configs/registered_gamepads.cfg" 2>/dev/null)

    if [ "$lines_check" = 0 ]; then
        gamepadsMENU
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Count the number of registered gamepads
countGamepads(){
    if [ ! -f "$INPUTS/configs/registered_gamepads.cfg" ]; then
        lines_check=0
    else
        lines_check=$(wc -l < "$INPUTS/configs/registered_gamepads.cfg" 2>/dev/null)
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Check if any gamepad is registered
testGamepads(){
    countGamepads # Count the number of registered gamepads

    if [ "$lines_check" = 0 ]; then
        messageNoGamepadConfigured # Show message that no gamepad has been registered yet
        registerGamepad
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the lines for the menu
linesArray(){
	sed -i '1{/^[[:space:]]*$/d}' "$DIR_TARGET"
    counter=1
    lines_array=()
    while IFS= read -r line; do
        lines_array[$((counter - 1))]="$line"
        ((counter++))
    done < "$DIR_TARGET"
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Start generating the menu with the registered gamepads
makeGamepadMENU(){
    checkRegisteredGamepads # Check if there are any registered gamepads

    DIR_TARGET="$INPUTS"/configs/registered_gamepads.cfg # DIR_TARGET to the linesArray
    linesArray # Generate the lines for the menu

    lines_menu=$((counter + 6 ))
    MESSAGE_MENU="$DISPLAY_MESSAGE"
    param_1=67
    param_2=4
    extra_options="--no-cancel"
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate gamepad list menu and run the dialog
generateListRegisteredGamepads(){
    OPTIONS="$1"

    for ((i = 1; i < counter; i++)); do
        output=${lines_array[((i-1))]}
        output_menu=$(echo "$output" | cut -c1-60 2>/dev/null)
        DIALOG+="$i \"$output_menu\" \\
"
    done

    choice=$(eval "$DIALOG")

    if [ "$?" -eq 1 ]; then
        gamepadsMENU
    fi

    if [ "$OPTIONS" = "ID_MODEL" ]; then
        ID_CHOICE=$(sed -n "${choice}p" "$INPUTS"/configs/registered_gamepads.cfg | cut -c1-9 2>/dev/null)
        MODEL_CHOICE=$(sed -n "${choice}p" "$INPUTS"/configs/registered_gamepads.cfg | cut -c13- 2>/dev/null)    
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Register the gamepad and update SELECTED_GAMEPAD ID and MODEL
recordGamepadID(){
    echo "$ID_CHOICE" > "$INPUTS"/configs/selected_gamepad_ID.cfg 2>/dev/null
    echo "$MODEL_CHOICE" > "$INPUTS"/configs/selected_gamepad_MODEL.cfg 2>/dev/null
    grep "$ID_CHOICE" "$INPUTS"/configs/registered_gamepads.cfg > "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    grep -v "$ID_CHOICE" "$INPUTS"/configs/registered_gamepads.cfg >> "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp 2>/dev/null
    mv "$INPUTS"/configs/REGISTERED_GAMEPADS.tmp "$INPUTS"/configs/registered_gamepads.cfg 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Update the NO_GAMEPAD message in the selected language
updateNoGamepadMessage(){
    if [ ! -f "$INPUTS/configs/registered_gamepads.cfg" ]; then
        lines=0
    else
        lines=$(wc -l < "$INPUTS/configs/registered_gamepads.cfg" 2>/dev/null)
    fi

    if [ "$lines" = 0 ]; then
        echo "$NO_GAMEPAD" > "$INPUTS/configs/selected_gamepad_MODEL.cfg" 2>/dev/null
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Show message that no gamepad has been registered yet
messageNoGamepadConfigured(){
    if [ "$LANGUAGE" = "en" ]; then
        lines_menu=15
    else
        lines_menu=16
    fi  
    dialog --title "$SLOGAN - $ATTENTION" --textbox "$INPUTS"/configs/NO_GAMEPAD_"$LANGUAGE".txt "$lines_menu" 75
    gamepadsMENU
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Prevention: removes duplicate records and sorts
cleanRegisteredFile(){ 
    awk '!seen[$1]++' "$INPUTS"/configs/registered_gamepads.cfg | sort > "$INPUTS"/configs/REGISTERED_GAMEPADS.temp 2>/dev/null
    mv "$INPUTS"/configs/REGISTERED_GAMEPADS.temp "$INPUTS"/configs/registered_gamepads.cfg 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the lines - List of Cores
linesGenerate(){
    find "$INPUTS"/gamepad-"$ID"/*-$ID/ -type d -exec basename {} \; | sed "s|-$ID$||" > "$menu_file" 2>/dev/null

    counter=1
    lines_reader=()

    while IFS= read -r line; do
        lines_reader+=("$line")
        ((counter++))
    done < "$menu_file"

    lines_menu=$((counter + "$increase"))
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generate the menu with the Profiles (Button Map)
generateLayoutsMENU(){
    find "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" -type f -name "LAYOUT_${ID}_*" | sort > "$menu_file" 2>/dev/null

    counter=0

    while IFS= read -r line; do
        ((counter++))
    done < "$menu_file"

    if [ "$counter" -eq 1 ] && [ "$CHECK_1_SLOT" != 0 ]; then
        title=$(printf "%s - %s" "$CORE" "$WINDOW_TITLE")
        message_ln1=$(printf "\n%s" "$ONLY_ONE")
        messageDIALOG
        coreMENU
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Check if there are LAYOUT files in the Core folder
layoutTEST(){
    counter=$(find "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID" -type f -name "LAYOUT_*" | wc -l 2>/dev/null)

    if [ "$counter" = 0 ]; then
        title=$(printf "%s - %s:%s - %s:[%s]" "$CORE" "$TYPE_CONTROL" "$TYPE_DISPLAY" "$CURRENT_INFO" "$CURRENT")
        message_ln1=$(printf "\n%s" "$SLOTS_NOT_FOUND")
        messageDIALOG
        coreMENU
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Move the Profiles (Buttons Map)
moveProfile(){
    if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
        mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$file_1".map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_"$file_2".map 2>/dev/null
    fi

    if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
        mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$file_1".map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_"$file_2".map 2>/dev/null
    fi

    mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$file_1".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_"$file_2".cfg 2>/dev/null
    mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$file_1".cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_"$file_2".cfg 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Reorganize the order of the PROFILES
reorganizeProfilesOrder(){
    for ((i = first_profile; condition; i+=inc)); do
        if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
            mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_$((i + inc)).map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_$i.map 2>/dev/null
        fi

        if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
            mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_$((i + inc)).map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_$i.map 2>/dev/null
        fi

        mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_$((i + inc)).cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_$i.cfg 2>/dev/null
        mv "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_$((i + inc)).cfg "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_$i.cfg 2>/dev/null
    done
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Copy the MiSTer configurations to a new SLOT
createNewSLOT(){
    if [ "$TYPE" = "v3" ] || [ "$TYPE" = "jk_v3" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_v3-CONFIG_$counter.map 2>/dev/null
    fi

    if [ "$TYPE" = "jk" ] || [ "$TYPE" = "jk_v3" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/"$CORE"_input_"$ID"_jk-CONFIG_$counter.map 2>/dev/null
    fi

    touch "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/GAMES_"$ID"_$counter.cfg 2>/dev/null
    touch "$INPUTS"/gamepad-"$ID"/"$CORE"-"$ID"/LAYOUT_"$ID"_$counter.cfg 2>/dev/null

    title=$(printf "%s - %s - %s:%s" "$CORE" "$MODEL" "$TYPE_CONTROL" "$TYPE_DISPLAY")
    message_ln1=$(printf "%s Core '%s'" "$CREATE_PROFILE" "$CORE")
    message_ln2=$(printf "%s '%s'." "$NUMBER" "$counter")
    messageDIALOG
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Message if a MiSTer configuration is not found
messageNoConfigurationFound(){
    title=$(printf "%s - %s - %s:%s" "$CORE" "$MODEL" "$TYPE_CONTROL" "$TYPE_DISPLAY")
    message_ln1=$(printf "%s Core '%s'." "$MISTER_PLEASE" "$CORE")
    messageDIALOG
    coreMENU
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Delete the temporary files and store the selection
prepareMENU(){
    if [ "$menu_status" -eq 1 ]; then
        rm -f "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null
        rm -f "$tmp_file_menu" 2>/dev/null
        coreMENU
    fi

    rm -f "$INPUTS"/tmp/MENU_TEMP.sh 2>/dev/null
    choice=$(<"$tmp_file_menu")
    rm -f "$tmp_file_menu" 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Adjust the menu formatting proportionally to the text
sizeAdjust(){
    size_title=$(echo ${#title})
    size_message_ln1=$(echo ${#message_ln1})
    size_message_ln2=$(echo ${#message_ln2})

    if [ "$size_message_ln1" -gt "$size_message_ln2" ]; then
        size_message="$size_message_ln1"
    else
        size_message="$size_message_ln2"
    fi

    if [ "$size_title" -lt "$size_message" ]; then
        size_dialog="$size_message"
    else
       size_dialog="$size_title"
    fi

    size_dialog=$((size_dialog + 5))
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Execute the dialog menu that was generated
runDIALOG(){
    OPTIONS="$1"
    choice=$(eval "$DIALOG")

    status_message="$?"

    # Check the name of the Core based on the selection
    if [ "$OPTIONS" != "NO_CORE_CHOICE" ]; then 
        if [ "$choice" != "-" ] && [ "$choice" != "X" ]; then
            CORE=$(sed -n "${choice}p" "$menu_file" 2>/dev/null)
        fi
        rm -f "$menu_file" 2>/dev/null
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Clear the fields of the dialog
messageResetDIALOG(){
    status_message="$?"
    title=""
    message_ln1=""
    message_ln2=""
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Format the dialog message to 1 or 2 lines
formatMessageDIALOG(){
    if [ "$size_message_ln2" = 0 ]; then
        OUTPUT="\n$message_ln1"
        size_lines="7"   
    else
        OUTPUT="\n$message_ln1\n\n$message_ln2"
        size_lines="9"        
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Print a message in the dialog
messageDIALOG(){
    sizeAdjust # Adjust the menu formatting proportionally to the text
    formatMessageDIALOG # Format the dialog message to 1 or 2 lines

    dialog --ok-label "$OK" --title "$title" \
        --msgbox "$OUTPUT" "$size_lines" "$size_dialog"

    messageResetDIALOG
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Open an input box in the dialog
inputDIALOG(){
    sizeAdjust # Adjust the menu formatting proportionally to the text
    formatMessageDIALOG # Format the dialog message to 1 or 2 lines

    DIALOG="dialog --ok-label "$OK" --cancel-label "$CANCEL" --title --stdout \"$title\" --inputbox \"$OUTPUT\" $size_lines $size_dialog"
    TMP_INPUT=$(eval "$DIALOG")

    messageResetDIALOG
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Open a 'Yes or No' box in the dialog
yesnoDIALOG(){
    sizeAdjust # Adjust the menu formatting proportionally to the text
    formatMessageDIALOG # Format the dialog message to 1 or 2 lines

    dialog --yes-label "$YES" --no-label "$NO" --title "$title" \
        --yesno "$OUTPUT" "$size_lines" "$size_dialog"
    messageResetDIALOG
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Display a message if the 'joystick' and/or 'Buttons/Key remap' configurations
# from MiSTer are not found
alertMisterDIALOG(){
    declare -n var="ALERT_MISTER_PROFILE_$EXT"
    ALERT_MISTER_MESSAGE=$(printf "%s" "$var" | base64 --decode)
    lines_dialog=$(( ((${#ALERT_MISTER_MESSAGE} + 69) / 70) + 6))

    dialog --ok-label "$OK" --title "$ATTENTION" --msgbox "\n$ALERT_MISTER_MESSAGE" $lines_dialog 80

    mainMENU
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Generates a list of found cores, removes duplicates, and sorts
generateCoresList(){
    OPTIONS="$1"

    if [ "$OPTIONS" = "HEADERS" ]; then
        echo "$SHOW_HEADER" > "$tmp_message" 2>/dev/null
        echo "" >> "$tmp_message" 2>/dev/null
    fi

    files=$(find "$CORES_COMPUTER" "$CORES_CONSOLE" "$CORES_OTHER" -type f -name "*.rbf" -exec basename {} .rbf \;)
    echo "$files" | while read file; do
        echo "${file%_*}" >> "$tmp_message" 2>/dev/null
    done
    files=$(find "$CORES_COMPUTER" "$CORES_CONSOLE" "$CORES_OTHER" -type f -name "*.mgl")
    echo "$files" | while read -r filepath; do
        file=$(basename "$filepath" .mgl)
        setname=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath" 2>/dev/null)
        echo "$setname" >> "$tmp_message" 2>/dev/null
    done

    awk '!seen[$0]++' "$tmp_message" > "$tmp_message.tmp" && mv "$tmp_message.tmp" "$tmp_message" 2>/dev/null

    if [ "$OPTIONS" = "HEADERS" ]; then
        echo "" >> "$tmp_message" 2>/dev/null
        echo "$UNSTABLE_HEADER" >> "$tmp_message" 2>/dev/null
        echo "" >> "$tmp_message" 2>/dev/null
    fi

    files=$(find "$CORES_UNSTABLE" -type f -name "*.rbf" -exec basename {} .rbf \;)
        echo "$files" | while read -r file; do
        echo "${file%_*_*_*}" >> "$tmp_message" 2>/dev/null
    done
    files=$(find "$CORES_UNSTABLE" -type f -name "*.mgl")
    echo "$files" | while read -r filepath; do
        file=$(basename "$filepath" .mgl)
        setname=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath" 2>/dev/null)
        echo "$setname" >> "$tmp_message" 2>/dev/null
    done

    awk '!seen[$0]++ && $0 != "menu"' "$tmp_message" | sort > "$tmp_message.tmp" && mv "$tmp_message.tmp" "$tmp_message" 2>/dev/null
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Checks if the Core exists or has already been added to the list
checkCORE(){
    check_cores=("$CORES_COMPUTER" "$CORES_CONSOLE" "$CORES_OTHER" "$CORES_UNSTABLE")
    find_cores=0

    for dir in "${check_cores[@]}"; do
        check=$(find "$dir" -type f -iname "$CORE*" \
            | grep -E "^$dir/$CORE(_[0-9]+)?\.[a-zA-Z0-9]+$" 2>/dev/null)
        check_mgl=$(find "$dir" -type f -name "*.mgl" 2>/dev/null \
            | while read -r filepath; do
                  setname=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath")
                  if [ "$setname" = "$CORE" ]; then
                      echo "$filepath"
                  fi
              done)
        if [ -n "$check" ] || [ -n "$check_mgl" ]; then
            ((find_cores++))
        fi
    done

    if [ "$find_cores" = 0 ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s '%s'." "$NOT_FIND_CORE" "$CORE")
        message_ln2=$(printf "%s" "$RETURN_TO_INPUT")
        messageDIALOG
        addCORE
    fi

    if [ -d "$INPUTS"/gamepad-"$ID"/"$CORE-$ID" ]; then
        title=$(printf "%s" "$ATTENTION")
        message_ln1=$(printf "%s" "$CORE_EXISTS")
        messageDIALOG
        addCORE
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# Check if the gamepad-$ID directory exists
checkGamepadDIR(){
    if [ ! -d "$INPUTS"/gamepad-"$ID" ] && [ "$ID" != "" ]; then
        mkdir "$INPUTS"/gamepad-"$ID" 2>/dev/null
    fi
}

# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

# End the program(script)
exitProgram(){
    clear

    title=$(printf "%s" "$CONFIRMATION")
    message_ln1=$(printf "%s" "$EXIT_CONFIRMATION")
    yesnoDIALOG
    
    if [ "$status_message" = 1 ]; then
        mainMENU
    fi

    clear

    echo "finished... script gamepad_config_manager.sh v1.0 25.12.12" 2>/dev/null
    exit 0
}

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
#                        SCRIPT INIT - Start execution from this point                      #

controllerID # Check the ID and MODEL of the registered controller

generateFiles # Check and generate the configuration files for GCM

firstRUN # Script executed on first launch to select language and visual help option

if [ ! -f "$INPUTS/configs/registered_gamepads.cfg" ] || \
    ! grep -q "_" "$INPUTS/configs/registered_gamepads.cfg"; then
    messageNoGamepadConfigured # Show message that no gamepad has been registered yet
    selectGamepad
    mainMENU
fi

lines=$(wc -l < "$INPUTS/configs/registered_gamepads.cfg" 2>/dev/null)

if [ "$lines" -lt 2 ]; then
    mainMENU
elif [ "$lines" -eq 0 ]; then
    gamepadsMENU
else
    display_init=1 # Enable an indication (arrow) in the menu to register a gamepad
    selectGamepad
fi

exit 0
