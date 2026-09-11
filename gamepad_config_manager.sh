#!/bin/bash
#
# Script:      gamepad_config_manager.sh
#
# Name:        'GCM' for MiSTer FPGA
# Description: Manage MiSTer gamepads with CORE-specific configurations,
#              organizing multiple SLOTS per CORE.
# Author:      Marcelo Marino - email.infomarc@gmail.com
#
# Copyright (c) 2026 Marcelo Marino
# License: GNU General Public License v3 (GPL v3)
# URL: https://www.gnu.org/licenses/gpl-3.0.html
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#
# Started: 2025-10-01
# Version: 1.0 (2026-09-15)
#
# SCRIPT INDEX:                  starts at line:
#   PATHS_AND_CONFIGURATIONS_FILES   72
#     MAIN                           149
#   SCRIPT_INIT                      366
#   SCRIPT_INIT_FUNCTIONS            448
#     loading                        2136
#     generation                     2185
#     checking                       2317
#     font and language              2367
#     first run                      2429
#   MENU_FUNCTIONS                   2763
#     menuHome                       2766
#     menuGamepads                   3505
#     menuSettings                   4463
#     menuCoreMain                   5256
#   SECONDARY_FUNCTIONS              6349
#     generate                       6352
#     run and store                  6652
#     gamepad                        6687
#     verify                         6835
#     messsage and dialog            6939
#     backup                         7166
#     CORES                          7273
#     SLOTS                          7559
#     language                       7807
#     font                           8148
#     color theme                    8178
#     exit                           8251
#   LAUNCH_MAIN_APPLICATION          8289
#     END OF SCRIPT                  8295
#
# ========================================================= #

# shellcheck disable=SC2086,SC2115,SC1090,SC1091,SC2001,SC2153,SC2034,SC2059,SC2129,SC2154

# Check if running on MiSTer
if [ ! -f "/media/fat/MiSTer" ]; then
    echo "Exiting. Use GCM only in MiSTer!"
    exit 1
fi

# ============================================================================= #
# === PATHS_AND_CONFIGURATIONS_FILES - Initialize paths and configuration files #
# ============================================================================= #

initPathsAndConfigs() {
    local required_dir

    # MiSTer system folders for configuration, CORES, and inputs
    MISTER_ROOT="/media/fat"                # Root directory for MiSTer system (mounted storage)
    INPUT_MISTER="/media/fat/config/inputs" # General directory for MiSTer input files
    GCM_DIR="/media/fat/Scripts/gcm"        # Directory for GCM input configuration files
    MISTER_CORES_FOLDERS="$MISTER_ROOT"     # Root directory for configured CORE folder

    # Directories and configuration files used by the GCM (Game Controller Manager)
    GCM_CFG="${GCM_DIR}/configs"                 # Directory for GCM configuration files
    GCM_TMP="${GCM_DIR}/tmp"                     # Directory for temporary files used by GCM
    GCM_DAT="${GCM_DIR}/data"                    # Directory for language text files
    GCM_GPD="${GCM_DIR}/gamepads"                # Directory for registered gamepads
    GCM_FNT="${GCM_DIR}/fonts"                   # Directory for fonts
    GCM_INI="${GCM_CFG}/gcm.ini"                 # Main configuration file for GCM settings
    GCM_LGI="${GCM_CFG}/list_gamepad_IDS.txt"    # List of gamepads IDs for GCM
    GCM_RGP="${GCM_CFG}/registered_gamepads.cfg" # Configuration file for registered gamepads
    GCM_SGP="${GCM_CFG}/selected_gamepad.cfg"    # Configuration file for the selected gamepad

    # Temporary files used during the script's execution
    TMP_FILE="${GCM_TMP}/file.temp"      # General temporary file for storing intermediate data
    TMP_MENU="${GCM_TMP}/file_menu.temp" # Temporary file used for dynamically generated menu content
    TMP_ORDER="${GCM_TMP}/order.temp"    # Temporary file used for alphabetically sorting (menuShowGames)
    TMP_IDS="${GCM_TMP}/ids.temp"        # Temporary file for storing gamepad IDs
    TMP_TAG="${GCM_TMP}/layout_tag.temp" # Temporary file for storing gamepad tag
    TMP_DIALOG="${GCM_TMP}/dialog.temp"  # Temporary file for editing lists and notes

    # Check for essential directories and gcm.ini
    if [ ! -d "$GCM_DIR" ]; then
        FIRST_RUN="ON" # Flag indicating First-run - open configuration menus
        clear
        echo " # First initialization: Creating required directories and files"
        sleep 1
    else
        FIRST_RUN="OFF"
    fi

    for required_dir in "$GCM_CFG" "$GCM_TMP" "$GCM_DAT" \
        "$GCM_GPD" "$GCM_FNT"; do
        if [ ! -d "$required_dir" ]; then
            mkdir -p "$required_dir" 2>/dev/null
        fi
    done

    # Generate default folders configuration
    if [ ! -f "${GCM_CFG}/folders.cfg" ]; then
        cat <<EOF >>"${GCM_CFG}/folders.cfg"
Computer
Console
Other
Selection
Unstable
Utility
EOF
    fi

    # Generate GCM.ini and default configuration files
    if [ ! -f "$GCM_INI" ]; then
        cat <<EOF >>"$GCM_INI"
dialogrc_color_scheme=DEFAULT
dialogrc_color_style=1
language=en
case=UPPERCASE
accents=OFF
font_size=SMALL
tips=ON
tip_help=ON
gcm_state=START
EOF
    fi
}

# ============================= #
# === MAIN - Main state machine #
# ============================= #

MAIN() {
    clear

    while true; do
        case "$STATE" in

        # -----------------------------
        # SCRIPT_INIT
        # -----------------------------
        SCRIPT_INIT)
            scriptInit
            ;;

        # -----------------------------
        # FIRST_RUN
        # -----------------------------
        FIRST_RUN)
            firstRun
            ;;

        # -----------------------------
        # MENU_HOME
        # -----------------------------
        MENU_HOME)
            menuHome
            ;;
        MENU_CORES_LIST)
            menuCoresList "$STATE_ARG"
            ;;
        MENU_ADD_CORE)
            menuAddCore
            ;;
        MENU_VIEW_NAMES)
            menuViewNames
            ;;
        MENU_RENAME_CORE)
            menuRenameCore
            ;;
        MENU_DELETE_CORE)
            menuDeleteCore
            ;;
        MENU_GAMEPADS)
            menuGamepads
            ;;
        MENU_SETTINGS)
            menuSettings
            ;;
        MENU_HELP)
            menuHelp
            ;;

        # -----------------------------
        # MENU_ADD_CORE
        # -----------------------------
        MENU_ADD_CORE_FROM_LIST)
            addCoreFromList
            ;;
        MENU_ADD_CORE_FROM_TYPE)
            addCoreFromType
            ;;
        CONFIGURE_EXPERT_MODE)
            configureExpertMode
            ;;
        VIEW_CORES_LIST)
            viewCoresList
            ;;

        # -----------------------------
        # MENU_RENAME_CORE
        # -----------------------------
        MENU_TYPE_NAME)
            menuTypeName
            ;;
        MENU_LIST_RENAMED)
            menuListRenamed
            ;;

        # -----------------------------
        # MENU_GAMEPAD
        # -----------------------------
        MENU_SELECT_GAMEPAD)
            menuSelectGamepad "$STATE_ARG"
            ;;
        MENU_LIST_GAMEPADS)
            menuListGamepads
            ;;
        MENU_RENAME_GAMEPAD)
            menuRenameGamepad
            ;;
        MENU_DELETE_GAMEPAD)
            menuDeleteGamepad
            ;;
        MENU_SELECT_EDIT_TAG)
            menuSelectEditTag "$STATE_ARG" "$STATE_ARG_2"
            ;;
        MENU_REGISTER_GAMEPAD)
            menuRegisterGamepad
            ;;
        MENU_CLONE_GAMEPAD)
            menuCloneGamepad
            ;;

        # -----------------------------
        # MENU_SETTINGS
        # -----------------------------
        MENU_COLORS)
            menuColors
            ;;
        MENU_COLOR_STYLE)
            menuColorStyle
            ;;
        MENU_LANGUAGE)
            menuLanguage
            ;;
        MENU_TEXT_CASE)
            menuTextCase
            ;;
        MENU_ACCENTS)
            menuAccents
            ;;
        MENU_FONT_SIZE)
            menuFontSize
            ;;
        MENU_TIPS)
            menuTips
            ;;
        MENU_ADVANCED_SETTINGS)
            menuAdvancedSettings
            ;;

        # -----------------------------
        # MENU_ADVANCED_SETTINGS
        # -----------------------------
        MENU_DELETE_MAPS)
            menuDeleteMaps
            ;;
        MENU_BACKUP)
            menuBackup
            ;;
        MENU_RESET)
            menuReset
            ;;
        MENU_UNINSTALL)
            menuUninstall
            ;;

        # -----------------------------
        # MENU_BACKUP
        # -----------------------------
        MENU_SAVE_BACKUP)
            menuSaveBackup
            ;;
        MENU_RESTORE_BACKUP)
            menuRestoreBackup
            ;;
        MENU_DELETE_BACKUP)
            menuDeleteBackup
            ;;

        # -----------------------------
        # MENU_CORE_MAIN
        # -----------------------------
        MENU_CORE_MAIN)
            menuCoreMain
            ;;
        MENU_LOAD_SLOT)
            menuLoadSlot
            ;;
        MENU_SHOW_LAYOUTS)
            menuShowlayouts "$STATE_ARG"
            ;;
        MENU_SHOW_GAMES)
            menuShowGames
            ;;
        MENU_SAVE_SLOT)
            menuSaveSLOT
            ;;
        MENU_EDIT_LAYOUT)
            menuEditLayout
            ;;
        MENU_EDIT_GAMES)
            menuEditGames
            ;;
        MENU_MOVE_SLOT)
            menuMoveSlot
            ;;
        MENU_SWITCH_SLOT)
            menuSwitchSlot
            ;;
        MENU_DELETE_SLOT)
            menuDeleteSlot
            ;;
        MENU_OVERWRITE_SLOT)
            menuOverwriteSlot
            ;;
        MENU_COPY_SLOT)
            menuCopySlot
            ;;
        MENU_SHOW_NOTES)
            menuShowNotes
            ;;

        # -----------------------------
        # EXIT_SCRIPT
        # -----------------------------
        EXIT_SCRIPT)
            exitScript "$STATE_ARG"
            ;;

        esac
    done
}

# =================================== #
# === SCRIPT_INIT - Initialize script #
# ====================================#

scriptInit() {
    SLOGAN="GCM"

    # initialization - Initialize paths and configuration
    initPathsAndConfigs                 # Initialize paths and enable FIRST_RUN if GCM_DIR is missing
    initializeLanguageFileDefinitions   # Load strings used by generateLanguageFile
    initializeHelpFileDefinitions       # Load strings used by generateHelpFile
    initializeAlertFilesDefinitions     # Load strings used by generateAlertFiles
    initializeGamepadDefinitions        # Load strings used by generateGamepadFiles
    initializeGCMFontsDefinitions       # Load strings used by generateGCMFonts
    initializeGCMiSTerKunDefinitions    # Load strings used by generateGCMiSTerKun
    initializeDialogSettingsDefinitions # Load strings used by generateDialogSettings

    # loading - Load settings
    loadTipsFlags        # Load tips flags
    loadLanguageSettings # Load language settings
    loadFontSize         # Load font size
    loadGCMState         # Load initial GCM state
    loadDialogSettings   # Load dialog settings

    # generation - Generate missing files
    generateLanguageFile   # Generate language files if missing
    generateHelpFile       # Generate HELP file if missing
    generateAlertFiles     # Generate alert messages if missing
    generateGamepadFiles   # Generate gamepad files if missing
    generateGCMFonts       # Generate font files used by GCM
    generateGCMiSTerKun    # Generate font size test screen files
    generateDialogSettings # Generate and apply dialog visual settings (load the color scheme)

    # checking - Check, validate, and repair settings
    checkAndFixGCMIni     # Reset GCM settings if the GCM.ini file is corrupted
    checkPreviousGCMState # Reset font size if GCM starts after an improper shutdown

    # font and language - Apply font and language settings
    setFontSize      # Apply configured font size
    loadLanguageFile # Load strings for the selected language

    # first run - First-run setup
    if [ "$FIRST_RUN" = "ON" ]; then
        STATE="FIRST_RUN"
        return
    fi

    # runtime - Initialize runtime flags
    FLAG_GAMEPAD_SHOW_MESSAGE="OFF" # Disable message after gamepad selection (ON / OFF)
    FLAG_COUNTER_CORES="ON"         # Count CORES on next CORE open (ON / OFF)
    FLAG_GENERATE_CORES_LIST="ON"   # Run generateCoresList to create the first list (ON / OFF)

    DISPLAY_MESSAGE_GAMEPAD="$SELECT_GAMEPAD_DEFAULT" # Default message in menuSelectGamepad

    # gamepads - Count registered gamepads
    if ! countRegisteredGamepads; then # If 0, exit scriptInit and go to menuRegisterGamepad
        return
    fi

    # menu - Open the appropriate menu
    # Check if exactly one gamepad is registered
    if [ "$COUNTER_GAMEPADS" -eq 1 ]; then
        # If no gamepad is selected, set the startup message and open menuSelectGamepad
        if [ "$ID" = "" ]; then
            DISPLAY_MESSAGE_GAMEPAD="$SELECT_GAMEPAD_CHOOSE" # Startup message in menuSelectGamepad
        else
            STATE="MENU_HOME"
            return
        fi
    # If more than one gamepad is registered, open menuSelectGamepad
    else
        # If no gamepad is selected, set startup message in menuSelectGamepad
        if [ "$ID" != "" ]; then
            DISPLAY_MESSAGE_GAMEPAD="$SELECT_GAMEPAD_CHOOSE"
        fi
    fi

    STATE="MENU_SELECT_GAMEPAD"
    STATE_ARG=""
    return
}

# ============================================= #
# === SCRIPT_INIT_FUNCTIONS - Startup functions #
# ============================================= #

### initializeLanguageFileDefinitions - Load strings used by generateLanguageFile
initializeLanguageFileDefinitions() {
    # LANGUAGE_en base64
    LANGUAGE_en="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"

    # LANGUAGE_pt base64
    LANGUAGE_pt="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
+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
dC50eHRQSwUGAAAAAAEAAQA9AAAARxoAAAAA"

    # LANGUAGE_es base64
    LANGUAGE_es="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"
}

### initializeHelpDefinitions - Load strings used by generateHelpFile
initializeHelpFileDefinitions() {
    # HELP_FILE_en - base64
    HELP_FILE_en="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
AQA5AAAABR4AAAAA"

    # HELP_FILE_pt - base64
    HELP_FILE_pt="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
AAA="

    # HELP_FILE_es - base64
    HELP_FILE_es="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"
}

### initializeAlertDefinitions - Load strings used by used by generateAlertFiles
initializeAlertFilesDefinitions() {
    # ALERT_DELETE_MAPS_en - base64
    ALERT_DELETE_MAPS_en="CiBUaGlzIGlzIGFuIGFkdmFuY2VkIG1haW50ZW5hbmNlIGZ1bmN0aW9uIHRoYXQgY2FuIGRlbGV0
ZQpqb3lzdGljayBkZWZpbml0aW9ucyBvciBidXR0b24va2V5IHJlbWFwcGluZ3MgZm9yIGEKc2Vs
ZWN0ZWQgQ09SRS4KCiBUaGUgc2VsZWN0ZWQgLm1hcCBmaWxlIHR5cGUgZm9yIHRoZSBzZWxlY3Rl
ZCBDT1JFIHdpbGwKYmUgZGVsZXRlZCBmcm9tIHRoZSBNaVNUZXIgJ2NvbmZpZy9pbnB1dHMnIGZv
bGRlciBhbmQKZnJvbSB0aGUgc2F2ZWQgU0xPVFMgZm9yIGFsbCBHQU1FUEFEUyByZWdpc3RlcmVk
IGluIEdDTS4KCiBTTE9UUyB0aGF0IGNvbnRhaW4gb25seSB0aGUgc2VsZWN0ZWQgY29uZmlndXJh
dGlvbiB0eXBlCndpbGwgYWxzbyBiZSBkZWxldGVkLiBUaGUgcmVtYWluaW5nIFNMT1RTIHdpbGwg
YmUKYXV0b21hdGljYWxseSByZW9yZ2FuaXplZC4KCiBXQVJOSU5HOiBUaGUgTEFZT1VUIGFuZCBH
QU1FIGNvbmZpZ3VyYXRpb25zIG9mIGRlbGV0ZWQKU0xPVFMgY2Fubm90IGJlIHJlY292ZXJlZC4K
CiBUaGUgQ09SRSB3aWxsIHJlbWFpbiBpbiB0aGUgbGlzdCBldmVuIGlmIGFsbCBvZiBpdHMKU0xP
VFMgYXJlIGRlbGV0ZWQuIEFmdGVyIHRoZSBjbGVhbnVwIHByb2Nlc3MsIHlvdSBjYW4KcmVjcmVh
dGUsIG1vZGlmeSwgb3Igc2F2ZSBuZXcgU0xPVFMgZm9yIEdBTUVQQURTIGFuZApDT1JFUy4KCg=="

    # ALERT_DELETE_MAPS_pt - base64
    ALERT_DELETE_MAPS_pt="CiBFc3RhIMOpIHVtYSBmdW7Dp8OjbyBkZSBtYW51dGVuw6fDo28gYXZhbsOnYWRhIHF1ZSBwb2Rl
IGFwYWdhcgpkZWZpbmnDp8O1ZXMgZGUgam95c3RpY2sgb3UgcmVtYXBlYW1lbnRvcyBkZSBib3TD
tWVzL3RlY2xhcwpwYXJhIHVtIENPUkUgZXNjb2xoaWRvLgoKIE8gdGlwbyBkZSBhcnF1aXZvIC5t
YXAgc2VsZWNpb25hZG8gcGFyYSBvIENPUkUgZXNjb2xoaWRvCnNlcsOhIGFwYWdhZG8gZGEgcGFz
dGEgJ2NvbmZpZy9pbnB1dHMnIGRvIE1pU1RlciBlIGRvcwpTTE9UUyBzYWx2b3MgcGFyYSB0b2Rv
cyBvcyBHQU1FUEFEUyBjYWRhc3RyYWRvcyBubyBHQ00uCgogT3MgU0xPVFMgcXVlIHBvc3N1w61y
ZW0gYXBlbmFzIG8gdGlwbyBkZSBjb25maWd1cmHDp8OjbwpzZWxlY2lvbmFkbyB0YW1iw6ltIHNl
csOjbyBleGNsdcOtZG9zLiBPcyBTTE9UUyByZXN0YW50ZXMKc2Vyw6NvIHJlb3JnYW5pemFkb3Mg
YXV0b21hdGljYW1lbnRlLgoKIEFURU7Dh8ODTzogYXMgY29uZmlndXJhw6fDtWVzIGRlIExBWU9V
VFMgZSBHQU1FUyBkb3MgU0xPVFMKZWxpbWluYWRvcyBuw6NvIHBvZGVyw6NvIHNlciByZWN1cGVy
YWRhcy4KCiBPIENPUkUgcGVybWFuZWNlcsOhIG5hIGxpc3RhIG1lc21vIHF1ZSB0b2RvcyBvcyBz
ZXVzClNMT1RTIHNlamFtIGVsaW1pbmFkb3MuIEFww7NzIG8gcHJvY2Vzc28gZGUgbGltcGV6YQp2
b2PDqiBwb2RlcsOhIHJlY3JpYXIsIGFsdGVyYXIgb3Ugc2FsdmFyIG5vdm9zIFNMT1RTCnBhcmEg
b3MgR0FNRVBBRFMgZSBDT1JFUy4K"

    # ALERT_DELETE_MAPS_es - base64
    ALERT_DELETE_MAPS_es="CkVzdGEgZXMgdW5hIGZ1bmNpw7NuIGRlIG1hbnRlbmltaWVudG8gYXZhbnphZG8gcXVlIHB1ZWRl
CmVsaW1pbmFyZGVmaW5pY2lvbmVzIGRlIGpveXN0aWNrIG8gcmVhc2lnbmFjaW9uZXMgZGUKYm90
b25lcy90ZWNsYXNwYXJhIHVuIENPUkUgc2VsZWNjaW9uYWRvLgoKRWwgdGlwbyBkZSBhcmNoaXZv
IC5tYXAgc2VsZWNjaW9uYWRvIHBhcmEgZWwgQ09SRSBlbGVnaWRvCnNlIGVsaW1pbmFyw6EgZGUg
bGEgY2FycGV0YSAnY29uZmlnL2lucHV0cycgZGUgTWlTVGVyIHkgZGUgbG9zClNMT1RTIGd1YXJk
YWRvcyBwYXJhIHRvZG9zIGxvcyBHQU1FUEFEUyByZWdpc3RyYWRvcyBlbiBHQ00uCgpMb3MgU0xP
VFMgcXVlIGNvbnRlbmdhbiDDum5pY2FtZW50ZSBlbCB0aXBvIGRlIGNvbmZpZ3VyYWNpw7NuCnNl
bGVjY2lvbmFkbyB0YW1iacOpbiBzZXLDoW4gZWxpbWluYWRvcy4gTG9zIFNMT1RTIHJlc3RhbnRl
cwpzZSByZW9yZ2FuaXphcsOhbiBhdXRvbcOhdGljYW1lbnRlLgoKQVRFTkNJw5NOOiBsYXMgY29u
ZmlndXJhY2lvbmVzIGRlIExBWU9VVFMgeSBHQU1FUyBkZSBsb3MgU0xPVFMKZWxpbWluYWRvcyBu
byBwb2Ryw6FuIHJlY3VwZXJhcnNlLgoKRWwgQ09SRSBwZXJtYW5lY2Vyw6EgZW4gbGEgbGlzdGEg
YXVucXVlIHRvZG9zIHN1cyBTTE9UUwpzZWFuIGVsaW1pbmFkb3MuIERlc3B1w6lzIGRlbCBwcm9j
ZXNvIGRlIGxpbXBpZXphLApwb2Ryw6EgY3JlYXIsIG1vZGlmaWNhciBvIGd1YXJkYXIgbnVldm9z
IFNMT1RTCnBhcmEgbG9zIEdBTUVQQURTIHkgQ09SRVMuCg=="

    # ALERT_NO_MAPS_en - base64
    ALERT_NO_MAPS_en="Ck5vIGNvbmZpZ3VyYXRpb25zIGZvdW5kIGZvciB0aGlzIGdhbWVwYWQgb24gYW55IGNvcmUgaW4g
TWlTVGVyLiBPcGVuCmEgY29yZSwgYWNjZXNzICJEZWZpbmUgJ0NPUkVOQU1FJyBidXR0b25zIiBh
bmQvb3IgIkJ1dHRvbi9LZXkgcmVtYXAiLApjb25maWd1cmUgdGhlIGdhbWVwYWQsIGFuZCB0cnkg
YWdhaW4uIE9ubHkgY29yZXMgd2l0aCAiQnV0dG9ucyIgYW5kL29yCiJCdXR0b24vS2V5IHJlbWFw
cGluZyIgY29uZmlndXJhdGlvbnMgYXBwZWFyIGluIHRoaXMgbGlzdC4K"

    # ALERT_NO_MAPS_pt - base64
    ALERT_NO_MAPS_pt="Ck5lbmh1bWEgY29uZmlndXJhw6fDo28gZW5jb250cmFkYSBwYXJhIGVzdGUgZ2FtZXBhZCBlbSBu
ZW5odW0gY29yZQpkbyBNaVNUZXIuIEFicmEgdW0gY29yZSwgYWNlc3NlICJEZWZpbmUgJ05PTUVE
T0NPUkUnIGJ1dHRvbnMiIGUvb3UKIkJ1dHRvbi9LZXkgcmVtYXAiLCBjb25maWd1cmUgbyBnYW1l
cGFkIGUgdGVudGUgbm92YW1lbnRlLiBBcGVuYXMKY29yZXMgY29tIGNvbmZpZ3VyYcOnw7VlcyBk
ZSAiQm90w7VlcyIgZS9vdSAiUmVtYXBlYW1lbnRvIGRlCkJvdMO1ZXMvVGVjbGFzIiBhcGFyZWNl
bSBuZXN0YSBsaXN0YS4K"

    # ALERT_NO_MAPS_es - base64
    ALERT_NO_MAPS_es="Ck5vIHNlIGVuY29udHLDsyBuaW5ndW5hIGNvbmZpZ3VyYWNpw7NuIHBhcmEgZXN0ZSBHQU1FUEFE
IGVuIG5pbmfDum4KQ09SRSBkZSBNaVNUZXIuIEFicmEgdW4gQ09SRSwgYWNjZWRhIGEgIkRlZmlu
ZSAnTk9NRURPQ09SRScgYnV0dG9ucyIKeS9vICJCdXR0b24vS2V5IHJlbWFwIiwgY29uZmlndXJl
IGVsIEdBTUVQQUQgZSBpbnTDqW50ZWxvIG51ZXZhbWVudGUuClNvbG8gbG9zIENPUkVTIGNvbiBj
b25maWd1cmFjaW9uZXMgZGUgIkJvdG9uZXMiIHkvbyAiUmVhc2lnbmFjacOzbiBkZQpib3RvbmVz
L3RlY2xhcyIgYXBhcmVjZW4gZW4gZXN0YSBsaXN0YS4K"

    # NO_GAMEPAD_en - base64
    NO_GAMEPAD_en="Ck5vIHJlZ2lzdGVyZWQgZ2FtZXBhZCB3YXMgZm91bmQhCgpUbyB1c2UgdGhpcyBzY3JpcHQsIGEg
Z2FtZXBhZCBtdXN0IGJlIHJlZ2lzdGVyZWQuIFRvIGRvIHRoaXMsCnRoZSBnYW1lcGFkIG11c3Qg
Zmlyc3QgYmUgY29uZmlndXJlZCBpbiB0aGUgTWlTVGVyIG1lbnUgYW5kL29yCkNPUkUgbWVudSB1
bmRlciAnRGVmaW5lIEJ1dHRvbnMnIGFuZC9vciAnQnV0dG9uL0tleSBSZW1hcCcuCgpJbiBhZGRp
dGlvbiwgZG8gbm90IGZvcmdldCB0byBhY2Nlc3MgdGhlICdIZWxwJyBtZW51IGZvcgppbXBvcnRh
bnQgaW5mb3JtYXRpb24gb24gaG93IHRvIGNvbmZpZ3VyZSBhbmQgdXNlIHRoaXMgc2NyaXB0LgoK
Q2xpY2sgJ0V4aXQnIHRvIGNvbnRpbnVlLgo="

    # NO_GAMEPAD_pt - base64
    NO_GAMEPAD_pt="Ck5lbmh1bSBnYW1lcGFkIHJlZ2lzdHJhZG8gZm9pIGVuY29udHJhZG8hCgpQYXJhIHV0aWxpemFy
IGVzdGUgc2NyaXB0LCDDqSBuZWNlc3PDoXJpbyByZWdpc3RyYXIgdW0gZ2FtZXBhZC4gUGFyYQpp
c3NvLCBvIGdhbWVwYWQgZGV2ZSBwcmltZWlybyBzZXIgY29uZmlndXJhZG8gbm8gbWVudSBkbyBN
aVNUZXIKZS9vdSBubyBtZW51IGRvIENPUkUsIGVtICdEZWZpbmUgQnV0dG9ucycgZS9vdSAnQnV0
dG9uL0tleSBSZW1hcCcuCgpBbMOpbSBkaXNzbywgbsOjbyBzZSBlc3F1ZcOnYSBkZSBhY2Vzc2Fy
IG8gbWVudSAnSGVscCcgcGFyYSBvYnRlcgppbmZvcm1hw6fDtWVzIGltcG9ydGFudGVzIHNvYnJl
IGNvbW8gY29uZmlndXJhciBlIHVzYXIgZXN0ZSBzY3JpcHQuCgpDbGlxdWUgZW0gJ1NhaXInIHBh
cmEgY29udGludWFyLgo="

    # NO_GAMEPAD_es - base64
    NO_GAMEPAD_es="CsKhTm8gc2UgZW5jb250csOzIG5pbmfDum4gR0FNRVBBRCByZWdpc3RyYWRvIQoKUGFyYSB1dGls
aXphciBlc3RlIHNjcmlwdCwgZXMgbmVjZXNhcmlvIHJlZ2lzdHJhciB1biBHQU1FUEFELiBQYXJh
CmVsbG8sIGVsIEdBTUVQQUQgZGViZSBjb25maWd1cmFyc2UgcHJpbWVybyBlbiBlbCBtZW7DuiBk
ZSBNaVNUZXIKeS9vIGVuIGVsIG1lbsO6IGRlbCBDT1JFLCBlbiAnRGVmaW5lIEJ1dHRvbnMnIHkv
byAnQnV0dG9uL0tleSBSZW1hcCcuCgpBZGVtw6FzLCBubyBvbHZpZGUgYWNjZWRlciBhbCBtZW7D
uiAnSGVscCcgcGFyYSBvYnRlbmVyCmluZm9ybWFjacOzbiBpbXBvcnRhbnRlIHNvYnJlIGPDs21v
IGNvbmZpZ3VyYXIgeSB1dGlsaXphciBlc3RlIHNjcmlwdC4KCkhhZ2EgY2xpYyBlbiAnU2FsaXIn
IHBhcmEgY29udGludWFyLgoK"
}

### initializeGamepadFilesDefinitions - Load strings used by generateGamepadFiles
initializeGamepadDefinitions() {
    # LIST CONTROLLER IDS - base64
    LIST_GAMEPAD_IDS="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
AEIAAADAGQAAAAA="

    # Initialize gamepad layout tags
    LAYOUT_TAGS[1]="← ↓ ↑ → A B X Y L1 R1 L2 R2 L3 R3 ST SL"
    LAYOUT_TAGS[2]="← ↓ ↑ → A B X Y L1 R L2 R ← ↓ ↑ → ST SL"
    LAYOUT_TAGS[3]="← ↓ ↑ → U D L R A B X Y L1 R L2 R ST SL"
    LAYOUT_TAGS[4]="← ↓ ↑ → ■ ✖ ● ▲ L1 R1 L2 R2 L3 R3 ST SL"
    LAYOUT_TAGS[5]="← ↓ ↑ → ■ ✖ ● ▲ L1 R L2 R ← ↓ ↑ → ST SL"
    LAYOUT_TAGS[6]="← ↓ ↑ → U D L R ■ ✖ ● ▲ L1 R L2 R ST SL"
    LAYOUT_TAGS[7]="← ↓ ↑ → A B L R Z Z2 L3 C:← ↓ ↑ → ST SL"
    LAYOUT_TAGS[8]="← ↓ ↑ →  A B C  X Y Z  L1 R1  EX  ST SL"
    LAYOUT_TAGS[9]="← ↓ ↑ →  A B C D  X Y Z W  B1 B2  ST SL"
}

### initializeGCMFontsDefinitions - Load strings used by generateGCMFonts
initializeGCMFontsDefinitions() {
    # GCM Fonts - base64
    GCM_TerminusBold16="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
AAAAAA=="

    GCM_TerminusBold22x11="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"

    GCM_TerminusBold28x14="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
AAEAAQBKAAAALRgAAAAA"

    GCM_TerminusBold32x16="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"

    # Fonts used by GCM and current terminal font
    SMALL_FONT="${GCM_FNT}/GCM-TerminusBold16.psf.gz"                         # small font
    MEDIUM_FONT="${GCM_FNT}/GCM-TerminusBold22x11.psf.gz"                     # medium font
    LARGE_FONT="${GCM_FNT}/GCM-TerminusBold28x14.psf.gz"                      # large font
    EXTRA_LARGE_FONT="${GCM_FNT}/GCM-TerminusBold32x16.psf.gz"                # extra large font
    CURRENT_FONT=$(setfont -v 2>&1 | grep -o '/usr/share/consolefonts/[^ ]*') # current font
}

### initializeGCMiSTerKunDefinitions - Load strings used by generateGCMiSTerKun
initializeGCMiSTerKunDefinitions() {
    # MiSTer Kun ASCII image - base64
    MiSTer_Kun="V1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dX
V1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXYy47WFdXV1dXV1dXV1dXWDsuY1dX
V1dXV1dXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXV1dXV04nLjosIGxXV1dX
V1dXV1dsICw7Li5OV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXV1dY
ZC4sYzsubCwuOzs7Ozs7Oy4sby47Oiwub1hXV1dXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dX
V1dXV1dXV1dXV3ggbDBOV1dXV1dYWFhYWFhYWFhXV1dXV04wbCBkV1dXV1dXV1dXV1dXV1dXV1dX
V1cKV1dXV1dXV1dXV1dXV1dXV1dXTS4nV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXVywuTVdXV1dX
V1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXTS4nV1dXV1dXV1dXV3gwV0t4TldXV1dX
V1dXVywuTVdXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXTS4nYzs6OjsnJyc6
Oi4gJyAuOjonJyc7Ojo7YywuTVdXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dO
bCA6Yy5XTU5sO29NTWsgYyB4TU1vO2NOTU0nOmMgbFhXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dX
V1dXV1dXV1dXV0sgOlhXTmwnbzBOTktrbDsuLi4sbGtLTk5LZCdjTldYYyAwV1dXV1dXV1dXV1dX
V1dXV1cKV1dXV1dXV1dXV1dXV1dXV2MgTldXV1dOT29jOycuO2RjJ2NkOyAnO2Nva05XV1dXVyA6
V1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV0suO0tXV1dXV1dXb2tra2w6Yzpja2t4
bFdXV1dXV1dLOiBLV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dObyA7V1dXV1dX
V09XV1dXV1dXV1cwV1dXV1dXVzogb05XV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dX
V1dXVy4nV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXVywuV1dXV1dXV1dXV1dXV1dXV1dXV1cKV1dX
V1dXV1dXV1dXV1dXV1cwIDtrV1dXV1dXV1dXVzBkb2RPTldXV1dXV1dXV2s6IE9XV1dXV1dXV1dX
V1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dvIGtOTk5OTk5OTk4wLidka3gnLjBOTk5OTk5OTk5P
IGxXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXazosLCwsLCwsLCwsOldXV1dX
OiwsLCwsLCwsLCw6a1dXV1dXV1dXV1dXV1dXV1dXV1cKV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dX
V1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1cKfD09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PXwK"

    # MiSTer Kun text files - base64
    MiSTer_Kun_en="ICAgICAgSWYgeW91IGNhbiBzZWUgdGhpcyBlbnRpcmUgd2luZG93IGNsZWFybHksIHRoZSBmb250
IHNpemUKICAgICBpcyBjb3JyZWN0LiBJZiB5b3UgY2Fubm90IHNlZSB0aGUgZW50aXJlIHdpbmRv
dywgc2VsZWN0CiAgICAgYSBzbWFsbGVyIGZvbnQgc2l6ZSBvbiB0aGUgc2VsZWN0aW9uIHNjcmVl
bi4K"

    MiSTer_Kun_pt="ICAgICBTZSB2b2PDqiBlc3TDoSB2ZW5kbyBlc3RhIGphbmVsYSBwZXJmZWl0YW1lbnRlLCBvIHRh
bWFuaG8gZGEKICAgIGZvbnRlIGVzdMOhIGNvcnJldG8uIENhc28gbsOjbyB2ZWphIHRvZGEgYSBq
YW5lbGEsIHNlbGVjaW9uZQogICAgdW0gdGFtYW5obyBkZSBmb250ZSBtZW5vciBuYSB0ZWxhIGRl
IHNlbGXDp8Ojby4K"

    MiSTer_Kun_es="ICAgIFNpIHB1ZWRlIHZlciBlc3RhIHZlbnRhbmEgY29ycmVjdGFtZW50ZSwgZWwgdGFtYcOxbyBk
ZSBsYQogICBmdWVudGUgZXMgYWRlY3VhZG8uIFNpIG5vIHB1ZWRlIHZlciB0b2RhIGxhIHZlbnRh
bmEsIHNlbGVjY2lvbmUKICAgdW4gdGFtYcOxbyBkZSBmdWVudGUgbWVub3IgZW4gbGEgcGFudGFs
bGEgZGUgc2VsZWNjacOzbi4K"
}

### initializeDialogSettingsDefinitions - Load strings used by generateDialogSettings
initializeDialogSettingsDefinitions() {
    # Dialog color themes and styles

    # ============ STYLES - NORMAL COLORS - DEFAULT ============ #
    THEME_DEFAULT_STYLE1=(BLACK WHITE YELLOW YELLOW YELLOW OFF ON)
    THEME_DEFAULT_STYLE2=(BLACK WHITE WHITE WHITE WHITE OFF OFF)
    THEME_DEFAULT_STYLE3=(BLACK WHITE BLUE BLUE BLUE OFF OFF)
    THEME_DEFAULT_STYLE4=(WHITE BLACK BLACK BLACK BLACK OFF OFF)
    THEME_DEFAULT_STYLE5=(GREEN WHITE WHITE WHITE WHITE OFF ON)
    THEME_DEFAULT_STYLE6=(RED WHITE WHITE WHITE WHITE OFF ON)

    # BLUE
    THEME_BLUE=(BLUE WHITE BLUE WHITE VALUE_4 BLACK WHITE DEFAULT BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 BLUE BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_BLUE_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_BLUE_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_BLUE_STYLE3=("${THEME_DEFAULT_STYLE3[@]}")
    THEME_BLUE_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_BLUE_STYLE5=("${THEME_DEFAULT_STYLE5[@]}")
    THEME_BLUE_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # CYAN
    THEME_CYAN=(CYAN BLACK BLACK WHITE VALUE_4 BLACK WHITE BLACK BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 CYAN BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_CYAN_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_CYAN_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_CYAN_STYLE3=(BLACK WHITE CYAN CYAN CYAN OFF OFF)
    THEME_CYAN_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_CYAN_STYLE5=("${THEME_DEFAULT_STYLE5[@]}")
    THEME_CYAN_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # GREEN
    THEME_GREEN=(GREEN BLACK GREEN WHITE VALUE_4 BLACK WHITE DEFAULT BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 GREEN BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_GREEN_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_GREEN_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_GREEN_STYLE3=(BLACK WHITE GREEN GREEN GREEN OFF OFF)
    THEME_GREEN_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_GREEN_STYLE5=(BLUE WHITE WHITE WHITE WHITE OFF ON)
    THEME_GREEN_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # YELLOW
    THEME_YELLOW=(YELLOW WHITE YELLOW WHITE VALUE_4 BLACK WHITE DEFAULT BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 YELLOW BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_YELLOW_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_YELLOW_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_YELLOW_STYLE3=(BLACK YELLOW YELLOW YELLOW YELLOW OFF OFF)
    THEME_YELLOW_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_YELLOW_STYLE5=("${THEME_DEFAULT_STYLE5[@]}")
    THEME_YELLOW_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # MAGENTA
    THEME_MAGENTA=(MAGENTA WHITE MAGENTA WHITE VALUE_4 BLACK WHITE DEFAULT BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 MAGENTA BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_MAGENTA_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_MAGENTA_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_MAGENTA_STYLE3=(BLACK WHITE MAGENTA MAGENTA MAGENTA OFF OFF)
    THEME_MAGENTA_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_MAGENTA_STYLE5=("${THEME_DEFAULT_STYLE5[@]}")
    THEME_MAGENTA_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # RED
    THEME_RED=(RED WHITE WHITE WHITE VALUE_4 WHITE WHITE BLACK BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 RED BLACK WHITE WHITE VALUE_18 VALUE_19)
    THEME_RED_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_RED_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_RED_STYLE3=(BLACK WHITE RED RED RED OFF OFF)
    THEME_RED_STYLE4=("${THEME_DEFAULT_STYLE4[@]}")
    THEME_RED_STYLE5=(GREEN BLACK WHITE WHITE WHITE OFF ON)
    THEME_RED_STYLE6=(BLUE WHITE WHITE WHITE WHITE OFF ON)

    # BLACK_WHITE
    THEME_BLACK_WHITE=(WHITE BLACK BLACK BLACK VALUE_4 BLACK WHITE DEFAULT BLACK VALUE_9 VALUE_10 BLACK VALUE_12 VALUE_13 WHITE WHITE WHITE WHITE VALUE_18 VALUE_19)
    THEME_BLACK_WHITE_STYLE1=("${THEME_DEFAULT_STYLE1[@]}")
    THEME_BLACK_WHITE_STYLE2=("${THEME_DEFAULT_STYLE2[@]}")
    THEME_BLACK_WHITE_STYLE3=(MAGENTA WHITE WHITE WHITE WHITE OFF OFF)
    THEME_BLACK_WHITE_STYLE4=(YELLOW BLACK BLACK BLACK BLACK OFF OFF)
    THEME_BLACK_WHITE_STYLE5=(BLACK WHITE GREEN GREEN GREEN OFF ON)
    THEME_BLACK_WHITE_STYLE6=("${THEME_DEFAULT_STYLE6[@]}")

    # ============= STYLES - NEON COLORS - DEFAULT ============= #
    THEME_NEON_DEFAULT_STYLE1=(RED WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_DEFAULT_STYLE2=(WHITE BLACK BLACK BLACK BLACK ON OFF)
    THEME_NEON_DEFAULT_STYLE3=(BLUE WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_DEFAULT_STYLE4=(WHITE BLACK BLACK BLACK BLACK ON OFF)
    THEME_NEON_DEFAULT_STYLE5=(GREEN WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_DEFAULT_STYLE6=(MAGENTA WHITE WHITE WHITE WHITE ON ON)

    # NEON_BLUE
    THEME_NEON_BLUE=(DEFAULT BLUE BLUE BLUE VALUE_4 BLUE BLUE BLUE DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT BLUE VALUE_18 VALUE_19)
    THEME_NEON_BLUE_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_BLUE_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_BLUE_STYLE3=("${THEME_NEON_DEFAULT_STYLE3[@]}")
    THEME_NEON_BLUE_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_BLUE_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_BLUE_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_CYAN
    THEME_NEON_CYAN=(DEFAULT CYAN CYAN CYAN VALUE_4 CYAN CYAN CYAN DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT CYAN VALUE_18 VALUE_19)
    THEME_NEON_CYAN_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_CYAN_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_CYAN_STYLE3=(CYAN WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_CYAN_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_CYAN_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_CYAN_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_GREEN
    THEME_NEON_GREEN=(DEFAULT GREEN GREEN GREEN VALUE_4 GREEN GREEN GREEN DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT GREEN VALUE_18 VALUE_19)
    THEME_NEON_GREEN_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_GREEN_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_GREEN_STYLE3=(GREEN WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_GREEN_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_GREEN_STYLE5=(BLUE WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_GREEN_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_YELLOW
    THEME_NEON_YELLOW=(DEFAULT YELLOW YELLOW YELLOW VALUE_4 YELLOW YELLOW YELLOW DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT YELLOW VALUE_18 VALUE_19)
    THEME_NEON_YELLOW_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_YELLOW_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_YELLOW_STYLE3=(YELLOW WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_YELLOW_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_YELLOW_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_YELLOW_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_MAGENTA
    THEME_NEON_MAGENTA=(DEFAULT MAGENTA MAGENTA MAGENTA VALUE_4 MAGENTA MAGENTA MAGENTA DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT MAGENTA VALUE_18 VALUE_19)
    THEME_NEON_MAGENTA_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_MAGENTA_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_MAGENTA_STYLE3=(MAGENTA WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_MAGENTA_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_MAGENTA_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_MAGENTA_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_RED
    THEME_NEON_RED=(DEFAULT RED RED RED VALUE_4 RED RED RED DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT RED VALUE_18 VALUE_19)
    THEME_NEON_RED_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_RED_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_RED_STYLE3=(WHITE RED RED RED RED ON ON)
    THEME_NEON_RED_STYLE4=("${THEME_NEON_DEFAULT_STYLE4[@]}")
    THEME_NEON_RED_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_RED_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # NEON_WHITE
    THEME_NEON_WHITE=(DEFAULT WHITE WHITE BLACK VALUE_4 WHITE WHITE WHITE DEFAULT VALUE_9 VALUE_10 DEFAULT VALUE_12 VALUE_13 DEFAULT DEFAULT DEFAULT WHITE VALUE_18 VALUE_19)
    THEME_NEON_WHITE_STYLE1=("${THEME_NEON_DEFAULT_STYLE1[@]}")
    THEME_NEON_WHITE_STYLE2=("${THEME_NEON_DEFAULT_STYLE2[@]}")
    THEME_NEON_WHITE_STYLE3=("${THEME_NEON_DEFAULT_STYLE3[@]}")
    THEME_NEON_WHITE_STYLE4=(YELLOW WHITE WHITE WHITE WHITE ON ON)
    THEME_NEON_WHITE_STYLE5=("${THEME_NEON_DEFAULT_STYLE5[@]}")
    THEME_NEON_WHITE_STYLE6=("${THEME_NEON_DEFAULT_STYLE6[@]}")

    # dialogrc template
    DIALOGRC_TEMPLATE="UEsDBBQAAgAIAHubBl3ODQzJWQMAAKgMAAAIAAAAZGlhbG9ncmOlVttu2zAMffdXEOlLCyRBm3VX
bCuyS4ACbQps6V4DxWZtoYpk6NKuwD5+lHyp7dqouwUIbIo8R0cyReogOoAfTs4s3yPESt7w1Glm
uZJwwwXCjdKQcCZUGh1Q6NJZtSd3zIR4gBQlUjAmsHuASREGs1mskQZnOoaPnuPzxEMJvHnI0YC6
gTsmHJoPYXDt9jvU4H8zgI8ymJ/J8dNqLtPKMTHBJCr4opRAJivE1frP1WrlEUtLMTtnMTgOSTqm
WjmZTHcsvi1fM55mgv727Cjys6AFZnKM7axY9jwqTPgEx1WAwZyRl7bCk8LeCctz2px7nqRoaUnO
5s4ezaMyELeFhzgmk4rEst1MoExtVrBY/G136ncYp42/Q21oeiKhgS0FVgIu2S2GIKuZD2IifJQ4
w/hWcGOngDaeT4HLWLiEQjMEPz6P7rjhdsst7g2R0SYFKRlL1H35TYEEoDmDTcYNMGEUWKclLUhS
Lgil55EzuDUFpKbYUEzhB+PyXGkLV2sgy/s9IPjCnOswJSUElojIBKMIoYjDX8uL6+/b0+m376vl
9cVmerU+asgsMcHoYt5Ni+f78nnyPiC/1Ssr0cVSu+hFhRpEW24FlhzhvUvxthZQim6Ad0onlNYF
ujC68Fe1ghK+jC2/Q6AMtkpGxWPLwmAXe3Jcgl+Xz8VxoDiXrElSzV9QcdlPNrAVLTlwiw9tNhoY
EvdqnLheyv8SKdgORZszDP2n0EHaF4o9l1QmGpnJvU3mi+Gt7KpZ+tNsgOwnMh1nDTEmDPSoOa2A
rwcZmkflkWfcoWnQtJb1yDPy+Kx8v8oV1TzfvbhMqEv5ml3QVY5t7XhW2SVK19igPZnjP1YNbi2q
4hi5pHOq3dVXptfRn1ZQA6OuzDtwUzqenIOT/nOwYWlV/1j60sltC/wvUz/WB8/gi8M/SHhKMijl
tF/KV99pG3kQOu9LpcS9JINS3nVz8ToHpnXdEV0wBkW8qTuSupctYDISGDIvQ5HP/D2lkUR+bDBv
3/YWZ7qu7KFB4+2qIvvh51e/6mPogw4p+YF0g5B0ZQ1aGuciMIXDocuQobJwsuhp8ylzaVX4wnsX
/ebZa0ZRChatq8JiJE23Iyz6W8JYuieleDFQi8cSdorgorcKjiL7C1BLAQI/AxQAAgAIAHubBl3O
DQzJWQMAAKgMAAAIAAAAAAAAAAAAAAC0gQAAAABkaWFsb2dyY1BLBQYAAAAAAQABADYAAAB/AwAA
AAA="

    DIALOGRC_DEFAULT="UEsDBBQAAgAIAGZ0Gl2ohq2gZAMAAEsLAAAIAAAAZGlhbG9ncmONVt9P4zAMfu9fYY0XkLbptMcT
d2jAuEMHmwRDiKcp60wbkSVVfsAh3R9/TtpuTbsCSEi1/X224zj2jpIjuHNyZPkWIVXymWdOM8uV
hGcuEJ6Vhg1nQmXJEUGnzqotmVMmxDtkKJHAuIH1OwxKGIxGqUZSjnQKp97Hz4GnEnn5XqAB9Qyv
TDg034Ny7rZr1OD/RgCnMog/yXBvNZdZbRiYIJIrOFdKIJM1YzH/t7i68oypJczaWQyGY0odM62c
3AzXLH2pPnOe5YL+7dmQRNSCSzwbanxFbfDsJPGR0QIzBaZ2VJZinJQi/IBvNcBgwchK5fGBYOuE
5QUV7I1vMrR0TGcLZ0/GSQXEVWkhH4NB7cSy9UigzGxeerH4167V36Cny/A5UXhyQooVAesEbtkL
BpDVzIOYCBeV5pi+CG7sENCm4yFwmQq3IWiO4PXj5JUbblfc4taQMypcSCVnG/VW3TNQAmjOYJlz
A0wYBdZpSQeS1B9C6XHiDK5MSdm5WBKmtINxRaG0hcUcSPJ2Twi2EHMeQlKTYMVITBBKCCGOL56m
8+H5zfTiz3AxP2lkWMGDsIeXyAh/uTtKxSnP1uY8/r5ezoaUYptkuRVYUcN3k/kwq4mdYGulqacq
YinsmSUpok5Ty18RqGltXd+kFFYsmNrsEL0iX0vWT+ey5aBZgW7oF3yP+aRop3AgsUNpHHTVSef4
bnbZqn+ckWBrFLGjoOoU5ml2c7N4/LAyvb66aUWNUXujl9zoJe5lEntLuydE/bDjtRqjTb9HptO8
EdAExUcRG5Rm6+6JcRM3pBY7SnhPb2XcFL2DK78qCkWjxS8OLje0IPxoLAG1YbUz9CVyi9I1zr0l
8aNT7+BR1jXrk5yvaQbWF0OfH5RW0OinHcdbBFMZPnsfS5bVk4Rl/VdQRbERui9G9yXUkfavz/P9
02tRu6+xE7/ro5NHeL7NJ3fhd0/j7sIu+ryo6UHaV0v7UADTercYXBD2Of66m83mrVmt3mTE2cSc
potdl+QoipHfzY3r97rucA4rKB5ntJi30CB7uT6IV392xqtD/IhYRQ9bszrmHdKKlPQTLURvdG5g
h/bVFaS1dvs2W8ZcVo+V8N3XyZ1tOInW4eTLU3NyeGxOvjIEYw/tOTb56kSZHBwpPfT/UEsBAj8D
FAACAAgAZnQaXaiGraBkAwAASwsAAAgAAAAAAAAAAAAAALSBAAAAAGRpYWxvZ3JjUEsFBgAAAAAB
AAEANgAAAIoDAAAAAA=="
}

# === loading

### loadTipsFlags - Load tips flags
loadTipsFlags() {
    # TIPS next to the menus flag (ENABLE / DISABLE)
    FLAG_SHOW_TIPS=$(grep -o '^[[:space:]]*tips=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)

    # HELP menu hint flag (ENABLE / DISABLE)
    FLAG_SHOW_TIP_HELP=$(grep -o '^[[:space:]]*tip_help=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
}

###  loadLanguageSettings - Load language settings
loadLanguageSettings() {
    # language settings
    LANGUAGE=$(grep -o '^[[:space:]]*language=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
    CASE=$(grep -o '^[[:space:]]*case=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
    MENU_ACCENTS=$(grep -o '^[[:space:]]*accents=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
}

### loadFontSize - Load font size (SMALL, MEDIUM, LARGE or extra large)
loadFontSize() {
    FONT_SIZE=$(grep -o '^[[:space:]]*font_size=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
}

### loadGCMState - Load initial GCM state - if 'stop' indicate error on shutdown
loadGCMState() {
    GCM_STATE=$(grep -o '^[[:space:]]*gcm_state=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
}

### loadDialogSettings - Load dialog settings
loadDialogSettings() {
    # dialog scheme
    SCHEME=$(grep -o '^[[:space:]]*dialogrc_color_scheme=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)
    SCHEME_COLOR_STYLE=$(grep -o '^[[:space:]]*dialogrc_color_style=[^[:space:]]*' "$GCM_INI" |
        cut -d'=' -f2 2>/dev/null)

    if [ -z "$SCHEME" ]; then
        SCHEME=BLUE
    fi
}

# === generation

### generateLanguageFile - Generate language and menu message file
generateLanguageFile() {
    local wait_mode
    local lang_base64

    # ARGUMENTS:
    wait_mode="$1"

    # Extract LANGUAGE file
    if [ ! -f "${GCM_DAT}/LANGUAGE.txt" ]; then
        if [ "$wait_mode" = "SHOW_WAIT" ]; then
            messageProcessingWait
        fi

        lang_base64="LANGUAGE_${LANGUAGE}"
        echo "${!lang_base64}" | base64 --decode >"${GCM_DAT}/LANGUAGE_${LANGUAGE}.zip" 2>/dev/null &&
            unzip -d "$GCM_DAT" "${GCM_DAT}/LANGUAGE_${LANGUAGE}.zip" >/dev/null 2>&1 &&
            rm -f "${GCM_DAT}/LANGUAGE_${LANGUAGE}.zip"
        mv "${GCM_DAT}/LANGUAGE_${LANGUAGE}.txt" "${GCM_DAT}/LANGUAGE.txt" 2>/dev/null
        generateTextFromOption "${GCM_DAT}/LANGUAGE.txt"
    fi
}

### generateHelpFile - Generate HELP file
generateHelpFile() {
    local flag_generate
    local help_base64

    if [ ! -f "${GCM_DAT}/HELP.txt" ]; then
        flag_generate="ON"
        help_base64="HELP_FILE_${LANGUAGE}"
        echo "${!help_base64}" | base64 --decode >"${GCM_DAT}/HELP_${LANGUAGE}.zip" 2>/dev/null &&
            unzip -d "$GCM_DAT" "${GCM_DAT}/HELP_${LANGUAGE}.zip" >/dev/null 2>&1 &&
            rm -f "${GCM_DAT}/HELP_${LANGUAGE}.zip" 2>/dev/null
        mv "${GCM_DAT}/HELP_${LANGUAGE}.txt" "${GCM_DAT}/HELP.txt" 2>/dev/null
        generateTextFromOption "${GCM_DAT}/HELP.txt"
    fi
}

### generateAlertFiles - Generate alert messages
generateAlertFiles() {
    local alert_file
    local file_base64

    for alert_file in NO_GAMEPAD ALERT_NO_MAPS ALERT_DELETE_MAPS; do
        if [ ! -f "${GCM_DAT}/${alert_file}.txt" ]; then
            file_base64="${alert_file}_${LANGUAGE}"
            echo "${!file_base64}" | base64 --decode >"${GCM_DAT}/${alert_file}.txt" 2>/dev/null
            generateTextFromOption "${GCM_DAT}/${alert_file}.txt"
        fi
    done
}

### generateGamepadFiles - Generate gamepad IDS, configuration files and set layout tags
generateGamepadFiles() {
    if [ ! -f "$GCM_LGI" ]; then
        echo "$LIST_GAMEPAD_IDS" |
            base64 --decode >"${GCM_LGI}.zip" 2>/dev/null &&
            unzip -d "$GCM_CFG" "${GCM_LGI}.zip" >/dev/null 2>&1 &&
            rm -f "${GCM_LGI}.zip" 2>/dev/null
    fi

    # Generate gamepad config files
    if [ ! -f "$GCM_RGP" ]; then
        touch "$GCM_RGP" 2>/dev/null
    fi

    if [ ! -f "$GCM_SGP" ]; then
        {
            echo "ID=\"\""
            echo "MODEL=\"$NO_GAMEPAD\""
        } >"$GCM_SGP" 2>/dev/null
    fi
}

### generateGCMFonts - Generate font files used by GCM
generateGCMFonts() {
    local gcm_lang
    local gcm_font

    for gcm_lang in GCM_TerminusBold16 GCM_TerminusBold22x11 GCM_TerminusBold28x14 GCM_TerminusBold32x16; do
        gcm_font="${gcm_lang//_/-}"

        if [ ! -f "${GCM_FNT}/${gcm_font}.psf.gz" ]; then
            printf '%s' "${!gcm_lang}" | base64 --decode >"${GCM_FNT}/${gcm_lang}.zip" 2>/dev/null &&
                unzip -d "$GCM_FNT" "${GCM_FNT}/${gcm_lang}.zip" >/dev/null 2>&1 &&
                rm -f "${GCM_FNT}/${gcm_lang}.zip" 2>/dev/null
        fi
    done
}

### generateGCMiSTerKun - Generate font size test screen files
generateGCMiSTerKun() {
    local mister_kun_base64

    if [ ! -f "${GCM_DAT}/MiSTer_Kun_message.txt" ]; then
        mister_kun_base64="MiSTer_Kun_${LANGUAGE}"
        echo "$MiSTer_Kun" | base64 --decode >"${GCM_DAT}/MiSTer_Kun_logo.txt" 2>/dev/null

        echo "${!mister_kun_base64}" | base64 --decode >"${GCM_DAT}/MiSTer_Kun_${LANGUAGE}.txt" 2>/dev/null
        generateTextFromOption "${GCM_DAT}/MiSTer_Kun_${LANGUAGE}.txt"

        cat "${GCM_DAT}/MiSTer_Kun_${LANGUAGE}.txt" "${GCM_DAT}/MiSTer_Kun_logo.txt" >"${GCM_DAT}/MiSTer_Kun_message.txt" 2>/dev/null
        rm -f "${GCM_DAT}/MiSTer_Kun_${LANGUAGE}.txt" "${GCM_DAT}/MiSTer_Kun_logo.txt" 2>/dev/null
    fi
}

### generateDialogSettings - Generate visual settings of the dialog
generateDialogSettings() {
    local apply_color_theme
    local apply_color_style

    # Generate dialogrc
    if [ "$SCHEME" != "DEFAULT" ]; then
        if [ ! -f "${GCM_CFG}/dialogrc" ]; then
            extractDialogString DIALOGRC_TEMPLATE
            apply_color_theme="THEME_${SCHEME}"
            apply_color_style="THEME_${SCHEME}_STYLE${SCHEME_COLOR_STYLE}"
            applyColorTheme "$apply_color_theme" "$apply_color_style"
        fi
    else
        if [ ! -f "${GCM_CFG}/dialogrc" ]; then
            extractDialogString DIALOGRC_DEFAULT
        fi
    fi

    # Export DIALOG config
    export DIALOGRC="${GCM_CFG}/dialogrc"
}

# === checking

### checkAndFixGCMIni - Check and restore integrity of gcm.ini
checkAndFixGCMIni() {
    if [ -z "$SCHEME" ] || [ -z "$SCHEME_COLOR_STYLE" ] || [ -z "$LANGUAGE" ] || [ -z "$CASE" ] ||
        [ -z "$MENU_ACCENTS" ] || [ -z "$FONT_SIZE" ] || [ -z "$FLAG_SHOW_TIPS" ] ||
        [ -z "$FLAG_SHOW_TIP_HELP" ] || [ -z "$GCM_STATE" ]; then

        if [ -f "$GCM_INI" ]; then
            rm -f "$GCM_INI"
        fi

        if [ ! -f "$GCM_INI" ]; then
            cat <<EOF >>"$GCM_INI"
dialogrc_color_scheme=DEFAULT
dialogrc_color_style=1
language=en
case=UPPERCASE
accents=OFF
font_size=SMALL
tips=ON
tip_help=ON
gcm_state=STOP
EOF

            SCHEME="BLUE"
            SCHEME_COLOR_STYLE="1"
            LANGUAGE="en"
            CASE="UPPERCASE"
            MENU_ACCENTS="OFF"
            FONT_SIZE="SMALL"
            FLAG_SHOW_TIPS="ON"
            FLAG_SHOW_TIP_HELP="ON"
            GCM_STATE="STOP"
            EXTENSION=""
        fi
    fi
}

# checkPreviousGCMState - Reset font size if GCM was not shut down properly
checkPreviousGCMState() {
    # if not correct exit, set font to SMALL.
    if [ "$GCM_STATE" = "RUN" ]; then
        FONT_SIZE="SMALL"
        sed -i "s/^font_size=[^ ]*/font_size=SMALL/" "$GCM_INI" 2>/dev/null
    else
        sed -i "s/^gcm_state=[^ ]*/gcm_state=RUN/" "$GCM_INI" 2>/dev/null
    fi
}

# === font and language

### setFontSize - Set font size
setFontSize() {
    local font_size_change
    local font_name

    # ARGUMENTS:
    font_size_change="$1"

    if [ -z "$font_size_change" ]; then
        font_size_change="$FONT_SIZE"
    fi

    font_name="${font_size_change}_FONT"

    setfont "${!font_name}" 2>/dev/null
}

### loadLanguageFile - Load the selected language
loadLanguageFile() {
    source "${GCM_DAT}/LANGUAGE.txt"

    HOME_ITENS=(HOME_EXIT_COL1 HOME_CORES_LIST_COL1 HOME_ADD_COL1 HOME_VIEW_NAMES_COL1 HOME_RENAME_CORE_COL1
        HOME_DELETE_COL1 HOME_GAMEPADS_COL1 HOME_SETTINGS_COL1 HOME_HELP_COL1)
    padLanguageStrings HOME_ITENS "$HOME_COLUMN_SIZE"

    ADD_CORE_ITENS=(ADD_CORE_EXIT_COL1 ADD_CORE_FROM_LIST_COL1 ADD_CORE_FROM_TYPE_COL1 ADD_CORE_FOLDERS_COL1
        ADD_CORE_LIST_COL1)
    padLanguageStrings ADD_CORE_ITENS "$ADD_CORE_COLUMN_SIZE"

    RENAME_CORE_ITENS=(RENAME_CORE_EXIT_COL1 RENAME_CORE_TYPE_COL1 RENAME_CORE_LIST_COL1)
    padLanguageStrings RENAME_CORE_ITENS "$RENAME_CORE_COLUMN_SIZE"

    GAMEPADS_ITENS=(GAMEPADS_RETURN_COL1 GAMEPADS_SELECT_GAMEPAD_COL1 GAMEPADS_LIST_COL1 GAMEPADS_RENAME_COL1
        GAMEPADS_DELETE_COL1 GAMEPADS_TAG_COL1 GAMEPADS_REGISTER_COL1 GAMEPADS_MENU_CLONE_COL1)
    padLanguageStrings GAMEPADS_ITENS "$GAMEPADS_COLUMN_SIZE"

    SETTINGS_ITENS=(SETTINGS_RETURN_COL1 SETTINGS_COLORS_COL1 SETTINGS_SCHEME_COLOR_STYLE_COL1 SETTINGS_LANGUAGE_COL1
        SETTINGS_CASE_COL1 SETTINGS_ACCENTS_COL1 SETTINGS_FONTSIZE_COL1 SETTINGS_LINES_MENU_COL1 SETTINGS_TIPS_COL1
        SETTINGS_ADVANCED_COL1)
    padLanguageStrings SETTINGS_ITENS "$SETTINGS_MENU_COLUMN_SIZE"

    ADVANCED_SETTINGS_ITENS=(ADVANCED_SETTINGS_RETURN_COL1 ADVANCED_SETTINGS_DELETE_COL1 ADVANCED_SETTINGS_RESET_COL1
        ADVANCED_SETTINGS_BACKUP_COL1 ADVANCED_SETTINGS_UNINSTALL_COL1)
    padLanguageStrings ADVANCED_SETTINGS_ITENS "$ADVANCED_SETTINGS_COLUMN_SIZE"

    DELETE_MAPS_ITENS=(MENU_DELETE_EXIT_COL1 MENU_DELETE_V3_COL1 MENU_DELETE_V1_JK_COL1)
    padLanguageStrings DELETE_MAPS_ITENS "$MENU_DELETE_MAPS_COLUMN_SIZE"

    BACKUP_ITENS=(BACKUP_EXIT_COL1 BACKUP_SAVE_COL1 BACKUP_RESTORE_COL1 BACKUP_DELETE_COL1)
    padLanguageStrings BACKUP_ITENS "$BACKUP_COLUMN_SIZE"

    CORE_MAIN_ITENS=(CORE_EXIT_COL1 CORE_LOAD_COL1 CORE_VIEW_LAYOUTS_COL1 CORE_VIEW_GAMES_COL1 CORE_SAVE_COL1
        CORE_EDIT_LAYOUTS_COL1 CORE_EDIT_GAMES_COL1 CORE_MOVE_COL1 CORE_SWITCH_COL1 CORE_DELETE_COL1 CORE_OVERWRITE_COL1
        CORE_COPY_COL1 CORE_NOTES_COL1)
    padLanguageStrings CORE_MAIN_ITENS "$CORE_COLUMN_SIZE"

    SHOW_NOTES_ITENS=(SHOW_NOTES_EXIT_COL1 SHOW_NOTES_READ_COL1 SHOW_NOTES_EDIT_COL1)
    padLanguageStrings SHOW_NOTES_ITENS "$SHOW_NOTES_COLUMN_SIZE"
}

# === first run

### firstRun - Script executed on first launch to select language and visual help option
firstRun() {
    local font_size
    local color_selected
    local restore_zip
    local restore_file
    local backup_file_found
    local backup_type
    local flag_backup_canceled

    GENERATE_FILES="OFF"

    MODEL_CUT="First Run"

    # Set initial tips flags
    setFlags() {
        sed -i "s/^tips=[^ ]*/tips=$TIPS_STATUS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_help=[^ ]*/tip_help=$TIPS_STATUS/" "$GCM_INI" 2>/dev/null
        FLAG_SHOW_TIPS="$TIPS_STATUS"
    }

    # Set language
    generateHeader "$LANGUAGE_MENU" 10 35 3

    DIALOG+="
- \"$EN\" \
P \"$PT\" \
S \"$ES\""

    runDialog

    case $CHOICE in
    "P")
        sed -i "s/^language=[^ ]*/language=pt/" "$GCM_INI" 2>/dev/null
        updateLanguageFirstRun
        ;;
    "S")
        sed -i "s/^language=[^ ]*/language=es/" "$GCM_INI" 2>/dev/null
        updateLanguageFirstRun
        ;;
    esac

    # Set text case
    generateHeader "$TEXT_CASE_MENU" 9 67 2

    DIALOG+="
N \"$TEXT_NORMAL\" \
- \"$TEXT_UPPERCASE\""

    runDialog

    case "$CHOICE" in
    "N")
        sed -i "s/^case=[^ ]*/case=NORMAL/" "$GCM_INI" 2>/dev/null
        updateLanguageFirstRun
        ;;
    esac

    if [ "$LANGUAGE" = "pt" ] || [ "$LANGUAGE" = "es" ]; then
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$TEXT_QUESTION_ACCENTS")

        if ! toggleYesNoDialog; then
            sed -i "s/^accents=[^ ]*/accents=ON/" "$GCM_INI" 2>/dev/null
            updateLanguageFirstRun
        fi
    fi

    if [ "$GENERATE_FILES" = "ON" ]; then
        generateFilesFirstRun
    fi

    # Set font size
    chooseFontsize() {
        local font_size

        while true; do
            generateHeader "$FONT_SIZE_MENU" 13 67 6

            DIALOG+="
X \"$FIRST_RUN_EXIT_FONT_SIZE\" \\
- \"$FIRST_RUN_SEPARATOR_FONT_SIZE\" \\
S \"$FONT_SIZE_SMALL\" \\
M \"$FONT_SIZE_MEDIUM\" \\
B \"$FONT_SIZE_LARGE\" \\
H \"$FONT_SIZE_EXTRA_LARGE\""

            runDialog

            case "$CHOICE" in
            X)
                return
                ;;
            -)
                continue
                ;;
            S)
                font_size="SMALL"
                ;;
            M)
                font_size="MEDIUM"
                ;;
            B)
                font_size="LARGE"
                ;;
            H)
                font_size="EXTRA_LARGE"
                ;;
            esac

            setFontSize "$font_size"
            testFontSizeScreen
            confirmFontSize "$font_size"
        done
    }

    chooseFontsize

    # set color scheme
    set_color_scheme() {
        local color_selected

        while true; do
            generateHeader "$COLORS_MENU" 26 67 19

            DIALOG+="
X \"$FIRST_RUN_EXIT_COLORS\" \
- \"$FIRST_RUN_SEPARATOR_COLORS\" \
B \"$COLOR_BLUE\" \
C \"$COLOR_CYAN\" \
G \"$COLOR_GREEN\" \
Y \"$COLOR_YELLOW\" \
M \"$COLOR_MAGENTA\" \
R \"$COLOR_RED\" \
W \"$COLOR_BLACK_WHITE\" \
- \"$FIRST_RUN_SEPARATOR_COLORS\" \
L \"$COLOR_NEON_BLUE\" \
A \"$COLOR_NEON_CYAN\" \
E \"$COLOR_NEON_GREEN\" \
O \"$COLOR_NEON_YELLOW\" \
N \"$COLOR_NEON_MAGENTA\" \
D \"$COLOR_NEON_RED\" \
H \"$COLOR_NEON_WHITE\" \
- \"$FIRST_RUN_SEPARATOR_COLORS\" \
F \"$COLOR_DEFAULT\""

            runDialog

            case "$CHOICE" in
            X)
                return
                ;;
            -)
                continue
                ;;
            "B" | "C" | "G" | "Y" | "M" | "R" | "W" | "L" | "A" | "E" | "O" | "N" | "D" | "H" | "F")

                case "$CHOICE" in
                "B")
                    color_selected="BLUE"
                    ;;
                "C")
                    color_selected="CYAN"
                    ;;
                "G")
                    color_selected="GREEN"
                    ;;
                "Y")
                    color_selected="YELLOW"
                    ;;
                "M")
                    color_selected="MAGENTA"
                    ;;
                "R")
                    color_selected="RED"
                    ;;
                "W")
                    color_selected="BLACK_WHITE"
                    ;;
                "L")
                    color_selected="NEON_BLUE"
                    ;;
                "A")
                    color_selected="NEON_CYAN"
                    ;;
                "E")
                    color_selected="NEON_GREEN"
                    ;;
                "O")
                    color_selected="NEON_YELLOW"
                    ;;
                "N")
                    color_selected="NEON_MAGENTA"
                    ;;
                "D")
                    color_selected="NEON_RED"
                    ;;
                "H")
                    color_selected="NEON_WHITE"
                    ;;
                "F")
                    color_selected="DEFAULT"
                    ;;
                esac

                applySelectedColorTheme "$color_selected"
                ;;
            esac
        done
    }

    set_color_scheme

    # set color scheme
    set_color_style() {
        local selected_color_style

        while true; do
            generateHeader "$COLORS_STYLE_MENU" 15 67 8

            DIALOG+="
X \"$FIRST_RUN_EXIT_COLOR_STYLE\" \
- \"$FIRST_RUN_SEPARATOR_STYLE\" \
1 \"$COLOR_STYLE_1\" \
2 \"$COLOR_STYLE_2\" \
3 \"$COLOR_STYLE_3\" \
4 \"$COLOR_STYLE_4\" \
5 \"$COLOR_STYLE_5\" \
6 \"$COLOR_STYLE_6\""

            runDialog

            case "$CHOICE" in
            "X")
                return
                ;;
            "-")
                continue
                ;;
            *)
                selected_color_style="$CHOICE"
                applySelectedColorStyle "$selected_color_style"
                ;;
            esac
        done
    }

    if [ "$SCHEME" != "DEFAULT" ]; then
        set_color_style
    fi

    # set tips in menus
    TIPS_MENU="${FIRST_RUN_TIPS}${TIPS_MENU}"
    generateHeader "$TIPS_MENU" 13 35 2

    DIALOG+="
A \"$ACTIVE_TIPS\" \
D \"$DEACTIVE_TIPS\""

    runDialog

    case "$CHOICE" in
    "A")
        TIPS_STATUS="ON"
        setFlags
        ;;
    "D")
        TIPS_STATUS="OFF"
        setFlags
        ;;
    esac

    # Ask to restore if backup file exists
    restore_zip=$(find "$MISTER_ROOT" -maxdepth 1 -name "Backup-GCM-MiSTer-*.zip" -print -quit)
    restore_file=$(basename "$restore_zip")

    if [ "$restore_file" != "" ]; then
        backup_file_found=1

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$FIRST_RUN_RESTORE_1")

        if ! toggleYesNoDialog; then
            if [[ "$restore_zip" == *full-* ]]; then
                TITLE=("$CONFIRMATION")
                MESSAGE_LN1=("$FIRST_RUN_RESTORE_2")

                if ! toggleYesNoDialog; then
                    backup_type="FULL"
                else
                    flag_backup_canceled=1
                fi
            else
                backup_type="GCM"
            fi
        else
            flag_backup_canceled=1
        fi

        if [ "$flag_backup_canceled" -eq 1 ]; then
            TITLE=("$CANCELED")
            MESSAGE_LN1=("$RESTORE_BACKUP_CANCELED")
            showDialogMessage
        else
            restoreBackupFiles "$restore_zip" "$backup_type"

            TITLE=("$DONE")
            MESSAGE_LN1=("$RESTORE_BACKUP_COMPLETED_1" "$restore_file")
            MESSAGE_LN2=("$RESTORE_BACKUP_COMPLETED_2")
            showDialogMessage
        fi
    fi

    # Ask to read the help
    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$FIRST_RUN_READ_HELP")

    if yesNoDialog; then
        if [ -f "${GCM_DAT}/HELP.txt" ]; then
            sed -i "s/^tip_help=[^ ]*/tip_help=OFF/" "$GCM_INI" 2>/dev/null
            FLAG_SHOW_TIP_HELP="OFF" # Disable FLAG_SHOW_TIP_HELP (ON / OFF)
            dialog --exit-label "$EXIT" --title "$SLOGAN" --textbox "${GCM_DAT}/HELP.txt" 26 72
        fi
    fi

    MODEL_CUT=""

    STATE="SCRIPT_INIT"
    return
}

# =============================================== #
# === MENU_FUNCTIONS - Functions for script menus #                                               #
# =============================================== #

# === menuHome - Main menu for all other menus
menuHome() {
    local lines_value

    FLAG_SLOT_CURRENT_CHECK="ON"   # Check CURRENT on first CORE open
    FLAG_COUNTER_SLOTS="ON"        # Enable slot count in countSlots (ON / OFF)
    FLAG_GAMEPAD_SHOW_MESSAGE="ON" # Enable message after gamepad selection (ON / OFF)
    GAMEPAD_DIR="${GCM_GPD}/${ID}" # Gamepad directory path

    verifyGamepadDir
    counterCores
    verifyTipsFlagsHome

    lines_value=23

    if [ "$SHOW_TIPS_MESSAGE_HOME" = "ON" ] && [ "$FLAG_SHOW_TIPS" = "ON" ]; then
        ((lines_value++))
    fi

    generateHeader "$HOME_MENU" "$lines_value" 67 16

    DIALOG+="
X \"$HOME_EXIT_COL1 - ${HOME_EXIT_COL2}${HOME_EXIT_INDICATOR}\" \
- \"$HOME_SEPARATOR\" \
L \"$HOME_CORES_LIST_COL1 - $HOME_CORES_LIST_COL2\" \
- \"$HOME_SEPARATOR\" \
A \"$HOME_ADD_COL1 - ${HOME_ADD_COL2}${HOME_ADD_INDICATOR}\" \
V \"$HOME_VIEW_NAMES_COL1 - $HOME_VIEW_NAMES_COL2\" \
N \"$HOME_RENAME_CORE_COL1 - $HOME_RENAME_CORE_COL2\" \
E \"$HOME_DELETE_COL1 - $HOME_DELETE_COL2\" \
- \"$HOME_SEPARATOR\" \
G \"$HOME_GAMEPADS_COL1 - ${HOME_GAMEPADS_COL2}${HOME_GAMEPAD_INDICATOR}\" \
- \"$HOME_SEPARATOR\" \
C \"$HOME_SETTINGS_COL1 - $HOME_SETTINGS_COL2\" \
- \"$HOME_SEPARATOR\" \
H \"$HOME_HELP_COL1 - ${HOME_HELP_COL2}${HOME_HELP_INDICATOR}\" \
- \"$HOME_SEPARATOR_2\" \
- \"${HOME_SPACES}GAMEPADS:$COUNTER_GAMEPADS / CORES:$COUNTER_CORES\""

    if [ "$SHOW_TIPS_MESSAGE_HOME" = "ON" ]; then
        DIALOG+=" \
- \"${TIP_FOOTER_HOME}: ${FOOTER_MESSAGE_HOME}\""
    fi

    runDialog CORE_CHOICE

    case "$CHOICE" in
    "X")
        STATE="EXIT_SCRIPT"
        STATE_ARG=""
        ;;
    "-")
        STATE="MENU_HOME"
        ;;
    "L")
        STATE="MENU_CORES_LIST"
        STATE_ARG=""
        ;;
    "A")
        STATE="MENU_ADD_CORE"
        ;;
    "V")
        STATE="MENU_VIEW_NAMES"
        ;;
    "N")
        STATE="MENU_RENAME_CORE"
        ;;
    "E")
        STATE="MENU_DELETE_CORE"
        ;;
    "G")
        STATE="MENU_GAMEPADS"
        ;;
    "C")
        STATE="MENU_SETTINGS"
        ;;
    "H")
        STATE="MENU_HELP"
        ;;
    esac

    return
}

### menuCoresList - List all CORES added to the script
menuCoresList() {
    local return_option
    local decrease_value
    local message_dialog
    local size_window
    local total_lines

    # ARGUMENTS:
    return_option="$1"

    if ! checkGamepads; then
        return 1
    fi

    if ! checkCounterCores; then
        return 1
    fi

    if [ "$return_option" = "DELETE_MAPS" ]; then
        decrease_value=2
        message_dialog="$MENU_DELETE_MAPS_CHOOSE_CORE"
    else
        decrease_value=0
        message_dialog="$LIST_CORES_MENU"
    fi

    generateCoresData

    size_window=$((LINES_MENU - 7))
    total_lines=$((LINES_MENU - decrease_value))
    generateHeader "$message_dialog" "$total_lines" 67 "$size_window"

    if [ "$return_option" != "DELETE_MAPS" ]; then
        DIALOG+="
X \"$LIST_CORES_EXIT\" \\
- \"$LIST_CORES_SEPARATOR\" \\"
    fi

    generateMenuLines LINES_CORES COUNTER_CORES
    runDialog CORE_CHOICE

    if [ "$return_option" = "DELETE_MAPS" ]; then
        return
    fi

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_CORES_LIST"
        STATE_ARG=""
        ;;
    *)
        STATE="MENU_CORE_MAIN"
        ;;
    esac

    return
}

### menuAddCore - Add a new CORE
menuAddCore() {
    if ! checkGamepads; then
        return
    fi

    generateHeader "$ADD_CORE_SELECTION" 14 67 7

    DIALOG+="
X \"$ADD_CORE_EXIT_COL1 - $ADD_CORE_EXIT_COL2\" \
- \"$ADD_CORE_SEPARATOR\" \
L \"$ADD_CORE_FROM_LIST_COL1 - $ADD_CORE_FROM_LIST_COL2\" \
- \"$ADD_CORE_SEPARATOR\" \
T \"$ADD_CORE_FROM_TYPE_COL1 - $ADD_CORE_FROM_TYPE_COL2\" \
F \"$ADD_CORE_FOLDERS_COL1 - $ADD_CORE_FOLDERS_COL2\" \
V \"$ADD_CORE_LIST_COL1 - $ADD_CORE_LIST_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_ADD_CORE"
        ;;
    "L")
        STATE="MENU_ADD_CORE_FROM_LIST"
        ;;
    "T")
        STATE="MENU_ADD_CORE_FROM_TYPE"
        ;;
    "F")
        STATE="CONFIGURE_EXPERT_MODE"
        ;;
    "V")
        STATE="VIEW_CORES_LIST"
        ;;
    esac

    return
}

### addCoreFromList - Add cores from the list of pre-configured gamepad configurations
addCoreFromList() {
    local total_lines
    local core

    messageProcessingWait

    find "$INPUT_MISTER" -maxdepth 1 -type f -name "*_input_${ID}*.map" \
        -printf "%f\n" 2>/dev/null |
        sed "s/_\(advanced_\)\?input_${ID}.*//" |
        sort -u >"$TMP_FILE"

    total_lines=$(wc -l <"$TMP_FILE")

    if [ "$total_lines" -eq 0 ]; then
        alertMiSTerNoMaps
        STATE="MENU_ADD_CORE"
        return
    fi

    while read -r core; do
        if [ ! -d "${GAMEPAD_DIR}/${core}" ]; then
            echo "$core"
        fi
    done <"$TMP_FILE" >"${TMP_FILE}.2"

    mv "${TMP_FILE}.2" "$TMP_FILE" 2>/dev/null

    PARAM_3=$(wc -l <"$TMP_FILE")

    if [ "$PARAM_3" -eq 0 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$ADD_ALL_ADDED")
        showDialogMessage

        STATE="MENU_ADD_CORE"
        return
    fi

    LINES_MENU=$((PARAM_3 + 7))
    adjustLinesMenuSize

    generateHeader "$ADD_CONFIGURED" "$LINES_MENU" 67 "$PARAM_3" SHOW_CANCELL_BUTTON

    generateLinesArray "$TMP_FILE"
    rm -f "$TMP_FILE" 2 >/dev/null

    generateMenuLines LINES_ARRAY COUNTER_LINES CUT_OUTPUT NEW_LINE

    if ! runDialog; then
        showCancelMessage "$ADD_CANCELED"
    else
        CORE_CHOICE="${LINES_ARRAY[((CHOICE - 1))]}"
        addCoreChoice
    fi

    STATE="MENU_ADD_CORE"
    return
}

### addCoreFromType - Add CORES by typing their name
addCoreFromType() {
    while true; do
        TITLE=("%s" "$ADD_CORE")
        MESSAGE_LN1=("%s" "$INSERT_CORE_NAME")

        if ! inputDialog; then
            showCancelMessage "$ADD_CANCELED"

            STATE="MENU_ADD_CORE"
            return
        fi

        CORE_CHOICE="$TMP_INPUT"

        if [ -z "$CORE_CHOICE" ]; then
            showNoInputMessage
            continue
        fi

        break
    done

    messageProcessingWait

    STATE="MENU_ADD_CORE"

    if checkTypedCore; then
        addCoreChoice
    fi

    return
}

### configureExpertMode - Configure folders used to search for CORES in Expert Mode
configureExpertMode() {
    local lines
    local window
    local itens
    local dir
    local folders

    lines=7
    window=0
    folders=()

    for dir in "$MISTER_CORES_FOLDERS"/_*; do
        if [ -d "$dir" ]; then
            addExpertModeFolder "$dir"
        fi
    done

    DIALOG=$(
        dialog --stdout \
            --separate-output \
            --title "$CONFIGURE_EXPERT_MODE_TITLE" \
            --checklist "$CONFIGURE_EXPERT_MODE_CHECKLIST" \
            $lines 67 $window \
            "${folders[@]}"
    )

    if [ -z "$DIALOG" ]; then
        STATE="MENU_ADD_CORE"
        return
    fi

    echo -n "" >"${GCM_CFG}/folders_tmp.cfg"

    while IFS= read -r item; do
        echo "$item" >>"${GCM_CFG}/folders_tmp.cfg" 2>/dev/null
    done <<<"$DIALOG"

    if grep -Fqx "Arcade" "${GCM_CFG}/folders_tmp.cfg" ||
        grep -Fqx "#Insert-Coin" "${GCM_CFG}/folders_tmp.cfg"; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$CONFIGURE_EXPERT_ALERT_ARCADE_1")
        MESSAGE_LN2=("$CONFIGURE_EXPERT_ALERT_ARCADE_2")
        showDialogMessage

        STATE="CONFIGURE_EXPERT_MODE"
        return
    fi

    mv "${GCM_CFG}/folders_tmp.cfg" "${GCM_CFG}/folders.cfg"
    FLAG_GENERATE_CORES_LIST="ON"

    STATE="MENU_ADD_CORE"
    return
}

### viewCoresList - Show list of cores from configured folders
viewCoresList() {
    generateCoresList

    dialog --exit-label "$EXIT" --title "$VIEW_CORES_LIST" --textbox "${GCM_TMP}/cores_list" 28 51

    STATE="MENU_ADD_CORE"
    return
}

### menuRenameCore - Rename added CORES with custom names
menuRenameCore() {
    if ! checkGamepads; then
        return
    fi

    if ! checkCounterCores; then
        return
    fi

    generateHeader "$RENAME_CORE_MESSAGE" 11 67 4

    DIALOG+="
X \"$RENAME_CORE_EXIT_COL1 - $RENAME_CORE_EXIT_COL2\" \
- \"$RENAME_CORE_SEPARATOR\" \
T \"$RENAME_CORE_TYPE_COL1 - $RENAME_CORE_TYPE_COL2\" \
L \"$RENAME_CORE_LIST_COL1 - $RENAME_CORE_LIST_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_RENAME_CORE"
        ;;
    "T")
        STATE="MENU_TYPE_NAME"
        ;;
    "L")
        STATE="MENU_LIST_RENAMED"
        ;;
    esac

    return
}

### menuTypeName - Show a list of instaled CORES to renamed
menuTypeName() {
    local new_name_choice

    if ! checkGamepads; then
        return
    fi

    if ! checkCounterCores; then
        return
    fi

    generateCoresData

    PARAM_3=$((LINES_MENU - 7))
    generateHeader "$TYPE_CORE_MENU" NULL 60 "$PARAM_3"

    DIALOG+="
X \"$EXIT_MENU\" \\
- \"$SEPARATOR_DEFAULT\" \\"

    generateMenuLines LINES_CORES COUNTER_CORES
    runDialog CORE_CHOICE

    case "$CHOICE" in
    "X")
        STATE="MENU_RENAME_CORE"
        ;;
    "-")
        STATE="MENU_TYPE_NAME"
        ;;
    *)
        renameCoreDisplayIfNeeded "$CORE"

        inputCoreName() {
            while true; do
                TITLE=("$TYPE_CORE_RENAME")
                MESSAGE_LN1=("$TYPE_CORE_INPUT" "$CORE_DISPLAY")
                MESSAGE_LN2=("$TYPE_CORE_MAXIMUM")

                if ! inputDialog "$RENAME"; then
                    showCancelMessage "$TYPE_CORE_CANCELED"

                    return 1
                fi

                TMP_INPUT=$(printf '%s' "$TMP_INPUT" |
                    sed 's/"/'\''/g; s/`/'\''/g; s/\\/\//g' 2>/dev/null)
                new_name_choice="${TMP_INPUT//\"/}"

                if [ -z "$new_name_choice" ]; then
                    showNoInputMessage
                    continue

                elif [ "$new_name_choice" = "reset" ]; then
                    if [ "$CORE" != "$CORE_DISPLAY" ]; then
                        sed -i "/$CORE/d" "$GAMEPAD_DIR/rename.cfg" 2>/dev/null

                        TITLE=("$INFORMATION")
                        MESSAGE_LN1=("$TYPE_CORE_RESTORED" "$CORE")
                        showDialogMessage
                    else
                        TITLE=("$ATTENTION")
                        MESSAGE_LN1=("$TYPE_CORE_NO_RESET")
                        showDialogMessage
                    fi

                    return 1

                elif [ "$CORE_DISPLAY" = "$new_name_choice" ]; then
                    TITLE=("$ATTENTION")
                    MESSAGE_LN1=("$TYPE_CORE_SAME_NAME")
                    showDialogMessage

                    continue
                fi

                new_name_choice="${new_name_choice:0:25}"

                if echo "$new_name_choice" | grep -q "@@"; then
                    TITLE=("$ATTENTION")
                    MESSAGE_LN1=("$TYPE_CORE_INVALID_CHARS_COL1")
                    MESSAGE_LN2=("$TYPE_CORE_INVALID_CHARS_COL2")
                    showDialogMessage

                    continue
                fi

                break
            done
        }

        if ! inputCoreName; then
            STATE="MENU_RENAME_CORE"
            return
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$TYPE_CORE_QUESTION" "$CORE_DISPLAY" "$new_name_choice")

        if ! yesNoDialog; then
            showCancelMessage "$TYPE_CORE_CANCELED"

            STATE="MENU_TYPE_NAME"
            return
        fi

        if grep -q "^${CORE}@@" "$GAMEPAD_DIR/rename.cfg"; then
            sed -i "s|^${CORE}@@.*|${CORE}@@${new_name_choice}|" "$GAMEPAD_DIR/rename.cfg" 2>/dev/null
        else
            printf '%s@@%s\n' "$CORE" "$new_name_choice" >>"$GAMEPAD_DIR/rename.cfg"
        fi

        sort "$GAMEPAD_DIR/rename.cfg" >"$TMP_FILE"
        mv "$TMP_FILE" "$GAMEPAD_DIR/rename.cfg" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$TYPE_CORE_DONE" "$CORE_DISPLAY" "$new_name_choice")
        showDialogMessage
        ;;
    esac

    STATE="MENU_RENAME_CORE"
    return
}

### menuViewNames - Display list of cores from MiSTer (names.txt - Fix .mgl names)
menuViewNames() {
    local show_title
    local open_file
    local full_paths
    local item
    local check_cores
    local mem_msg
    local line
    local first_col
    local second_col
    local setname_found
    local dir
    local check_cores
    local filepath
    local len
    local pad

    if [ ! -f "${MISTER_ROOT}/names.txt" ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$VIEW_NAMES_MISSING_1")
        MESSAGE_LN2=("$VIEW_NAMES_MISSING_2")
        showDialogMessage

        STATE="MENU_HOME"
        return
    else
        messageProcessingWait

        cp "${MISTER_ROOT}/names.txt" "$TMP_FILE" 2>/dev/null
        full_paths=()

        for dir in "$MISTER_CORES_FOLDERS"/_*; do
            [[ -d "$dir" ]] || continue

            full_paths+=("$dir")
        done

        check_cores=("${full_paths[@]}")
        mem_msg="$VIEW_NAMES_CORES|$VIEW_NAMES_FILE"
        echo "$mem_msg" >"${TMP_FILE}.2"

        while IFS= read -r line; do
            first_col="${line%%:*}"
            second_col="${line:20}"
            setname_found=""

            for dir in "${check_cores[@]}"; do
                filepath="${dir}/${first_col}.mgl"

                if [ -f "$filepath" ]; then
                    setname_found=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath" 2>/dev/null)
                    break
                fi
            done

            if [ -n "$setname_found" ]; then
                first_col="$setname_found"
                len=${#first_col}
                pad=$((20 - len - 1))
                printf "%s:%*s%s\n" "$first_col" "$pad" "" "$second_col"
            else
                echo "$line"
            fi
        done <"$TMP_FILE" >>"${TMP_FILE}.2"

        mv "${TMP_FILE}.2" "${GCM_TMP}/cores_list_names" 2>/dev/null
        rm -f "${TMP_FILE}" 2>/dev/null
        open_file="${GCM_TMP}/cores_list_names"
        show_title="$VIEW_NAMES_MENU"
    fi

    dialog --exit-label "$EXIT" --title "$show_title" --textbox "$open_file" 28 51
    rm -f "${GCM_TMP}/cores_list_names"

    STATE="MENU_HOME"
    return
}

### menuListRenamed - Display all renamed CORES in 2 columns
menuListRenamed() {
    local rename_file
    local tmp_file
    local original
    local display_core

    if ! checkGamepads; then
        return
    fi

    if ! checkCounterCores; then
        return
    fi

    rename_file="$GAMEPAD_DIR/rename.cfg"
    tmp_file="$TMP_FILE"

    if [ ! -s "$rename_file" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$LIST_RENAMED_EMPTY")
        showDialogMessage

        STATE="MENU_RENAME_CORE"
        return
    fi

    while IFS= read -r line; do
        if [[ "$line" == *@@* ]]; then
            original="${line%%@@*}"
            display_core="${line#*@@}"
            printf "%-20s %s\n" "$original" "$display_core" >>"$tmp_file"
        fi
    done <"$rename_file"

    {
        echo "$LIST_RENAMED_HEADER"
        echo " "
        cat "${tmp_file}"
    } >"${tmp_file}.2" 2>/dev/null

    mv "${tmp_file}.2" "$tmp_file" 2>/dev/null
    dialog --exit-label "$EXIT" --title "$LIST_RENAMED_MENU" --textbox "$tmp_file" 28 51
    rm -f "$tmp_file" 2>/dev/null

    STATE="MENU_RENAME_CORE"
    return
}

### menuDeleteCore - Delete an existing CORE
menuDeleteCore() {
    if ! checkGamepads; then
        return
    fi

    if ! checkCounterCores; then
        return
    fi

    generateCoresData

    PARAM_3=$((LINES_MENU - 7))
    generateHeader "$DELETE_CORE_MENU" NULL 60 "$PARAM_3"

    DIALOG+="
X \"$DELETE_CORE_EXIT\" \\
- \"$DELETE_CORE_SEPARATOR\" \\"

    generateMenuLines LINES_CORES COUNTER_CORES
    runDialog CORE_CHOICE

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_DELETE_CORE"
        ;;
    *)
        CORE_DIR="${GAMEPAD_DIR}/${CORE}"
        CORE_DISPLAY=$(renameCoreIfNeeded "$CORE")

        deleteCoreFiles() {
            if [ -z "$CORE_DIR" ] || [ "$CORE_DIR" == "/" ]; then
                STATE="MENU_HOME"
                return
            fi

            sed -i "/^${CORE}@@/d" "${GAMEPAD_DIR}/rename.cfg" 2>/dev/null
            rm -rf "$CORE_DIR" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$DELETE_CORE_COMPLETED" "$CORE_DISPLAY")
            MESSAGE_LN2=("$DELETE_CORE_DELETED")
            showDialogMessage
        }

        saveCoreFiles() {
            mv "$CORE_DIR" "${CORE_DIR}-stored" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$DELETE_CORE_COMPLETED" "$CORE_DISPLAY")
            MESSAGE_LN2=("$DELETE_CORE_RETAINED")
            showDialogMessage
        }

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$DELETE_CORE_QUESTION" "$CORE_DISPLAY")

        if ! toggleYesNoDialog; then
            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$DELETE_CORE_SAVE_FILES" "$CORE_DISPLAY")

            if yesNoDialog; then
                saveCoreFiles
            else
                deleteCoreFiles
            fi
        else
            showCancelMessage "$DELETE_CORE_CANCELED"

            STATE="MENU_HOME"
            return
        fi

        ((COUNTER_CORES--))

        STATE="MENU_HOME"
        ;;
    esac

    return
}

### menuHelp - Show the script's help and usage instructions
menuHelp() {
    sed -i "s/^tip_help=[^ ]*/tip_help=OFF/" "$GCM_INI" 2>/dev/null
    FLAG_SHOW_TIP_HELP="OFF" # Disable FLAG_SHOW_TIP_HELP (ON / OFF)

    if [ -f "${GCM_DAT}/HELP.txt" ]; then
        dialog --exit-label "$EXIT" --title "$SLOGAN" --textbox "${GCM_DAT}/HELP.txt" 26 72
    fi

    STATE="MENU_HOME"
    return
}

# === menuGamepads - Manage gamepads
menuGamepads() {
    local lines_value

    if [ -z "$COUNTER_CORES" ]; then
        COUNTER_CORES=-1 # Disable tips flags - no selected gamepad
    fi

    verifyTipsFlagsHome

    lines_value=18

    if [ "$SHOW_TIPS_MESSAGE_HOME" = "ON" ] && [ "$MESSAGE_GAMEPADS" = "ON" ]; then
        lines_value=$((lines_value + 2))
    fi

    generateHeader "$GAMEPADS_MENU" "$lines_value" 67 11

    DIALOG+="
X \"$GAMEPADS_RETURN_COL1 - $GAMEPADS_RETURN_COL2\" \
- \"$GAMEPADS_MENU_SEPARATOR\" \
S \"$GAMEPADS_SELECT_GAMEPAD_COL1 - $GAMEPADS_SELECT_GAMEPAD_COL2\" \
- \"$GAMEPADS_MENU_SEPARATOR\" \
L \"$GAMEPADS_LIST_COL1 - $GAMEPADS_LIST_COL2\" \
N \"$GAMEPADS_RENAME_COL1 - $GAMEPADS_RENAME_COL2\" \
D \"$GAMEPADS_DELETE_COL1 - $GAMEPADS_DELETE_COL2\" \
T \"$GAMEPADS_TAG_COL1 - $GAMEPADS_TAG_COL2\" \
R \"$GAMEPADS_REGISTER_COL1 - ${GAMEPADS_REGISTER_COL2}${GAMEPADS_REGISTER_INDICATOR}\" \
- \"$GAMEPADS_MENU_SEPARATOR\" \\"

    if [ "$SHOW_TIPS_MESSAGE_HOME" = "ON" ] && [ "$MESSAGE_GAMEPADS" = "ON" ]; then
        DIALOG+="
C \"$GAMEPADS_MENU_CLONE_COL1 - $GAMEPADS_MENU_CLONE_COL2\" \
- \"$GAMEPADS_MENU_SEPARATOR_2\" \
- \" ${TIP_FOOTER}: ${FOOTER_MESSAGE_GAMEPADS}\""
    else
        DIALOG+="
C \"$GAMEPADS_MENU_CLONE_COL1 - $GAMEPADS_MENU_CLONE_COL2\""
    fi

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_GAMEPADS"
        ;;
    "S")
        STATE="MENU_SELECT_GAMEPAD"
        STATE_ARG="SHOW_CANCELL_BUTTON"
        ;;
    "L")
        STATE="MENU_LIST_GAMEPADS"
        ;;
    "N")
        STATE="MENU_RENAME_GAMEPAD"
        ;;
    "D")
        STATE="MENU_DELETE_GAMEPAD"
        ;;
    "T")
        STATE="MENU_SELECT_EDIT_TAG"
        STATE_ARG="$ID"
        STATE_ARG_2="change_tag"
        ;;
    "R")
        STATE="MENU_REGISTER_GAMEPAD"
        ;;
    "C")
        STATE="MENU_CLONE_GAMEPAD"
        ;;
    esac

    return
}

### menuSelectGamepad - Select default gamepad
menuSelectGamepad() {
    local additional_option
    local test_id

    # ARGUMENTS:
    additional_option="$1"

    # RESET MAIN ARGUMENTS:
    STATE_ARG=""

    if ! checkRegisteredGamepads; then
        return
    fi

    test_id="$ID"

    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        STATE="MENU_GAMEPADS"
        return
    fi

    if [ "$COUNTER_GAMEPADS" -eq 1 ] && [ "$ID" != "" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$SELECT_GAMEPAD_ONLY_ONE")
        MESSAGE_LN2=("$MODEL_CUT - $ID")
        showDialogMessage

        STATE="MENU_GAMEPADS"
        return
    fi

    if ! prepareGamepadMenu "$DISPLAY_MESSAGE_GAMEPAD"; then
        return
    fi

    DISPLAY_MESSAGE_GAMEPAD="$SELECT_GAMEPAD_DEFAULT" # Reset to default message

    generateHeader "$MESSAGE_MENU" "$additional_option"

    generateMenuLines LINES_ARRAY COUNTER_LINES CUT_OUTPUT NEWLINE
    if ! runDialogRegisteredGamepads LOAD_GAMEPAD SKIP_IF_FIRST; then
        return
    fi

    recordGamepadData
    importSelectedGamepadData

    if [ "$FLAG_GAMEPAD_SHOW_MESSAGE" = "ON" ] &&
        { { [ "$CHOICE" -eq 1 ] && [ "$test_id" = "" ]; } || [ "$CHOICE" -gt 1 ]; }; then

        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$SELECT_GAMEPAD_NEW")
        MESSAGE_LN2=("$MODEL_CHOICE - $ID_CHOICE")
        showDialogMessage
    fi

    FLAG_GAMEPAD_SHOW_MESSAGE="ON"
    FLAG_COUNTER_CORES="ON"
    STATE="MENU_HOME"
    return
}

### menuListGamepads - Display registered gamepads
menuListGamepads() {
    local return_mode

    # ARGUMENTS:
    return_mode="$1"

    if ! checkRegisteredGamepads; then
        return
    fi

    LINES_MENU=$((COUNTER_GAMEPADS + 8))
    adjustLinesMenuSize

    {
        echo ""
        echo "-- ID: --   --- MODEL: ---"
        echo ""
        cat "$GCM_RGP"
    } >"$TMP_MENU" 2>/dev/null

    dialog --exit-label "$EXIT" --title "$SLOGAN - $MODEL_CUT" --textbox "$TMP_MENU" "$LINES_MENU" 72
    rm -f "$TMP_MENU" 2>/dev/null

    if [ "$return_mode" != "RETURN" ]; then
        STATE="MENU_GAMEPADS"
        return 1
    fi
}

### menuRenameGamepad - Rename a registered gamepad
menuRenameGamepad() {
    local new_name_choice
    local replace_string_1
    local id_choice_list
    local replace_string_2

    if ! checkRegisteredGamepads; then
        return
    fi

    if ! prepareGamepadMenu "$RENAME_GAMEPAD_MENU" ADD_LINES; then
        return
    fi

    generateHeader "$MESSAGE_MENU"

    # ADD_LINES argument on prepareGamepadMenu - adds 2 lines to the DIALOG
    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"$SEPARATOR_DEFAULT\" \\"

    generateMenuLines LINES_ARRAY COUNTER_LINES CUT_OUTPUT NEWLINE
    runDialogRegisteredGamepads

    case "$CHOICE" in
    "X")
        rm -f "$TMP_IDS" 2>/dev/null
        STATE="MENU_GAMEPADS"
        ;;
    "-")
        STATE="MENU_RENAME_GAMEPAD"
        ;;
    *)
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$RENAME_GAMEPAD_QUESTION_1")
        MESSAGE_LN2=("$RENAME_GAMEPAD_QUESTION_2" "$ID_CHOICE" "$MODEL_CHOICE")

        if ! yesNoDialog; then
            showCancelMessage "$RENAME_GAMEPAD_CANCELED"

            STATE="MENU_GAMEPADS"
            return
        fi

        inputGamepadName() {
            while true; do
                TITLE=("$RENAME_GAMEPAD_TITLE")
                MESSAGE_LN1=("$RENAME_GAMEPAD_INPUT_1")
                MESSAGE_LN2=("$RENAME_GAMEPAD_INPUT_2" "$MODEL_CHOICE")

                if ! inputDialog "$RENAME"; then
                    showCancelMessage "$RENAME_GAMEPAD_CANCELED"

                    STATE="MENU_GAMEPADS"
                    return 1
                fi

                if [ -z "$TMP_INPUT" ]; then
                    showNoInputMessage
                    continue
                fi

                break
            done

            return
        }

        if ! inputGamepadName; then
            return
        fi

        TMP_INPUT=$(printf '%s' "$TMP_INPUT" |
            sed 's/"/'\''/g; s/`/'\''/g; s/\\/\//g' 2>/dev/null)
        new_name_choice="${TMP_INPUT//\"/}"

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$YOU_TYPED" "$new_name_choice")
        MESSAGE_LN2=("$RENAME_GAMEPAD_CONFIRMATION")

        if ! yesNoDialog; then
            showCancelMessage "$RENAME_GAMEPAD_CANCELED"

            STATE="MENU_GAMEPADS"
            return
        fi

        replace_string_1=$(printf "%s - %s" "$ID_CHOICE" "$new_name_choice")
        id_choice_list=${ID_CHOICE/_/:}
        replace_string_2=$(printf "(\"%s\" \"%s\")" "$id_choice_list" "$new_name_choice")
        sed -i "/$ID_CHOICE/c\\$replace_string_1" "$GCM_RGP" 2>/dev/null
        sed -i "/$id_choice_list/c\\$replace_string_2" "$GCM_LGI" 2>/dev/null
        organizeGamepadIds

        if [ "$CHOICE" = "1" ]; then
            {
                echo "ID=\"$ID_CHOICE\""
                echo "MODEL=\"$new_name_choice\""
            } >"$GCM_SGP" 2>/dev/null
        fi

        importSelectedGamepadData

        TITLE=("$DONE")
        MESSAGE_LN1=("$RENAME_GAMEPAD_COMPLETED")
        showDialogMessage

        showUpdateList "$COUNTER_GAMEPADS"
        ;;
    esac

    return
}

### menuDeleteGamepad - Delete a registered gamepad
menuDeleteGamepad() {
    local gamepad_choice
    local delete_files
    local current_id

    if ! checkRegisteredGamepads; then
        return
    fi

    if ! prepareGamepadMenu "$DELETE_GAMEPAD_MENU" ADDLINES; then
        return
    fi

    generateHeader "$MESSAGE_MENU"

    # ADD_LINES argument on prepareGamepadMenu - adds 2 lines to the DIALOG
    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"$SEPARATOR_DEFAULT\" \\"

    generateMenuLines LINES_ARRAY COUNTER_LINES CUT_OUTPUT NEWLINE
    runDialogRegisteredGamepads

    case "$CHOICE" in
    "X")
        rm -f "$TMP_IDS" 2>/dev/null
        STATE="MENU_GAMEPADS"
        ;;
    "-")
        STATE="MENU_DELETE_GAMEPAD"
        ;;
    *)
        gamepad_choice=${LINES_ARRAY[$((CHOICE - 1))]}
        ID_CHOICE=$(echo "$gamepad_choice" | cut -c1-9 2>/dev/null)

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$DELETE_GAMEPAD_QUESTION_1")
        MESSAGE_LN2=("$DELETE_GAMEPAD_QUESTION_2" "$gamepad_choice")

        if toggleYesNoDialog; then
            showCancelMessage "$DELETE_GAMEPAD_CANCELED"

            STATE="MENU_GAMEPADS"
            return
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$DELETE_GAMEPAD_KEEP_1")
        MESSAGE_LN2=("$DELETE_GAMEPAD_KEEP_2")

        if ! yesNoDialog; then
            delete_files=1
        else
            delete_files=0
        fi

        source "$GCM_SGP"
        current_id="$ID"
        sed -i "/$ID_CHOICE/d" "$GCM_RGP" 2>/dev/null

        if [ "$current_id" = "$ID_CHOICE" ]; then
            ID=""
            if grep -q "_" "$GCM_RGP"; then
                MODEL="$SELECT_A_GAMEPAD"
            else
                MODEL="$NO_GAMEPAD"
            fi
        fi

        {
            echo "ID=\"$ID\""
            echo "MODEL=\"$MODEL\""
        } >"$GCM_SGP" 2>/dev/null

        importSelectedGamepadData

        if [ "$delete_files" -eq 1 ]; then
            if [ -z "$GCM_DIR" ] || [ "$GCM_DIR" == "/" ] || [ -z "$ID_CHOICE" ]; then
                STATE="MENU_GAMEPADS"
                return
            fi

            rm -rf "${GCM_GPD}/${ID_CHOICE}" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$DELETE_GAMEPAD_COMPLETED")
            MESSAGE_LN2=("$DELETE_GAMEPAD_DELETED")
            showDialogMessage
        else
            mv "${GCM_GPD}/${ID_CHOICE}" "${GCM_GPD}/${ID_CHOICE}-stored" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$DELETE_GAMEPAD_COMPLETED")
            MESSAGE_LN2=("$DELETE_GAMEPAD_PRESERVED")
            showDialogMessage

            TITLE=("$INFORMATION")
            MESSAGE_LN1=("$DELETE_GAMEPAD_INFO")
            showDialogMessage
        fi

        ((COUNTER_GAMEPADS--))
        showUpdateList "$COUNTER_GAMEPADS"
        ;;
    esac

    return
}

### menuSelectEditTag - Select or edit gamepad layout tag
menuSelectEditTag() {
    local spaces_block_width
    local spaces_block
    local id_gamepad
    local option
    local lines_menu
    local param_3
    local i
    local layout_tag
    local layout_tag_output
    local layout_name
    local layout_name_output
    local total_spaces
    local left_spaces
    local right_spaces
    local current_tag
    local select_tag_dialog
    local size
    local spaces
    local string_spaces

    if ! checkRegisteredGamepads; then
        return
    fi

    spaces_block_width=58
    spaces_block=$(printf '%*s' "$spaces_block_width" '')

    # ARGUMENTS:
    id_gamepad="$1"
    option="$2"

    # RESET MAIN ARGUMENTS:
    STATE_ARG=""
    STATE_ARG_2=""

    if [ "$option" = "change_tag" ] && [ "$id_gamepad" = "" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$SELECT_TAG_NO_GAMEPAD")
        showDialogMessage

        STATE="MENU_GAMEPADS"
        return
    fi

    if [ "$option" = "change_tag" ]; then
        lines_menu=28
        param_3=21
    else
        lines_menu=26
        param_3=19
    fi

    while true; do
        {
            echo "#!/bin/bash"
            echo "TMP_MENU=$TMP_MENU"
            echo "TITLE_FORMATTED=\"$(printf "%s" "$SELECT_GAMEPAD_TAG $MODEL_CUT")\""
            echo "message=\"$(printf " %s" "$SELECT_TAG_MESSAGE")\""
            echo "dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear --no-tags \\"
            echo "--title \"\$TITLE_FORMATTED\" \\"
            echo "--menu \"\$message\" $lines_menu 65 $param_3 \\"
        } >"${TMP_MENU}.sh"

        for ((i = 1; i <= 9; i++)); do
            layout_tag="LAYOUT_TAGS[$i]"
            layout_tag_output="${!layout_tag}"
            layout_name="LAYOUT_NAMES[$i]"
            layout_name_output="${!layout_name}"

            if [ "${#layout_name_output}" -lt 11 ]; then
                total_spaces=$((11 - ${#layout_name_output}))
                left_spaces=$((total_spaces / 2))
                right_spaces=$((total_spaces - left_spaces))

                layout_name_output="$(printf "%*s%s%*s" \
                    "$left_spaces" "" \
                    "$layout_name_output" \
                    "$right_spaces" "")"
            fi

            echo " $i \"[$layout_name_output]  $i) $layout_tag_output\" \\" >>"${TMP_MENU}.sh"
            echo "- \"$spaces_block\" \\" >>"${TMP_MENU}.sh"
        done

        echo "10 \"              10) $SELECT_TAG_CUSTOM\" \\" >>"${TMP_MENU}.sh"

        if [ "$option" = "change_tag" ]; then
            echo "- \"$spaces_block\" \\" >>"${TMP_MENU}.sh"
            echo "11 \"              11) $SELECT_TAG_EDIT_CURRENT\" \\" >>"${TMP_MENU}.sh"
        fi

        echo "2>\"\$TMP_MENU\"" >>"${TMP_MENU}.sh" 2>/dev/null
        source "${TMP_MENU}.sh"
        MENU_STATUS="$?"
        CHOICE=$(<"$TMP_MENU")
        rm -f "${TMP_MENU}.sh" 2>/dev/null
        rm -f "$TMP_MENU" 2>/dev/null

        if [ "$MENU_STATUS" -eq 1 ]; then
            STATE="MENU_GAMEPADS"
            break
        fi

        if [ "$CHOICE" = "-" ]; then
            break
        fi

        if [ "$CHOICE" = "11" ]; then
            current_tag=$(cat "${GCM_GPD}/${id_gamepad}/gamepad_tag.txt")
        else
            current_tag="← ↓ ↑ →  ■ ✖ ● ▲ ← ↓ ↑ →  ■ ✖ ● ▲  ← ↓ ↑ →"
        fi

        if [ "$CHOICE" -ge 10 ]; then
            {
                echo "$current_tag"
                echo "|------------- 42 $SELECT_TAG_LINE_1 ------------|"
                echo ""
            } >"$TMP_TAG"

            if [ "$CHOICE" -eq 10 ]; then
                {
                    SELECT_TAG_EDIT="$SELECT_TAG_EDIT_MENU_CUSTOM"
                    echo "$SELECT_TAG_LINE_2"
                    echo "$SELECT_TAG_LINE_3"
                    echo ""
                } >>"$TMP_TAG"
            else
                SELECT_TAG_EDIT="$SELECT_TAG_EDIT_MENU_CURRENT"
            fi

            {
                echo "$SELECT_TAG_LINE_4"
                echo "$SELECT_TAG_LINE_5"
            } >>"$TMP_TAG"
            if dialog --ok-label "$OK" --cancel-label "$RESET" --title "$SELECT_TAG_EDIT" --editbox "$TMP_TAG" 20 49 \
                2>"${TMP_TAG}.2"; then
                sed -i '1s/^\(.\{39\}\).*/\1/' "${TMP_TAG}.2" 2>/dev/null && sed -i '2,$d' "${TMP_TAG}.2" 2>/dev/null
                LAYOUT_TAG=$(cat "${TMP_TAG}.2")
                rm -f "$TMP_TAG" "${TMP_TAG}.2"
                select_tag_dialog="$SELECT_TAG_QUESTION_CUSTOM"
            else
                continue
            fi
        else
            select_tag_dialog="$SELECT_TAG_QUESTION"
            LAYOUT_TAG="${LAYOUT_TAGS[$CHOICE]}"
        fi

        size=${#LAYOUT_TAG}

        if [ "$size" -lt 39 ]; then
            spaces=$((39 - size))
            string_spaces=$(printf "%${spaces}s" "")
            LAYOUT_TAG="${LAYOUT_TAG}${string_spaces}"
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$select_tag_dialog")
        MESSAGE_LN2=("'%s'" "$LAYOUT_TAG")

        if ! yesNoDialog; then
            break
        fi

        echo "$LAYOUT_TAG" >"${GCM_GPD}/${id_gamepad}/gamepad_tag.txt"

        if [ "$option" = "change_tag" ]; then
            TITLE=("$INFORMATION")
            MESSAGE_LN1=("$SELECT_TAG_EDIT_SUCCESSFULLY")
            showDialogMessage
            STATE="MENU_GAMEPADS"
        fi

        return
    done

    return 1
}

### menuRegisterGamepad - Register a new gamepad
menuRegisterGamepad() {
    local found_gamepads
    local joystick
    local id
    local ids_list
    local model
    local indice
    local print_indice
    local i
    local output
    local search
    local name
    local new_gamepad_id
    local id_choice_list

    if [ -z "$(ls "${INPUT_MISTER}"/input*.map 2>/dev/null)" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_NO")
        showDialogMessage

        NO_MISTER_GAMEPAD="ON"
        STATE="EXIT_SCRIPT"
        STATE_ARG="NO_GAMEPAD"
        return
    fi

    messageProcessingWait

    echo -n "" >"$TMP_IDS" 2>/dev/null
    cd "$INPUT_MISTER" || exit 1

    for joystick in *.map; do
        id=$(echo "$joystick" | sed -nE 's/.*input_([a-f0-9]{4}_[a-f0-9]{4}).*\.map/\1/p' 2>/dev/null)

        if ! grep -q "^$id$" "$TMP_IDS" 2>/dev/null; then
            if ! grep -q "^$id " "$GCM_RGP"; then
                echo "$id" >>"$TMP_IDS" 2>/dev/null
            fi
        fi
    done

    found_gamepads=$(wc -l <"$TMP_IDS")

    if [ "$found_gamepads" -eq 0 ]; then
        rm -f "$TMP_IDS" 2>/dev/null

        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_ALL_DONE")
        showDialogMessage

        if ! menuListGamepads; then
            return
        fi
    fi

    generateLinesArray "$TMP_IDS"

    PARAM_3=$((COUNTER_LINES + 2))
    generateHeader "$REGISTER_GAMEPAD_MENU" 9 67 "$PARAM_3" INCREASE

    DIALOG+="
X \"$EXIT_MENU\" \\
- \"$SEPARATOR_DEFAULT\" \\"

    ids_list="$GCM_LGI"
    model=()
    indice=()
    print_indice=()

    for ((i = 1; i < $((COUNTER_LINES + 1)); i++)); do
        output=${LINES_ARRAY[$((i - 1))]}
        search=${output/_/:}
        name=$(grep -m 1 "$search" "$ids_list" 2>/dev/null)

        if [ -n "$name" ]; then
            model+=("$(echo "$name" | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)")
        else
            model+=("")
        fi

        indice+=("$output - ${model[$((i - 1))]}")
        print_indice+=("${indice[$((i - 1))]% - }")

        if [ "$i" -lt "$COUNTER_LINES" ]; then
            DIALOG+="$i \"${print_indice[$((i - 1))]}\" \\"
        else
            DIALOG+="$i \"${print_indice[$((i - 1))]}\""
        fi
    done

    if ! runDialog; then
        rm -f "$TMP_IDS" 2>/dev/null

        STATE="MENU_GAMEPADS"
        return
    fi

    case "$CHOICE" in
    "X")
        rm -f "$TMP_IDS" 2>/dev/null

        STATE="MENU_GAMEPADS"
        ;;
    "-")
        STATE="MENU_REGISTER_GAMEPAD"
        ;;
    *)
        ID_CHOICE=$(sed -n "${CHOICE}p" "$TMP_IDS" 2>/dev/null)
        rm -f "$TMP_IDS" 2>/dev/null

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_SELECTED_1")
        MESSAGE_LN2=("$REGISTER_GAMEPAD_SELECTED_2" "${print_indice[$CHOICE - 1]}")

        if ! yesNoDialog; then
            showCancelMessage "$REGISTER_GAMEPAD_CANCELED"

            STATE="MENU_GAMEPADS"
            return
        fi

        if [ "${model[$((CHOICE - 1))]}" = "" ]; then
            new_gamepad_id=1

            inputModel() {
                while true; do
                    TITLE=("$INFORMATION")
                    MESSAGE_LN1=("$REGISTER_GAMEPAD_NO_MODEL")
                    MESSAGE_LN2=("$REGISTER_GAMEPAD_INPUT")

                    if ! inputDialog; then
                        showCancelMessage "$REGISTER_GAMEPAD_CANCELED"

                        STATE="MENU_GAMEPADS"
                        return 1
                    fi

                    if [ -z "$TMP_INPUT" ]; then
                        TITLE=("$ATTENTION")
                        MESSAGE_LN1=("$REGISTER_GAMEPAD_NAME")
                        showDialogMessage

                        continue
                    fi

                    TMP_INPUT=$(printf '%s' "$TMP_INPUT" |
                        sed 's/"/'\''/g; s/`/'\''/g; s/\\/\//g' 2>/dev/null)
                    MODEL_CHOICE="$TMP_INPUT"
                    break
                done

                return
            }

            if ! inputModel; then
                return
            fi

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$YOU_TYPED" "$MODEL_CHOICE")

            if ! yesNoDialog; then
                STATE="MENU_GAMEPADS"
                return
            fi
        else
            new_gamepad_id=0
            MODEL_CHOICE=${model[$CHOICE - 1]}
        fi

        id_choice_list=${ID_CHOICE/_/:}

        if [ -d "${GCM_GPD}/${ID_CHOICE}-stored" ]; then
            mv "${GCM_GPD}/${ID_CHOICE}-stored" "${GCM_GPD}/${ID_CHOICE}" 2>/dev/null

            TITLE=("$INFORMATION")
            MESSAGE_LN1=("$REGISTER_GAMEPAD_RESTORE_1")
            MESSAGE_LN2=("$REGISTER_GAMEPAD_RESTORE_2")

            showDialogMessage

        else
            mkdir "${GCM_GPD}/${ID_CHOICE}" 2>/dev/null
            touch "${GCM_GPD}/${ID_CHOICE}/rename.cfg" 2>/dev/null
            touch "${GCM_GPD}/${ID_CHOICE}/gamepad_tag.txt"
            if ! menuSelectEditTag "$ID_CHOICE"; then
                rm -rf "${GCM_GPD}/${ID_CHOICE}" 2>/dev/null
                showCancelMessage "$REGISTER_GAMEPAD_CANCELED"
                STATE="MENU_GAMEPADS"
                return
            fi
        fi

        echo "$ID_CHOICE - $MODEL_CHOICE" >>"$GCM_RGP" 2>/dev/null

        if [ "$new_gamepad_id" -eq 1 ]; then
            echo "(\"$id_choice_list\" \"$MODEL_CHOICE\")" >>"$GCM_LGI" 2>/dev/null
        fi
        # New gamepad register
        recordGamepadData

        if [ "$new_gamepad_id" -eq 1 ]; then
            organizeGamepadIds
        fi

        importSelectedGamepadData

        TITLE=("$SLOGAN - $MODEL_CHOICE - $ID_CHOICE")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_COMPLETED")
        showDialogMessage

        ((COUNTER_GAMEPADS++))
        FLAG_COUNTER_CORES="ON"
        showUpdateList SHOWLIST
        ;;
    esac

    return
}

### menuCloneGamepad - Copy all settings from one gamepad to another
menuCloneGamepad() {
    local gamepads_registereds
    local output
    local i
    local gamepad_choice_1
    local id_choice_1
    local gamepad_choice_2
    local id_choice_2
    local cores_dir
    local slots_dir
    local cores_map
    local name
    local rename

    if ! checkRegisteredGamepads; then
        return
    fi

    if [ "$COUNTER_GAMEPADS" -lt 2 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$CLONE_GAMEPAD_ONLY_ONE")
        showDialogMessage

        STATE="MENU_GAMEPADS"
        return
    fi

    if ! prepareGamepadMenu "$CLONE_GAMEPAD_SELECT" ADD_LINES; then
        return
    fi

    generateHeader "$MESSAGE_MENU"

    # ADD_LINES argument on prepareGamepadMenu - adds 2 lines to the DIALOG
    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"$SEPARATOR_DEFAULT\" \\"

    generateLinesArray "$GCM_RGP"
    gamepads_registereds=""

    for ((i = 1; i < $((COUNTER_LINES + 1)); i++)); do
        output=${LINES_ARRAY[$((i - 1))]}

        if [ "$i" -lt $COUNTER_LINES ]; then
            gamepads_registereds+="$i \"$output\" \\"
        else
            gamepads_registereds+="$i \"$output\""
        fi
    done

    DIALOG+="$gamepads_registereds"
    if ! runDialog; then
        STATE="MENU_GAMEPADS"
        return
    fi

    case "$CHOICE" in
    "X")
        rm -f "$TMP_IDS" 2>/dev/null
        STATE="MENU_GAMEPADS"
        return
        ;;
    "-")
        STATE="MENU_CLONE_GAMEPAD"
        return
        ;;
    *)
        gamepad_choice_1=${LINES_ARRAY[$((CHOICE - 1))]}
        id_choice_1=$(echo "$gamepad_choice_1" | cut -c1-9 2>/dev/null)

        selectSecondGamepad() {
            while true; do
                prepareGamepadMenu "$CLONE_GAMEPAD_DESTINY"

                generateHeader "$MESSAGE_MENU" SHOW_CANCELL_BUTTON

                DIALOG+="${gamepads_registereds//${LINES_ARRAY[$((CHOICE - 1))]}/ <<< $CLONE_GAMEPAD_SELECTED >>>}"

                if ! runDialog; then
                    STATE="MENU_GAMEPADS"
                    return 1
                fi

                gamepad_choice_2=${LINES_ARRAY[$((CHOICE - 1))]}
                id_choice_2=$(echo "$gamepad_choice_2" | cut -c1-9 2>/dev/null)

                if [ "$gamepad_choice_2" = "$gamepad_choice_1" ]; then
                    continue
                fi

                break
            done

            return
        }

        if ! selectSecondGamepad; then
            return
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$CLONE_GAMEPAD_QUESTION_1" "$gamepad_choice_1")
        MESSAGE_LN2=("$CLONE_GAMEPAD_QUESTION_2" "$gamepad_choice_2")

        if toggleYesNoDialog; then
            showCancelMessage "$CLONE_GAMEPAD_CANCELED"

            STATE="MENU_GAMEPADS"
            return
        fi

        if ls -d "${GCM_GPD}/${id_choice_2}" &>/dev/null; then
            TITLE=("$WARNING")
            MESSAGE_LN1=("$CLONE_GAMEPAD_REPLACED_1" "$gamepad_choice_2")
            MESSAGE_LN2=("$CLONE_GAMEPAD_REPLACED_2")

            if toggleYesNoDialog; then
                showCancelMessage "$CLONE_GAMEPAD_CANCELED"

                STATE="MENU_GAMEPADS"
                return
            else
                if [ -n "$id_choice_2" ] && [ -d "${GCM_GPD}/${id_choice_2}" ]; then
                    rm -rf "${GCM_GPD}/${id_choice_2}"/* 2>/dev/null
                else
                    STATE="MENU_GAMEPADS"
                    return
                fi
            fi
        else
            mkdir "${GCM_GPD}/${id_choice_2}" 2>/dev/null
        fi

        cp -R -f "${GCM_GPD}/${id_choice_1}"/* "${GCM_GPD}/${id_choice_2}"/ 2>/dev/null

        for cores_dir in "${GCM_GPD}/${id_choice_2}"/*/; do
            cores_dir="${cores_dir%/}"
            for slots_dir in "${cores_dir}"/*/; do
                slots_dir="${slots_dir%/}"
                for cores_map in "${slots_dir}"/*.map; do
                    name=$(basename "$cores_map")
                    rename=$(basename "$cores_map" | sed "s|$id_choice_1|$id_choice_2|" 2>/dev/null)
                    mv "${slots_dir}/${name}" "${slots_dir}/${rename}" 2>/dev/null
                done
            done
        done

        TITLE=("$DONE")
        MESSAGE_LN1=("$CLONE_GAMEPAD_COMPLETED")
        showDialogMessage

        STATE="MENU_GAMEPADS"
        return
        ;;
    esac
}

# === menuSettings - General configuration menu including backup and uninstall functions
menuSettings() {
    generateHeader "$SETTINGS_MENU" 20 67 11

    DIALOG+="
X \"$SETTINGS_RETURN_COL1 - $SETTINGS_RETURN_COL2\" \
- \"$SETTINGS_SEPARATOR\" \
C \"$SETTINGS_COLORS_COL1 - $SETTINGS_COLORS_COL2\" \
O \"$SETTINGS_SCHEME_COLOR_STYLE_COL1 - $SETTINGS_SCHEME_COLOR_STYLE_COL2\" \
- \"$SETTINGS_SEPARATOR\" \
L \"$SETTINGS_LANGUAGE_COL1 - $SETTINGS_LANGUAGE_COL2\" \
F \"$SETTINGS_CASE_COL1 - $SETTINGS_CASE_COL2\" \
A \"$SETTINGS_ACCENTS_COL1 - $SETTINGS_ACCENTS_COL2\" \
S \"$SETTINGS_FONTSIZE_COL1 - $SETTINGS_FONTSIZE_COL2\" \
- \"$SETTINGS_SEPARATOR\" \
T \"$SETTINGS_TIPS_COL1 - $SETTINGS_TIPS_COL2\" \
- \"$SETTINGS_SEPARATOR\" \
D \"$SETTINGS_ADVANCED_COL1 - $SETTINGS_ADVANCED_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_SETTINGS"
        ;;
    "C")
        STATE="MENU_COLORS"
        ;;
    "O")
        STATE="MENU_COLOR_STYLE"
        ;;
    "L")
        STATE="MENU_LANGUAGE"
        ;;
    "F")
        STATE="MENU_TEXT_CASE"
        ;;
    "A")
        STATE="MENU_ACCENTS"
        ;;
    "S")
        STATE="MENU_FONT_SIZE"
        ;;
    "T")
        STATE="MENU_TIPS"
        ;;
    "D")
        STATE="MENU_ADVANCED_SETTINGS"
        ;;
    esac

    return
}

### menuColors - Adjust Color Theme
menuColors() {
    local color_selected

    generateHeader "$COLORS_MENU" 26 67 19

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$SEPARATOR_COLORS_MENU\" \
B \"$COLOR_BLUE\" \
C \"$COLOR_CYAN\" \
G \"$COLOR_GREEN\" \
Y \"$COLOR_YELLOW\" \
M \"$COLOR_MAGENTA\" \
R \"$COLOR_RED\" \
W \"$COLOR_BLACK_WHITE\" \
- \"$SEPARATOR_COLORS_MENU\" \
L \"$COLOR_NEON_BLUE\" \
A \"$COLOR_NEON_CYAN\" \
E \"$COLOR_NEON_GREEN\" \
O \"$COLOR_NEON_YELLOW\" \
N \"$COLOR_NEON_MAGENTA\" \
D \"$COLOR_NEON_RED\" \
H \"$COLOR_NEON_WHITE\" \
- \"$SEPARATOR_COLORS_MENU\" \
F \"$COLOR_DEFAULT\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        ;;
    "-")
        STATE="MENU_COLORS"
        ;;
    "B" | "C" | "G" | "Y" | "M" | "R" | "W" | "L" | "A" | "E" | "O" | "N" | "D" | "H" | "F")

        case "$CHOICE" in
        "B")
            color_selected="BLUE"
            ;;
        "C")
            color_selected="CYAN"
            ;;
        "G")
            color_selected="GREEN"
            ;;
        "Y")
            color_selected="YELLOW"
            ;;
        "M")
            color_selected="MAGENTA"
            ;;
        "R")
            color_selected="RED"
            ;;
        "W")
            color_selected="BLACK_WHITE"
            ;;
        "L")
            color_selected="NEON_BLUE"
            ;;
        "A")
            color_selected="NEON_CYAN"
            ;;
        "E")
            color_selected="NEON_GREEN"
            ;;
        "O")
            color_selected="NEON_YELLOW"
            ;;
        "N")
            color_selected="NEON_MAGENTA"
            ;;
        "D")
            color_selected="NEON_RED"
            ;;
        "H")
            color_selected="NEON_WHITE"
            ;;
        "F")
            color_selected="DEFAULT"
            ;;
        esac

        applySelectedColorTheme "$color_selected"

        STATE="MENU_COLORS"
        ;;
    esac

    return
}

### menuColorStyle - Select color style
menuColorStyle() {
    local selected_color_style

    if [ "$SCHEME" = "DEFAULT" ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$COLOR_STYLE_DEFAULT_MESSAGE")
        showDialogMessage

        STATE="MENU_SETTINGS"
        return
    fi

    generateHeader "$COLORS_STYLE_MENU" 15 67 8

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$SEPARATOR_COLORS_STYLE\" \
1 \"$COLOR_STYLE_1\" \
2 \"$COLOR_STYLE_2\" \
3 \"$COLOR_STYLE_3\" \
4 \"$COLOR_STYLE_4\" \
5 \"$COLOR_STYLE_5\" \
6 \"$COLOR_STYLE_6\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        ;;
    "-")
        STATE="MENU_COLOR_STYLE"
        ;;
    *)

        selected_color_style="$CHOICE"

        applySelectedColorStyle "$selected_color_style"

        STATE="MENU_COLOR_STYLE"
        ;;
    esac

    return
}

### menuLanguage - Select language (en for english, pt for portuguese)
menuLanguage() {
    generateHeader "$LANGUAGE_MENU" 12 67 5

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$SEPARATOR_DEFAULT\" \
E \"$EN\" \
P \"$PT\" \
S \"$ES\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        return
        ;;
    "-")
        STATE="MENU_LANGUAGE"
        return
        ;;
    "E")
        if [ "$LANGUAGE" != "en" ]; then
            sed -i "s/^language=[^ ]*/language=en/" "$GCM_INI" 2>/dev/null
            sed -i "s/^accents=[^ ]*/accents=OFF/" "$GCM_INI" 2>/dev/null
        fi
        ;;
    "P")
        if [ "$LANGUAGE" != "pt" ]; then
            sed -i "s/^language=[^ ]*/language=pt/" "$GCM_INI" 2>/dev/null
        fi
        ;;
    "S")
        if [ "$LANGUAGE" != "es" ]; then
            sed -i "s/^language=[^ ]*/language=es/" "$GCM_INI" 2>/dev/null
        fi
        ;;
    esac

    updateLanguage
    STATE="MENU_LANGUAGE"

    return
}

### menuTextCase - Select text case for menus
menuTextCase() {
    generateHeader "$TEXT_CASE_MENU" 11 67 4

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$TEXT_CASE_SEPARATOR\" \
N \"$TEXT_NORMAL\" \
U \"$TEXT_UPPERCASE\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        ;;
    "-")
        STATE="MENU_TEXT_CASE"
        ;;
    "N")
        if [ "$CASE" != "NORMAL" ]; then
            sed -i "s/^case=[^ ]*/case=NORMAL/" "$GCM_INI" 2>/dev/null
            STATE="MENU_TEXT_CASE"
            updateLanguage
        fi
        ;;
    "U")
        if [ "$CASE" != "UPPERCASE" ]; then
            sed -i "s/^case=[^ ]*/case=UPPERCASE/" "$GCM_INI" 2>/dev/null
            STATE="MENU_TEXT_CASE"
            updateLanguage
        fi
        ;;
    esac

    return
}

### menuAccents - Enable or disable text accents for pt and es languages
menuAccents() {
    if [ "$LANGUAGE" = "en" ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$MENU_ACCENTS_NOT_AVAILABLE_1")
        MESSAGE_LN2=("$MENU_ACCENTS_NOT_AVAILABLE_2")
        showDialogMessage
    else
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$TEXT_QUESTION_ACCENTS")
        toggleYesNoDialog

        if { [ "$MENU_ACCENTS" = "OFF" ] && [ "$STATUS_MESSAGE" -eq 1 ]; } ||
            { [ "$MENU_ACCENTS" = "ON" ] && [ "$STATUS_MESSAGE" -eq 0 ]; }; then

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                sed -i "s/^accents=[^ ]*/accents=ON/" "$GCM_INI" 2>/dev/null
            else
                sed -i "s/^accents=[^ ]*/accents=OFF/" "$GCM_INI" 2>/dev/null
            fi

            updateLanguage
        fi
    fi

    STATE="MENU_SETTINGS"
    return
}

### menuFontSize - Set font size in menus
menuFontSize() {
    local font_size

    generateHeader "$FONT_SIZE_MENU" 13 67 6

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$FONT_SIZE_SEPARATOR\" \
S \"$FONT_SIZE_SMALL\" \
M \"$FONT_SIZE_MEDIUM\" \
B \"$FONT_SIZE_LARGE\" \
H \"$FONT_SIZE_EXTRA_LARGE\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        return
        ;;
    "-")
        STATE="MENU_FONT_SIZE"
        return
        ;;
    "S")
        font_size="SMALL"
        ;;
    "M")
        font_size="MEDIUM"
        ;;
    "B")
        font_size="LARGE"
        ;;
    "H")
        font_size="EXTRA_LARGE"
        ;;
    esac

    if [ "$FONT_SIZE" != "$font_size" ]; then
        setFontSize "$font_size"
        testFontSizeScreen
        confirmFontSize "$font_size"
    fi

    STATE="MENU_FONT_SIZE"
    return
}

### menuTips - Enable/Disable Tips
menuTips() {
    local tips_display_state

    if [ "$FLAG_SHOW_TIPS" = "ON" ]; then
        tips_display_state="On"
    else
        tips_display_state="Off"
    fi

    tipsConfigCommand() {
        sed -i "s/^tips=[^ ]*/tips=$FLAG_SHOW_TIPS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_help=[^ ]*/tip_help=$FLAG_SHOW_TIPS/" "$GCM_INI" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$TIPS_MESSAGE")
        showDialogMessage

        STATE="MENU_TIPS"
    }

    generateHeader "$TIPS_MENU" 13 67 6

    DIALOG+="
X \"$EXIT_MENU\" \
- \"$TIPS_SEPARATOR\" \
A \"$ACTIVE_TIPS\" \
D \"$DEACTIVE_TIPS\" \
- \"$TIPS_SEPARATOR\" \
- \"Status: $tips_display_state\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        ;;
    "-")
        STATE="MENU_TIPS"
        ;;
    "A")
        if [ "$FLAG_SHOW_TIPS" != "ON" ]; then
            FLAG_SHOW_TIPS="ON"
            TIPS_MESSAGE="$TIPS_ENABLED"
            tipsConfigCommand
        fi
        ;;
    "D")
        if [ "$FLAG_SHOW_TIPS" != "OFF" ]; then
            FLAG_SHOW_TIPS="OFF"
            TIPS_MESSAGE="$TIPS_DISABLED"
            tipsConfigCommand
        fi
        ;;
    esac

    return
}

### menuAdvancedSettings - Display the advanced settings menu
menuAdvancedSettings() {
    generateHeader "$ADVANCED_SETTINGS_MENU" 13 67 6

    DIALOG+="
X \"$ADVANCED_SETTINGS_RETURN_COL1 - $ADVANCED_SETTINGS_RETURN_COL2\" \
- \"$ADVANCED_SETTINGS_SEPARATOR\" \
E \"$ADVANCED_SETTINGS_DELETE_COL1 - $ADVANCED_SETTINGS_DELETE_COL2\" \
R \"$ADVANCED_SETTINGS_RESET_COL1 - $ADVANCED_SETTINGS_RESET_COL2\" \
B \"$ADVANCED_SETTINGS_BACKUP_COL1 - $ADVANCED_SETTINGS_BACKUP_COL2\" \
U \"$ADVANCED_SETTINGS_UNINSTALL_COL1 - $ADVANCED_SETTINGS_UNINSTALL_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_SETTINGS"
        ;;
    "-")
        STATE="MENU_ADVANCED_SETTINGS"
        ;;
    "E")
        STATE="MENU_DELETE_MAPS"
        ;;
    "R")
        STATE="MENU_RESET"
        ;;
    "B")
        STATE="MENU_BACKUP"
        ;;
    "U")
        STATE="MENU_UNINSTALL"
        ;;
    esac

    return
}

### menuReset - Reset configuration to default, but save gamepad-* folders
menuReset() {
    local gamepad_folder

    TITLE=("$RESET_TITLE")
    MESSAGE_LN1=("$RESET_QUESTION")

    if toggleYesNoDialog; then
        showCancelMessage "$RESET_CANCELED"

        STATE="MENU_ADVANCED_SETTINGS"
        return
    else
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$RESET_INFO_1")
        MESSAGE_LN2=("$RESET_INFO_2")
        showDialogMessage

        TITLE=("$RESET_TITLE")
        MESSAGE_LN1=("$RESTORE_SETTINGS_CONFIRM")

        if toggleYesNoDialog; then
            showCancelMessage "$RESET_CANCELED"

            STATE="MENU_ADVANCED_SETTINGS"
            return
        else
            for gamepad_folder in "${GCM_DIR}"/gamepads/*; do
                if [[ -d "$gamepad_folder" && "$gamepad_folder" != *-stored ]]; then
                    mv "$gamepad_folder" "${gamepad_folder}-stored"
                fi
            done

            for directory in "$GCM_CFG" "$GCM_TMP" "$GCM_DAT"; do
                if [ -d "$directory" ] && [ "$directory" != "/" ]; then
                    rm -f "$directory"/*
                fi
            done

            TITLE=("$ATTENTION")
            MESSAGE_LN1=("$RESET_DONE_1")
            MESSAGE_LN2=("$RESET_DONE_2")
            showDialogMessage

            FIRST_RUN="ON"
            STATE="SCRIPT_INIT"
            return
        fi
    fi
}

### menuBackup - Backup menu functions
menuBackup() {
    generateHeader "$BACKUP_MENU" 12 67 5

    DIALOG+="
X \"$BACKUP_EXIT_COL1 - $BACKUP_EXIT_COL2\" \
- \"$BACKUP_SEPARATOR\" \
S \"$BACKUP_SAVE_COL1 - $BACKUP_SAVE_COL2\" \
R \"$BACKUP_RESTORE_COL1 - $BACKUP_RESTORE_COL2\" \
D \"$BACKUP_DELETE_COL1 - $BACKUP_DELETE_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_ADVANCED_SETTINGS"
        ;;
    "-")
        STATE="MENU_BACKUP"
        ;;
    "S")
        STATE="MENU_SAVE_BACKUP"
        ;;
    "R")
        STATE="MENU_RESTORE_BACKUP"
        ;;
    "D")
        STATE="MENU_DELETE_BACKUP"
        ;;
    esac

    return
}

### menuSaveBackup - Backup save function
menuSaveBackup() {
    local add_mister_files
    local xtra_tag
    local bkp_dir
    local current_date

    add_mister_files=0
    xtra_tag=""

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SAVE_BACKUP_QUESTION")

    if toggleYesNoDialog; then
        showCancelMessage "$SAVE_BACKUP_CANCELED"

        STATE="MENU_BACKUP"
        return
    else
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$SAVE_BACKUP_QUESTION_FILES_1")
        MESSAGE_LN2=("$SAVE_BACKUP_QUESTION_FILES_2")
        SAVE_BACKUP_QUESTION_FILES_1

        if ! toggleYesNoDialog; then
            add_mister_files=1
            xtra_tag="full-"

            TITLE=("$INFORMATION")
            MESSAGE_LN1=("$SAVE_BACKUP_INFO_1")
            MESSAGE_LN2=("$SAVE_BACKUP_INFO_2")
            showDialogMessage
        fi

        bkp_dir="${GCM_TMP}/Backup-GCM-MiSTer"
        current_date=$(date +"%y_%m_%d-%H_%M")
        mkdir -p "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null

        if [ -z "$bkp_dir" ] || [ "$bkp_dir" == "/" ]; then
            STATE="MENU_HOME"
            return
        else
            if [ "$add_mister_files" -eq 1 ]; then
                cp "${INPUT_MISTER}"/*.map "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            fi

            cp -R -f "$GCM_CFG" "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cp -R -f "$GCM_DAT" "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cp -R -f "${GCM_DIR}"/gamepads "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cd "$bkp_dir" || {
                STATE="MENU_BACKUP"
                return
            }
            zip -r "${GCM_DIR}/Backup-GCM-MiSTer-${xtra_tag}${current_date}.zip" "Backup-GCM-MiSTer-${current_date}"/* >/dev/null 2>&1
            mv "${GCM_DIR}/Backup-GCM-MiSTer-${xtra_tag}${current_date}.zip" "$MISTER_ROOT/"
            rm -rf "$bkp_dir" 2>/dev/null
        fi

        TITLE=("$SAVE_BACKUP_COMPLETED")
        MESSAGE_LN1=("$SAVE_BACKUP_FILE_1" "$xtra_tag" "$current_date")
        MESSAGE_LN2=("$SAVE_BACKUP_FILE_2")
        showDialogMessage
    fi

    STATE="MENU_BACKUP"
    return
}

### menuRestoreBackup - Backup restore function
menuRestoreBackup() {
    local backup_type
    local selected_backup
    local exit_string
    local restore_file

    backup_type="GCM" # GCM only, FULL (GCM + MiSTer .map)

    if ! generateMenuBackup "$RESTORE_BACKUP_MENU"; then
        return
    fi

    case "$CHOICE" in
    "X")
        STATE="MENU_BACKUP"
        ;;
    "-")
        STATE="MENU_RESTORE_BACKUP"
        ;;
    *)
        selected_backup="${BACKUPS[$CHOICE - 1]}"

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$RESTORE_BACKUP_QUESTION" "$CHOICE")

        if toggleYesNoDialog; then
            showCancelMessage "$RESTORE_BACKUP_CANCELED"

            STATE="MENU_BACKUP"
            return
        fi

        if [[ "$selected_backup" == *full-* ]]; then
            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$RESTORE_BACKUP_FULL_1")

            if toggleYesNoDialog; then
                showCancelMessage "$RESTORE_BACKUP_CANCELED"

                STATE="MENU_BACKUP"
                return
            else
                TITLE=("$WARNING")
                MESSAGE_LN1=("$RESTORE_BACKUP_FULL_2")

                if toggleYesNoDialog; then
                    showCancelMessage "$RESTORE_BACKUP_CANCELED"

                    STATE="MENU_BACKUP"
                    return
                else
                    backup_type="FULL"

                    exit_string="$EXIT"
                    EXIT="$CONTINUE"

                    TITLE=("$CONFIRMATION")
                    MESSAGE_LN1=("$RESTORE_BACKUP_INFO_1")
                    MESSAGE_LN2=("$RESTORE_BACKUP_INFO_2")
                    showDialogMessage

                    EXIT="$exit_string"
                fi
            fi
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$RESTORE_BACKUP_CONFIRMATION_1")
        MESSAGE_LN2=("$RESTORE_BACKUP_CONFIRMATION_2")

        if ! toggleYesNoDialog; then
            if [ -z "$GCM_DIR" ] || [ "$GCM_DIR" == "/" ]; then
                STATE="MENU_BACKUP"
                return
            fi

            restoreBackupFiles "$selected_backup" "$backup_type"

            restore_file=$(basename "$selected_backup")

            TITLE=("$DONE")
            MESSAGE_LN1=("$RESTORE_BACKUP_COMPLETED_1" "$restore_file")
            MESSAGE_LN2=("$RESTORE_BACKUP_COMPLETED_2")
            showDialogMessage
        else
            showCancelMessage "$RESTORE_BACKUP_CANCELED"
        fi

        countRegisteredGamepads

        STATE="MENU_BACKUP"
        ;;
    esac

    return
}

### menuDeleteBackup - Backup delete function
menuDeleteBackup() {
    local selected_backup
    local output

    if ! generateMenuBackup "$DELETE_BACKUP_MENU"; then
        return
    fi

    case "$CHOICE" in
    "X")
        STATE="MENU_BACKUP"
        ;;
    "-")
        STATE="MENU_DELETE_BACKUP"
        ;;
    *)
        selected_backup="${BACKUPS[$CHOICE - 1]}"
        output=$(basename "${BACKUPS[$CHOICE - 1]}")

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$DELETE_BACKUP_QUESTION" "$CHOICE")
        MESSAGE_LN2=("$CONTINUE?")

        if ! toggleYesNoDialog; then
            if [ -e "$selected_backup" ]; then
                rm -f "$selected_backup" 2>/dev/null

                TITLE=("$DONE")
                MESSAGE_LN1=("$DELETE_BACKUP_COMPLETED")
                showDialogMessage
            else
                showCancelMessage "$DELETE_BACKUP_ERROR"
            fi
        else
            showCancelMessage "$DELETE_BACKUP_CANCELED"
        fi

        STATE="MENU_BACKUP"
        ;;
    esac

    return
}

### menuUninstall - Uninstall the GCM script and folder
menuUninstall() {
    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$UNINSTALL_QUESTION")

    if ! toggleYesNoDialog; then
        TITLE=("$WARNING")
        MESSAGE_LN1=("$UNINSTALL_CONFIRMATION_1")
        MESSAGE_LN2=("$UNINSTALL_CONFIRMATION_2")

        if ! toggleYesNoDialog; then
            TITLE=("%s" "$CONFIRMATION")
            MESSAGE_LN1=("$UNINSTALL_EXECUTE")

            if ! toggleYesNoDialog; then
                if [ -z "$GCM_DIR" ] || [ "$GCM_DIR" == "/" ] ||
                    [ -z "$MISTER_ROOT" ] || [ "$MISTER_ROOT" == "/" ]; then
                    STATE="MENU_HOME"
                    return
                else
                    if [ -d "$GCM_DIR" ] && [ "$GCM_DIR" != "/" ]; then
                        rm -rf "$GCM_DIR" 2>/dev/null
                    fi

                    rm -f "${MISTER_ROOT}/Scripts/gamepad_config_manager.sh" 2>/dev/null
                fi

                dialog --title "$SLOGAN" --timeout 2 --msgbox "\n $UNINSTALATION_COMPLETED" 7 30
                exit 0
            fi
        fi
    fi

    showCancelMessage "$UNINSTALL_CANCELED"

    STATE="MENU_ADVANCED_SETTINGS"
    return
}

# === menuCoreMain - Show menu to access SLOTS of the selected CORE
menuCoreMain() {
    local lines_value

    renameCoreDisplayIfNeeded "$CORE"
    CORE_DIR="${GCM_GPD}/${ID}/${CORE}"
    LAYOUT_TAG=$(cat "${GCM_GPD}/${ID}/gamepad_tag.txt")
    checkCoreConfig "$CORE"
    countSlots
    loadCoreConfigContents
    checkCurrentSlotStatus
    verifyTipsFlagsCore

    lines_value=25

    if [ "$SHOW_TIPS_MESSAGE_CORE" = "ON" ]; then
        ((lines_value++))
    fi

    generateHeader "$CORE_MENU - $SELECT_OPTIONS" "$lines_value" 67 18 CORE

    DIALOG+="
X \"$CORE_EXIT_COL1 - $CORE_EXIT_COL2\" \
- \"$CORE_SEPARATOR\" \
S \"$CORE_LOAD_COL1 - $CORE_LOAD_COL2\" \
V \"$CORE_VIEW_LAYOUTS_COL1 - $CORE_VIEW_LAYOUTS_COL2\" \
G \"$CORE_VIEW_GAMES_COL1 - $CORE_VIEW_GAMES_COL2\" \
- \"$CORE_SEPARATOR\" \
N \"$CORE_SAVE_COL1 - ${CORE_SAVE_COL2}${CORE_SAVE_INDICATOR}\" \
E \"$CORE_EDIT_LAYOUTS_COL1 - ${CORE_EDIT_LAYOUTS_COL2}${CORE_EDIT_LAYOUT_INDICATOR}\" \
L \"$CORE_EDIT_GAMES_COL1 - ${CORE_EDIT_GAMES_COL2}${CORE_EDIT_GAMES_INDICATOR}\" \
- \"$CORE_SEPARATOR\" \
M \"$CORE_MOVE_COL1 - $CORE_MOVE_COL2\" \
C \"$CORE_SWITCH_COL1 - $CORE_SWITCH_COL2\" \
D \"$CORE_DELETE_COL1 - $CORE_DELETE_COL2\" \
R \"$CORE_OVERWRITE_COL1 - $CORE_OVERWRITE_COL2\" \
O \"$CORE_COPY_COL1 - $CORE_COPY_COL2\" \
P \"$CORE_NOTES_COL1 - $CORE_NOTES_COL2\" \
- \"$CORE_SEPARATOR_2\" \
- \"${CORE_MAIN_SPACES}SLOTS:$COUNTER_SLOTS / LOADED SLOT:$CURRENT\""

    if [ "$SHOW_TIPS_MESSAGE_CORE" = "ON" ]; then
        DIALOG+=" \
- \"${TIP_FOOTER_CORE_MAIN}: ${FOOTER_MESSAGE_CORE}\""
    fi

    runDialog

    case $CHOICE in
    "S")
        STATE="MENU_LOAD_SLOT"
        ;;
    "V")
        STATE="MENU_SHOW_LAYOUTS"
        STATE_ARG=""
        ;;
    "G")
        STATE="MENU_SHOW_GAMES"
        ;;
    "N")
        STATE="MENU_SAVE_SLOT"
        ;;
    "E")
        STATE="MENU_EDIT_LAYOUT"
        ;;
    "L")
        STATE="MENU_EDIT_GAMES"
        ;;
    "M")
        STATE="MENU_MOVE_SLOT"
        ;;
    "C")
        STATE="MENU_SWITCH_SLOT"
        ;;
    "D")
        STATE="MENU_DELETE_SLOT"
        ;;
    "R")
        STATE="MENU_OVERWRITE_SLOT"
        ;;
    "O")
        STATE="MENU_COPY_SLOT"
        ;;
    "P")
        STATE="MENU_SHOW_NOTES"
        ;;
    "X" | "")
        STATE="MENU_HOME"
        ;;
    "-")
        STATE="MENU_CORE_MAIN"
        ;;
    *)
        STATE="MENU_HOME"
        ;;
    esac

    return
}

### menuLoadSlot - Set SLOT as default MiSTer CORE configuration
menuLoadSlot() {
    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    generateHeaderOnDisk "$LOAD_SLOT_MENU"
    generateLayoutsOnDiskRun

    if ! storeChoiceAndClean; then
        return
    fi

    case "$CHOICE" in
    "-")
        STATE="MENU_LOAD_SLOT"
        ;;
    "")
        STATE="MENU_CORE_MAIN"
        ;;
    *)
        if ! checkMapFiles SLOT "$CHOICE"; then
            return
        fi

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$LOAD_SLOT_QUESTION_1" "$CHOICE")
        MESSAGE_LN2=("$LOAD_SLOT_QUESTION_2")

        if yesNoDialog; then
            cp "${CORE_DIR}/SLOT_${CHOICE}/${CORE}_input_${ID}"*.map \
                "$INPUT_MISTER"/ 2>/dev/null
            sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$CHOICE/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
            CURRENT="$CHOICE"

            TITLE=("$DONE")
            MESSAGE_LN1=("$LOAD_SLOT_COMPLETED" "$CHOICE")
            showDialogMessage

            FLAG_SLOT_CURRENT_CHECK="OFF"
        else
            showCancelMessage "$LOAD_SLOT_CANCELED"
        fi

        STATE="MENU_CORE_MAIN"
        ;;
    esac

    return
}

### menuShowlayouts - Show 'layouts' (button maps) for each SLOT
menuShowlayouts() {
    local flag_new_slot
    local index
    local i
    local layouts_lines
    local position
    local type

    # ARGUMENTS:
    flag_new_slot="$1"

    # RESET MAIN ARGUMENTS:
    STATE_ARG=""

    index=0

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    {
        if [ "$COUNTER_SLOTS" -lt 20 ]; then
            echo ""
        fi
        echo "    SLOT  $LAYOUT_TAG       $COMMENTS_2"
        echo "    ----  --------------------------------------- ------------------"
    } >"$TMP_FILE" 2>/dev/null

    for ((i = 1; i <= COUNTER_SLOTS; i++)); do
        getSlotIndicator "$i"

        if [ "$index" = 20 ]; then
            {
                echo ""
                echo "    SLOT  $LAYOUT_TAG       $COMMENTS_2"
                echo "    ----  --------------------------------------- ------------------"
            } >>"$TMP_FILE" 2>/dev/null
            index=0
        fi

        ((index++))
        layouts_lines=$(<"${CORE_DIR}/SLOT_${i}/LAYOUT.cfg")
        position=$(printf "%3d" $i)
        CHOICE="$i"

        if ! checkMapFiles SLOT "$i"; then
            return
        fi

        if [ "$TYPE" = "v3" ]; then
            type="J"
        elif [ "$TYPE" = "jk" ] || [ "$TYPE" = "v1" ] || [ "$TYPE" = "v1_jk" ]; then
            type="R"
        else
            type="A"
        fi

        if [ "$i" = "$COUNTER_SLOTS" ] && [ "$flag_new_slot" = "ADD_SLOT" ]; then
            echo "${SLOT_INDICATOR} ${type} ${position})  ${NEW_SLOT_CREATED}" >>"$TMP_FILE" 2>/dev/null
        else
            echo "${SLOT_INDICATOR} ${type} ${position})  ${layouts_lines}" >>"$TMP_FILE" 2>/dev/null
        fi
    done

    LINES_MENU=$((COUNTER_SLOTS + 8))
    adjustLinesMenuSize

    TITLE=("%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")
    formatMessage

    dialog --exit-label "$EXIT" --title "$TITLE_FORMATTED" --textbox "$TMP_FILE" "$LINES_MENU" 72
    rm -f "$TMP_FILE" 2>/dev/null

    STATE="MENU_CORE_MAIN"
    return
}

### menuShowGames - Show the 'game list' for each SLOT
menuShowGames() {
    local i
    local lines_text

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    echo "" >"$TMP_FILE" 2>/dev/null

    for ((i = 1; i <= COUNTER_SLOTS; i++)); do
        getSlotIndicator "$i"

        while IFS= read -r line; do
            eval "OUTPUT=\"\$line\""
            echo "${SLOT_INDICATOR} ${OUTPUT} - ${i}" >>"$TMP_FILE" 2>/dev/null
        done <"${CORE_DIR}/SLOT_${i}/GAMES.cfg"
    done

    touch "$TMP_ORDER" 2>/dev/null
    sort -k1.3 "$TMP_FILE" >>"$TMP_ORDER" 2>/dev/null
    rm "$TMP_FILE" 2>/dev/null
    cat "$TMP_ORDER" >"$TMP_FILE" 2>/dev/null
    rm -f "$TMP_ORDER" 2>/dev/null

    lines_text=$(wc -l <"$TMP_FILE" 2>/dev/null)
    LINES_MENU=$((lines_text + 5))
    adjustLinesMenuSize

    TITLE=("%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")
    formatMessage

    if [[ -z $(tr -d '\n' <"$TMP_FILE") ]]; then
        {
            echo " "
            echo "$SHOW_GAMES_EMPTY_LIST"
        } >"$TMP_FILE" 2>/dev/null
    fi

    dialog --exit-label "$EXIT" --title "$TITLE_FORMATTED" --textbox "$TMP_FILE" "$LINES_MENU" 70
    rm -f "$TMP_FILE" 2>/dev/null

    STATE="MENU_CORE_MAIN"
    return
}

### menuSaveSLOT - Create a new SLOT
menuSaveSLOT() {
    local new_slot_id

    if ! checkMapFiles; then
        return
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SAVE_SLOT_QUESTION_1")
    MESSAGE_LN2=("$SAVE_SLOT_QUESTION_2" "$CORE_DISPLAY")

    if ! yesNoDialog; then
        showCancelMessage "$SAVE_SLOT_CANCELED"

        STATE="MENU_CORE_MAIN"
        return
    fi

    if [ "$COUNTER_SLOTS" -ne 0 ]; then
        new_slot_id=$((COUNTER_SLOTS + 1))
        createNewSlot "$new_slot_id"
    else
        new_slot_id=1
        createNewSlot "$new_slot_id"
    fi

    sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$new_slot_id/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null

    TITLE=("$DONE")
    MESSAGE_LN1=("$SAVE_SLOT_COMPLETED_1" "$CORE_DISPLAY")
    MESSAGE_LN2=("$SAVE_SLOT_COMPLETED_2" "$new_slot_id")
    showDialogMessage

    ((COUNTER_SLOTS++))

    CURRENT="$new_slot_id"

    STATE="MENU_SHOW_LAYOUTS"
    STATE_ARG="ADD_SLOT"
    return
}

### menuEditLayout - Show menu and edit 'button map' of the selected SLOT
menuEditLayout() {

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    generateHeaderOnDisk "$EDIT_LAYOUT_MENU"
    generateLayoutsOnDiskRun

    if ! storeChoiceAndClean; then
        return
    fi

    case "$CHOICE" in
    "-")
        STATE="MENU_EDIT_LAYOUT"
        ;;
    *)
        if [ -f "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" ]; then
            cp "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
            echo -e "← ↓ ↑ → \n$LAYOUT_TAG |${LINE_TAG}$COMMENTS ----|\n\n $EDIT_LAYOUT_MESSAGE_1\n $EDIT_LAYOUT_MESSAGE_2" >>"${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null

            if [ -s "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" ]; then
                echo -e "\n $EDIT_LAYOUT_MESSAGE_3\n $EDIT_LAYOUT_MESSAGE_4\n\n $EDIT_LAYOUT_MESSAGE_5" >>"${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
            fi

            if dialog --ok-label "$SAVE" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE_DISPLAY - $EDIT_LAYOUT_BUTTON_MAP '$CHOICE'" --editbox "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 20 65 \
                2>"$TMP_DIALOG"; then
                sed -i "s/\"/'/g; s/\`/'/g" "$TMP_DIALOG" 2>/dev/null
                cp "$TMP_DIALOG" "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" 2>/dev/null
                sed -i '1s/^\(.\{128\}\).*/\1/' "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" 2>/dev/null && sed -i '2,$d' "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" 2>/dev/null

                if [ "$FLAG_SHOW_TIPS_EDIT_LAYOUTS" = "ON" ]; then
                    sed -i "s/^show_tips_edit_layouts=[^ ]*/show_tips_edit_layouts=OFF/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                    FLAG_SHOW_TIPS_EDIT_LAYOUTS="OFF"
                fi
            else
                rm -f "$TMP_DIALOG" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
                showCancelMessage "$EDIT_LAYOUT_CANCELED"

                STATE="MENU_CORE_MAIN"
                return
            fi

            TITLE=("$DONE")
            MESSAGE_LN1=("$EDIT_LAYOUT_COMPLETED")
            showDialogMessage
        fi

        rm -f "$TMP_DIALOG" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
        STATE="MENU_SHOW_LAYOUTS"
        STATE_ARG=""
        ;;
    esac

    return
}

### menuEditGames - Show menu and edit 'game list' of selected SLOT
menuEditGames() {
    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    generateHeaderOnDisk "$EDIT_GAMES_MENU"
    generateLayoutsOnDiskRun

    if ! storeChoiceAndClean; then
        return
    fi

    case "$CHOICE" in
    "-")
        STATE="MENU_EDIT_GAMES"
        ;;
    *)
        if [ -f "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" ]; then
            cp "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null

            if dialog --ok-label "$SAVE" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE_DISPLAY - $EDIT_GAMES_LIST '$CHOICE'" --editbox "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 20 60 \
                2>"$TMP_DIALOG"; then
                sed -i '/^[[:space:]]*$/d' "$TMP_DIALOG" 2>/dev/null
                sed -i "s/\"/'/g; s/\`/'/g" "$TMP_DIALOG" 2>/dev/null
                cp "$TMP_DIALOG" "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" 2>/dev/null

                if [ "$FLAG_SHOW_TIPS_EDIT_GAMES" = "ON" ]; then
                    sed -i "s/^show_tips_edit_games=[^ ]*/show_tips_edit_games=OFF/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                    FLAG_SHOW_TIPS_EDIT_GAMES="OFF"
                fi

                TITLE=("$DONE")
                MESSAGE_LN1=("$EDIT_GAMES_COMPLETED")
                showDialogMessage
            else
                rm -f "$TMP_DIALOG" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null
                showCancelMessage "$EDIT_GAMES_CANCELED"

                STATE="MENU_CORE_MAIN"
                return
            fi
        else
            messageSlotsNotFound
        fi

        rm -f "$TMP_DIALOG" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null
        STATE="MENU_SHOW_GAMES"
        ;;
    esac

    return
}

### menuMoveSlot - Move a SLOT to a different position
menuMoveSlot() {
    local first_slot
    local destination_slot
    local condition
    local inc
    local update_current

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    if ! checkOneSlot; then
        return
    fi

    selectFirstSlot() {
        while true; do
            generateHeaderOnDisk "$MOVE_SLOT_FIRST"
            generateLayoutsOnDiskRun

            if ! storeChoiceAndClean; then
                return 1
            fi

            first_slot="$CHOICE"

            if [ "$CHOICE" = "-" ]; then
                continue
            fi

            break
        done

        return
    }

    if ! selectFirstSlot; then
        return
    fi

    selectSecondSlot() {
        while true; do
            messageProcessingWait

            generateHeaderOnDisk "$MOVE_SLOT_SECOND"
            generateLayoutsOnDiskRun EXCLUDE "$first_slot"

            if ! storeChoiceAndClean; then
                return 1
            fi

            destination_slot="$CHOICE"

            if [ "$CHOICE" = "-" ]; then
                continue
            fi

            break
        done

        return
    }

    if ! selectSecondSlot; then
        return
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$MOVE_SLOT_QUESTION_1" "$first_slot" "$destination_slot")

    if [ "$COUNTER_SLOTS" -gt 2 ]; then
        MESSAGE_LN2=("$MOVE_SLOT_QUESTION_2")
    fi

    if yesNoDialog; then
        messageProcessingWait

        relocateSlot "$first_slot" "TEMP"

        if [ "$first_slot" -gt "$destination_slot" ]; then
            condition="i > destination_slot"
            inc=-1
        else
            condition="i < destination_slot"
            inc=1
        fi

        reorganizeSlotsOrder "$first_slot" "$condition" "$inc"
        relocateSlot "TEMP" "$destination_slot"
        update_current="$CURRENT"

        if [ "$first_slot" = "$CURRENT" ]; then
            update_current="$destination_slot"
        else
            if [ "$destination_slot" = "$CURRENT" ]; then
                if [ "$first_slot" -gt "$destination_slot" ]; then
                    update_current=$((CURRENT + 1))
                else
                    update_current=$((CURRENT - 1))
                fi
            elif [ "$destination_slot" -lt "$CURRENT" ] && [ "$first_slot" -gt "$CURRENT" ]; then
                update_current=$((CURRENT + 1))
            elif [ "$destination_slot" -gt "$CURRENT" ] && [ "$first_slot" -lt "$CURRENT" ]; then
                update_current=$((CURRENT - 1))
            fi
        fi

        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$update_current/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
        CURRENT="$update_current"

        TITLE=("$DONE")
        MESSAGE_LN1=("$MOVE_SLOT_COMPLETED" "$first_slot" "$destination_slot")
        showDialogMessage
    else
        showCancelMessage "$MOVE_SLOT_CANCELED"

        STATE="MENU_CORE_MAIN"
        return
    fi

    STATE="MENU_SHOW_LAYOUTS"
    STATE_ARG=""
    return
}

### menuSwitchSlot - Swap the position of two SLOTS
menuSwitchSlot() {
    local first_slot
    local second_slot
    local destination_slot
    local update_current

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    if ! checkOneSlot; then
        return
    fi

    selectFirstSlot() {
        while true; do
            generateHeaderOnDisk "$SWITCH_SLOT_FIRST"
            generateLayoutsOnDiskRun

            if ! storeChoiceAndClean; then
                return 1
            fi

            first_slot="$CHOICE"

            if [ "$CHOICE" = "-" ]; then
                continue
            fi

            break
        done

        return
    }

    if ! selectFirstSlot; then
        return
    fi

    selectSecondSlot() {
        while true; do
            messageProcessingWait

            generateHeaderOnDisk "$SWITCH_SLOT_SECOND"
            generateLayoutsOnDiskRun EXCLUDE "$first_slot"

            if ! storeChoiceAndClean; then
                return 1
            fi

            second_slot="$CHOICE"

            if [ "$CHOICE" = "-" ]; then
                continue
            fi

            break
        done

        return
    }

    if ! selectSecondSlot; then
        return
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SWITCH_SLOT_QUESTION" "$first_slot" "$second_slot")

    if yesNoDialog; then
        destination_slot="$second_slot"
        relocateSlot "$first_slot" "TEMP"
        relocateSlot "$second_slot" "$first_slot"
        relocateSlot "TEMP" "$second_slot"
        update_current="$CURRENT"

        if [ "$first_slot" = "$CURRENT" ]; then
            update_current="$second_slot"
        elif [ "$second_slot" = "$CURRENT" ]; then
            update_current="$first_slot"
        fi

        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$update_current/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
        CURRENT="$update_current"

        TITLE=("$DONE")
        MESSAGE_LN1=("$SWITCH_SLOT_COMPLETED" "$first_slot" "$second_slot")
        showDialogMessage
    else
        showCancelMessage "$SWITCH_SLOT_CANCELED"

        STATE="MENU_CORE_MAIN"
        return
    fi

    STATE="MENU_SHOW_LAYOUTS"
    STATE_ARG=""
    return
}

### menuDeleteSlot - Delete a SLOT
menuDeleteSlot() {
    local first_slot
    local condition
    local inc
    local update_current

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    generateHeaderOnDisk "$DELETE_SLOT_MENU"
    generateLayoutsOnDiskRun

    if ! storeChoiceAndClean; then
        return
    fi

    case "$CHOICE" in
    "-")
        STATE="MENU_DELETE_SLOT"
        ;;
    "")
        STATE="MENU_CORE_MAIN"
        ;;
    *)
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$DELETE_SLOT_QUESTION" "$CHOICE")

        if toggleYesNoDialog; then
            showCancelMessage "$DELETE_SLOT_CANCELED"

            STATE="MENU_CORE_MAIN"
            return
        fi

        if [ -d "${CORE_DIR}/SLOT_${CHOICE}" ]; then
            rm -rf "${CORE_DIR}/SLOT_${CHOICE}"
        fi

        first_slot="$CHOICE"
        condition="i < COUNTER_SLOTS"
        inc=1
        reorganizeSlotsOrder "$first_slot" "$condition" "$inc"
        update_current="$CURRENT"

        if [ "$CHOICE" = "$CURRENT" ]; then
            update_current="X"
        elif [ "$CHOICE" -lt "$CURRENT" ]; then
            update_current=$((CURRENT - 1))
        fi

        CURRENT="$update_current"
        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=${CURRENT}/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$DELETE_SLOT_COMPLETED" "$CHOICE")
        showDialogMessage

        ((COUNTER_SLOTS--))

        if [ "$COUNTER_SLOTS" -eq 0 ]; then
            sed -i "s/^show_tips_edit_games=[^ ]*/show_tips_edit_games=ON/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
            sed -i "s/^show_tips_edit_layouts=[^ ]*/show_tips_edit_layouts=ON/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null

            TITLE=("$INFORMATION")
            MESSAGE_LN1=("$DELETE_SLOT_EMPTY")
            showDialogMessage

            STATE="MENU_CORE_MAIN"
            return
        fi

        STATE="MENU_SHOW_LAYOUTS"
        STATE_ARG=""
        ;;
    esac

    return
}

### menuOverwriteSlot - Overwrite an existing SLOT with the CORE configuration
menuOverwriteSlot() {
    local overwrite_slot

    if ! checkCounterSlots; then
        return
    fi

    overwriteSlot() {
        if [ "$COUNTER_SLOTS" -eq 1 ]; then
            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$OVERWRITE_SLOT_ONLY_ONE_1" "$CORE_DISPLAY")
            MESSAGE_LN2=("$OVERWRITE_SLOT_ONLY_ONE_2")

            if toggleYesNoDialog; then
                showCancelMessage "$OVERWRITE_SLOT_CANCELED"

                STATE="MENU_CORE_MAIN"
                return
            fi

            overwrite_slot="1"
        else
            while true; do
                generateHeaderOnDisk "$OVERWRITE_SLOT_MENU"
                generateLayoutsOnDiskRun

                if ! storeChoiceAndClean; then
                    return 1
                fi

                overwrite_slot="$CHOICE"

                if [ "$CHOICE" = "-" ]; then
                    continue
                fi

                break
            done
        fi

        return
    }

    if ! overwriteSlot; then
        return
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$OVERWRITE_SLOT_QUESTION" "$overwrite_slot")

    if ! toggleYesNoDialog; then
        if ! checkMapFiles; then
            return
        fi

        if [ "$TYPE" = "v3" ] || [ "$TYPE" = "v3_jk" ] || [ "$TYPE" = "v3_v1" ] ||
            [ "$TYPE" = "v3_v1_jk" ]; then
            cp "${INPUT_MISTER}/${CORE}_input_${ID}_v3.map" \
                "${CORE_DIR}/SLOT_${overwrite_slot}" 2>/dev/null
        fi

        if [ "$TYPE" = "jk" ] || [ "$TYPE" = "v3_jk" ] || [ "$TYPE" = "v1_jk" ] ||
            [ "$TYPE" = "v3_v1_jk" ]; then
            cp "${INPUT_MISTER}/${CORE}_input_${ID}_jk.map" \
                "${CORE_DIR}/SLOT_${overwrite_slot}" 2>/dev/null
        fi

        if [ "$TYPE" = "v1" ] || [ "$TYPE" = "v3_v1" ] || [ "$TYPE" = "v1_jk" ] ||
            [ "$TYPE" = "v3_v1_jk" ]; then
            cp "${INPUT_MISTER}/${CORE}_advanced_input_${ID}_v1.map" \
                "${CORE_DIR}/SLOT_${overwrite_slot}" 2>/dev/null
        fi

        CURRENT="$overwrite_slot"
        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$overwrite_slot/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$OVERWRITE_SLOT_COMPLETED" "$overwrite_slot")
        showDialogMessage
    else
        showCancelMessage "$OVERWRITE_SLOT_CANCELED"
    fi

    STATE="MENU_SHOW_LAYOUTS"
    STATE_ARG=""
    return
}

### menuCopySlot - Copy SLOT to new SLOT
menuCopySlot() {
    local new_slot
    local copy_slot

    messageProcessingWait

    if ! checkCounterSlots; then
        return
    fi

    selectCopySlot() {
        while true; do
            generateHeaderOnDisk "$COPY_SLOT_MENU"
            generateLayoutsOnDiskRun

            if ! storeChoiceAndClean; then
                return 1
            fi

            copy_slot="$CHOICE"

            if [ "$copy_slot" = "-" ]; then
                continue
            fi

            break
        done
    }

    if ! selectCopySlot; then
        return
    fi

    new_slot=$((COUNTER_SLOTS + 1))

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$COPY_SLOT_QUESTION" "$copy_slot" "$new_slot")

    if toggleYesNoDialog; then
        showCancelMessage "$COPY_SLOT_CANCELED"

        STATE="MENU_CORE_MAIN"
        return
    fi

    cp -R -f "${CORE_DIR}/SLOT_${copy_slot}" "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null
    ((COUNTER_SLOTS++))

    TITLE=("$DONE")
    MESSAGE_LN1=("$COPY_SLOT_COMPLETED" "$copy_slot" "$new_slot")
    showDialogMessage

    STATE="MENU_SHOW_LAYOUTS"
    STATE_ARG=""
    return
}

### menuDeleteMaps - Delete selected joystick or remap definitions from inputs and SLOTS
menuDeleteMaps() {
    local find_map
    local search
    local extension
    local counter
    local line
    local slot_directory
    local core_directory

    messageDeleteMaps

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$MENU_DELETE_OPEN_CONFIRMATION")

    if toggleYesNoDialog; then
        STATE="MENU_SETTINGS"
        return
    fi

    if ! menuCoresList "DELETE_MAPS"; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$MENU_DELETE_NO_CORE_DETECTED_1")
        MESSAGE_LN2=("$MENU_DELETE_NO_CORE_DETECTED_2")
        showDialogMessage

        STATE="MENU_SETTINGS"
        return
    fi

    while true; do
        generateHeader "$MENU_DELETE_MAPS $CORE:" 11 72 4

        DIALOG+="
X \"$MENU_DELETE_EXIT_COL1 - $MENU_DELETE_EXIT_COL2\" \
- \"$MENU_DELETE_SEPARATOR\" \
V \"$MENU_DELETE_V3_COL1 - $MENU_DELETE_V3_COL2\" \
J \"$MENU_DELETE_V1_JK_COL1 - $MENU_DELETE_V1_JK_COL2\""

        runDialog

        case "$CHOICE" in
        "X")
            STATE="MENU_ADVANCED_SETTINGS"
            return
            ;;
        "-")
            continue
            ;;
        "V")
            find_map="v3"
            message_selected_map="$MENU_DELETE_JOYSTICK_CONFIRMATION"
            ;;
        "J")
            find_map="v1 jk"
            message_selected_map="$MENU_DELETE_REMAP_CONFIRMATION"
            ;;
        esac

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$message_selected_map")
        MESSAGE_LN2=("$MENU_DELETE_ACTION_CONFIRMATION" "$CORE")

        if toggleYesNoDialog; then
            showCancelMessage "$MENU_DELETE_CANCELED"
            STATE="MENU_SETTINGS"
            return
        fi

        if [ -f "$TMP_FILE" ]; then
            rm -f "$TMP_FILE" 2>/dev/null
        fi

        if [ -f "${TMP_FILE}_2" ]; then
            rm -f "${TMP_FILE}_2" 2>/dev/null
        fi

        for search in $find_map; do
            if [ "$search" = "v1" ]; then
                extension="_advanced"
            else
                extension=""
            fi

            find "${INPUT_MISTER}/" -type f -name "${CORE}${extension}_input_*_${search}.map" >>"$TMP_FILE"
            find "${GCM_GPD}/" -type f -name "${CORE}${extension}_input_*_${search}.map" >>"$TMP_FILE"
        done

        counter=0

        while IFS= read -r line; do
            ((counter++))
            if [ -n "$line" ] && [ "$line" != "/" ]; then
                rm -f "$line" 2>/dev/null
                slot_directory=$(dirname "$line")
                core_directory=$(dirname "$(dirname "$line")")

                case "$slot_directory/" in
                "$GCM_GPD"/*)
                    if [ -z "$(find "$slot_directory" -type f -name "*.map" -print)" ]; then
                        if [ -n "$slot_directory" ] || [ "$slot_directory" != "/" ]; then
                            rm -rf "$slot_directory" 2>/dev/null
                            echo "$core_directory" >>"${TMP_FILE}_2"
                        fi
                    fi
                    ;;
                esac
            fi
        done <"$TMP_FILE"

        if [ -f "${TMP_FILE}_2" ]; then
            sort -u "${TMP_FILE}_2" -o "${TMP_FILE}_2" 2>/dev/null

            while IFS= read -r line; do
                CORE_DIR="$line"
                FLAG_COUNTER_SLOTS="ON"
                countSlots NO_ERROR_MESSAGE
            done <"${TMP_FILE}_2"

            rm -f "${TMP_FILE}_2" 2>/dev/null
        fi

        TITLE=("$INFORMATION")

        if [ "$counter" = 0 ]; then
            MESSAGE_LN1=("$MENU_DELETE_NO_FILES_1")
            MESSAGE_LN2=("$MENU_DELETE_NO_FILES_2")
        else
            MESSAGE_LN1=("$MENU_DELETE_DELETE_FILES")
        fi

        showDialogMessage

        STATE="MENU_SETTINGS"
        return
    done
}

### MenuShowNotes - A page to store GAMEPAD/CORE notes
menuShowNotes() {
    if [ ! -f "${CORE_DIR}/NOTES.txt" ]; then
        touch "${CORE_DIR}/NOTES.txt" 2>/dev/null
    fi

    generateHeader "$SHOW_NOTES_MENU - $SELECT_OPTIONS" 11 70 4 CORE

    DIALOG+="
        X \"$SHOW_NOTES_EXIT_COL1 - $SHOW_NOTES_EXIT_COL2\" \
        - \"$SHOW_NOTES_SEPARATOR\" \
        V \"$SHOW_NOTES_READ_COL1 - $SHOW_NOTES_READ_COL2\" \
        E \"$SHOW_NOTES_EDIT_COL1 - $SHOW_NOTES_EDIT_COL2\""

    runDialog

    case "$CHOICE" in
    "X")
        STATE="MENU_CORE_MAIN"
        ;;
    "-")
        STATE="MENU_SHOW_NOTES"
        ;;
    "V")
        dialog --exit-label "$EXIT" --title "$CORE_DISPLAY - $MODEL_CUT" \
            --textbox "${CORE_DIR}/NOTES.txt" 20 65
        STATE="MENU_SHOW_NOTES"
        ;;
    "E")
        cp "${CORE_DIR}/NOTES.txt" "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 2>/dev/null

        if dialog --ok-label "$SAVE" --cancel-label "$CANCEL" --title "$CORE_DISPLAY - $MODEL_CUT - $SHOW_NOTES_MENU_EDIT" \
            --editbox "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 20 67 2>"$TMP_DIALOG"; then
            sed -i "s/\"/'/g; s/\`/'/g" "$TMP_DIALOG" 2>/dev/null
            cp "$TMP_DIALOG" "${CORE_DIR}/NOTES.txt" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$SHOW_NOTES_COMPLETED")
            showDialogMessage
        else
            showCancelMessage "$SHOW_NOTES_CANCELED"
        fi

        rm -f "$TMP_DIALOG" "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 2>/dev/null
        STATE="MENU_SHOW_NOTES"
        ;;
    esac

    return
}

# =========================================================================== #
# === SECONDARY_FUNCTIONS - Configuration and shared functions in this script #
# =========================================================================== #

# === generate

### adjustLinesMenuSize - Limit LINES_MENU to a maximum of 26 lines
adjustLinesMenuSize() {
    if [ "$LINES_MENU" -gt 26 ]; then
        LINES_MENU=26
        PARAM_3=19
    fi
}

### generateHeader - Generate the header of the dialog menu
generateHeader() {
    local additional_option
    local message_menu
    local title
    local tittle_formatted
    local message_formatted

    # ARGUMENTS:
    # $1 = message to display in the --menu
    # $2 = total number of lines in the dialog
    # $3 = width of the dialog
    # $4 = size of the inner window frame (lines inside the dialog box)
    # $5 = additional options: INCREASE, SHOW_CANCELL_BUTTON or CORE

    additional_option="--no-cancel"
    title="$SLOGAN"

    if [ -n "$1" ]; then
        message_menu="$1"
    fi

    if [ -n "$2" ] && [ "$2" != "NULL" ] && [ "$2" != "SHOW_CANCELL_BUTTON" ]; then
        LINES_MENU="$2"
    elif [ "$2" = "SHOW_CANCELL_BUTTON" ]; then
        additional_option=""
    fi

    if [ -n "$3" ] && [ -n "$4" ]; then
        PARAM_2="$3"
        PARAM_3="$4"
    fi

    if [ "$5" = "INCREASE" ]; then
        LINES_MENU=$((COUNTER_LINES + LINES_MENU))
    elif [ "$5" = "SHOW_CANCELL_BUTTON" ]; then
        additional_option=""
    elif [ "$5" = "CORE" ]; then
        title="$CORE"
    fi

    adjustLinesMenuSize

    tittle_formatted="$(printf "%s - %s - %s" "$title" "$MODEL_CUT" "$ID")"
    message_formatted="$(printf " %s" "$message_menu")"

    DIALOG="dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear $additional_option --no-tags --stdout \\
        --title \"$tittle_formatted\" \\
        --column-separator \"|\" \\
        --menu \"$message_formatted\" $LINES_MENU $PARAM_2 $PARAM_3 \\"
}

### generateHeaderOnDisk - Generate dialog menu header on disk
generateHeaderOnDisk() {
    local message_menu

    # ARGUMENTS:
    message_menu="$1"

    LINES_MENU=$((COUNTER_SLOTS + 8))
    PARAM_2=71
    PARAM_3=$((LINES_MENU - 7))
    adjustLinesMenuSize

    rm -f "${TMP_MENU}.sh" 2>/dev/null

    {
        echo "#!/bin/bash" 2>/dev/null
        echo "TMP_MENU=$TMP_MENU" 2>/dev/null
        echo "TITLE_FORMATTED=\"$(printf "%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")"\" 2>/dev/null
        echo "message=\"$(printf " %s" "$message_menu")"\" 2>/dev/null
        echo "dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear --no-tags \\" 2>/dev/null
        echo "--title \"\$TITLE_FORMATTED\" \\" 2>/dev/null
        echo "--menu \"\$message\" $LINES_MENU $PARAM_2 $PARAM_3 \\" 2>/dev/null
    } >"${TMP_MENU}.sh" 2>/dev/null
}

### generateLayoutsOnDiskRun - Generate layouts (button maps) on disk and run the menu
generateLayoutsOnDiskRun() {
    local option_exclude_input
    local first_slot
    local i
    local index
    local output
    local position

    # ARGUMENTS:
    option_exclude_input="$1"
    first_slot="$2"

    index=0

    {
        echo "- \"       $LAYOUT_TAG -${LINE_TAG}$COMMENTS -----\" \\" 2>/dev/null

        for ((i = 1; i <= COUNTER_SLOTS; i++)); do
            getSlotIndicator "$i"

            if [ "$index" = 20 ]; then
                echo "" >>"$TMP_FILE" 2>/dev/null
                echo "    SLOT  $LAYOUT_TAG        $COMMENTS" >>"$TMP_FILE" 2>/dev/null
                echo "    ----  ------------------------------------------ -------------------" >>"$TMP_FILE" 2>/dev/null
                index=0
            fi

            ((index++))

            if [ "$i" != "$first_slot" ] || [ "$option_exclude_input" != "EXCLUDE" ]; then
                output=$(cat "${CORE_DIR}/SLOT_${i}/LAYOUT.cfg" 2>/dev/null)
                position=$(printf "%3d" $i)
                echo "$i \"${SLOT_INDICATOR} ${position}) ${output}\" \\" 2>/dev/null
            else
                position=$(printf "%3d" $i)
                echo "- \"${SLOT_INDICATOR} ${position}) $SELECTED\" \\" 2>/dev/null
            fi
        done
    } >>"${TMP_MENU}.sh"

    echo "2>\"\$TMP_MENU\"" >>"${TMP_MENU}.sh" 2>/dev/null
    source "${TMP_MENU}.sh"
    MENU_STATUS="$?"
}

### generateMenuLines - Generate menu lines from arguments defining data and options
generateMenuLines() {
    local array_name
    local variable_name
    local cut_line
    local line_type
    local output
    local last_line
    local i
    local output_menu

    # ARGUMENTS:
    array_name="$1"    # Store the array name to be accessed dynamically
    variable_name="$2" # Store the name of the variable to be accessed indirectly
    cut_line="$3"      # Limit output to first 60 characters
    line_type="$4"     # Determine if a new line should be added to DIALOG

    for ((i = 1; i <= $(eval echo "\$$variable_name"); i++)); do
        output=$(eval echo "\${${array_name}[$((i - 1))]}")

        if [ "$cut_line" = "CUT_OUTPUT" ]; then
            output_menu=$(echo "$output" | cut -c1-60 2>/dev/null)
        fi

        if [ "$i" = "$(eval echo "\$$variable_name")" ]; then
            DIALOG+="$i \"$output\""
        else
            if [ "$line_type" = "NEW_LINE" ]; then
                DIALOG+="$i \"$output_menu\" \\
"
            else
                DIALOG+="$i \"$output\" \\"
            fi
        fi
    done
}

### generateLinesArray - Generate COUNTER_LINES and LINES_ARRAY from DIR_TARGET
generateLinesArray() {
    local dir_target

    # ARGUMENTS:
    dir_target="$1"

    sed -i '1{/^[[:space:]]*$/d}' "$dir_target" 2>/dev/null
    COUNTER_LINES=0
    LINES_ARRAY=()

    while IFS= read -r line; do
        LINES_ARRAY[COUNTER_LINES]="$line"
        ((COUNTER_LINES++))
    done <"$dir_target"
}

### generateCoresList - Generate, remove duplicates, and sort the CORES list
generateCoresList() {
    local item
    local check_cores
    local dir
    local header
    local size_header
    local number_spaces
    local string_spaces
    local core_dir
    local file
    local filename
    local setname
    local mgl_name

    if [ "$FLAG_GENERATE_CORES_LIST" = "OFF" ]; then
        return
    fi

    rm -f "${TMP_FILE}_LINES" 2>/dev/null

    while IFS= read -r item; do
        check_cores+=("$item")
    done <"${GCM_CFG}/folders.cfg"

    for dir in "${check_cores[@]}"; do
        messageProcessingList "$dir"

        rm -f "${TMP_FILE}_HEADER" 2>/dev/null
        rm -f "${TMP_FILE}_LIST" 2>/dev/null

        header="${dir#_}"
        size_header=${#header}
        number_spaces=$(((40 - size_header) / 2))
        string_spaces=$(printf "%${number_spaces}s" "")

        echo "_______________________________________________" >"${TMP_FILE}_HEADER"
        echo "$string_spaces=== $header ===" >>"${TMP_FILE}_HEADER"

        core_dir="${MISTER_CORES_FOLDERS}/_${dir}"

        if [ -d "$core_dir" ]; then
            if [ "$dir" = "Unstable" ]; then
                for file in "$core_dir"/*.rbf; do
                    if [ -f "$file" ]; then
                        filename=$(basename "$file" .rbf)
                        filename=$(echo "$filename" |
                            sed 's/_[^_]*_[^_]*_[^_]*$//' |
                            sed 's/_[^_]*$//')

                        if ! echo "$filename" | grep -q 'Arcade-'; then
                            echo "$filename" >>"${TMP_FILE}_LIST"
                        fi
                    fi
                done
            else
                for file in "$core_dir"/*.rbf; do
                    if [ -f "$file" ]; then
                        filename=$(basename "$file" .rbf)
                        filename=$(echo "$filename" | sed 's/_[^_]*$//')
                        echo "$filename" >>"${TMP_FILE}_LIST"
                    fi
                done
            fi

            for file in "$core_dir"/*.mgl; do
                if [ -f "$file" ]; then
                    setname=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$file" 2>/dev/null)

                    if [ -z "$setname" ]; then
                        continue
                    fi

                    mgl_name=$(basename "$file" .mgl)
                    echo "${setname} ==> ${mgl_name}" >>"${TMP_FILE}_LIST"
                fi
            done

            awk '!seen[$0]++' "${TMP_FILE}_LIST" |
                sort >"${TMP_FILE}_TMPLIST" &&
                mv "${TMP_FILE}_TMPLIST" "${TMP_FILE}_LIST" 2>/dev/null

            cat "${TMP_FILE}_HEADER" "${TMP_FILE}_LIST" >>"${TMP_FILE}_LINES"
        fi
    done

    cat "${TMP_FILE}_LINES" >"${GCM_TMP}/cores_list_processed" 2>/dev/null
    rm -f "${TMP_FILE}_HEADER" "${TMP_FILE}_LIST" "${TMP_FILE}_LINES" 2>/dev/null

    mv "${GCM_TMP}/cores_list_processed" "${GCM_TMP}/cores_list" 2>/dev/null

    FLAG_GENERATE_CORES_LIST="OFF"
}

### generateTextFromOption - Apply the selected text formatting options to a file
generateTextFromOption() {
    local target_file

    # ARGUMENTS:
    target_file="$1"

    if [ "$CASE" = "UPPERCASE" ]; then
        convertTextToUpperCase "$target_file"
        if [ "$target_file" = "${GCM_DAT}/HELP.txt" ]; then
            restoreHelpStrings "$target_file"
        fi
    fi

    if { [ "$LANGUAGE" = "pt" ] || [ "$LANGUAGE" = "es" ]; } && [ "$MENU_ACCENTS" = "OFF" ]; then
        removeAccentsFromFile "$target_file"
    fi
}

# === run and store

### runDialog - Execute the generated dialog menu and store CHOICE, STATUS_MESSAGE and CORE
runDialog() {
    local function_parameter

    # ARGUMENTS:
    function_parameter="$1"

    CHOICE=$(eval "$DIALOG")
    STATUS_MESSAGE="$?"

    if [ "$function_parameter" = "CORE_CHOICE" ]; then
        if [ "$CHOICE" != "-" ] && [ "$CHOICE" != "X" ]; then
            CORE=$(sed -n "${CHOICE}p" "$TMP_MENU" 2>/dev/null)
        fi
        rm -f "$TMP_MENU" 2>/dev/null
    fi

    return "$STATUS_MESSAGE"
}

### storeChoiceAndClean - Store selection and delete temporary files
storeChoiceAndClean() {
    if [ "$MENU_STATUS" -eq 1 ]; then
        rm -f "${TMP_MENU}.sh" "$TMP_MENU" 2>/dev/null

        STATE="MENU_CORE_MAIN"
        return 1
    fi

    CHOICE=$(<"$TMP_MENU")
    rm -f "${TMP_MENU}.sh" "$TMP_MENU" 2>/dev/null
}

# === gamepad

### prepareGamepadMenu - Start generating the menu with registered gamepads
prepareGamepadMenu() {
    local message_gamepad_menu
    local function_option
    local add_lines

    # ARGUMENTS:
    message_gamepad_menu="$1"
    function_option="$2"

    if [ "$function_option" = "ADD_LINES" ]; then
        add_lines=2
    else
        add_lines=0
    fi

    generateLinesArray "$GCM_RGP"

    LINES_MENU=$((COUNTER_LINES + 7 + add_lines))
    MESSAGE_MENU="$message_gamepad_menu"
    PARAM_2=67
    PARAM_3=$((LINES_MENU - 7))
}

### recordGamepadData - Register the gamepad, update SELECTED_GAMEPAD ID and MODEL, and sort
recordGamepadData() {
    {
        echo "ID=\"$ID_CHOICE\""
        echo "MODEL=\"$MODEL_CHOICE\""
    } >"$GCM_SGP" 2>/dev/null

    grep "$ID_CHOICE" "$GCM_RGP" >"$TMP_FILE" 2>/dev/null
    grep -v "$ID_CHOICE" "$GCM_RGP" >>"$TMP_FILE" 2>/dev/null
    mv "$TMP_FILE" "$GCM_RGP" 2>/dev/null
}

### importSelectedGamepadData - Import the ID and MODEL of the registered controller
importSelectedGamepadData() {
    source "$GCM_SGP"
    MODEL_CUT=$(echo "$MODEL" | cut -c1-30 2>/dev/null)
}

### countRegisteredGamepads - Count registered gamepads (COUNTER_GAMEPADS)
countRegisteredGamepads() {
    if [ ! -f "$GCM_RGP" ] || ! grep -q "_" "$GCM_RGP"; then
        COUNTER_GAMEPADS=0
        updateNoGamepadMessage
        messageNoGamepadConfigured
        STATE="MENU_REGISTER_GAMEPAD"
        return 1
    else
        COUNTER_GAMEPADS=$(wc -l <"$GCM_RGP" 2>/dev/null)
    fi

    importSelectedGamepadData
}

### checkGamepads - 0: menuRegisterGamepad; >=1 & none: menuSelectGamepad
checkGamepads() {
    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        messageNoGamepadConfigured
        STATE="MENU_REGISTER_GAMEPAD"
        return 1
    elif [ "$COUNTER_GAMEPADS" -ge 1 ] && [ "$ID" = "" ]; then
        STATE="MENU_SELECT_GAMEPAD"
        STATE_ARG="SHOW_CANCELL_BUTTON"
        return 1
    fi
}

### checkRegisteredGamepads - Check COUNTER_GAMEPADS; if 0, go to menuGamepads
checkRegisteredGamepads() {
    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        STATE="MENU_GAMEPADS"
        return 1
    fi
}

### organizeGamepadIds - Remove duplicate records and sort them for prevention
organizeGamepadIds() {
    awk '!seen[$1]++' "$GCM_LGI" | sort >"$TMP_FILE" 2>/dev/null
    mv "$TMP_FILE" "$GCM_LGI" 2>/dev/null
}

### runDialogRegisteredGamepads - Show dialog with registered gamepads and/or save MODEL and ID
runDialogRegisteredGamepads() {
    local flag_load
    local flag_skip

    # ARGUMENTS:
    flag_load="$1"
    flag_skip="$2"

    CHOICE=$(eval "$DIALOG")

    if [ "$?" -eq 1 ] || { [ "$CHOICE" = "1" ] && [ "$flag_skip" = "SKIP_IF_FIRST" ] &&
        [ "$FLAG_GAMEPAD_MESSAGE_MODE" = "DEFAULT" ] && [ "$ID" != "" ]; }; then
        STATE="MENU_GAMEPADS"
        return 1
    fi

    if [ "$flag_load" = "LOAD_GAMEPAD" ] && [ "$CHOICE" != "X" ] && [ "$CHOICE" != "-" ]; then
        ID_CHOICE=$(sed -n "${CHOICE}p" "$GCM_RGP" | cut -c1-9 2>/dev/null)
        MODEL_CHOICE=$(sed -n "${CHOICE}p" "$GCM_RGP" | cut -c13- 2>/dev/null)
    fi
}

### showUpdateList - Show updated gamepad list
showUpdateList() {
    local function_argument

    # ARGUMENTS:
    function_argument="${1:-0}"

    if [ "$function_argument" = "SHOWLIST" ]; then
        STATE="MENU_HOME"
    else
        STATE="MENU_GAMEPADS"
        if [ "$function_argument" -eq 0 ]; then
            return
        fi
    fi

    MODEL_CUT="$MESSAGE_UPDATE_LIST"
    ID=""
    menuListGamepads RETURN
    importSelectedGamepadData
}

### updateNoGamepadMessage - Update NO_GAMEPAD message in selected language
updateNoGamepadMessage() {
    if [ ! -f "$GCM_RGP" ] || [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        {
            echo "ID=\"\""
            echo "MODEL=\"$NO_GAMEPAD\""
        } >"$GCM_SGP" 2>/dev/null

        importSelectedGamepadData
    fi
}

### messageNoGamepadConfigured - Show message if no gamepad is registered
messageNoGamepadConfigured() {
    dialog --title "$SLOGAN - $ATTENTION" --textbox "${GCM_DAT}/NO_GAMEPAD.txt" 16 72
}

# === verify

### verifyGamepadDir - Checks and recreates the gamepad directory if missing
verifyGamepadDir() {
    if [ "$ID" = "" ]; then
        return
    fi

    if [ ! -d "$GAMEPAD_DIR" ]; then
        mkdir "$GAMEPAD_DIR" 2>/dev/null
    fi

    if [ ! -f "${GAMEPAD_DIR}/rename.cfg" ]; then
        touch "${GAMEPAD_DIR}/rename.cfg" 2>/dev/null
    fi

    if [ ! -f "${GAMEPAD_DIR}/gamepad_tag.txt" ]; then
        echo "${LAYOUT_TAGS[1]}" >"${GAMEPAD_DIR}/gamepad_tag.txt" 2>/dev/null
    fi
}

### verifyTipsFlagsHOME - Verify flags and variables and set tip text in HOME and GAMEPADS menu
verifyTipsFlagsHome() {
    SHOW_TIPS_MESSAGE_HOME="OFF"
    HOME_HELP_INDICATOR=""
    HOME_EXIT_INDICATOR=""
    HOME_GAMEPAD_INDICATOR=""
    HOME_ADD_INDICATOR=""
    GAMEPADS_REGISTER_INDICATOR=""

    # If FLAG_SHOW_TIPS is ON, check the other conditions
    if [ "$FLAG_SHOW_TIPS" = "ON" ]; then
        if [ "$FLAG_SHOW_TIP_HELP" = "ON" ]; then
            SHOW_TIPS_MESSAGE_HOME="ON"
            MESSAGE_HELP="ON"
            HOME_HELP_INDICATOR="$INDICATOR"
            FOOTER_MESSAGE_HOME="$HOME_HELP_SHOW_MESSAGE"
            return
        fi

        if [ "$NO_MISTER_GAMEPAD" = "ON" ]; then
            SHOW_TIPS_MESSAGE_HOME="ON"
            NO_MISTER_GAMEPAD_MESSAGE="ON"
            HOME_EXIT_INDICATOR="$INDICATOR"
            FOOTER_MESSAGE_HOME="$HOME_NO_GAMEPAD_SHOW_MESSAGE"
            return
        fi

        if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
            SHOW_TIPS_MESSAGE_HOME="ON"
            MESSAGE_GAMEPADS="ON"
            HOME_GAMEPAD_INDICATOR="$INDICATOR"
            GAMEPADS_REGISTER_INDICATOR="$INDICATOR"
            FOOTER_MESSAGE_HOME="$GAMEPADS_REGISTER_SHOW_MESSAGE"
            FOOTER_MESSAGE_GAMEPADS="$FOOTER_MESSAGE_HOME"
            return
        fi

        if [ "$COUNTER_CORES" -eq 0 ]; then
            SHOW_TIPS_MESSAGE_HOME="ON"
            MESSAGE_CORES="ON"
            HOME_ADD_INDICATOR="$INDICATOR"
            FOOTER_MESSAGE_HOME="$HOME_ADD_CORE_SHOW_MESSAGE"
            return
        fi
    fi
}

### verifyTipsFlagsCore - Verify flags and variables and set tip text in CORE menu
verifyTipsFlagsCore() {
    SHOW_TIPS_MESSAGE_CORE="OFF"
    CORE_SAVE_INDICATOR=""
    CORE_EDIT_LAYOUT_INDICATOR=""
    CORE_EDIT_GAMES_INDICATOR=""

    if [ "$FLAG_SHOW_TIPS" = "ON" ]; then
        if [ "$COUNTER_SLOTS" -eq 0 ]; then
            MESSAGE_SAVE_SLOT="ON"
            SHOW_TIPS_MESSAGE_CORE="ON"
            FOOTER_MESSAGE_CORE="$CORE_SAVE_SHOW_MESSAGE"
            CORE_SAVE_INDICATOR="$INDICATOR"
            return
        fi

        if [ "$FLAG_SHOW_TIPS_EDIT_LAYOUTS" = "ON" ] || [ "$FLAG_SHOW_TIPS_EDIT_GAMES" = "ON" ]; then
            if [ "$FLAG_SHOW_TIPS_EDIT_LAYOUTS" = "ON" ]; then
                SHOW_TIPS_MESSAGE_CORE="ON"
                MESSAGE_EDIT_LAYOUT="ON"
                FOOTER_MESSAGE_CORE="$CORE_LAYOUT_SHOW_MESSAGE"
                CORE_EDIT_LAYOUT_INDICATOR="$INDICATOR"
                return
            fi

            if [ "$FLAG_SHOW_TIPS_EDIT_GAMES" = "ON" ]; then
                SHOW_TIPS_MESSAGE_CORE="ON"
                MESSAGE_EDIT_GAMES="ON"
                FOOTER_MESSAGE_CORE="$CORE_GAMES_SHOW_MESSAGE"
                CORE_EDIT_GAMES_INDICATOR="$INDICATOR"
                return
            fi
        fi
    fi
}

# === messsage and dialog

### processMessage - Processe the message text before formatting
processMessage() {
    local -n proc_msg=$1
    printf "${proc_msg[0]}" "${proc_msg[@]:1}"
}

### formatMessage - Format the message string for display
formatMessage() {
    if [[ ${#TITLE[@]} -gt 0 ]]; then
        TITLE_FORMATTED=$(processMessage TITLE)
    fi

    if [[ ${#MESSAGE_LN1[@]} -gt 0 ]]; then
        MESSAGE_FORMATTED_LN1=$(processMessage MESSAGE_LN1)
    fi

    if [[ ${#MESSAGE_LN2[@]} -gt 0 ]]; then
        MESSAGE_FORMATTED_LN2=$(processMessage MESSAGE_LN2)
    fi
}

### adjustMenuSize - Adjust menu format based on text size
adjustMenuSize() {
    SIZE_TITLE=${#TITLE_FORMATTED}
    SIZE_MESSAGE_LN1=${#MESSAGE_FORMATTED_LN1}
    SIZE_MESSAGE_LN2=${#MESSAGE_FORMATTED_LN2}

    if [ "$SIZE_MESSAGE_LN1" -gt "$SIZE_MESSAGE_LN2" ]; then
        SIZE_MESSAGE="$SIZE_MESSAGE_LN1"
    else
        SIZE_MESSAGE="$SIZE_MESSAGE_LN2"
    fi

    if [ "$SIZE_TITLE" -lt "$SIZE_MESSAGE" ]; then
        SIZE_DIALOG="$SIZE_MESSAGE"
    else
        SIZE_DIALOG="$SIZE_TITLE"
    fi

    SIZE_DIALOG=$((SIZE_DIALOG + 5))
}

### formatDialogMessage - Format the dialog message to 1 or 2 lines
formatDialogMessage() {
    if [ "$SIZE_MESSAGE_LN2" -eq 0 ]; then
        OUTPUT="\n$MESSAGE_FORMATTED_LN1"
        SIZE_LINES="7"
    else
        OUTPUT="\n$MESSAGE_FORMATTED_LN1\n\n$MESSAGE_FORMATTED_LN2"
        SIZE_LINES="9"
    fi
}

### yesNoDialog - Open a 'Yes/No' dialog
yesNoDialog() {
    formatMessage
    adjustMenuSize
    formatDialogMessage
    dialog --yes-label "$YES" --no-label "$NO" --title "$TITLE_FORMATTED" \
        --yesno "$OUTPUT" "$SIZE_LINES" "$SIZE_DIALOG"
    resetDialogMessage

    return "$STATUS_MESSAGE"
}

### toggleYesNoDialog - Temporarily toggle Yes/No buttons, run yesNoDialog, then restore them
toggleYesNoDialog() {
    local yes_current
    local no_current
    local dialog_status

    yes_current="$YES"
    no_current="$NO"

    YES="$no_current"
    NO="$yes_current"

    yesNoDialog
    dialog_status="$?"

    YES="$yes_current"
    NO="$no_current"

    return "$dialog_status"
}

### inputDialog - Open an input box in the dialog
inputDialog() {
    local button

    # Arguments:
    if [ "$1" = "" ]; then
        button="$OK"
    else
        button="$1"
    fi

    formatMessage
    adjustMenuSize
    formatDialogMessage
    SIZE_LINES=$((SIZE_LINES + 2))

    DIALOG="dialog --ok-label \"$button\" --cancel-label \"$CANCEL\" --title --stdout \"$TITLE_FORMATTED\" --inputbox \"$OUTPUT\" $SIZE_LINES $SIZE_DIALOG"

    TMP_INPUT=$(eval "$DIALOG")

    resetDialogMessage

    return "$STATUS_MESSAGE"
}

### resetDialogMessage - Clear the fields of the dialog
resetDialogMessage() {
    STATUS_MESSAGE="$?"
    TITLE=()
    MESSAGE_LN1=()
    MESSAGE_LN2=()
    TITLE_FORMATTED=""
    MESSAGE_FORMATTED_LN1=""
    MESSAGE_FORMATTED_LN2=""
}

### alertMiSTerNoMaps - Show message if MiSTer configs are missing: 'Joystick' or 'B/K remap'
alertMiSTerNoMaps() {
    LINES=$(($(wc -l <"${GCM_DAT}/ALERT_NO_MAPS.txt") + 5))
    dialog --title "$SLOGAN - $ATTENTION" --textbox "${GCM_DAT}/ALERT_NO_MAPS.txt" "$LINES" 72
}

### showDialogMessage - Display a message in the dialog
showDialogMessage() {
    formatMessage
    adjustMenuSize
    formatDialogMessage
    dialog --ok-label "$EXIT" --title "$TITLE_FORMATTED" \
        --msgbox "$OUTPUT" "$SIZE_LINES" "$SIZE_DIALOG"
    resetDialogMessage
}

### showCancelMessage - Display a Show cancellation message when the action is canceled
showCancelMessage() {
    local msg_canceled

    # ARGUMENTS:
    msg_canceled="$1"

    TITLE=("$CANCELED")
    MESSAGE_LN1=("$msg_canceled")
    showDialogMessage
}

### showNoInputMessage - Display a message when no input is provided
showNoInputMessage() {
    TITLE=("$ATTENTION")
    MESSAGE_LN1=("$MSG_BLANK")
    showDialogMessage
}

### showSlotErrorMessage - Display a message if structure errors are detected
showSlotStructureErrorMessage() {
    TITLE=("$ATTENTION")
    MESSAGE_LN1=("$CORE_STRUCTURE_ERROR_COL1")
    MESSAGE_LN2=("$CORE_STRUCTURE_ERROR_COL2")
    showDialogMessage
}

### showNoGamepadConfigForCoreMessage - Display a message when no gamepad config is found for the CORE
showNoGamepadConfigForCoreMessage() {
    TITLE=("$ATTENTION")
    MESSAGE_LN1=("$SLOT_SAVE_NO_GAMEPAD_CONFIG_COL1")
    MESSAGE_LN2=("$SLOT_SAVE_NO_GAMEPAD_CONFIG_COL2")
    showDialogMessage
}

### messageSlotsNotFound - Show message if no SLOTS is found
messageSlotsNotFound() {
    TITLE=("$CORE_DISPLAY - $MODEL_CUT - $LAST_LOAD:[$CURRENT]")
    MESSAGE_LN1=("$SLOTS_NOT_FOUND")
    showDialogMessage
}

### messageProcessingWait - Display a message to wait
messageProcessingWait() {
    local sizetext
    local sizedialog

    sizetext=${#PROCESSING_DIALOG}
    sizedialog=$((sizetext + 4))
    dialog --title "$INFORMATION" \
        --infobox "\n$PROCESSING_DIALOG" 5 "$sizedialog"
}

### messageProcessingList - Display a message while processing the list
messageProcessingList() {
    local dir
    local sizetext_1
    local sizetext_2
    local sizedir
    local sizedialog

    # ARGUMENTS:
    dir="$1"

    sizetext_1=${#PROCESSING_DIR}
    sizetext_2=${#PROCESSING_WAIT}
    sizedir=${#dir}
    sizedialog=$((sizetext_1 + sizetext_2 + sizedir + 12))
    dialog --title "$INFORMATION" \
        --infobox "\n$PROCESSING_DIR '$dir'. $PROCESSING_WAIT..." 5 "$sizedialog"
}

### messageDeleteMaps - Display messages related to deleting joystick or remap definitions
messageDeleteMaps() {
    dialog --title "$SLOGAN - $ATTENTION" --textbox "${GCM_DAT}/ALERT_DELETE_MAPS.txt" 25 61
}

### testFontSizeScreen -
testFontSizeScreen() {
    clear

    dialog --exit-label "$EXIT" --title "$FONT_SIZE_TEST_SCREEN" \
        --textbox "${GCM_DAT}/MiSTer_Kun_message.txt" 26 72

    rm -f "$TMP_FILE" 2>/dev/null
}

# === backup

### generateMenuBackup - Generate the menu from the backup files found on disk
generateMenuBackup() {
    local backup_message
    local backups_found
    local line
    local i
    local output

    # ARGUMENTS:
    backup_message="$1"
    backups_found=$(find "$MISTER_ROOT" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' | wc -l 2>/dev/null)

    if [ "$backups_found" -eq 0 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$NO_BACKUP_FILES")
        showDialogMessage

        STATE="MENU_BACKUP"
        return 1
    fi

    find "$MISTER_ROOT" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' >"$TMP_MENU"
    BACKUPS=()

    while IFS= read -r line; do
        BACKUPS+=("$line")
    done <"$TMP_MENU"

    rm "$TMP_MENU"

    LINES_MENU=$((backups_found + 9))
    PARAM_2=67
    PARAM_3=$((LINES_MENU - 7))
    adjustLinesMenuSize

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \\
            --title \"$SLOGAN - $MODEL_CUT - $ID\" \\
            --menu \"$backup_message\" $LINES_MENU $PARAM_2 $PARAM_3 \\
X \"$EXIT_MENU\" \\
- \"$SEPARATOR_DEFAULT\" \\"

    for ((i = 0; i < ${#BACKUPS[@]}; i++)); do
        output=$(basename "${BACKUPS[$i]}")

        if [ "$i" -lt $((${#BACKUPS[@]} - 1)) ]; then
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\" \\"
        else
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\""
        fi
    done

    runDialog
}

### restoreBackupFiles - Restore backup files from a .zip archive
restoreBackupFiles() {
    local zip_file
    local backup_type
    local bkp_dir
    local extraction_dir

    # ARGUMENTS:
    zip_file="$1"
    backup_type="$2"

    for directory in "$GCM_CFG" "$GCM_DAT" "$GCM_GPD"; do
        if [ -d "$directory" ] && [ "$directory" != "/" ]; then
            rm -rf "$directory" 2>/dev/null
        fi
    done

    bkp_dir="${GCM_TMP}/Backup-GCM-MiSTer"
    mkdir -p "$bkp_dir" 2>/dev/null
    extraction_dir="$bkp_dir/$(basename "$zip_file" .zip)"

    if [ "$backup_type" = "FULL" ]; then
        extraction_dir="${extraction_dir//full-/}"
    fi

    if [[ "$extraction_dir" != *Backup-GCM-MiSTer* ]]; then
        return
    fi

    rm -rf "$extraction_dir" 2>/dev/null
    unzip "$zip_file" -d "$bkp_dir" >/dev/null 2>&1

    mv "$extraction_dir"/gamepads "$GCM_DIR/" 2>/dev/null
    mv "$extraction_dir"/configs "$GCM_DIR/" 2>/dev/null
    mv "$extraction_dir"/data "$GCM_DIR/" 2>/dev/null

    if [ "$backup_type" = "FULL" ]; then
        mv "$extraction_dir"/*.map "$INPUT_MISTER"/ 2>/dev/null
    fi

    if [ -d "$bkp_dir" ] && [ "$bkp_dir" != "/" ]; then
        rm -rf "$bkp_dir" 2>/dev/null
    fi

    generateGCMStaticFiles

    TITLE=("$DONE")
    MESSAGE_LN1=("$RESTORE_COMPLETED")
    showDialogMessage
}

# === CORES

### addExpertModeFolder - Add folder and its subfolders to the Expert Mode menu
addExpertModeFolder() {
    local dir
    local name
    local filtered_name
    local option
    local lines
    local window
    local subdir
    local subname
    local subfiltered_name
    local suboption

    # ARGUMENTS
    dir="$1"

    if [ ! -d "$dir" ]; then
        return
    fi

    name="${dir#"$MISTER_CORES_FOLDERS"/}"

    if [ "$name" = "_Computer/_X68000 Games" ]; then
        return
    fi

    filtered_name="${name#_}"

    if grep -Fqx "$filtered_name" "${GCM_CFG}/folders.cfg" 2>/dev/null; then
        option="on"
    else
        option="off"
    fi

    folders+=("$filtered_name" "" "$option")
    ((lines++))
    ((window++))

    if [ "$name" = "_Arcade" ] || [ "$name" = "_#Insert-Coin" ]; then
        return
    fi

    for subdir in "$dir"/_*; do
        if [ -d "$subdir" ]; then
            subname="${subdir#"$MISTER_CORES_FOLDERS"/}"

            if [ "$subname" = "_Computer/_X68000 Games" ]; then
                continue
            fi

            subfiltered_name="${subname#_}"

            if grep -Fqx "$subfiltered_name" "${GCM_CFG}/folders.cfg" 2>/dev/null; then
                suboption="on"
            else
                suboption="off"
            fi

            folders+=("$subfiltered_name" "" "$suboption")
            ((lines++))
            ((window++))
        fi
    done
}

### checkTypedCore - Check if the typed CORE exists and is not already added
checkTypedCore() {
    local check_cores
    local find_cores
    local dir
    local check
    local filename
    local filepath
    local core_name
    local suffix
    local check_mgl
    local setname

    check_cores=()

    if [ -d "$GAMEPAD_DIR"/"$CORE_CHOICE" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$CHECK_CORE_ALREADY_EXISTS")
        showDialogMessage

        STATE="MENU_ADD_CORE"
        return 1
    fi

    while IFS= read -r item; do
        check_cores+=("${MISTER_CORES_FOLDERS}/_${item}")
    done <"${GCM_CFG}/folders.cfg"

    find_cores=0

    for dir in "${check_cores[@]}"; do
        check=""

        while IFS= read -r filepath; do
            filename="${filepath##*/}"

            if [ "$filename" = "$CORE_CHOICE.rbf" ]; then
                check="$filepath"
                break
            fi

            core_name="${filename%.rbf}"

            if [ "${core_name%_*}" = "$CORE_CHOICE" ]; then
                suffix="${core_name##*_}"

                case "$suffix" in
                '' | *[!0-9]*) ;;
                *)
                    check="$filepath"
                    break
                    ;;
                esac
            fi
        done <<EOF
$(find "$dir" -type f -iname "$CORE_CHOICE*.rbf" 2>/dev/null)
EOF

        check_mgl=$(find "$dir" -type f -name "*.mgl" 2>/dev/null |
            while read -r filepath; do
                setname=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath" 2>/dev/null)

                if [ "$setname" = "$CORE_CHOICE" ]; then
                    echo "$filepath"
                fi
            done)

        if [ -n "$check" ] || [ -n "$check_mgl" ]; then
            ((find_cores++))
        fi
    done

    if [ "$find_cores" -eq 0 ]; then
        TITLE=("%s" "$ATTENTION")
        MESSAGE_LN1=("$CHECK_CORE_NOT_FOUND" "$CORE_CHOICE")
        showDialogMessage

        return 1
    fi
}

### addCoreChoice - Add selected or entered CORE
addCoreChoice() {
    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$ADD_CORE_CHOICE_QUESTION" "$CORE_CHOICE")

    if ! yesNoDialog; then
        showCancelMessage "$ADD_CORE_CHOICE_CANCELED"

        STATE="MENU_HOME"
        return
    fi

    if [ -d "${GAMEPAD_DIR}/${CORE_CHOICE}-stored" ]; then
        mv "${GAMEPAD_DIR}/${CORE_CHOICE}-stored" "${GAMEPAD_DIR}/${CORE_CHOICE}" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$ADD_CORE_CHOICE_RESTORED" "$CORE_CHOICE")
        showDialogMessage
    else
        mkdir "${GAMEPAD_DIR}/${CORE_CHOICE}" 2>/dev/null
        checkCoreConfig "$CORE_CHOICE"

        TITLE=("$DONE")
        MESSAGE_LN1=("$ADD_CORE_CHOICE_CREATED" "$CORE_CHOICE")
        showDialogMessage
    fi

    ((COUNTER_CORES++))
}

### checkCoreConfig - Create the CORE configuration file if missing
checkCoreConfig() {
    local core

    # ARGUMENTS:
    core="$1"

    if [ ! -f "${GAMEPAD_DIR}/${core}/${core}.cfg" ]; then
        {
            echo "show_tips_edit_games=$FLAG_SHOW_TIPS"
            echo "show_tips_edit_layouts=$FLAG_SHOW_TIPS"
            echo "selected_SLOT=X"
        } >"${GAMEPAD_DIR}/${core}/${core}".cfg 2>/dev/null
    fi
}

### generateCoresData - Generate LINES_MENU, and array LINES_CORES
generateCoresData() {
    local line

    LINES_CORES=()
    find "$GAMEPAD_DIR" -maxdepth 1 -type d ! -path "$GAMEPAD_DIR" -exec basename {} \; >"$TMP_MENU" 2>/dev/null
    sed -i '/-stored$/d' "$TMP_MENU" 2>/dev/null

    if ls -d "$GAMEPAD_DIR"/*/ &>/dev/null; then
        while IFS= read -r line; do
            line=$(renameCoreIfNeeded "$line")
            LINES_CORES+=("$line")
        done <"$TMP_MENU"
    fi

    LINES_MENU=$((COUNTER_CORES + 9))

    if [ "$COUNTER_CORES" -eq 0 ]; then
        ((LINES_MENU++))
    fi
}

### counterCores - Count added CORES
counterCores() {
    if ! ls -d "$GAMEPAD_DIR"/*/ 1>/dev/null 2>&1; then
        COUNTER_CORES=0
        return
    fi

    if [ "$FLAG_COUNTER_CORES" = "ON" ]; then
        find "$GAMEPAD_DIR" -maxdepth 1 -type d ! -path "$GAMEPAD_DIR" -exec basename {} \; | grep -v '^$' >"$TMP_FILE" 2>/dev/null
        sed -i '/-stored$/d' "$TMP_FILE" 2>/dev/null
        COUNTER_CORES=$(wc -l <"$TMP_FILE")
        rm -f "$TMP_FILE" 2>/dev/null
        FLAG_COUNTER_CORES="OFF"
    fi
}

### checkCounterCores - Check COUNTER_CORES; if 0, return to the menuHome
checkCounterCores() {
    if [ "$COUNTER_CORES" -eq 0 ]; then
        STATE="MENU_HOME"
        return 1
    fi
}

### loadCoreConfigContents - Loads CORE config contents and stores variables in the script
loadCoreConfigContents() {
    CURRENT=$(grep -o '^[[:space:]]*selected_SLOT=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" |
        cut -d'=' -f2 2>/dev/null)
    FLAG_SHOW_TIPS_EDIT_GAMES=$(grep -o '^[[:space:]]*show_tips_edit_games=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" |
        cut -d'=' -f2 2>/dev/null)
    FLAG_SHOW_TIPS_EDIT_LAYOUTS=$(grep -o '^[[:space:]]*show_tips_edit_layouts=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" |
        cut -d'=' -f2 2>/dev/null)
}

### renameCoreIfNeeded - If a rename exists in rename.cfg (CORE@@DISPLAY), return DISPLAY; otherwise return original CORE
renameCoreIfNeeded() {
    local line
    local rename_file
    local result

    # ARGUMENTS:
    line="$1"

    rename_file="${GAMEPAD_DIR}/rename.cfg"
    result=$(awk -F'@@' -v core="$line" '$1==core {print $2; exit}' "$rename_file")

    if [ -n "$result" ]; then
        printf '%s\n' "$result"
    else
        printf '%s\n' "$line"
    fi
}

### renameCoreDisplayIfNeeded - Set CORE_DISPLAY based on rename.cfg (CORE@%DISPLAY); fallback to original CORE if not found
renameCoreDisplayIfNeeded() {
    local line
    local new_name

    # ARGUMENTS:
    line="$1"

    new_name=$(awk -F'@@' -v core="$line" '$1==core {print $2; exit}' "${GAMEPAD_DIR}/rename.cfg")

    if [ -n "$new_name" ]; then
        CORE_DISPLAY="$new_name"
    else
        CORE_DISPLAY="$line"
    fi
}

# === SLOTS

### checkOneSlot - Show message if one slot exists
checkOneSlot() {
    if [ "$COUNTER_SLOTS" -eq 1 ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$ONLY_ONE_1")
        MESSAGE_LN2=("$ONLY_ONE_2")
        showDialogMessage

        STATE="MENU_CORE_MAIN"
        return 1
    fi
}

### relocateSlot - relocateSlot SLOT from source to target
relocateSlot() {
    local source_slot
    local target_slot

    # ARGUMENTS:
    source_slot="$1"
    target_slot="$2"

    mv "${CORE_DIR}/SLOT_${source_slot}" "${CORE_DIR}/SLOT_${target_slot}" 2>/dev/null
}

### reorganizeSlotsOrder - Reorganize the order of SLOTS after changes
reorganizeSlotsOrder() {
    local first_slot_rso
    local condition_rso
    local inc_rso
    local i

    # ARGUMENTS:
    first_slot_rso="$1"
    condition_rso="$2"
    inc_rso="$3"

    for ((i = first_slot_rso; condition_rso; i += inc_rso)); do
        mv "${CORE_DIR}/SLOT_$((i + inc_rso))" "${CORE_DIR}/SLOT_${i}" 2>/dev/null
    done
}

### createNewSlot - Create new SLOT from MiSTer .map; create empty GAMES and LAYOUTS files/lists
createNewSlot() {
    local new_slot

    # ARGUMENTS:
    new_slot="$1"

    if [ ! -d "${CORE_DIR}/SLOT_${new_slot}" ]; then
        mkdir "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null
    fi

    if [ "$TYPE" = "v3" ] || [ "$TYPE" = "v3_jk" ] || [ "$TYPE" = "v3_v1" ] ||
        [ "$TYPE" = "v3_v1_jk" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null
    fi

    if [ "$TYPE" = "jk" ] || [ "$TYPE" = "v3_jk" ] || [ "$TYPE" = "v1_jk" ] ||
        [ "$TYPE" = "v3_v1_jk" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null
    fi

    if [ "$TYPE" = "v1" ] || [ "$TYPE" = "v3_v1" ] || [ "$TYPE" = "v1_jk" ] ||
        [ "$TYPE" = "v3_v1_jk" ]; then
        cp "$INPUT_MISTER"/"$CORE"_advanced_input_"$ID"_v1.map "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null
    fi

    touch "${CORE_DIR}/SLOT_${new_slot}/GAMES.cfg" 2>/dev/null
    touch "${CORE_DIR}/SLOT_${new_slot}/LAYOUT.cfg" 2>/dev/null
}

### countSlots - Count slots and fix structure if errors are found
countSlots() {
    local show_error_message
    local i
    local slot_number
    local slot_test
    local new_slot

    # ARGUMENTS:
    show_error_message="$1"

    if [ "$FLAG_COUNTER_SLOTS" = "OFF" ]; then
        return
    fi

    COUNTER_SLOTS=$(find "$CORE_DIR" -type d -name "SLOT_*" 2>/dev/null | wc -l)

    for ((i = 1; i <= COUNTER_SLOTS; i++)); do
        if [[ ! -d "${CORE_DIR}/SLOT_${i}" ]] ||
            [[ ! -f "${CORE_DIR}/SLOT_${i}/LAYOUT.cfg" ]] ||
            [[ ! -f "${CORE_DIR}/SLOT_${i}/GAMES.cfg" ]] ||
            ! find "${CORE_DIR}/SLOT_${i}" -maxdepth 1 -type f -name "*.map" | grep -q .; then

            if [ "$show_error_message" != "NO_ERROR_MESSAGE" ]; then
                showSlotStructureErrorMessage
            fi

            slot_number=1

            find "$CORE_DIR" -type d -name "SLOT_*" | sort -V |
                while IFS= read -r slot_test; do
                    if [[ ! -f "${slot_test}/LAYOUT.cfg" ]] ||
                        [[ ! -f "${slot_test}/GAMES.cfg" ]] ||
                        ! find "$slot_test" -maxdepth 1 -type f -name "*.map" -print -quit | grep -q .; then

                        rm -rf "$slot_test" 2>/dev/null
                        continue
                    fi

                    new_slot="${CORE_DIR}/SLOT_${slot_number}"

                    if [[ "$slot_test" != "$new_slot" ]]; then
                        mv "$slot_test" "$new_slot"
                    fi

                    ((slot_number++))
                done

            break
        fi
    done

    FLAG_COUNTER_SLOTS="OFF"
}

### checkCounterSlots - Verify COUNTER_SLOTS before opening CORE menu
checkCounterSlots() {
    if [ "$COUNTER_SLOTS" -eq 0 ]; then
        messageSlotsNotFound
        STATE="MENU_CORE_MAIN"
        return 1
    fi
}

### checkCurrentSlotStatus - Verifies if the CURRENT SLOT matches MiSTer's current config
checkCurrentSlotStatus() {
    local test_core_map
    local type
    local test_md5sum_mister
    local test_md5sum_current

    if [ "$FLAG_SLOT_CURRENT_CHECK" = "OFF" ] || [ "$CURRENT" = "X" ]; then
        return
    fi

    FLAG_SLOT_CURRENT_CHECK="OFF"
    test_core_map=0

    for type in v3 jk v1; do
        if [ "$type" = "v1" ]; then
            EXTENSION="_advanced"
        else
            EXTENSION=""
        fi

        if [ -f "${INPUT_MISTER}/${CORE}${EXTENSION}_input_${ID}_${type}.map" ]; then
            test_core_map=1
            test_md5sum_mister=$(md5sum "${INPUT_MISTER}/${CORE}${EXTENSION}_input_${ID}_${type}.map" | awk '{print $1}')

            if [ -f "${CORE_DIR}/SLOT_${CURRENT}/${CORE}${EXTENSION}_input_${ID}_${type}.map" ]; then
                test_md5sum_current=$(md5sum "${CORE_DIR}/SLOT_${CURRENT}/${CORE}${EXTENSION}_input_${ID}_${type}.map" | awk '{print $1}')
                if [ "$test_md5sum_current" != "$test_md5sum_mister" ]; then
                    CURRENT="X"
                    break
                fi
            fi
        fi
    done

    if [ "$test_core_map" -eq 0 ]; then
        CURRENT="X"
    fi

    if [ "$CURRENT" = "X" ]; then
        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$CURRENT/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
    fi
}

### checkSlotMapFiles - Set TYPE based on .map file search
checkMapFiles() {
    local category
    local slot
    local path
    local test_v3
    local test_jk
    local test_v1

    # ARGUMENTS:
    category="$1"
    slot="$2"

    if [ "$category" = "SLOT" ]; then
        path="$CORE_DIR/SLOT_${slot}"
    else
        path="$INPUT_MISTER"
    fi

    TYPE=""
    test_v3=0
    test_jk=0
    test_v1=0

    if [ -f "${path}/${CORE}_input_${ID}_v3.map" ]; then
        test_v3=1
    fi

    if [ -f "${path}/${CORE}_input_${ID}_jk.map" ]; then
        test_jk=1
    fi

    if [ -f "${path}/${CORE}_advanced_input_${ID}_v1.map" ]; then
        test_v1=1
    fi

    case "${test_v3}${test_jk}${test_v1}" in
    100) TYPE="v3" ;;
    010) TYPE="jk" ;;
    110) TYPE="v3_jk" ;;
    001) TYPE="v1" ;;
    101) TYPE="v3_v1" ;;
    011) TYPE="v1_jk" ;;
    111) TYPE="v3_v1_jk" ;;
    *)
        showNoGamepadConfigForCoreMessage
        STATE="MENU_CORE_MAIN"
        return 1
        ;;
    esac
}

### getSlotIndicator - Set an indicator if the specified SLOT is the CURRENT
getSlotIndicator() {
    local slot_counter

    # ARGUMENT:
    slot_counter="$1"

    if [ "$slot_counter" = "$CURRENT" ]; then
        SLOT_INDICATOR="⇒"
    else
        SLOT_INDICATOR=" "
    fi
}

# === language

### deleteLanguageFiles - Delete language files to switch to another language
deleteLanguageFiles() {
    local language_file

    for language_file in ALERT_DELETE_MAPS ALERT_NO_MAPS HELP LANGUAGE MiSTer_Kun_message NO_GAMEPAD; do
        if [ -f "${GCM_DAT}/${language_file}.txt" ]; then
            rm -f "${GCM_DAT}/${language_file}.txt" 2>/dev/null
        fi
    done
}

#### padLanguageStrings - Pad language strings to a fixed length
padLanguageStrings() {
    local array_name
    local size
    local var
    local value
    local padding
    local length

    # ARGUMENTS:
    array_name="$1"
    size="$2"

    eval "local -a strings=(\"\${${array_name}[@]}\")"

    for var in "${strings[@]}"; do
        eval "value=\"\${$var}\""

        length=${#value}

        if [ "$length" -lt "$size" ]; then
            padding=$((size - length))
            eval "$var=\"\$value\$(printf '%*s' \"$padding\" '')\""
        fi
    done
}

### updateLanguageFirstRun - Update language text strings on First-run
updateLanguageFirstRun() {
    deleteLanguageFiles
    loadLanguageSettings
    generateLanguageFile SHOW_WAIT
    loadLanguageFile
    GENERATE_FILES="ON"
}

### generateFilesFirstRun - Generate other language files on First-run
generateFilesFirstRun() {
    generateHelpFile
    generateAlertFiles
    generateGCMiSTerKun
    updateNoGamepadMessage
}

## updateLanguage - Update the language text strings
updateLanguage() {
    deleteLanguageFiles
    loadLanguageSettings
    generateLanguageFile SHOW_WAIT
    generateHelpFile
    generateAlertFiles
    generateGCMiSTerKun
    loadLanguageFile
    updateNoGamepadMessage
}

### applyLanguageOverrides - Apply language string overrides to a language file
applyLanguageOverrides() {
    local language_file
    local language_overrides
    local line
    local variable
    local replacement

    # ARGUMENTS:
    language_file="$1"
    language_overrides="$2"

    while IFS= read -r line; do
        case "$line" in
        "" | \#*)
            continue
            ;;
        esac

        variable="${line%%=*}"
        replacement="${line//&/\\&}"

        sed -i "s|^${variable}=.*|${replacement}|" \
            "${GCM_DAT}/${language_file}" 2>/dev/null

    done <"${GCM_DAT}/$language_overrides"
}

#### removeAccentsFromFile - Replace accented characters in a text file
removeAccentsFromFile() {
    local file
    local sed_commands
    local accents
    local replacements
    local i

    # ARGUMENTS:
    file="$1"

    sed_commands=""

    accents=(
        "á" "à" "ã" "â" "ä" "Á" "À" "Ã" "Â" "Ä"
        "é" "è" "ê" "ë" "É" "È" "Ê" "Ë"
        "í" "ì" "î" "ï" "Í" "Ì" "Î" "Ï"
        "ó" "ò" "õ" "ô" "ö" "Ó" "Ò" "Õ" "Ô" "Ö"
        "ú" "ù" "û" "ü" "Ú" "Ù" "Û" "Ü"
        "ç" "Ç" "ñ" "Ñ"
    )

    replacements=(
        "a" "a" "a" "a" "a" "A" "A" "A" "A" "A"
        "e" "e" "e" "e" "E" "E" "E" "E"
        "i" "i" "i" "i" "I" "I" "I" "I"
        "o" "o" "o" "o" "o" "O" "O" "O" "O" "O"
        "u" "u" "u" "u" "U" "U" "U" "U"
        "c" "C" "n" "N"
    )

    for ((i = 0; i < ${#accents[@]}; i++)); do
        sed_commands="${sed_commands};s#${accents[i]}#${replacements[i]}#g"
    done

    sed -i "$sed_commands" "$file" 2>/dev/null
}

#### convertTextToUpperCase - Convert text to uppercase
convertTextToUpperCase() {
    local file
    local sed_commands
    local lower_chars
    local upper_chars
    local exceptions_from
    local exceptions_to
    local i

    # ARGUMENTS:
    file="$1"

    sed_commands=""

    lower_chars=(
        "á" "à" "ã" "â" "ä" "é" "è" "ê" "ë"
        "í" "ì" "î" "ï" "ó" "ò" "õ" "ô" "ö"
        "ú" "ù" "û" "ü" "ç" "ñ"
    )

    upper_chars=(
        "Á" "À" "Ã" "Â" "Ä" "É" "È" "Ê" "Ë"
        "Í" "Ì" "Î" "Ï" "Ó" "Ò" "Õ" "Ô" "Ö"
        "Ú" "Ù" "Û" "Ü" "Ç" "Ñ"
    )

    exceptions_from=(
        "SCRIPTS/GCM"
        "BACKUP-GCM-MISTER"
        "MISTER"
        "'INPUTS'"
        "%S"
        "'FULL'"
        "\.MAP"
        "NAMES.TXT"
        "\"DEFINE 'CORENAME' BUTTONS\""
        "\"DEFINE 'NOMEDOCORE' BUTTONS"
        "\"BUTTON/KEY REMAP\""
        "'DEFINE BUTTONS'"
        "'BUTTON/KEY REMAP'"
    )

    exceptions_to=(
        "Scripts/gcm"
        "Backup-GCM-MiSTer"
        "MiSTer"
        "'inputs'"
        "%s"
        "'full'"
        ".map"
        "names.txt"
        "\"Define 'CORENAME' buttons\""
        "\"Define 'NOMEDOCORE' buttons"
        "\"Button/Key remap\""
        "'Define Buttons'"
        "'Button/Key Remap'"
    )

    for ((i = 0; i < ${#lower_chars[@]}; i++)); do
        sed_commands="${sed_commands};s#${lower_chars[i]}#${upper_chars[i]}#g"
    done

    sed_commands="${sed_commands};y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"

    for ((i = 0; i < ${#exceptions_from[@]}; i++)); do
        sed_commands="${sed_commands};s#${exceptions_from[i]}#${exceptions_to[i]}#g"
    done

    sed -i "$sed_commands" "$file" 2>/dev/null
}

#### restoreHelpStrings - Restore HELP strings to their original format
restoreHelpStrings() {
    local file
    local sed_commands
    local restore_from
    local restore_to
    local i

    # ARGUMENTS:
    file="$1"

    sed_commands=""

    restore_from=(
        "'/MEDIA/FAT/CONFIG/INPUTS'"
        "'SMB://IP/SDCARD/CONFIG/INPUTS'"
        "'SMB://IP/SDCARD/SCRIPTS'"
        "'Scripts/gcm/DATA/HELP_EN.TXT'"
        "'Scripts/gcm/DATA/HELP_PT.TXT'"
        "'Scripts/gcm/DATA/HELP_ES.TXT'"
        "'SCRIPTS/GCM'"
        "'INPUTS'"
        "Scripts/gcm/GAMEPADS/1234_abcd/MSX"
        "Scripts/gcm/GAMEPADS/1234_abcd/Intellivision"
        "Scripts/gcm/GAMEPADS/1234_abcd/Apple-II"
        "SCRIPTS/GCM"
        "/MEDIA/FAT"
        "INPUT_1234_ABCD_V3\.map"
        "CORE_INPUT_ID_JK\.map"
        "CORE_ADVANCED_INPUT_ID_V1\.map"
        "ZX81_INPUT_1234_ABCD_JK\.map"
        "ZX81_ADVANCED_INPUT_1234_ABCD_V1\.map"
        "CORE_INPUT_ID_V3\.map"
        "MSX_INPUT_1234_ABCD_V3\.map"
        "MSX_INPUT_1234_ABCD_JK\.map"
        "MSX_ADVANCED_INPUT_1234_ABCD_V1\.map"
        "INTELLIVISION_INPUT_1234_ABCD_V3\.map"
        "INPUT     - FILE PREFIX"
        "INPUT     - PREFIXO DO ARQUIVO"
        "'DEFINE JOYSTICK BUTTONS'"
        "'DEFINE CORENAME BUTTONS'"
        "'DEFINE INTELLIVISION BUTTONS'"
        "'DEFINE INTELLIVISION"
        "JOYSTICK BUTTONS'"
        "'DEFINE"
        "BUTTONS'"
        "-FULL-"
        "INTELLIVISION"
        "APPLE-II"
        "ATLANTIS"
        "BUMP'N'JUMP"
        "BURGERTIME"
        "TRON"
        "LODE RUNNER"
        "KARATEKA"
        "1234_ABCD"
        "ADVANCED_INPUT"
        "'CONFIGS'"
        "'DATA'"
        "'FONTS'"
        "'TMP'"
        "'GAMEPADS'"
        "JK"
        "V1"
        "V3"
        "\.ZIP"
        "GAMEPAD_CONFIG_MANAGER\.SH"
        "SCRIPTS"
    )

    restore_to=(
        "'/media/fat/config/inputs'"
        "'smb://IP/sdcard/config/inputs'"
        "'smb://IP/sdcard/Scripts'"
        "'Scripts/gcm/data/HELP_en.txt'"
        "'Scripts/gcm/data/HELP_pt.txt'"
        "'Scripts/gcm/data/HELP_es.txt'"
        "'Scripts/gcm'"
        "'inputs'"
        "Scripts/gcm/gamepads/1234_abcd/MSX"
        "Scripts/gcm/gamepads/1234_abcd/Intellivision"
        "Scripts/gcm/gamepads/1234_abcd/Apple-II"
        "Scripts/gcm"
        "/media/fat"
        "input_1234_abcd_v3.map"
        "CORE_input_ID_jk.map"
        "CORE_advanced_input_ID_v1.map"
        "ZX81_input_1234_abcd_jk.map"
        "ZX81_advanced_input_1234_abcd_v1.map"
        "CORE_input_ID_v3.map"
        "MSX_input_1234_abcd_v3.map"
        "MSX_input_1234_abcd_jk.map"
        "MSX_advanced_input_1234_abcd_v1.map"
        "Intellivision_input_1234_abcd_v3.map"
        "input     - FILE PREFIX"
        "input     - PREFIXO DO ARQUIVO"
        "'Define joystick buttons'"
        "'Define CoreName buttons'"
        "'Define Intellivision buttons'"
        "'Define Intellivision"
        "joystick buttons'"
        "'Define"
        "buttons'"
        "-full-"
        "Intellivision"
        "Apple-II"
        "Atlantis"
        "Bump'n'Jump"
        "Burgertime"
        "Tron"
        "Lode Runner"
        "Karateka"
        "1234_abcd"
        "advanced_input"
        "'configs'"
        "'data'"
        "'fonts'"
        "'tmp'"
        "'gamepads'"
        "jk"
        "v1"
        "v3"
        ".zip"
        "gamepad_config_manager.sh"
        "Scripts"
    )

    for ((i = 0; i < ${#restore_from[@]}; i++)); do
        sed_commands="${sed_commands};s#${restore_from[i]}#${restore_to[i]}#g"
    done

    sed -i "$sed_commands" "$file" 2>/dev/null
}

# === font

### confirmFontSize - Confirm the selected font size
confirmFontSize() {
    local font_size_change

    # ARGUMENTS:
    font_size_change="$1"

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$FONT_SIZE_CONFIRMATION_1")
    MESSAGE_LN2=("$FONT_SIZE_CONFIRMATION_2")

    if ! yesNoDialog; then
        setFontSize "$FONT_SIZE"

        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$FONT_SIZE_CANCELED_1")

        if [ "$font_size_change" != "SMALL" ]; then
            MESSAGE_LN2=("$FONT_SIZE_CANCELED_2")
        fi

        showDialogMessage
    else
        sed -i "s/^font_size=[^ ]*/font_size=$font_size_change/" "$GCM_INI" 2>/dev/null
        FONT_SIZE="$font_size_change"
    fi
}

# === color theme

### extractDialogString - Extract a DIALOGRC string
extractDialogString() {
    local dialog_string

    # ARGUMENTS:
    dialog_string="$1"

    echo "${!dialog_string}" |
        base64 --decode >"${GCM_CFG}/${dialog_string}.zip" 2>/dev/null &&
        unzip -d "$GCM_CFG" "${GCM_CFG}/${dialog_string}.zip" >/dev/null 2>&1 &&
        rm -f "${GCM_CFG}/${dialog_string}.zip" 2>/dev/null
}

### applyColorTheme - Set colors in dialorc
applyColorTheme() {
    local apply_color_theme
    local apply_color_style
    local total_colors
    local apply_color
    local i

    # ARGUMENTS:
    apply_color_theme="$1"
    apply_color_style="$2"

    eval "${apply_color_theme}[4]=\${${apply_color_style}[0]}"
    eval "${apply_color_theme}[9]=\${${apply_color_style}[1]}"
    eval "${apply_color_theme}[10]=\${${apply_color_style}[2]}"
    eval "${apply_color_theme}[12]=\${${apply_color_style}[3]}"
    eval "${apply_color_theme}[13]=\${${apply_color_style}[4]}"
    eval "${apply_color_theme}[18]=\${${apply_color_style}[5]}"
    eval "${apply_color_theme}[19]=\${${apply_color_style}[6]}"

    eval "total_colors=\${#${apply_color_theme}[@]}"

    for ((i = total_colors; i >= 1; i--)); do
        eval "apply_color=\${${apply_color_theme}[$((i - 1))]}"
        sed -i "s/VALUE_$i/$apply_color/g" "${GCM_CFG}/dialogrc" 2>/dev/null
    done
}

### applySelectedColorTheme - Apply selected color theme
applySelectedColorTheme() {
    local color_selected

    # ARGUMENTS:
    color_selected="$1"

    if [ "$SCHEME" != "$color_selected" ]; then
        sed -i "s/^dialogrc_color_scheme=[^ ]*/dialogrc_color_scheme=$color_selected/" "$GCM_INI" 2>/dev/null
        SCHEME="$color_selected"
        rm -f "${GCM_CFG}/dialogrc" 2>/dev/null
        generateDialogSettings
    fi
}

### applySelectedColorStyle - Apply selected color style
applySelectedColorStyle() {
    local selected_color_style

    # ARGUMENTS:
    selected_color_style="$1"

    if [ "$SCHEME_COLOR_STYLE" != "$selected_color_style" ]; then
        sed -i "s/^dialogrc_color_style=[^ ]*/dialogrc_color_style=$selected_color_style/" "$GCM_INI" 2>/dev/null
        SCHEME_COLOR_STYLE="$selected_color_style"
        rm -f "${GCM_CFG}/dialogrc" 2>/dev/null
        generateDialogSettings
    fi
}

# === exit

### exitScript - End the script
exitScript() {
    if [ "$1" != "NO_GAMEPAD" ]; then
        EXIT_MESSAGE_LN1="$EXIT_QUESTION"
    else
        EXIT_MESSAGE_LN1="$EXIT_GAMEPAD_CONFIGURE"
    fi

    # RESET MAIN ARGUMENTS:
    STATE_ARG=""

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$EXIT_MESSAGE_LN1")

    if ! yesNoDialog; then
        STATE="MENU_HOME"
        return
    fi

    if [ -f "${GCM_TMP}/cores_list" ]; then
        rm "${GCM_TMP}/cores_list"
    fi

    if [ "$CURRENT_FONT" != "$SMALL_FONT" ] || [ "$FONT_SIZE" = "LARGE" ] || [ "$FONT_SIZE" = "EXTRA_LARGE" ]; then
        setfont "$CURRENT_FONT" 2>/dev/null
    fi

    sed -i "s/^gcm_state=[^ ]*/gcm_state=STOP/" "$GCM_INI" 2>/dev/null

    clear
    echo "finished... script gamepad_config_manager.sh v1.0 26.09.15" 2>/dev/null

    exit 0
}

# ======================================= #
# === LAUNCH_MAIN_APPLICATION - Start GCM #
# ======================================= #

STATE="SCRIPT_INIT"
MAIN

# === END OF SCRIPT
