#!/bin/bash
#
# Script: gamepad_config_manager.sh
# Description: Manage MiSTer gamepads with CORE-specific configurations,
#             organizing multiple SLOTS per CORE.
# Author: Marcelo Marino <email.infomarc@gmail.com>
# Copyright (c) 2026 Marcelo Marino
# License: GNU General Public License v3 (GPL v3)
# URL: <http://www.gnu.org/licenses/>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Date: 2026/04/23 v1.0 Marcelo Marino <email.infomarc@gmail.com>
#
#            - 'MENU_FUNCTIONS' starts at line 40
#                   - '### menuHome'           43
#                   - '### menuGamepads'      578
#                   - '### menuSettings'     1364
#                   - '### menuCoreMain'     1906
#            - 'STARTUP_FUNCTIONS'           2553
#            - 'SECONDARY_FUNCTIONS'         3510
#            - 'SCRIPT_INIT'                 4521
#
# ================================================= #

clear

# ========================================================================================= #
# MENU FUNCTIONS - Functions for script menus                                               #
# ========================================================================================= #

### menuHome - Main menu for all other menus
menuHome() {
    clear

    FLAG_SLOT_CURRENT_CHECK=1   # Resets flag to ensure slot check on core exit
    FLAG_COUNTER_SLOTS=1        # Flag to enable SLOTS count in function countSlots (0 = disable, 1 = enable)
    FLAG_GAMEPAD_SHOW_MESSAGE=1 # Show message after gamepad selection (1 = show, 0 = hide)
    GAMEPAD_DIR="${GCM_GPD}/${ID}"

    if [ "$SHOW_TIP_EXIT" -eq 1 ]; then # Execute only on first MENU open
        sed -i "s/^tip_exit=[^ ]*/tip_exit=0/" "$GCM_INI" 2>/dev/null
        SHOW_TIP_EXIT=0 # Enable HELP menu hint flag (0 = disable, 1 = enable)
    fi

    counterCores
    verifyGamepadDir
    verifyTipsFlagsHome
    generateHeader 67 14 21 null --no-cancel "$(eval "printf \"%s\" \"\${HOME_MENU_${MESSAGE_MODE_1}}\"")"

    DIALOG+="
X \"$HOME_EXIT\" \\
- -------------------- \\
L \"$HOME_CORES_LIST\" \\
S \"$HOME_SELECT_GAMEPAD\" \\
- -------------------- \\
A \"$(eval "printf \"%s\" \"\${HOME_ADD_${MESSAGE_MODE_1}}\"")\" \\
V \"$HOME_VIEW_NAMES\" \\
N \"$HOME_RENAME_CORE\" \\
E \"$HOME_DELETE\" \\
G \"$(eval "printf \"%s\" \"\${HOME_GAMEPADS_${MESSAGE_MODE_2}}\"")\" \\
- -------------------- \\
C \"$HOME_SETTINGS\" \\
- -------------------- \\
H \"$(eval "printf \"%s\" \"\${HOME_HELP_${MESSAGE_MODE_3}}\"")\""

    runDialog

    case "$CHOICE" in
        "X")
            exitScript
            ;;
        "L")
            menuCoresList
            ;;
        "S")
            menuSelectGamepad
            ;;
        "A")
            menuAddCore
            ;;
        "N")
            menuRenameCore
            ;;
        "V")
            menuViewNames
            ;;
        "E")
            menuDeleteCore
            ;;
        "G")
            menuGamepads
            ;;
        "C")
            menuSettings
            ;;
        "H")
            menuHelp
            ;;
        "-")
            menuHome
            ;;
        *)
            menuCoreMain
            ;;
    esac
}

### menuCoresList - List all CORES added to the script
menuCoresList() {
    clear

    checkGamepads
    checkCounterCores
    generateCoresData
    PARAM_3=$((LINES_MENU - 7))
    generateHeader 67 "$PARAM_3" null null --no-cancel "$LIST_CORES_MENU"

    DIALOG+="
X \"$LIST_CORES_EXIT\" \\
- -------------------- \\"

    generateMenuLines LINES_CORES COUNTER_CORES EXCLUDE_LAST_BACKSLASH
    runDialog

    case "$CHOICE" in
        "X")
            menuHome
            ;;
        "-")
            menuCoresList
            ;;
        *)
            menuCoreMain
            ;;
    esac
}

### menuAddCore - Add a new CORE
menuAddCore() {
    clear

    local total_lines
    local filtered_lines
    local core
    local adjusted_lines

    checkGamepads
    messageProcessingWait

    find "$INPUT_MISTER" -maxdepth 1 -type f -name "*_input_${ID}*.map" \
        -printf "%f\n" 2>/dev/null \
        | sed "s/_input_${ID}.*//" \
        | sort -u >"$TMP_FILE"

    total_lines=$(wc -l <"$TMP_FILE")

    if [ "$total_lines" -eq 0 ]; then
        alertMiSTerNoMaps
        menuHome
    fi

    while read -r core; do
        if [ ! -d "${GAMEPAD_DIR}/${core}" ]; then
            echo "$core"
        fi
    done <"$TMP_FILE" >"${TMP_FILE}.2"

    mv "${TMP_FILE}.2" "$TMP_FILE" 2>/dev/null

    filtered_lines=$(wc -l <"$TMP_FILE")

    if [ "$filtered_lines" -eq 0 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$ADD_ALL_ADDED")
        showDialogMessage

        menuHome
    fi

    adjusted_lines=$((filtered_lines + 7))

    if [ "$adjusted_lines" -gt 28 ]; then
        adjusted_lines=28
        filtered_lines=21
    fi

    generateHeader 67 "$filtered_lines" "$adjusted_lines" null null "$ADD_CONFIGURED"
    generateLinesArray "$TMP_FILE"
    rm -f "$TMP_FILE" 2 >/dev/null
    generateMenuLines LINES_ARRAY COUNTER_LINES EXCLUDE_LAST_BACKSLASH CUT_OUTPUT NEW_LINE
    runDialog NO_CORE_CHOICE

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        showCancelMessageAndExit "$ADD_CANCELED" menuHome
    fi

    CORE_CHOICE="${LINES_ARRAY[((CHOICE - 1))]}"

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$ADD_QUESTION" "$CORE_CHOICE")
    yesNoDialog

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        showCancelMessageAndExit "$ADD_CANCELED" menuHome
    fi

    if [ -d "${GAMEPAD_DIR}/${CORE_CHOICE}-stored" ]; then
        mv "${GAMEPAD_DIR}/${CORE_CHOICE}-stored" "${GAMEPAD_DIR}/${CORE_CHOICE}" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$ADD_RESTORED" "$CORE_CHOICE")
        showDialogMessage
    else
        mkdir "${GAMEPAD_DIR}/${CORE_CHOICE}" 2>/dev/null
        generateCoreConfig "$CORE_CHOICE"

        TITLE=("$DONE")
        MESSAGE_LN1=("$ADD_CREATED" "$CORE_CHOICE")
        showDialogMessage
    fi

    FLAG_COUNTER_CORES=1
    menuHome
}

### menuViewNames - Display list of cores from MiSTer (names.txt - Fix .mgl names)
menuViewNames() {
    clear

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

        menuHome
    else
        messageProcessingWait
        cp "${MISTER_ROOT}/names.txt" "$TMP_FILE" 2>/dev/null
        full_paths=()

        for item in "${LIST_FOLDERS[@]}"; do
            full_paths+=("${MISTER_CORES_FOLDERS}/${item}")
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
                    setname_found=$(sed -n 's/.*<setname>\(.*\)<\/setname>.*/\1/p' "$filepath")
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
    menuHome
}

### menuRenameCore - Rename added CORES with custom names
menuRenameCore() {
    clear

    checkGamepads
    checkCounterCores

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$RENAME_CORE_MESSAGE\" 11 67 4 \
        X \"$RENAME_CORE_EXIT\" \
        - \"---------------------------------\" \
        L \"$RENAME_CORE_LIST\" \
        T \"$RENAME_CORE_TYPE\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            menuHome
            ;;
        "L")
            menuListRenamed
            ;;
        "T")
            menuTypeName
            ;;
        *)
            menuRenameCore
            ;;
    esac

    menuHome
}

### menuListRenamed - Display all renamed COREs in 2 columns
menuListRenamed() {
    clear

    local rename_file
    local tmp_file
    local original
    local display_core

    checkGamepads
    checkCounterCores
    rename_file="$GAMEPAD_DIR/rename.cfg"
    tmp_file="$TMP_MENU"

    if [ ! -s "$rename_file" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$LIST_RENAMED_EMPTY")
        showDialogMessage

        menuRenameCore
    fi

    while IFS= read -r line; do
 
        if [[ "$line" == *@%* ]]; then
            original="${line%%@*}"
            display_core="${line#*@%}"
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
    menuRenameCore
}

### menuTypeName - Show a list of instaled CORES to renamed
menuTypeName() {
    clear

    local new_name_choice

    checkGamepads
    checkCounterCores
    generateCoresData
    PARAM_3=$((LINES_MENU - 7))
    generateHeader 60 "$PARAM_3" null null --no-cancel "$TYPE_CORE_MENU"

    DIALOG+="
X \"$EXIT_MENU\" \\
- \"-------------\" \\"

    generateMenuLines LINES_CORES COUNTER_CORES EXCLUDE_LAST_BACKSLASH
    runDialog

    case "$CHOICE" in
        "X")
            menuRenameCore
            ;;
        "-")
            menuTypeName
            ;;
        *)
            renameCoreDisplayIfNeeded "$CORE"

            inputCoreName() {
                TITLE=("$TYPE_CORE_RENAME")
                MESSAGE_LN1=("$TYPE_CORE_INPUT" "$CORE_DISPLAY")
                MESSAGE_LN2=("$TYPE_CORE_MAXIMUM")
                inputDialog

                if [ "$STATUS_MESSAGE" -eq 1 ]; then
                    showCancelMessageAndExit "$TYPE_CORE_CANCELED" menuTypeName
                fi

                new_name_choice="${TMP_INPUT//\"/}"

                if [ "$new_name_choice" = "" ]; then
                    showNoInputMessage
                    inputCoreName
                elif [ "$new_name_choice" = "reset" ]; then

                    if [ "$CORE" != "$CORE_DISPLAY" ]; then
                        sed -i "/$CORE/d" "$GAMEPAD_DIR/rename.cfg"

                        TITLE=("$INFORMATION")
                        MESSAGE_LN1=("$TYPE_CORE_RESTORED" "$CORE")
                        showDialogMessage
                    else
                        TITLE=("$ATTENTION")
                        MESSAGE_LN1=("$TYPE_CORE_NO_RESET")
                        showDialogMessage
                    fi

                    menuRenameCore
                elif [ "$CORE_DISPLAY" = "$new_name_choice" ]; then
                    TITLE=("$ATTENTION")
                    MESSAGE_LN1=("$TYPE_CORE_SAME_NAME")
                    showDialogMessage

                    menuTypeName
                fi

                new_name_choice="${new_name_choice:0:25}"
            }

            inputCoreName

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$TYPE_CORE_QUESTION" "$CORE_DISPLAY" "$new_name_choice")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                showCancelMessageAndExit "$TYPE_CORE_CANCELED" menuTypeName
            fi

            if grep -q "^${CORE}@%" "$GAMEPAD_DIR/rename.cfg"; then
                sed -i "s|^${CORE}@%.*|${CORE}@%${new_name_choice}|" "$GAMEPAD_DIR/rename.cfg"
            else
                printf '%s@%%%s\n' "$CORE" "$new_name_choice" >>"$GAMEPAD_DIR/rename.cfg"
            fi

            sort "$GAMEPAD_DIR/rename.cfg" >"$TMP_FILE"
            mv "$TMP_FILE" "$GAMEPAD_DIR/rename.cfg" 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$TYPE_CORE_DONE" "$CORE_DISPLAY" "$new_name_choice")
            showDialogMessage
            ;;
    esac

    menuRenameCore
}

### menuDeleteCore - Delete an existing CORE
menuDeleteCore() {
    clear

    checkGamepads
    checkCounterCores
    generateCoresData
    PARAM_3=$((LINES_MENU - 7))
    generateHeader 60 "$PARAM_3" null null --no-cancel "$DELETE_CORE_MENU"

    DIALOG+="
X \"$DELETE_CORE_EXIT\" \\
- \"-------------\" \\"

    generateMenuLines LINES_CORES COUNTER_CORES EXCLUDE_LAST_BACKSLASH
    runDialog

    case "$CHOICE" in
        "X")
            menuHome
            ;;
        "-")
            menuDeleteCore
            ;;
        *)
            CORE_DIR="${GAMEPAD_DIR}/${CORE}"
            CORE_DISPLAY=$(renameCoreIfNeeded "$CORE")

            deleteCoreFiles() {
                if [ -z "$CORE_DIR" ] || [ "$CORE_DIR" == "/" ]; then
                    menuHome
                fi

                sed -i "/^${CORE}@%/d" "${GAMEPAD_DIR}/rename.cfg" 2>/dev/null
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
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                TITLE=("$CONFIRMATION")
                MESSAGE_LN1=("$DELETE_CORE_SAVE_FILES" "$CORE_DISPLAY")
                yesNoDialog

                if [ "$STATUS_MESSAGE" -eq 0 ]; then
                    saveCoreFiles
                else
                    deleteCoreFiles
                fi
            else
                showCancelMessageAndExit "$DELETE_CORE_CANCELED" menuHome
            fi

            FLAG_COUNTER_CORES=1
            menuHome
            ;;
    esac
}

### menuHelp - Show the script's help and usage instructions
menuHelp() {
    clear

    sed -i "s/^tip_help=[^ ]*/tip_help=0/" "$GCM_INI" 2>/dev/null
    SHOW_TIP_HELP=0 # Disable SHOW_TIP_HELP (0 = disable, 1 = enable)

    if [ -f "${GCM_DAT}/HELP_${LANGUAGE}.txt" ]; then
        dialog --exit-label "$EXIT" --title "$SLOGAN" --textbox "${GCM_DAT}/HELP_${LANGUAGE}.txt" 28 78
    fi

    menuHome
}

### menuGamepads - Manage gamepads
menuGamepads() {
    clear

    verifyTipsFlagsHome

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \" $(eval "printf \"%s\" \"\${GAMEPADS_MENU_${MESSAGE_MODE_4}}\"")\" 16 67 9 \
        X \"$(eval "printf \"%s\" \"\${GAMEPADS_RETURN_${MESSAGE_MODE_5}}\"")\" \
        - \"---------------------------------\" \
        L \"$GAMEPADS_LIST\" \
        N \"$GAMEPADS_RENAME\" \
        D \"$GAMEPADS_DELETE\" \
        T \"$GAMEPADS_TAG\" \
        R \"$(eval "printf \"%s\" \"\${GAMEPADS_REGISTER_${MESSAGE_MODE_4}}\"")\" \
        - \"---------------------------------\" \
        C \"$GAMEPADS_MENU_CLONE\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            menuHome
            ;;
        "L")
            menuListGamepads
            ;;
        "N")
            menuRenameGamepad
            ;;
        "D")
            menuDeleteGamepad
            ;;
        "T")
            EXTRA_OPTIONS=""
            menuSelectEditTag "$ID" change_tag
            ;;
        "R")
            menuRegisterGamepad
            ;;
        "C")
            menuCloneGamepad
            ;;
        "-")
            menuGamepads
            ;;
        *)
            menuHome
            ;;
    esac
}

### menuSelectGamepad - Select default gamepad
menuSelectGamepad() {
    clear

    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        menuHome
    fi

    if [ "$COUNTER_GAMEPADS" -eq 1 ] && [ "$ID" != "" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$SELECT_GAMEPAD_ONLY_ONE")
        MESSAGE_LN2=("$ID - $MODEL_CUT")
        showDialogMessage

        menuHome
    fi

    if [ "$FLAG_GAMEPAD_MESSAGE_MODE" -eq 0 ]; then
        DISPLAY_MESSAGE="$SELECT_GAMEPAD_DEFAULT"
    else
        DISPLAY_MESSAGE="$SELECT_GAMEPAD_CHOOSE"
    fi

    FLAG_GAMEPAD_MESSAGE_MODE=0 # 0: Default message (default gamepad), 1 or null: Selection gamepad message
    prepareGamepadMenu "$DISPLAY_MESSAGE"
    generateHeader
    generateMenuLines LINES_ARRAY COUNTER_LINES EXCLUDE_LAST_BACKSLASH CUT_OUTPUT NEWLINE
    runDialogRegisteredGamepads ID_MODEL SKIP_IF_FIRST
    recordGamepadID
    importControllerData

    if [ "$FLAG_GAMEPAD_SHOW_MESSAGE" -ne 0 ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$SELECT_GAMEPAD_NEW")
        MESSAGE_LN2=("$MODEL_CHOICE - $ID_CHOICE")
        showDialogMessage
    fi

    FLAG_COUNTER_CORES=1
    menuHome
}

### menuListGamepads - Display registered gamepads
menuListGamepads() {
    clear

    local return_mode

    # ARGUMENTS:
    return_mode="$1"

    checkRegisteredGamepads
    LINES_MENU=$((COUNTER_GAMEPADS + 8))
    adjustLinesMenuSize

    {
        echo ""
        echo "-- ID: --   --- MODEL: ---"
        echo ""
        cat "$GCM_RGP"
    } >"$TMP_MENU" 2>/dev/null

    dialog --exit-label "$EXIT" --title "$SLOGAN - $MODEL_CUT - $ID" --textbox "$TMP_MENU" "$LINES_MENU" 75
    rm -f "$TMP_MENU" 2>/dev/null

    if [ "$return_mode" != "RETURN" ]; then
        menuGamepads
    fi
}

### menuRegisterGamepad - Register a new gamepad
menuRegisterGamepad() {
    clear

    local found_gamepads
    local joystick
    local id
    local ids_list
    local model
    local indice
    local print_indice
    local output
    local search
    local name
    local new_gamepad_id
    local id_choice_list

    if [ -z "$(ls "${INPUT_MISTER}"/input*v3.map 2>/dev/null)" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_NO")
        showDialogMessage

        exitScript NO_GAMEPAD
    fi

    echo "" >"$TMP_IDS" 2>/dev/null
    cd "$INPUT_MISTER" || exit 1
    found_gamepads=0

    for joystick in input*v3.map; do
        ((found_gamepads++))

        if [[ -f "$joystick" ]]; then
            id=$(echo "$joystick" | sed -E 's/input_([a-f0-9]{4}_[a-f0-9]{4})_v3\.map/\1/' 2>/dev/null)

            if [ -n "$id" ]; then
                if ! grep -q "^$id " "$GCM_RGP"; then
                    echo "$id" >>"$TMP_IDS" 2>/dev/null

                fi
            fi
        fi
    done

    generateLinesArray "$TMP_IDS"

    if [ "$COUNTER_GAMEPADS" -gt 0 ] && [ "$found_gamepads" -eq "$COUNTER_GAMEPADS" ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$REGISTER_GAMEPAD_ALL_DONE")
        showDialogMessage

        menuListGamepads
    fi

    PARAM_2=$((COUNTER_LINES + 2))
    generateHeader 67 "$PARAM_2" 9 increase --no-cancel "$REGISTER_GAMEPAD_MENU"

    DIALOG+="
X \"$EXIT_MENU\" \\
- \"--------------------\" \\"

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

    runDialog NO_CORE_CHOICE

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        rm -f "$TMP_IDS" 2>/dev/null

        menuGamepads
    fi

    case "$CHOICE" in
        "X")
            rm -f "$TMP_IDS" 2>/dev/null

            menuGamepads
            ;;
        "-")
            menuRegisterGamepad
            ;;
        *)
            ID_CHOICE=$(sed -n "${CHOICE}p" "$TMP_IDS" 2>/dev/null)
            rm -f "$TMP_IDS" 2>/dev/null

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$REGISTER_GAMEPAD_SELECTED_1")
            MESSAGE_LN2=("$REGISTER_GAMEPAD_SELECTED_2" "${print_indice[$CHOICE - 1]}")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                showCancelMessageAndExit "$REGISTER_GAMEPAD_CANCELED" menuGamepads
            fi

            if [ "${model[$((CHOICE - 1))]}" = "" ]; then
                new_gamepad_id=1

                inputModel() {
                    TITLE=("$INFORMATION")
                    MESSAGE_LN1=("$REGISTER_GAMEPAD_NO_MODEL")
                    MESSAGE_LN2=("$REGISTER_GAMEPAD_INPUT")
                    inputDialog

                    if [ "$STATUS_MESSAGE" -eq 1 ]; then
                        showCancelMessageAndExit "$REGISTER_GAMEPAD_CANCELED" menuGamepads
                    fi

                    if [ "$TMP_INPUT" = "" ]; then
                        TITLE=("$ATTENTION")
                        MESSAGE_LN1=("$REGISTER_GAMEPAD_NAME")
                        showDialogMessage

                        inputModel
                    fi

                    MODEL_CHOICE="$TMP_INPUT"
                }

                inputModel

                TITLE=("$CONFIRMATION")
                MESSAGE_LN1=("$YOU_TYPED" "$MODEL_CHOICE")
                yesNoDialog

                if [ "$STATUS_MESSAGE" -eq 1 ]; then
                    menuGamepads
                fi
            else
                new_gamepad_id=0
                MODEL_CHOICE=${model[$CHOICE - 1]}

            fi

            id_choice_list=${ID_CHOICE/_/:}
            echo "$ID_CHOICE - $MODEL_CHOICE" >>"$GCM_RGP" 2>/dev/null

            if [ "$new_gamepad_id" -eq 1 ]; then
                echo "(\"$id_choice_list\" \"$MODEL_CHOICE\")" >>"$GCM_LGI" 2>/dev/null
            fi

            if [ -d "${GCM_GPD}/${ID_CHOICE}-stored" ]; then
                mv "${GCM_GPD}/${ID_CHOICE}-stored" "${INPUTS}/gamepad-${ID_CHOICE}" 2>/dev/null

                TITLE=("$INFORMATION")
                MESSAGE_LN1=("$REGISTER_GAMEPAD_RESTORE_1")
                MESSAGE_LN2=("$REGISTER_GAMEPAD_RESTORE_2")

                showDialogMessage
            else
                mkdir "${GCM_GPD}/${ID_CHOICE}" 2>/dev/null
                touch "${GCM_GPD}/${ID_CHOICE}/rename.cfg" 2>/dev/null
                touch "${GCM_GPD}/${ID_CHOICE}/gamepad_tag.txt"
                menuSelectEditTag "$ID_CHOICE"
            fi

            recordGamepadID

            if [ "$new_gamepad_id" -eq 1 ]; then
                organizeGamepadIDs
            fi

            importControllerData

            TITLE=("$SLOGAN - $MODEL_CHOICE - $ID_CHOICE")
            MESSAGE_LN1=("$REGISTER_GAMEPAD_COMPLETED")
            showDialogMessage

            ((COUNTER_GAMEPADS++))
            FLAG_COUNTER_CORES=1
            showUpdateList SHOWLIST
            ;;
    esac
}

### menuRenameGamepad - Rename a registered gamepad
menuRenameGamepad() {
    clear

    local new_name_choice
    local replace_string_1
    local id_choice_list
    local replace_string_2

    prepareGamepadMenu "$RENAME_GAMEPAD_MENU" 2
    generateHeader null null null null --no-cancel

    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"--------------------\" \\"

    generateMenuLines LINES_ARRAY COUNTER_LINES EXCLUDE_LAST_BACKSLASH CUT_OUTPUT NEWLINE
    runDialogRegisteredGamepads ID_MODEL

    case "$CHOICE" in
        "X")
            rm -f "$TMP_IDS" 2>/dev/null

            menuGamepads
            ;;
        "-")
            menuRenameGamepad
            ;;
        *)
            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$RENAME_GAMEPAD_QUESTION_1")
            MESSAGE_LN2=("$RENAME_GAMEPAD_QUESTION_2" "$ID_CHOICE" "$MODEL_CHOICE")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                showCancelMessageAndExit "$RENAME_GAMEPAD_CANCELED" menuGamepads
            fi

            inputGamepadName() {

                TITLE=("$RENAME_GAMEPAD_TITLE")
                MESSAGE_LN1=("$RENAME_GAMEPAD_INPUT_1")
                MESSAGE_LN2=("$RENAME_GAMEPAD_INPUT_2" "$ID_CHOICE" "$MODEL_CHOICE")
                inputDialog

                if [ "$STATUS_MESSAGE" -eq 1 ]; then
                    showCancelMessageAndExit "$RENAME_GAMEPAD_CANCELED" menuGamepads
                fi

                if [ "$TMP_INPUT" = "" ]; then
                    showNoInputMessage
                    inputGamepadName
                fi
            }

            inputGamepadName
            new_name_choice="${TMP_INPUT//\"/}"

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$YOU_TYPED" "$new_name_choice")
            MESSAGE_LN2=("$RENAME_GAMEPAD_CONFIRMATION")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                showCancelMessageAndExit "$RENAME_GAMEPAD_CANCELED" menuGamepads
            fi

            replace_string_1=$(printf "%s - %s" "$ID_CHOICE" "$new_name_choice")
            id_choice_list=${ID_CHOICE/_/:}
            replace_string_2=$(printf "(\"%s\" \"%s\")" "$id_choice_list" "$new_name_choice")
            sed -i "/$ID_CHOICE/c\\$replace_string_1" "$GCM_RGP" 2>/dev/null
            sed -i "/$id_choice_list/c\\$replace_string_2" "$GCM_LGI" 2>/dev/null
            organizeGamepadIDs

            if [ "$CHOICE" = "1" ]; then
                {
                    echo "ID=\"$ID_CHOICE\""
                    echo "MODEL=\"$new_name_choice\""
                } >"$GCM_SGP" 2>/dev/null
            fi

            importControllerData

            TITLE=("$DONE")
            MESSAGE_LN1=("$RENAME_GAMEPAD_COMPLETED")
            showDialogMessage

            showUpdateList null "$COUNTER_GAMEPADS"
            ;;
    esac
}

### menuDeleteGamepad - Delete a registered gamepad
menuDeleteGamepad() {
    clear

    local gamepad_choice
    local delete_files
    local current_id

    prepareGamepadMenu "$DELETE_GAMEPAD_MENU" 2
    generateHeader null null null null --no-cancel

    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"--------------------\" \\"

    generateMenuLines LINES_ARRAY COUNTER_LINES EXCLUDE_LAST_BACKSLASH CUT_OUTPUT NEWLINE
    runDialogRegisteredGamepads

    case "$CHOICE" in
        "X")
            rm -f "$TMP_IDS" 2>/dev/null
            menuGamepads
            ;;
        "-")
            menuDeleteGamepad
            ;;
        *)
            gamepad_choice=${LINES_ARRAY[$((CHOICE - 1))]}
            ID_CHOICE=$(echo "$gamepad_choice" | cut -c1-9 2>/dev/null)

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$DELETE_GAMEPAD_QUESTION_1")
            MESSAGE_LN2=("$DELETE_GAMEPAD_QUESTION_2" "$gamepad_choice")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                showCancelMessageAndExit "$DELETE_GAMEPAD_CANCELED" menuGamepads
            fi

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$DELETE_GAMEPAD_KEEP_1")
            MESSAGE_LN2=("$DELETE_GAMEPAD_KEEP_2")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
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

            importControllerData

            if [ "$delete_files" -eq 1 ]; then

                if [ -z "$INPUTS" ] || [ "$INPUTS" == "/" ] || [ -z "$ID_CHOICE" ]; then
                    menuGamepads
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
            showUpdateList null "$COUNTER_GAMEPADS"
            ;;
    esac
}

### menuSelectEditTag - select or edit gamepad layout tag
menuSelectEditTag() {
    clear

    local id_gamepad
    local option
    local lines_menu
    local param_3
    local layout_tag
    local layout_tag_output
    local current_tag
    local select_tag_dialog
    local size
    local spaces
    local string_spaces

    # ARGUMENTS:
    id_gamepad="$1"
    option="$2"

    if [ "$option" = "change_tag" ] && [ "$id_gamepad" = "" ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$SELECT_TAG_NO_GAMEPAD")
        showDialogMessage

        menuGamepads
    fi

    if [ "$option" = "change_tag" ]; then
        lines_menu=28
        param_3=21
    else
        lines_menu=26
        param_3=19
    fi

    {
        echo "#!/bin/bash"
        echo "TMP_MENU=$TMP_MENU"
        echo "TITLE_FORMATTED=\"$(printf "%s" "$SELECT_GAMEPAD_TAG")\""
        echo "message=\"$(printf " %s" "$SELECT_TAG_MESSAGE")\""
        echo "dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear $EXTRA_OPTIONS --no-tags \\"
        echo "--title \"\$TITLE_FORMATTED\" \\"
        echo "--menu \"\$message\" $lines_menu 53 $param_3 \\"
    } >"${TMP_MENU}.sh"

    for ((i = 1; i <= 9; i++)); do
        layout_tag="LAYOUT_TAG[$i]"
        layout_tag_output="${!layout_tag}"
        echo " $i \" $i) $layout_tag_output\" \\" >>"${TMP_MENU}.sh"
        echo "- \"                                              \" \\" >>"${TMP_MENU}.sh"
    done

    echo "10 \"10) $SELECT_TAG_CUSTOM\" \\" >>"${TMP_MENU}.sh"

    if [ "$option" = "change_tag" ]; then
        echo "- \"                                              \" \\" >>"${TMP_MENU}.sh"
        echo "11 \"11) $SELECT_TAG_EDIT_CURRENT\" \\" >>"${TMP_MENU}.sh"
    fi

    echo "2>\"\$TMP_MENU\"" >>"${TMP_MENU}.sh" 2>/dev/null
    source "${TMP_MENU}.sh"
    MENU_STATUS="$?"
    CHOICE=$(<"$TMP_MENU")
    rm -f "${TMP_MENU}.sh" 2>/dev/null
    rm -f "$TMP_MENU" 2>/dev/null

    if [ "$MENU_STATUS" -eq 1 ]; then
        menuGamepads
    fi

    if [ "$CHOICE" = "-" ]; then
        menuSelectEditTag "$id_gamepad" "$option"
    fi

    if [ "$CHOICE" = "11" ]; then
        current_tag=$(cat "${GCM_GPD}/${id_gamepad}/gamepad_tag.txt")
    else
        current_tag="← ↓ ↑ →         ← ↓ ↑ →"
    fi

    if [ "$CHOICE" -ge 10 ]; then
        {
            echo "$current_tag"
            echo "|------------- 42 $SELECT_TAG_LINE_1 ------------|"
            echo ""
            echo "$SELECT_TAG_LINE_2"
            echo "$SELECT_TAG_LINE_3"
            echo ""
            echo "$SELECT_TAG_LINE_4"
            echo "$SELECT_TAG_LINE_5"
        } >"$TMP_TAG"

        if dialog --ok-label "$OK" --cancel-label "$RESET" --title "$SELECT_TAG_EDIT" --editbox "$TMP_TAG" 20 49 \
            2>"${TMP_TAG}.2"; then
            sed -i '1s/^\(.\{42\}\).*/\1/' "${TMP_TAG}.2" && sed -i '2,$d' "${TMP_TAG}.2"
            LAYOUT_TAG=$(cat "${TMP_TAG}.2")
            rm -f "$TMP_TAG" "${TMP_TAG}.2"
            select_tag_dialog="$SELECT_TAG_QUESTION_CUSTOM"
        else
            rm -f "$TMP_TAG" "${TMP_TAG}.2"
            menuSelectEditTag "$id_gamepad" "$option"
        fi
    else
        select_tag_dialog="$SELECT_TAG_QUESTION"
        LAYOUT_TAG="${LAYOUT_TAG[$CHOICE]}"
    fi

    size=${#LAYOUT_TAG}

    if [ "$size" -lt 42 ]; then
        spaces=$((42 - size))
        string_spaces=$(printf '%*s' "$spaces")
        LAYOUT_TAG="${LAYOUT_TAG}${string_spaces}"
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$select_tag_dialog")
    MESSAGE_LN2=("'%s'" "$LAYOUT_TAG")
    yesNoDialog

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        menuSelectEditTag "$id_gamepad" "$option"
    fi

    echo "$LAYOUT_TAG" >"${GCM_GPD}/${id_gamepad}/gamepad_tag.txt"

    if [ "$option" = "change_tag" ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$SELECT_TAG_EDIT_SUCCESSFULLY")
        showDialogMessage
        menuGamepads
    fi
}

### menuCloneGamepad - Copy all settings from one gamepad to another
menuCloneGamepad() {
    clear

    local gamepads_registereds
    local output
    local gamepad_choice_1
    local id_choice_1
    local gamepad_choice_2
    local id_choice_2
    local cores_dir
    local slots_dir
    local cores_map
    local name
    local rename

    checkRegisteredGamepads

    if [ "$COUNTER_GAMEPADS" -lt 2 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$CLONE_GAMEPAD_ONLY_ONE")
        showDialogMessage

        menuGamepads
    fi

    prepareGamepadMenu "$CLONE_GAMEPAD_SELECT" 2
    generateHeader null null null null --no-cancel

    DIALOG+="
    X \"$EXIT_MENU\" \\
    - \"--------------------\" \\"

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
    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            rm -f "$TMP_IDS" 2>/dev/null
            menuGamepads
            ;;
        "-")
            menuCloneGamepad
            ;;
        *)
            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                menuGamepads
            fi

            gamepad_choice_1=${LINES_ARRAY[$((CHOICE - 1))]}
            id_choice_1=$(echo "$gamepad_choice_1" | cut -c1-9 2>/dev/null)

            selectSecondGamepad() {
                prepareGamepadMenu "$CLONE_GAMEPAD_DESTINY"
                generateHeader

                DIALOG+="${gamepads_registereds//${LINES_ARRAY[$((CHOICE - 1))]}/ <<< $CLONE_GAMEPAD_SELECTED >>>}"
                runDialog NO_CORE_CHOICE

                if [ "$STATUS_MESSAGE" -eq 1 ]; then
                    menuGamepads
                fi

                gamepad_choice_2=${LINES_ARRAY[$((CHOICE - 1))]}
                id_choice_2=$(echo "$gamepad_choice_2" | cut -c1-9 2>/dev/null)

                if [ "$gamepad_choice_2" = "$gamepad_choice_1" ]; then
                    selectSecondGamepad
                fi
            }

            selectSecondGamepad

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$CLONE_GAMEPAD_QUESTION_1" "$gamepad_choice_1")
            MESSAGE_LN2=("$CLONE_GAMEPAD_QUESTION_2" "$gamepad_choice_2")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                showCancelMessageAndExit "$CLONE_GAMEPAD_CANCELED" menuGamepads
            fi

            if ls -d "${GCM_GPD}/${id_choice_2}" &>/dev/null; then
                TITLE=("$WARNING")
                MESSAGE_LN1=("$CLONE_GAMEPAD_REPLACED_1" "$gamepad_choice_2")
                MESSAGE_LN2=("$CLONE_GAMEPAD_REPLACED_2")
                toggleYesNoDialog

                if [ "$STATUS_MESSAGE" -eq 0 ]; then
                    showCancelMessageAndExit "$CLONE_GAMEPAD_CANCELED" menuGamepads
                else
                    if [ -d "${GCM_GPD}/${id_choice_2}" ]; then
                        rm -rf "${GCM_GPD}/${id_choice_2}"/* 2>/dev/null
                    else
                        menuGamepads
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
                        rename=$(basename "$cores_map" | sed "s|$id_choice_1|$id_choice_2|")
                        mv "${slots_dir}/${name}" "${slots_dir}/${rename}" 2>/dev/null
                        echo "${slots_dir}/${name}" "${slots_dir}/${rename}"
                    done
                done
            done

            TITLE=("$DONE")
            MESSAGE_LN1=("$CLONE_GAMEPAD_COMPLETED")
            showDialogMessage

            menuGamepads
            ;;
    esac
}

### menuSettings - General configuration menu including backup and uninstall functions
menuSettings() {
    clear

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$SETTINGS_MENU\" 17 67 10 \
        X \"$SETTINGS_RETURN\" \
        - ----------------------------- \
        C \"$SETTINGS_COLORS\" \
        L \"$SETTINGS_LANGUAGE\" \
        T \"$SETTINGS_TIPS\" \
		- ----------------------------- \
        R \"$SETTINGS_RESET\" \
        - ----------------------------- \
        B \"$SETTINGS_BACKUP\" \
        U \"$SETTINGS_UNINSTALL\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            menuHome
            ;;
        "C")
            menuColors
            ;;
        "L")
            menuLanguage
            ;;
        "T")
            menuTips
            ;;
        "R")
            menuReset
            ;;
        "B")
            menuBackup
            ;;
        "U")
            menuUninstall
            ;;
        "-")
            menuSettings
            ;;
        *)
            menuHome
            ;;
    esac
}

### menuColors - Adjust Color Theme
menuColors() {
    clear

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$COLORS_MENU\" 16 67 9 \
        X \"$EXIT_MENU\" \
        - ----------------------------- \
        B \"$COLOR_BLUE\" \
        Y \"$COLOR_YELLOW\" \
        M \"$COLOR_MAGENTA\" \
        G \"$COLOR_NEON_GREEN\" \
        N \"$COLOR_NEON_YELLOW\" \
        W \"$COLOR_BLACK_WHITE\" \
        D \"$COLOR_DEFAULT\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            menuSettings
            ;;
        "-")
            menuColors
            ;;
        "B" | "Y" | "M" | "G" | "N" | "W" | "D")

            rm -f "${GCM_CFG}/dialogrc" 2>/dev/null
            case "$CHOICE" in
                "B")
                    COLOR_SELECTED="BLUE"
                    ;;
                "Y")
                    COLOR_SELECTED="YELLOW"
                    ;;
                "M")
                    COLOR_SELECTED="MAGENTA"
                    ;;
                "G")
                    COLOR_SELECTED="NEON_GREEN"
                    ;;
                "N")
                    COLOR_SELECTED="NEON_YELLOW"
                    ;;
                "W")
                    COLOR_SELECTED="BLACK_WHITE"
                    ;;
                "D")
                    COLOR_SELECTED="DEFAULT"
                    ;;
            esac

            sed -i "s/^dialogrc_color-scheme=[^ ]*/dialogrc_color-scheme=$COLOR_SELECTED/" "$GCM_INI" 2>/dev/null
            updateDialogSettings
            menuColors
            ;;
        *)
            menuColors
            ;;
    esac
}

### menuLanguage - Select language (en for english, pt for portuguese)
menuLanguage() {
    clear

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \" $LANGUAGE_MENU\" 11 67 4 \
        X \"$EXIT_MENU\" \
        - \"------------------------------\" \
        E \"$EN\" \
        P \"$PT\""

    runDialog NO_CORE_CHOICE

    # Run 'updateDictionary' and 'updateNoGamepadMessage' to update the language
    updateLanguage() {
        updateDictionary
        updateNoGamepadMessage
        menuLanguage
    }

    case "$CHOICE" in
        "X")
            menuSettings
            ;;
        "-")
            menuLanguage
            ;;
        "E")
            sed -i "s/^language=[^ ]*/language=en/" "$GCM_INI" 2>/dev/null

            updateLanguage
            ;;
        "P")
            sed -i "s/^language=[^ ]*/language=pt/" "$GCM_INI" 2>/dev/null

            updateLanguage
            ;;
        *)
            menuSettings
            ;;
    esac
}

### menuTips - Enable/Disable Tips
menuTips() {
    clear

    local tips_display_state

    if [ "$SHOW_TIPS" -eq 1 ]; then
        tips_display_state="On"
    else
        tips_display_state="Off"
    fi

    tipsConfigCommand() {
        sed -i "s/^tips=[^ ]*/tips=$SHOW_TIPS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_help=[^ ]*/tip_help=$SHOW_TIPS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_exit=[^ ]*/tip_exit=$SHOW_TIPS/" "$GCM_INI" 2>/dev/null

        TITLE=("$DONE")
        MESSAGE_LN1=("$TIPS_MESSAGE")
        showDialogMessage

        menuTips
    }

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$TIPS_MENU\" 13 67 6 \
        X \"$EXIT_MENU\" \
        - \"------------------------------\" \
        A \"$ACTIVE_TIPS\" \
        D \"$DEACTIVE_TIPS\" \
		- \"------------------------------\" \
		- \"Status: $tips_display_state\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "-")
            menuTips
            ;;
        "X")
            menuSettings
            ;;
        "A")
            SHOW_TIPS="1"
            TIPS_MESSAGE="$TIPS_ENABLED"
            tipsConfigCommand
            ;;
        "D")
            SHOW_TIPS="0"
            TIPS_MESSAGE="$TIPS_DISABLED"
            tipsConfigCommand
            ;;
        *)
            menuSettings
            ;;
    esac
}

### menuReset - Reset configuration to default, but save GAMEPADS and CORES folders
menuReset() {
    clear

    local gamepad_folder

    TITLE=("$RESET_TITLE")
    MESSAGE_LN1=("$RESET_QUESTION")
    toggleYesNoDialog

    if [ "$STATUS_MESSAGE" -eq 0 ]; then
        showCancelMessageAndExit "$RESET_CANCELED" menuSettings
    else
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$RESET_INFO_1")
        MESSAGE_LN2=("$RESET_INFO_2")
        showDialogMessage

        TITLE=("$RESET_TITLE")
        MESSAGE_LN1=("$RESTORE_SETTINGS_CONFIRM")
        toggleYesNoDialog

        if [ "$STATUS_MESSAGE" -eq 0 ]; then
            showCancelMessageAndExit "$RESET_CANCELED" menuSettings
        else
            for gamepad_folder in "${INPUTS}"/gamepad-*; do
                if [[ -d "$gamepad_folder" && "$gamepad_folder" != *-stored ]]; then
                    mv "$gamepad_folder" "${gamepad_folder}-stored"
                fi
            done

            if [ -d "$GCM_CFG" ] && [ "$GCM_CFG" != "/" ]; then
                rm -f "$GCM_CFG"/*
            fi

            if [ -d "$GCM_DAT" ] && [ "$GCM_DAT" != "/" ]; then
                rm -f "$GCM_DAT"/*
            fi

            if [ -d "$GCM_TMP" ] && [ "$GCM_TMP" != "/" ]; then
                rm -f "$GCM_TMP"/*
            fi

            echo "$DIALOGRC_CONFIG_BLUE" \
                | base64 --decode >"${GCM_CFG}/dialogrc.zip" 2>/dev/null \
                && unzip -d "$GCM_CFG" "${GCM_CFG}/dialogrc.zip" >/dev/null 2>&1 \
                && rm -f "${GCM_CFG}/dialogrc.zip" 2>/dev/null

            TITLE=("$ATTENTION")
            MESSAGE_LN1=("$RESET_DONE_1")
            MESSAGE_LN2=("$RESET_DONE_2")
            showDialogMessage

            FIRST_RUN=1
            scriptInit
        fi
    fi
}

### menuBackup - Backup menu functions
menuBackup() {
    clear

    DIALOG="dialog  --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN - $MODEL_CUT - $ID\" \
        --menu \"$BACKUP_MENU\" 12 67 5 \
        X \"$BACKUP_EXIT\" \
        - \"------------------------------\" \
        S \"$BACKUP_SAVE\" \
        R \"$BACKUP_RESTORE\" \
        D \"$BACKUP_DELETE\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "-")
            menuBackup
            ;;
        "X")
            menuSettings
            ;;
        "S")
            menuSaveBackup
            ;;
        "R")
            menuRestoreBackup
            ;;
        "D")
            menuDeleteBackup
            ;;
        *)
            menuSettings
            ;;
    esac
}

### menuSaveBackup - Backup save function
menuSaveBackup() {
    clear

    local add_mister_files
    local xtra_tag
    local bkp_dir
    local current_date

    add_mister_files=0
    xtra_tag=""

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SAVE_BACKUP_QUESTION")
    toggleYesNoDialog

    if [ "$STATUS_MESSAGE" -eq 0 ]; then
        showCancelMessageAndExit "$SAVE_BACKUP_CANCELED" menuBackup
    else
        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$SAVE_BACKUP_QUESTION_MISTER")
        toggleYesNoDialog

        if [ "$STATUS_MESSAGE" -eq 1 ]; then
            TITLE=("$WARNING")
            MESSAGE_LN1=("$SAVE_BACKUP_QUESTION_CONFIRM")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                showCancelMessageAndExit "$SAVE_BACKUP_CANCELED" menuBackup
            else
                add_mister_files=1
                xtra_tag="full-"

                TITLE=("$INFORMATION")
                MESSAGE_LN1=("$SAVE_BACKUP_INFO_1")
                MESSAGE_LN2=("$SAVE_BACKUP_INFO_2")
                showDialogMessage
            fi
        fi

        bkp_dir="${GCM_TMP}/Backup-GCM-MiSTer"
        current_date=$(date +"%y_%m_%d-%H_%M")
        mkdir -p "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null

        if [ -z "$bkp_dir" ] || [ "$bkp_dir" == "/" ]; then
            menuHome
        else
            if [ "$add_mister_files" -eq 1 ]; then
                cp "${INPUT_MISTER}"/*.map "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            fi

            cp -R -f "$GCM_CFG" "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cp -R -f "$GCM_DAT" "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cp -R -f "${INPUTS}"/gamepads "${bkp_dir}/Backup-GCM-MiSTer-${current_date}" 2>/dev/null
            cd "$bkp_dir" || menuBackup
            zip -r "${INPUTS}/Backup-GCM-MiSTer-${xtra_tag}${current_date}.zip" "Backup-GCM-MiSTer-${current_date}"/* >/dev/null 2>&1
            rm -rf "$bkp_dir" 2>/dev/null
        fi

        TITLE=("$SAVE_BACKUP_COMPLETED")
        MESSAGE_LN1=("$SAVE_BACKUP_FILE_1" "$xtra_tag" "$current_date")
        MESSAGE_LN2=("$SAVE_BACKUP_FILE_2")
        showDialogMessage
    fi

    menuBackup
}

### menuRestoreBackup - Backup restore function
menuRestoreBackup() {
    clear

    local backup_full
    local selected_backup

    backup_full=0 # 0=GCM only, 1=full(GCM + .map)
    generateMenuBackup "$RESTORE_BACKUP_MENU"

    case "$CHOICE" in
        "-")
            menuRestoreBackup
            ;;

        "X")
            menuBackup
            ;;
        *)
            selected_backup="${BACKUPS[$CHOICE - 1]}"

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$RESTORE_BACKUP_QUESTION" "$CHOICE")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                showCancelMessageAndExit "$RESTORE_BACKUP_CANCELED" menuBackup
            fi

            if [[ "$selected_backup" == *full-* ]]; then
                TITLE=("$CONFIRMATION")
                MESSAGE_LN1=("$RESTORE_BACKUP_FULL_1")
                toggleYesNoDialog

                if [ "$STATUS_MESSAGE" -eq 0 ]; then
                    showCancelMessageAndExit "$RESTORE_BACKUP_CANCELED" menuBackup
                else
                    TITLE=("$WARNING")
                    MESSAGE_LN1=("$RESTORE_BACKUP_FULL_2")
                    toggleYesNoDialog

                    if [ "$STATUS_MESSAGE" -eq 0 ]; then
                        showCancelMessageAndExit "$RESTORE_BACKUP_CANCELED" menuBackup
                    else
                        backup_full=1

                        TITLE=("$CONFIRMATION")
                        MESSAGE_LN1=("$RESTORE_BACKUP_INFO_1")
                        MESSAGE_LN2=("$RESTORE_BACKUP_INFO_2")
                        showDialogMessage
                    fi
                fi
            fi

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$RESTORE_BACKUP_CONFIRMATION_1")
            MESSAGE_LN2=("$RESTORE_BACKUP_CONFIRMATION_2")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 1 ]; then
                if [ -z "$INPUTS" ] || [ "$INPUTS" == "/" ]; then
                    menuBackup
                fi

                restoreBackupFiles "$selected_backup" "$backup_full"
            else
                actionCanceled "$RESTORE_BACKUP_CANCELED"
            fi

            countGamepads
            importControllerData
            menuBackup
            ;;
    esac
}

### menuDeleteBackup - Backup delete function
menuDeleteBackup() {
    clear

    local selected_backup
    local output

    generateMenuBackup "$DELETE_BACKUP_MENU"

    case "$CHOICE" in
        "-")
            menuDeleteBackup
            ;;
        "X")
            menuBackup
            ;;
        *)
            selected_backup="${BACKUPS[$CHOICE - 1]}"
            output=$(basename "${BACKUPS[$CHOICE - 1]}")

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$DELETE_BACKUP_QUESTION" "$CHOICE")
            MESSAGE_LN2=("$CONTINUE")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -ne 0 ]; then
                if [ -e "$selected_backup" ]; then
                    rm -f "$selected_backup" 2>/dev/null

                    TITLE=("$DONE")
                    MESSAGE_LN1=("$DELETE_BACKUP_COMPLETED")
                    showDialogMessage
                else
                    actionCanceled "$DELETE_BACKUP_ERROR"
                fi
            else
                actionCanceled "$DELETE_BACKUP_CANCELED"
            fi

            menuBackup
            ;;
    esac
}

### menuUninstall - Uninstall the GCM script and folder
menuUninstall() {
    clear

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$UNINSTALL_QUESTION")
    toggleYesNoDialog

    if [ "$STATUS_MESSAGE" -ne 0 ]; then
        TITLE=("$WARNING")
        MESSAGE_LN1=("$UNINSTALL_CONFIRMATION_1")
        MESSAGE_LN2=("$UNINSTALL_CONFIRMATION_2")
        toggleYesNoDialog

        if [ "$STATUS_MESSAGE" -ne 0 ]; then
            TITLE=("%s" "$CONFIRMATION")
            MESSAGE_LN1=("$UNINSTALL_EXECUTE")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -ne 0 ]; then
                if [ -z "$INPUTS" ] || [ "$INPUTS" == "/" ] \
                    || [ -z "$MISTER_ROOT" ] || [ "$MISTER_ROOT" == "/" ]; then
                    menuHome
                else
                    if [ -d "$INPUTS" ] && [ "$INPUTS" != "/" ]; then
                        rm -rf "$INPUTS" 2>/dev/null
                    fi

                    rm -f "${MISTER_ROOT}/Scripts/gamepad_config_manager.sh" 2>/dev/null
                fi

                dialog --title "$SLOGAN" --timeout 2 --msgbox "\n $UNINSTALATION_COMPLETED" 7 30
                exit 0
            fi
        fi
    fi

    showCancelMessageAndExit "$UNINSTALL_CANCELED" menuSettings
}

### menuCoreMain - Show menu to access SLOTS of the selected CORE
menuCoreMain() {
    clear

    renameCoreDisplayIfNeeded "$CORE"
    CORE_DIR="${GCM_GPD}/${ID}/${CORE}"
    LAYOUT_TAG=$(cat "${GCM_GPD}/${ID}/gamepad_tag.txt")
    generateCoreConfig "$CORE"
    countSlots
    loadCoreConfigContents
    checkCurrentSlotStatus
    verifyTipsFlagsCore

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout \
        --title \"$CORE_DISPLAY - $MODEL_CUT - $LAST_LOAD:[$CURRENT]\" \
        --menu \" $CORE_MENU - $SELECT_OPTIONS\" 22 67 15 \
        X \"$CORE_EXIT\" \
        - \"-----------------------------\" \
        S \"$CORE_LOAD\" \
        V \"$CORE_VIEW_LAYOUTS\" \
        G \"$CORE_VIEW_GAMES\" \
        - \"-----------------------------\" \
        N \"$(eval "printf \"%s\" \"\${CORE_SAVE_${MESSAGE_MODE_6}}\"")\" \
        E \"$(eval "printf \"%s\" \"\${CORE_EDIT_LAYOUTS_${MESSAGE_MODE_7}}\"")\" \
        L \"$(eval "printf \"%s\" \"\${CORE_EDIT_GAMES_${MESSAGE_MODE_8}}\"")\" \
        - \"-----------------------------\" \
        M \"$CORE_MOVE\" \
        C \"$CORE_SWITCH\" \
        D \"$CORE_DELETE\" \
        - \"-----------------------------\" \
        P \"$CORE_NOTES\""

    runDialog NO_CORE_CHOICE

    case $CHOICE in
        "S")
            menuLoadSlot
            ;;
        "V")
            menuShowlayouts
            ;;
        "G")
            menuShowGames
            ;;
        "N")
            menuSaveSLOT
            ;;
        "E")
            menuEditLayout
            ;;
        "L")
            menuEditGames
            ;;
        "M")
            menuMoveSlot
            ;;
        "C")
            menuSwitchSlot
            ;;
        "D")
            menuDeleteSlot
            ;;
        "P")
            MenuShowNotes
            ;;
        "X" | "")
            menuHome
            ;;
        "-")
            menuCoreMain
            ;;
        *)
            menuHome
            ;;
    esac
}

### menuLoadSlot - Set SLOT as default MiSTer CORE configuration
menuLoadSlot() {
    clear

    messageProcessingWait
    checkCounterSlots
    generateHeaderOnDisk "$LOAD_SLOT_MENU"
    generateLayoutsOnDiskRun
    storeChoiceAndClean

    case "$CHOICE" in
        "-")
            menuLoadSlot
            ;;
        "")
            menuCoreMain
            ;;
        *)
            checkMapFiles SLOT

            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$LOAD_SLOT_QUESTION_1" "$CHOICE")
            MESSAGE_LN2=("$LOAD_SLOT_QUESTION_2")
            yesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                cp "${CORE_DIR}/SLOT_${CHOICE}/${CORE}_input_${ID}"*.map \
                    "$INPUT_MISTER"/ 2>/dev/null
                sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$CHOICE/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                CURRENT="$CHOICE"

                TITLE=("$DONE")
                MESSAGE_LN1=("$LOAD_SLOT_COMPLETED" "$CHOICE")
                showDialogMessage

                FLAG_SLOT_CURRENT_CHECK=0
                menuCoreMain
            else
                showCancelMessageAndExit "$LOAD_SLOT_CANCELED" menuCoreMain
            fi
            ;;
    esac
}

### menuShowlayouts - Show Layouts (Button Maps) for each SLOT
menuShowlayouts() {
    clear

    local flag_new_slot
    local index
    local layouts_lines
    local position
    local type
    local size_lines

    # ARGUMENTS:
    flag_new_slot="$1"

    index=0
    messageProcessingWait
    checkCounterSlots

    {
        echo ""
        echo "  SLOT  $LAYOUT_TAG        $COMMENTS"
        echo "  ----  ------------------------------------------ --------------------"
    } >"$TMP_FILE" 2>/dev/null

    for ((i = 1; i <= COUNTER_SLOTS; i++)); do
        if [ "$index" = 20 ]; then
            {
            echo ""
            echo "  SLOT  $LAYOUT_TAG        $COMMENTS"
            echo "  ----  ------------------------------------------ --------------------"
            } >>"$TMP_FILE" 2>/dev/null
            index=0
        fi

        ((index++))
        layouts_lines=$(<"${CORE_DIR}/SLOT_${i}/LAYOUT.cfg")
        position=$(printf "%3d" $i)
        CHOICE="$i"
        checkMapFiles SLOT "$i"

        if [ "$TYPE" = "v3" ]; then
            type="J"
        elif [ "$TYPE" = "jk" ]; then
            type="R"
        else
            type="A"
        fi

        if [ "$i" = "$COUNTER_SLOTS" ] && [ "$flag_new_slot" = "ADD_SLOT" ]; then
            echo "$type $position)  $NEW_SLOT_CREATED" >>"$TMP_FILE" 2>/dev/null
        else
            echo "$type $position)  $layouts_lines" >>"$TMP_FILE" 2>/dev/null
        fi
    done

    size_lines=$((COUNTER_SLOTS + 8))

    if [ "$size_lines" -gt 28 ]; then
        size_lines=28
    fi

    TITLE=("%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")
    formatMessage

    dialog --exit-label "$EXIT" --title "$TITLE_FORMATTED" --textbox "$TMP_FILE" "$size_lines" 75
    rm -f "$TMP_FILE" 2>/dev/null
    menuCoreMain
}

### menuShowGames - Show the 'game list' for each SLOT
menuShowGames() {
    clear

    local lines_text
    local size_lines

    messageProcessingWait
    checkCounterSlots
    echo "" >"$TMP_FILE" 2>/dev/null

    for ((i = 1; i <= COUNTER_SLOTS; i++)); do
        while IFS= read -r line; do
            eval "OUTPUT=\"\$line\""
            echo "$OUTPUT - $i" >>"$TMP_FILE" 2>/dev/null
        done <"${CORE_DIR}/SLOT_${i}/GAMES.cfg"
    done

    touch "$TMP_ORDER" 2>/dev/null
    sort "$TMP_FILE" >>"$TMP_ORDER" 2>/dev/null
    rm "$TMP_FILE" 2>/dev/null
    cat "$TMP_ORDER" >"$TMP_FILE" 2>/dev/null
    rm -f "$TMP_ORDER" 2>/dev/null
    lines_text=$(wc -l <"$TMP_FILE" 2>/dev/null)
    size_lines=$((lines_text + 5))

    if [ "$size_lines" -gt 28 ]; then
        size_lines=28
    fi

    TITLE=("%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")
    formatMessage

    if [[ -z $(tr -d '\n' <"$TMP_FILE") ]]; then
        {
            echo " "
            echo "$SHOW_GAMES_EMPTY_LIST"
        } >"$TMP_FILE" 2>/dev/null
    fi

    dialog --exit-label "$EXIT" --title "$TITLE_FORMATTED" --textbox "$TMP_FILE" "$size_lines" 70
    rm -f "$TMP_FILE" 2>/dev/null
    menuCoreMain
}

### menuSaveSLOT - Create a new SLOT
menuSaveSLOT() {
    clear

    local new_slot_id

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SAVE_SLOT_QUESTION_1")
    MESSAGE_LN2=("$SAVE_SLOT_QUESTION_2" "$CORE_DISPLAY")
    yesNoDialog

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        showCancelMessageAndExit "$SAVE_SLOT_CANCELED" menuCoreMain
    fi

    checkMapFiles

    if [ "$COUNTER_SLOTS" -ne 0 ]; then
        new_slot_id=$((COUNTER_SLOTS + 1))
        createNewSlot "$new_slot_id"
    else
        new_slot_id=1
        createNewSlot "$new_slot_id"
    fi

    sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$new_slot_id/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
    FLAG_COUNTER_SLOTS=1

    TITLE=("$DONE")
    MESSAGE_LN1=("$SAVE_SLOT_COMPLETED_1" "$CORE_DISPLAY")
    MESSAGE_LN2=("$SAVE_SLOT_COMPLETED_2" "$new_slot_id")
    showDialogMessage

    ((COUNTER_SLOTS++))
    menuShowlayouts ADD_SLOT
}

### menuEditLayout - Edit button visualization of each SLOT
menuEditLayout() {
    clear

    messageProcessingWait
    checkCounterSlots
    generateHeaderOnDisk "$EDIT_LAYOUT_MENU"
    generateLayoutsOnDiskRun
    storeChoiceAndClean

    case "$CHOICE" in
        "-")
            menuEditLayout
            ;;
        *)
            if [ -f "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" ]; then
                cp "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
                echo -e "← ↓ ↑ → \n$LAYOUT_TAG |----- $COMMENTS -----|\n\n$EDIT_LAYOUT_MESSAGE_1\n$EDIT_LAYOUT_MESSAGE_2" >>"${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null

                if [ -s "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" ]; then
                    echo -e "\n$EDIT_LAYOUT_MESSAGE_3\n$EDIT_LAYOUT_MESSAGE_4\n\n$EDIT_LAYOUT_MESSAGE_5" >>"${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
                fi

                if dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE_DISPLAY - $EDIT_LAYOUT_BUTTON_MAP '$CHOICE'" --editbox "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 20 70 \
                    2>"$TMP_DIALOG"; then
                    cp "$TMP_DIALOG" "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" 2>/dev/null
                    sed -i '1s/^\(.\{63\}\).*/\1/' "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg" && sed -i '2,$d' "${CORE_DIR}/SLOT_${CHOICE}/LAYOUT.cfg"

                    if [ "$SHOW_TIPS_EDIT_LAYOUTS" -eq 1 ]; then
                        sed -i "s/^show_tips_edit_layouts=[^ ]*/show_tips_edit_layouts=0/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                    fi
                else
                    rm -f "$TMP_DIALOG" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
                    showCancelMessageAndExit "$EDIT_LAYOUT_CANCELED" menuCoreMain
                fi

                TITLE=("$DONE")
                MESSAGE_LN1=("$EDIT_LAYOUT_COMPLETED")
                showDialogMessage
            fi

            rm -f "$TMP_DIALOG" "${GCM_TMP}/LAYOUT_${ID}_${CHOICE}.tmp" 2>/dev/null
            menuShowlayouts
            ;;
    esac
}

### menuEditGames - Edit game list of each SLOT
menuEditGames() {
    clear

    messageProcessingWait
    checkCounterSlots
    generateHeaderOnDisk "$EDIT_GAMES_MENU"
    generateLayoutsOnDiskRun
    storeChoiceAndClean

    case "$CHOICE" in
        "-")
            menuEditGames
            ;;
        *)
            if [ -f "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" ]; then
                cp "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null

                if dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$FILE_EDITING - $CORE_DISPLAY - $EDIT_GAMES_LIST '$CHOICE'" --editbox "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 20 60 \
                    2>"$TMP_DIALOG"; then
                    sed -i '/^[[:space:]]*$/d' "$TMP_DIALOG" 2>/dev/null
                    cp "$TMP_DIALOG" "${CORE_DIR}/SLOT_${CHOICE}/GAMES.cfg" 2>/dev/null

                    if [ "$SHOW_TIPS_EDIT_GAMES" -eq 1 ]; then
                        sed -i "s/^show_tips_edit_games=[^ ]*/show_tips_edit_games=0/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                    fi

                    TITLE=("$DONE")
                    MESSAGE_LN1=("$EDIT_GAMES_COMPLETED")
                    showDialogMessage
                else
                    rm -f "$TMP_DIALOG" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null
                    showCancelMessageAndExit "$EDIT_GAMES_CANCELED" menuCoreMain
                fi
            else
                messageSlotsNotFound
            fi

            rm -f "$TMP_DIALOG" "${GCM_TMP}/GAMES_${ID}_${CHOICE}.tmp" 2>/dev/null
            menuShowGames
            ;;
    esac
}

### menuMoveSlot - Move a SLOT
menuMoveSlot() {
    clear

    local first_slot
    local destination_slot
    local condition
    local inc
    local update_current

    messageProcessingWait
    checkCounterSlots
    checkOneSlot

    selectFirstSlot() {
        generateHeaderOnDisk "$MOVE_SLOT_FIRST"
        generateLayoutsOnDiskRun
        storeChoiceAndClean
        first_slot="$CHOICE"

        if [ "$CHOICE" = "-" ]; then
            selectFirstSlot
        fi
    }
    selectFirstSlot

    selectSecondSlot() {
        messageProcessingWait
        generateHeaderOnDisk "$MOVE_SLOT_SECOND"
        generateLayoutsOnDiskRun EXCLUDE "$first_slot"
        storeChoiceAndClean
        destination_slot="$CHOICE"

        if [ "$CHOICE" = "-" ]; then
            selectSecondSlot
        fi
    }
    selectSecondSlot

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$MOVE_SLOT_QUESTION_1" "$first_slot" "$destination_slot")
    if [ "$COUNTER_SLOTS" -gt 2 ]; then
        MESSAGE_LN2=("$MOVE_SLOT_QUESTION_2")
    fi
    yesNoDialog

    messageProcessingWait

    if [ "$STATUS_MESSAGE" -eq 0 ]; then
        moveSlot "$first_slot" "TEMP"

        if [ "$first_slot" -gt "$destination_slot" ]; then
            condition="i > destination_slot"
            inc=-1
        else
            condition="i < destination_slot"
            inc=1
        fi

        reorganizeSlotsOrder "$first_slot" "$condition" "$inc"
        moveSlot "TEMP" "$destination_slot"
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
        showCancelMessageAndExit "$MOVE_SLOT_CANCELED" menuCoreMain
    fi

    menuShowlayouts
}

### menuSwitchSlot - Swap two SLOTS
menuSwitchSlot() {
    clear

    local first_slot
    local second_slot
    local destination_slot
    local update_current

    messageProcessingWait
    checkCounterSlots
    checkOneSlot

    selectFirstSlot() {
        generateHeaderOnDisk "$SWITCH_SLOT_FIRST"
        generateLayoutsOnDiskRun
        storeChoiceAndClean
        first_slot="$CHOICE"

        if [ "$CHOICE" = "-" ]; then
            selectFirstSlot
        fi
    }
    selectFirstSlot

    selectSecondSlot() {
        messageProcessingWait
        generateHeaderOnDisk "$SWITCH_SLOT_SECOND"
        generateLayoutsOnDiskRun EXCLUDE "$first_slot"
        storeChoiceAndClean
        second_slot="$CHOICE"

        if [ "$CHOICE" = "-" ]; then
            selectSecondSlot
        fi
    }
    selectSecondSlot

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$SWITCH_SLOT_QUESTION" "$first_slot" "$second_slot")
    yesNoDialog

    destination_slot="$second_slot"

    if [ "$STATUS_MESSAGE" -eq 0 ]; then
        moveSlot "$first_slot" "TEMP"
        moveSlot "$second_slot" "$first_slot"
        moveSlot "TEMP" "$second_slot"
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
        showCancelMessageAndExit "$SWITCH_SLOT_CANCELED" menuCoreMain
    fi

    menuShowlayouts
}

### menuDeleteSlot - Delete a SLOT
menuDeleteSlot() {
    clear

    local first_slot
    local condition
    local inc
    local update_current

    messageProcessingWait
    checkCounterSlots
    generateHeaderOnDisk "$DELETE_SLOT_MENU"
    generateLayoutsOnDiskRun
    storeChoiceAndClean

    case "$CHOICE" in
        "-")
            menuDeleteSlot
            ;;
        "")
            menuCoreMain
            ;;
        *)
            TITLE=("$CONFIRMATION")
            MESSAGE_LN1=("$DELETE_SLOT_QUESTION" "$CHOICE")
            toggleYesNoDialog

            if [ "$STATUS_MESSAGE" -eq 0 ]; then
                showCancelMessageAndExit "$DELETE_SLOT_CANCELED" menuCoreMain
            fi

            if [ -e "${CORE_DIR}/SLOT_${CHOICE}" ]; then
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
            MESSAGE_LN1=("$DELETE_SLOT_COMPLETE" "$CHOICE")
            showDialogMessage

            ((COUNTER_SLOTS--))

            if [ "$COUNTER_SLOTS" -eq 0 ]; then
                sed -i "s/^show_tips_edit_games=[^ ]*/show_tips_edit_games=1/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
                sed -i "s/^show_tips_edit_layouts=[^ ]*/show_tips_edit_layouts=1/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null

                TITLE=("$INFORMATION")
                MESSAGE_LN1=("$DELETE_SLOT_EMPTY")
                showDialogMessage

                menuCoreMain
            fi

            menuShowlayouts
            ;;
    esac
}

### MenuShowNotes - A page to store CORE notes
MenuShowNotes() {
    clear

    if [ ! -f "${CORE_DIR}/NOTES.txt" ]; then
        touch "${CORE_DIR}/NOTES.txt" 2>/dev/null
    fi

    DIALOG="dialog --ok-label \"$OK\" --clear --no-cancel --no-tags --stdout\
        --title \"$CORE_DISPLAY - $MODEL_CUT - $ID\" \
        --menu \" $SHOW_NOTES_MENU - $SELECT_OPTIONS\" 11 70 4 \
        X \"$SHOW_NOTES_EXIT\" \
        - \"-------------\" \
        V \"$SHOW_NOTES_READ\" \
        E \"$SHOW_NOTES_EDIT\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "X")
            menuCoreMain
            ;;
        "V")
            dialog --exit-label "$EXIT" --title "$CORE_DISPLAY - $MODEL_CUT - $SHOW_NOTES_MENU" \
                --textbox "${CORE_DIR}/NOTES.txt" 20 65
            MenuShowNotes
            ;;
        "E")
            cp "${CORE_DIR}/NOTES.txt" "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 2>/dev/null

            if dialog --ok-label "$OK" --cancel-label "$CANCEL" --title "$CORE_DISPLAY - $MODEL_CUT - $SHOW_NOTES_MENU_EDIT" \
                --editbox "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 20 67 2>"$TMP_DIALOG"; then
                cp "$TMP_DIALOG" "${CORE_DIR}/NOTES.txt" 2>/dev/null

                TITLE=("$DONE")
                MESSAGE_LN1=("$SHOW_NOTES_COMPLETED")
                showDialogMessage
            else
                showCancelMessageAndExit "$SHOW_NOTES_CANCELED" MenuShowNotes
            fi

            rm -f "$TMP_DIALOG" "${GCM_TMP}/NOTES_${CORE}-${ID}.tmp" 2>/dev/null
            MenuShowNotes
            ;;
        *)
            MenuShowNotes
            ;;
    esac
}

# ========================================================================================= #
# STARTUP_FUNCTIONS - Paths, config files, and initialization                               #
# ========================================================================================= #

### initPathsAndConfigs - Set essential PATHs and initialize required configurations
initPathsAndConfigs() {
    FIRST_RUN=0 # FIRST_RUN flag initialization

    # MiSTer system folders for configuration, CORES, and inputs
    MISTER_ROOT=/media/fat                # Root directory for MiSTer system (mounted storage)
    INPUT_MISTER=/media/fat/config/inputs # General directory for MiSTer input files
    INPUTS=/media/fat/config/inputs/gcm   # Directory for GCM input configuration files
    MISTER_CORES_FOLDERS="/media/fat"     # Root directory for configured CORE folders

    # Directories and configuration files used by the GCM (Game Controller Manager)
    GCM_CFG="${INPUTS}/configs"                  # Directory for GCM configuration files
    GCM_TMP="${INPUTS}/tmp"                      # Directory for temporary files used by GCM
    GCM_DAT="${INPUTS}/data"                     # Directory for language text files
    GCM_GPD="${INPUTS}/gamepads"                 # Directory for registered gamepads
    GCM_INI="${GCM_CFG}/gcm.ini"                 # Main configuration file for GCM settings
    GCM_LGI="${GCM_CFG}/list_gamepad_IDS.txt"    # List of gamepads IDs for GCM
    GCM_RGP="${GCM_CFG}/registered_gamepads.cfg" # Configuration file for registered gamepads
    GCM_SGP="${GCM_CFG}/selected_gamepad.cfg"    # Configuration file for the selected gamepad

    # Temporary files used during the script's execution
    TMP_FILE="${GCM_TMP}/file.temp"       # General temporary file for storing intermediate data
    TMP_MENU="${GCM_TMP}/file_menu.temp"  # Temporary file used for dynamically generated menu content
    TMP_COUNTER="${GCM_TMP}/counter.temp" # Temporary file used by the counterCORES function
    TMP_ORDER="${GCM_TMP}/order.temp"     # Temporary file used for alphabetically sorting lists
    TMP_IDS="${GCM_TMP}/ids.temp"         # Temporary file for storing gamepad IDs
    TMP_TAG="${GCM_TMP}/layout_tag.temp"  # Temporary file for storing gamepad tag
    TMP_DIALOG="${GCM_TMP}/dialog.temp"   # Temporary file for editing lists and notes (e.g., user inputs)

    # Check for essential directories and gcm.ini
    if [ ! -d "$INPUTS" ]; then
        FIRST_RUN=1 # Flag indicating first run - open configuration menus
        clear
        echo " # First initialization: Creating required directories and files"
        sleep 1
    fi

    if [ ! -d "$GCM_CFG" ]; then
        mkdir -p "$GCM_CFG" 2>/dev/null
    fi

    if [ ! -d "$GCM_TMP" ]; then
        mkdir -p "$GCM_TMP" 2>/dev/null
    fi

    if [ ! -d "$GCM_DAT" ]; then
        mkdir -p "$GCM_DAT" 2>/dev/null
    fi

    if [ ! -d "$GCM_GPD" ]; then
        mkdir -p "$GCM_GPD" 2>/dev/null
    fi

    if [ ! -f "$GCM_INI" ]; then
        cat <<EOF >>"$GCM_INI"
dialogrc_color-scheme=BLUE
language=en
tips=1
tip_help=1
tip_exit=1
EOF
    fi

    # Flag that enables tips next to the menus
    SHOW_TIPS=$(grep -o '^[[:space:]]*tips=[^[:space:]]*' "$GCM_INI" \
        | cut -d'=' -f2 2>/dev/null)

    # Enables HELP menu hint flag (0 = disable, 1 = enable)
    SHOW_TIP_HELP=$(grep -o '^[[:space:]]*tip_help=[^[:space:]]*' "$GCM_INI" \
        | cut -d'=' -f2 2>/dev/null)

    # Enables EXIT menu hint flag (0 = disable, 1 = enable)
    SHOW_TIP_EXIT=$(grep -o '^[[:space:]]*tip_exit=[^[:space:]]*' "$GCM_INI" \
        | cut -d'=' -f2 2>/dev/null)
}

### updateDialogSettings - Update visual settings of the dialog
updateDialogSettings() {
    # DIALOG DEFINITIONS - base64
    DIALOGRC_CONFIG_BLUE="UEsDBBQAAAAIAGJgN1tsewVUcAMAAFQLAAAIAAAAZGlhbG9ncmOdVttu2zAMffdXCOnLCjjBkMdh
F6RbgxXLEmBLMewpkG3GFqpIhi7NAuzjR0l2LDuXFgvQxLwcHlKiyd4kN+SHFWPDdkByKbastIoa
JgXZMg5kKxUpGOWyTG7QdWaN3KE5p5wfSAkC0BkKkh3IKLiR8ThXgMqxysl7F+PjyEERvD7UoInc
kmfKLeh3Xrm0uwwUcZ8xIe+FFz+i4adRTJStYaS9iKHInZQcqGgRq+Xf1XzuEDODPpk14A1vMHUo
lbSiSDOaPzWPFSsrjn/m023iWMAQqmvIzTiUPUmCSD6Qt62DhpqiFY/CBSU7yw2r8XD2rCjBYEnW
1NbcTpLGETbBgjFGozaIodmYgyhNFaIY+GMy+cfr8eCfQWmkxyCo2KBjm8B3+gTeySjqnCj3l5JX
kD9xpk1KwOSTlDCRc1ugawXE6SfJM9PMbJiBncZgeEg+lYoWct/cKcEEQH8i64ppQrmWxFglsCCB
vcClmiRWw0YHyDHEGn2CnWhb11IZsloSlJzdAbzNcy49JTYENIhEeyG4oMebX18f1vfpl/v57HGx
TlfL2yjJBuGFDtH63i1mn7+lyOkhX44FNbBQ4ZDobvF4n8rtdogxzHBokP75FOjZlkNgJlWB/RuQ
Qeigns1/NcBZbtgzEGxSI0USfjbUK68SPggaI1u6gGfiUgRH3JxPj5k8waEfAxUnefy+XyxWv64n
cjbQfyTEaQa8H8mrhkldSPdcahdDviq9B4GvdNROzMkovhLUa4sjdtAfcYuGMUFVXkWk2iteYo1g
cRt34H5DR9IA3Uu6gw+yjkUXYO72RC1x1ritwUSB28HNyuDQGjZHw6VEvoOwUe07FOPKh4d1dO9l
3aJeyPkBh2J7OfjYHe++QjnNcD8dp8RP4LgPcMmxAUg3hg59AM7lHuG4b1Ic5n5a0rKdK7QbRx1r
j8L0nE8IztC2FN2L6JDu/RjU1Jt8PcJT6Osq++xWUHRjfiVdae6GMj8LO6E8MxxdmMeaUKWOy8F6
4fqwlnvRwxR9TBzi2BsV8HrsVnR04U43mO2BbjDScD3vSIR1cluHU79U4vwcvgeMydsr/QG4JgX+
V+bpo171cN85qnF57W4rqS3baeKfO2BohN57crIUp72tOL0KHk7O6fnReT3IySibXphl18MMJsv0
7Gi5EuIfUEsBAj8DFAAAAAgAYmA3W2x7BVRwAwAAVAsAAAgAAAAAAAAAAAAAALSBAAAAAGRpYWxv
Z3JjUEsFBgAAAAABAAEANgAAAJYDAAAAAA=="

    DIALOGRC_CONFIG_YELLOW="UEsDBBQAAAAIAAehN1uVdGnqagMAAHYLAAAIAAAAZGlhbG9ncmOdVtuK2zAQffdXDNmXLjih5LH0
Qtpu6NJtAm1K6VOQ7YktVpGMJG8a6Md3JMvxJd5kaSDEo5lzzkgaz+QmuoHvlZxavkdIldzxvNLM
ciVhxwXCTmnIOBMqj24odFFZtSd3yoQ4Qo4SKRgzSI4wqcNgOk010uJUp/DWcbyfOCiBN8cSDagd
PDFRoXnjF1fVPkEN7jMFeCu9+Z4cP6zmMm8cE+NNooKPSglkskGsV3/Xy6VDLCzFJJVF73hFqWOu
VSWzOGHpY3gseF4I+toPt5FTQQvMlJjaab3tWVSb8A5eNwEGS0ZeOgpHCvtKWF7S4Rx4lqOlLVW2
rOztLAqBuK09xDGZNCSWJVOBMrdFzWLxj03UH79OB/+E2pA8kdDClgKbBL6xR/RBVjMXxIS/lLTA
9FFwY2NAm85i4DIVVUahBYJbn0VP3HC75Rb3hsjokHwqBcvUIdwpUAJoPsCm4AaYMApspSVtSFIt
CKVnUWVwa2rIiWJDMbUfTFWWSltYr4As53cA7/OaKy9JBYEBERlv1CEU8erXl/vNXfz5brn4+bCJ
16vbTpIB4Y0W0cR+fFh8+hqTpod8Pm0owOodtrBDQScR/757eFj/itVuN0RZbgUGrH8e5hj0VkNg
onRGFVwja6OFBr3wE8CL1PInBCpVq2RU/2yZX7woei9ZF9lI1nguxxka6XBOPW14xGOfhRbOMgkM
F1MZJfqvlARLUPS5/NIwrWcSHkvuWcoXJngv6fXulBZ3NpkvhvVK5IQe1Eq3YOumwXRadGSNX7iu
2wF2i7qF98u7Yw3QvbRb+CDvrukIlm5ulIp6j5siXGY0LVzvrAMax/bkeC6Rbyirzu73ZHb3Pjyu
U3gv6wZ1Jed7apLN9dDjsGscUQh1OHWNHyhoQtDY4wOYCY4WH5CJoAkUU3v3/ZPlTZ9hbYNqdXsS
thd8JjAi20i0r6RDuvfkci/sSZ6DX7a3T24sdW7Nj6kLJR4k01HYmeRIq3Q0P0tgWp8GRuWNy+1b
HWQPk/UxXYpTfRQoyqkb250rd2tnnbIWHLQ3Gtp76KCd3ezELV/b5HIM3wP25Ztr/Y40PiX9W/MJ
dCrWE/j60SHkpRMvZ1XedBX/fOV9ORuW8960nF+BD/vofLyRXqM5a2zzZzrbNaJBp5mPtpqLJP8A
UEsBAj8DFAAAAAgAB6E3W5V0aepqAwAAdgsAAAgAAAAAAAAAAAAAALSBAAAAAGRpYWxvZ3JjUEsF
BgAAAAABAAEANgAAAJADAAAAAA=="

    DIALOGRC_CONFIG_MAGENTA="UEsDBBQAAAAIAGKhN1v+l/b8cgMAAIcLAAAIAAAAZGlhbG9ncmOdVtuO2jAQfc9XWOxLVwqo4rHq
RbRd2lV3QWqpqj4hJxkSa40d+bIUqR/fsRPnRhZQkRAZz5xzxvZkhpvohny3YmrYHkgqxY7lVlHD
pCA7xoHspCIZo1zm0Q2GLqyRe3SnlPMjyUEABkNGkiOZVGFkOk0V4OJUpeSt43g/cVAEb44laCJ3
5JlyC/qNX1zZfQKKuM+UkLfCm+/R8cMoJvLgmGhvIhX5KCUHKgJivfq7Xi4dYmEwJrEGvOMVpg65
klZkcULTp/qxYHnB8Ws+3EZOBQyhuoTUTKttz6LKJO/I6xCgoaToxaNwpGRvuWElHs6BZTkY3JI1
pTW3s6gOhG3lQY7JJJAYmkw5iNwUFYuBPyaRf/w6HvwzKI3ySIILWwwMCTzSJ/BBRlEXRLm/lLSA
9IkzbWICJp3FhImU2wxDCyBufRY9M83MlhnYayTDQ/KpFDSTh/pOCSYA+gPZFEwTyrUkxiqBGxJY
C1yqWWQ1bHUFaSg2GFP5ibZlKZUh6xVBy/kdwPu85spLYkFAjYi0N6oQjHj16+v95i7+fLdc/HzY
xOvVbSfJGuGNFhFiPz4sPn2LUdNDPjcbqmHVDlvYocCTiB8XX+5Wm0Usd7shzDDDoQb752GSteBq
CEykyrCEK2RltNAgGH5r+CI17BkIVquRIqp+ttQvnpW9F7SLDKIVnolxhka7PqueOHmCY58GF05S
+X338LD+dT6XUaL/y4nTBHifzC8N83oh47HsXqS8NsN7gS95p8CYs9G8HtcrlAY+qJhu3Va9g6q0
6Ohqv3CFcAfZre0W36/yjjVA9/Ju4YPEu6YjWLr5UUrsQW6aMJHh1HA9tAoIjm3jeCmRRxC2s/09
mt3ND8+rCe9lHVAXcr7HZhnuBx+H3WNPceQZ2nSPH8BxVOD8YwOcrh0twRE4l4c44TiKYuzzvpHS
PPQb2naqVrgnYXrBJwIjskGifS8d0r0rF5piT/MUfd3mPrkB1bk3P7DOVHktmY7CTiRHOqaj+VkS
qlQzOqw3zvdxeRA9TNbHdCmaCimAl1M3wDt37tZO236lOGhyOL/3pAN3dtiKW760y+UYvgcc6IeL
/Q44SgX+c/MZdIrWM/gSUnXItcMvpzYPncU/X3pnTgbnvDc555fww3Y6H++nF3lO+tv8hQZ3kWnQ
ceajLec8yz9QSwECPwMUAAAACABioTdb/pf2/HIDAACHCwAACAAAAAAAAAAAAAAAtIEAAAAAZGlh
bG9ncmNQSwUGAAAAAAEAAQA2AAAAmAMAAAAA"

    DIALOGRC_CONFIG_NEON_GREEN="UEsDBBQAAAAIAF2yN1sBwalOTQMAAKULAAAIAAAAZGlhbG9ncmOdVdtu2zgQfddXDJI+NIDtdVx0
H4zuFtnGaQ3sOkDqoI8GLU0kIhQpkJSTAP34HVKXUIoSqw0cQHM5Z4bD4cwpvFsnSzCCxfcPTONM
x5MDnM/O57CYny/+oN/8HObz5Yc/lx8/glU5rB4LeBedwoELXMZK3uUqQZJvSjm1PEdwOp6Wmlmu
JNyRG9wpDQlnQqUTyJmNMzTwvYlJAEF2Q9ocZ9EpcW2fCvJQd3BgokSz9MpNme9Rg/ubAnySXvyb
DN+t5jJtDCfGiydk+EcpgUw2iOvNz+urK4e4sOSzLy16w3tKD1OtSplM9pRU/ZnxNBP0bz+fRS4K
WmCmwNhOq6PNokqEv2DeOBgsGFnpOI4U8lJYXlABHniSoqUjlbYo7dksqh1xV1mI4+SkIbFsPxUo
U5tVLBYf7V49ej0V94DaUHgiIcWOHJsE/mP36J2sZs6JCV94qmt8L7ixE0AbzybAZSzKhFwzBKef
RQduuN1xi7khMiqSTyVjiXqo7w0oATSfYZtxA0wYBbbUkg4kq+ubRaXBnakgLcWWfJrrLYtCaQvX
GyDJ2R3A23zMjQ8Za8QaERkvVC7k8f7rzWq1mVyuri5u/91OrjdnQZI1wgtHEJfteWpUdcDxKMut
qJs28t/joXulE2rhClsJR8AXseUHBOpV25Q6qoQd86Zn/I9v6+1qcrO6bLBryV5Hc9nHj4h/j09d
FlL08xjIbiiZQarfSkqwPYoul1f9ZmKv0o1Mbi3phQftxZ1M4mhYp0ladK9bQrGaG0zHWRDWeMXx
uAEwbOxn+JgWD0g62T+zjGr2K7crCkWzyG0OLhMe+1lakTWGXWvoX+3LFvJjEWUZFCYnMSxL+Pw7
7p2TNKgj17CmEdrcHH0eLZug/YEJ8B7M1IY3HveWpc0MYseGVxvHdkAjozy/VAdyNf6FaC/BI6J+
cRsruDK/wcZGjQfBL6MOstwWwLRuF0rphWPzXT3IDirpokKStkcyFMXULfbg2p2uRYW7LJh5tNBz
CHBObkaaU7f47tjxr2sI2sEMn+8GKRMpnqrYQat6At+vunYZvwlTVqbNrPHfv7pEF50tunj1Offn
6mJ4sC56T3oxOFq7FP3p9gZHb6gsBqfKa/j/AVBLAQI/AxQAAAAIAF2yN1sBwalOTQMAAKULAAAI
AAAAAAAAAAAAAAC0gQAAAABkaWFsb2dyY1BLBQYAAAAAAQABADYAAABzAwAAAAA="

    DIALOGRC_CONFIG_NEON_YELLOW="UEsDBBQAAAAIACKyN1u9YHqOUAMAALoLAAAIAAAAZGlhbG9ncmOdVdtu2zgQfddXDJI+NIDtdbxo
H4x2i+zGwRrI2kDqIOiTQUsTiQhFCSTlJEA/fofUJZQi13IDB9BczpnhcDhzDh+W0Ry0YOHTM1M4
UeFoD5eTyynMppezP+g3vYTpdP7n5/mnT2CyFBYvOXwIzmHPBc7DTD6mWYQk3xVybHiKYHU8LhQz
PJPwSG7wmCmIOBNZPIKUmTBBDd/rmAQQZNekTXESnBPX5jUnj+wR9kwUqOdOuSrSHSqwf2OAL9KJ
f5Hhu1FcxrXhTDvxjAx/Z5lAJmvEevVzfXNjEVeGfHaFQWf4SOlhrLJCRqMdJVV9JjxOBP2bbxeB
jYIGmM4xNOPyaJOgFOErTGsHjTkjKx3HkkJaCMNzKsAzj2I0dKTC5IW5mASVI25LC3GcndUkhu3G
AmVskpLF4IvZZS9OT8Xdo9IUnkhIsSXHOoH/2BM6J6OYdWLCFZ7qGj4Jrs0I0ISTEXAZiiIi1wTB
6ifBnmtuttxgqomMiuRSSViUPVf3BpQA6m+wSbgGJnQGplCSDiTL65sEhcatLiENxYZ86ust8jxT
BtYrIMnaLcDZXMyVCxkqxAoRaCeULuTx8cfi9nb9MLpe3Fzd325G69WFl2UFccIxyHVzogpWHvEE
mOFGVH0buO8TsLtMRdTGJbgUjqGvQsP3CNSwpq53UApb5kxvBA//LjeL0d3iusYuJTuM5rKLH5LA
E762aUjRTaQnvb5seql+LyvBdijaZE71m5kdpBua3VLSS/eajFuZxOG4Vqc08E7L+GI5QJgKEy+u
dooBgT2k399v+EGd7rG08n+jGdbzN3Zv5BnNJbtFuIx46OZqyVYbto2he7/vG8mNSJSFV5uURL8y
/iBoubeOUqOO3MSSxml9efR5vHCClglGwDs4XRl+8cg3LK6nETs6x5pApoUaGObtxVqQrfIp4d6j
B4T9xy4w79bcQhscNuxFvw/bT3OfA1OqWTCFE45O++xZtmBRG+azNJ2SoMjHdtV7d291Dcpfbt74
oxWfgoezcj3drLrBtweQe2N90BbmwAHvkFKR4rUM7jWsY3BdqyqXEzZjzIq4njru++StOmut1dnB
d92dsbP+ITvrvO1Z75htU3Tn3C84OtNl1jteDuH/B1BLAQI/AxQAAAAIACKyN1u9YHqOUAMAALoL
AAAIAAAAAAAAAAAAAAC0gQAAAABkaWFsb2dyY1BLBQYAAAAAAQABADYAAAB2AwAAAAA="

    DIALOGRC_CONFIG_BLACK_WHITE="UEsDBBQAAAAIAAW1N1tsEaGzmwMAADsNAAAIAAAAZGlhbG9ncmOlVslu2zAQvfMrBs3FApygyL0o
sqJF0wVtih4NSprYTGjS4ZKknxP00FNP/QT/WIekLEuW7CjpxbLImTdvRrPtsT04Mrde3GkoEQqt
rsTUG778vfylYcENh1JwqacwOjZcFRoQvhh0OmN7LOg6cccN6Rm0zFucFFpqY+ENfP4U7r+hA4sB
x2kDoyv6mXvpxEIi3Ityis6C9m7hXXbAKkGcpBsCefVqBeJ4vi9RTd0soTh8cLl+iOfE+g6NFVoR
CB1MSJCUXwfdj/wGo5AzPAhxCUG9mGFxI4V1Y0BXHIxBqEJ6ioCbIYTzA3YnrHAT4XAe3Tk/j1Rm
vNT3q5gQAbRv4XImLHBpNThvFDmkIIbhIEbEJpUa4oTMk6Err0qKOSdPJGe2MIgqRY9ER8cXRycf
xnB6dn70/eJyTNHMal0OVs9z+jKjgpNNtA6vOXjLA2C6yliyugaskX68e395Ng5kmogFFw880CrF
8pFc0xTlSDCPX30c400JkT59cn8NXmFWpFvQFJPlH+el3mKlgTuGpsmMOeEkbjXSDIilL2HCo99G
xTrIoBnIOtcuVAB3oTJ2scy9c1pNeEGSXbZfz07bXGtkoQZjk2g/eh91isCMMr3rwy4LN/hzsAdd
A7UrT5l4liMazPJvypy2KytEyXOUm7S3OLQTteLfxn1u0Fdph4o6DR2MhKKuFlpEBvuwtZhYFCOp
gXZiovcZXANt5HmzWPsIL9BS/7fUg5CbYtaiUnHo6xn9hd0D1i7jxttOr3qANvxqvjZYCVWKgnpf
bLILbUUaZSOt6F1D4Y2lO2qay8eMhXsnYokFLZpRTxCt+c1ReRZ+mvHaEuqudy3tQX5ZoElEs0Xp
qLyzbYSZNazEVqgWJRYUBx6OahMJtTKR7LVMRC2H5YCeYWkGTy2M0Ilbj47bjMzYaMfSyF7PkjX3
jvKaJE86Hfs9rJoosW/ZGjBihEYxqPI66l0+AesZMVmnAy0m4oryL6Yqi7vJ4PJt6TY5VTgdQj0D
q7la0MdJe18h5px5bkxzjdgxhBuqOZHTrGzrNqGaXSTmFTnCr32oklVOxhSboVwMXTMiThpE9EpL
Hi2ay0cjNAv/V/4GsUGhqJn1YLVAdtMKXmxghB2NmjbtmShoYeQJM+auQapAJbenZCvgOUU0NUuj
p7SA0zI4mnI/xYzFx3NHShev2pkO/3c4weHmeHo55GoyEObmbHg5aGx4hxsteTfcP1BLAQI/AxQA
AAAIAAW1N1tsEaGzmwMAADsNAAAIAAAAAAAAAAAAAAC0gQAAAABkaWFsb2dyY1BLBQYAAAAAAQAB
ADYAAADBAwAAAAA="

    DIALOGRC_CONFIG_DEFAULT="UEsDBBQAAAAIAJalN1tZZZqOaQMAAEkLAAAIAAAAZGlhbG9ncmONVt9P4zAMfu9fEY0XkLbptMcT
xzRgu0MHmwRDiKcpa702WpZU+QFMuj/+nLTd0nYFkEC1/X224zg2Z9EZebRiYNgOSCzFhqVWUcOk
IBvGgWykIgmjXKbRGUIn1sgdmmPK+Z6kIADBkJD1nvQKGBkMYgWoHKiYXDofVz1HRfJyn4MmckPe
KLegf3rl3O7WoIj7GRByKbx4hYYno5hIK0NPexFdkWspOVBRMRbzf4vZzDEmBjFra8AbzjF1SJW0
IumvabwtPzOWZhx/zbiPIijOBIz7Ct5AaRhfRC4yGEJ1DrEZFKUYRoVIfpEfFUBDTtGK5XGByM5y
w3Is2DtLUjB4TGtyay6GUQmEVWFBH71e5cTQ9YCDSE1WeDHwYdbyw+vxMlxOGB6doGKFwCqBB7oF
DzKKOhDl/qLiDOItZ9r0CZh42CdMxNwmCM2AOP0wemOamRUzsNPoDAvnU8loIt/LeyaYAOgxWWZM
E8q1JMYqgQcS2B9cqmFkNax0QUEXc+dhiZDCTLTNc6kMGghKLoLDe5s+4J+wR6BkRNoLBQQR5zev
k3n/+v552l/ML4L8SrQXjujr+8nN337xt8TfHg5ScoqTNTkvf+6WGGM2a5IMMxxKqv8OmZhWSWwF
W0uFHVUSC+HILEg16iQ27A0ItqypqhsVwop6U5MdFuVO0G46Ew0HYQXaobewr/NR0UzhRGKn0jjp
qpXO+eP0tlH/ekacroHXHXlVqzCv0/v7xcunlen01U6r1hiVN3zHQS8xJ6PYWdojodYPB16jMZr0
J6AqzoKA2is+ixhQwtY9EutNHEgNdi3hI72RcSg6BzO3KHKJg8WtDSYSXA9uMBaAyrA6GLoSeQBh
g3PvUPzs1Ad4LeuK9UXOdzgBq4vBz09Ky3Hw44ZjDYIuDV+9jyVNq0lC0+4rKKOYGrorRvslVJGO
r8/x3dNrUNuvsRW/7aOVh3++4ZO7cZsnuDu/ib4uanyS9t3SPueEKnVYDNYLxxx/P06n88aslu+i
xknqnNDFoUsy4PnAbebg+p2uPZz9CqqPM1zLOxKQnVwdxKm/OuPsFL9GLKP7pVke8xFwRQr8B81H
DzrXs337qhLS2Lpdmy2lNq3Giv/u6uTWNhzV1uHo21NzdHpsdjtojbFRxxzrdtGYKKOTI6WD/h9Q
SwECPwMUAAAACACWpTdbWWWajmkDAABJCwAACAAAAAAAAAAAAAAAtIEAAAAAZGlhbG9ncmNQSwUG
AAAAAAEAAQA2AAAAjwMAAAAA"

    SCHEME=$(grep -o '^[[:space:]]*dialogrc_color-scheme=[^[:space:]]*' "$GCM_INI" \
        | cut -d'=' -f2 2>/dev/null)
    eval "DIALOGRC_CONFIG_SCHEME=\${DIALOGRC_CONFIG_${SCHEME}}"

    # Generate DIALOGRC
    if [ ! -f "${GCM_CFG}/dialogrc" ]; then
        echo "$DIALOGRC_CONFIG_SCHEME" \
            | base64 --decode >"${GCM_CFG}/dialogrc.zip" 2>/dev/null \
            && unzip -d "$GCM_CFG" "${GCM_CFG}/dialogrc.zip" >/dev/null 2>&1 \
            && rm -f "${GCM_CFG}/dialogrc.zip" 2>/dev/null
    fi

    # Export DIALOG config
    export DIALOGRC="${GCM_CFG}/dialogrc"

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

    # LAYOUT TAGS for gamepads
    LAYOUT_TAG[1]="← ↓ ↑ → A B C X Y Z L1 R1 L2 R2 Z2 STR SEL"
    LAYOUT_TAG[2]="← ↓ ↑ → A B X Y L1 R1 L2 R2 L3 R3  STR SEL"
    LAYOUT_TAG[3]="← ↓ ↑ → A B X Y L1 R1 L2 R2  ← ↓ ↑ → ST SL"
    LAYOUT_TAG[4]="← ↓ ↑ → [] X () /\ L R L2 R2 L3 R3 STR SEL"
    LAYOUT_TAG[5]="← ↓ ↑ → [] X () /\ L R L2 R2 ← ↓ ↑ → ST SL"
    LAYOUT_TAG[6]="← ↓ ↑ → U D L R [] X () /\ L R L2 R2 ST SL"
    LAYOUT_TAG[7]="← ↓ ↑ → A B C  X Y Z  L1 R1  EXT   STR SEL"
    LAYOUT_TAG[8]="← ↓ ↑ → A B L1 R1 Z1 Z2 L3 C:← ↓ ↑ → ST SL"
    LAYOUT_TAG[9]="← ↓ ↑ → A B C D   W X Y Z   B1 B2  STR SEL"
}

### updateDictionary - Update language and menu messages
updateDictionary() {
    local lang_dict
    local lang_base64

    # LANGUAGE_en base64
    LANGUAGE_en="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"

    # LANGUAGE_pt base64
    LANGUAGE_pt="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
AABMEQAAAAA="

    for lang_dict in en pt; do
        if [ ! -f "${GCM_DAT}/LANGUAGE_${lang_dict}.txt" ]; then
            lang_base64="LANGUAGE_${lang_dict}"
            echo "${!lang_base64}" | base64 --decode >"${GCM_DAT}/LANGUAGE_${lang_dict}.zip" 2>/dev/null \
                && unzip -d "$GCM_DAT" "${GCM_DAT}/LANGUAGE_${lang_dict}.zip" >/dev/null 2>&1 \
                && rm -f "${GCM_DAT}/LANGUAGE_${lang_dict}.zip" 2>/dev/null
        fi
    done

    SLOGAN="MiSTer GCM"
    # LANGUAGE 'pt' or 'en' - Select Language
    LANGUAGE=$(grep -o '^[[:space:]]*language=[^[:space:]]*' "$GCM_INI" \
        | cut -d'=' -f2 2>/dev/null)
    source "${GCM_DAT}/LANGUAGE_${LANGUAGE}.txt"
}

### generateGCMStaticFiles - Check and create static files
generateGCMStaticFiles() {
    local lang_help
    local help_base64
    local lang_no_gamepads
    local file_no_gamepad
    local no_gamepad_base64
    local lang_no_maps
    local file_no_maps
    local no_maps_base64

    # HELP MESSAGES en - base64
    HELP_MESSAGE_en="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
AAAAAA=="

    # HELP MESSAGES pt - base64
    HELP_MESSAGE_pt="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"

    # Generate HELP_${lang}.txt
    for lang_help in en pt; do
        if [ ! -f "${GCM_DAT}/HELP_${lang_help}.txt" ]; then
            help_base64="HELP_MESSAGE_${lang_help}"
            echo "${!help_base64}" | base64 --decode >"${GCM_DAT}/HELP_${lang_help}.txt.zip" 2>/dev/null \
                && unzip -d "$GCM_DAT" "${GCM_DAT}/HELP_${lang_help}.txt.zip" >/dev/null 2>&1 \
                && rm -f "${GCM_DAT}/HELP_${lang_help}.txt.zip" 2>/dev/null
        fi
    done

    # NO GAMEPAD en - base64
    NO_GAMEPAD_en="Ck5PIFJFR0lTVEVSRUQgR0FNRVBBRCBXQVMgRk9VTkQhCgpUTyBVU0UgVEhJUyBTQ1JJUFQsIEEg
R0FNRVBBRCBNVVNUIEJFIFJFR0lTVEVSRUQuIFRPIERPIFRISVMsClRIRSBHQU1FUEFEIE1VU1Qg
QkUgUFJFVklPVVNMWSBDT05GSUdVUkVEIElOIE1pU1RlciBGUEdBLgoKSU4gQURESVRJT04sIERP
IE5PVCBGT1JHRVQgVE8gQUNDRVNTIFRIRSAnSEVMUCcgTUVOVSBUTyBPQlRBSU4KSU1QT1JUQU5U
IElORk9STUFUSU9OIE9OIEhPVyBUTyBDT05GSUdVUkUgQU5EIFVTRSBUSElTIFNDUklQVC4KCkNM
SUNLICdFWElUJyBUTyBDT05USU5VRS4KCg=="

    # NO GAMEPAD pt - base64
    NO_GAMEPAD_pt="Ck5FTkhVTSBHQU1FUEFEIFJFR0lTVFJBRE8gRk9JIEVOQ09OVFJBRE8hCgpQQVJBIFVUSUxJWkFS
IEVTVEUgU0NSSVBULCDDiSBORUNFU1PDgVJJTyBSRUdJU1RSQVIgVU0gR0FNRVBBRC4gUEFSQQpJ
U1NPLCBPIEdBTUVQQUQgREVWRSBTRVIgUFJFVklBTUVOVEUgQ09ORklHVVJBRE8gTk8gTWlTVGVy
IEZQR0EuCgpBTMOJTSBESVNTTywgTsODTyBTRSBFU1FVRcOHQSBERSBBQ0VTU0FSIE8gTUVOVSAn
SEVMUCcgUEFSQSBPQlRFUgpJTkZPUk1Bw4fDlUVTIElNUE9SVEFOVEVTIFNPQlJFIENPTU8gQ09O
RklHVVJBUiBFIFVTQVIgRVNURSBTQ1JJUFQuCgpDTElRVUUgRU0gJ1NBSVInIFBBUkEgQ09OVElO
VUFSLgoK"

    # Generate NO_GAMEPAD TXT
    for lang_no_gamepads in en pt; do
        file_no_gamepad="${GCM_DAT}/NO_GAMEPAD_${lang_no_gamepads}.txt"

        if [ ! -f "$file_no_gamepad" ]; then
            no_gamepad_base64="NO_GAMEPAD_${lang_no_gamepads}"
            echo "${!no_gamepad_base64}" | base64 --decode >"$file_no_gamepad" 2>/dev/null
        fi
    done

    # ALERT_MISTER - base64
    ALERT_NO_MAPS_en="Ck5PIENPTkZJR1VSQVRJT05TIEZPVU5EIEZPUiBUSElTIEdBTUVQQUQgT04gQU5ZIENPUkUgSU4g
TWlTVGVyLiBPUEVOCkEgQ09SRSwgQUNDRVNTICJEZWZpbmUgJ0NPUkVOQU1FJyBidXR0b25zIiBB
TkQvT1IgIkJ1dHRvbi9LZXkgcmVtYXAiLApDT05GSUdVUkUgVEhFIEdBTUVQQUQsIEFORCBUUlkg
QUdBSU4uIE9OTFkgQ09SRVMgV0lUSCAiQlVUVE9OUyIgQU5EL09SCiJCVVRUT04vS0VZIFJFTUFQ
IiBDT05GSUdVUkFUSU9OUyBBUFBFQVIgSU4gVEhJUyBMSVNULgo="

    # ALERT_MISTER - base64
    ALERT_NO_MAPS_pt="Ck5FTkhVTUEgQ09ORklHVVJBw4fDg08gRU5DT05UUkFEQSBQQVJBIEVTVEUgR0FNRVBBRCBFTSBO
RU5IVU0gQ09SRQpETyBNaVNUZXIuIEFCUkEgVU0gQ09SRSwgQUNFU1NFICJEZWZpbmUgJ05PTUVE
T0NPUkUnIGJ1dHRvbnMiIEUvT1UKIkJ1dHRvbi9LZXkgcmVtYXAiLCBDT05GSUdVUkUgTyBHQU1F
UEFEIEUgVEVOVEUgTk9WQU1FTlRFLiBBUEVOQVMKQ09SRVMgQ09NIENPTkZJR1VSQcOHw5VFUyBE
RSAiQk9Uw5VFUyIgRS9PVSAiUkVNQVBFQU1FTlRPIERFCkJPVMOVRVMvVEVDTEFTIiBBUEFSRUNF
TSBORVNUQSBMSVNUQS4K"

    # Generate NO_MAPS TXT
    for lang_no_maps in en pt; do
        file_no_maps="${GCM_DAT}/ALERT_NO_MAPS_${lang_no_maps}.txt"

        if [ ! -f "$file_no_maps" ]; then
            no_maps_base64="ALERT_NO_MAPS_${lang_no_maps}"
            echo "${!no_maps_base64}" | base64 --decode >"$file_no_maps" 2>/dev/null
        fi
    done

    # LIST CONTROLLER IDS - base64
    list_gamepad_IDS="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
dFBLBQYAAAAAAQABAEIAAADMGQAAAAA="

    # GENERATE list_gamepad_IDS.txt & gamepad config files
    if [ ! -f "$GCM_LGI" ]; then
        echo "$list_gamepad_IDS" \
            | base64 --decode >"${GCM_LGI}.zip" 2>/dev/null \
            && unzip -d "$GCM_CFG" "${GCM_LGI}.zip" >/dev/null 2>&1 \
            && rm -f "${GCM_LGI}.zip" 2>/dev/null
    fi
}

### firstRUN - Script executed on first launch to select language and visual help option
firstRUN() {
    local restore_zip
    local restore_file
    local backup_file_found
    local backup_full
    local flag_backup_canceled

    # Set initial tips flags
    setFlags() {
        sed -i "s/^tips=[^ ]*/tips=$TIPS_STATUS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_help=[^ ]*/tip_help=$TIPS_STATUS/" "$GCM_INI" 2>/dev/null
        sed -i "s/^tip_exit=[^ ]*/tip_exit=$TIPS_STATUS/" "$GCM_INI" 2>/dev/null
        SHOW_TIPS="$TIPS_STATUS"
    }

    DIALOG="dialog --clear --no-cancel --no-tags --stdout \
        --title \"$SLOGAN\" \
        --menu \" $LANGUAGE_MENU\" 9 35 2 \
        E \"$EN\" \
        P \"$PT"\"

    runDialog NO_CORE_CHOICE

    case $CHOICE in
        "E")
            sed -i "s/^language=[^ ]*/language=en/" "$GCM_INI" 2>/dev/null
            updateDictionary
            ;;
        "P")
            sed -i "s/^language=[^ ]*/language=pt/" "$GCM_INI" 2>/dev/null
            updateDictionary
            ;;
    esac

    clear

    DIALOG="dialog --clear --no-cancel --no-tags --stdout\
        --title \"$SLOGAN\" \
        --menu \"$TIPS_MENU\" 9 35 2 \
        A \"$ACTIVE_TIPS\" \
        D \"$DEACTIVE_TIPS\""

    runDialog NO_CORE_CHOICE

    case "$CHOICE" in
        "A")
            TIPS_STATUS=1
            setFlags
            ;;
        "D")
            TIPS_STATUS=0
            setFlags
            ;;
    esac

    restore_zip=$(find "$INPUT_MISTER" -maxdepth 1 -name "Backup-GCM-MiSTer-*.zip" -print -quit)
    restore_file=$(basename "$restore_zip")

    if [ "$restore_file" != "" ]; then
        backup_file_found=1

        TITLE=("$CONFIRMATION")
        MESSAGE_LN1=("$FIRST_RUN_RESTORE_1")
        toggleYesNoDialog

        if [ "$STATUS_MESSAGE" -eq 1 ]; then
            if [[ "$restore_zip" == *full-* ]]; then
                TITLE=("$CONFIRMATION")
                MESSAGE_LN1=("$FIRST_RUN_RESTORE_2")
                toggleYesNoDialog

                if [ "$STATUS_MESSAGE" -eq 1 ]; then
                    backup_full=1
                else
                    flag_backup_canceled=1
                fi
            else
                backup_full=0
            fi
        else
            flag_backup_canceled=1
        fi

        if [ "$flag_backup_canceled" -eq 1 ]; then
            TITLE=("$CANCELED")
            MESSAGE_LN1=("$RESTORE_BACKUP_CANCELED")
            showDialogMessage
        else
            restoreBackupFiles "$restore_zip" "$backup_full"
        fi

        if [ "$backup_file_found" -eq 1 ]; then
            mv "$restore_zip" "$INPUTS"/ 2>/dev/null

            TITLE=("$DONE")
            MESSAGE_LN1=("$FIRST_RUN_MOVE_FILE_1" "$restore_file")
            MESSAGE_LN2=("$FIRST_RUN_MOVE_FILE_2")

            showDialogMessage
        fi

    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$FIRST_RUN_READ_HELP")
    yesNoDialog

    if [ "$STATUS_MESSAGE" -eq 0 ]; then
        if [ -f "${GCM_DAT}/HELP_${LANGUAGE}.txt" ]; then
            sed -i "s/^tip_help=[^ ]*/tip_help=0/" "$GCM_INI" 2>/dev/null
            SHOW_TIP_HELP=0 # Disable SHOW_TIP_HELP (0 = disable, 1 = enable)
            dialog --exit-label "$EXIT" --title "$SLOGAN" --textbox "${GCM_DAT}/HELP_${LANGUAGE}.txt" 28 89
        fi
    fi
}

### checkAndFixGCM - Check and restore integrity of gcm.ini
checkAndFixGCM() {
    if [ -z "$SCHEME" ] || [ -z "$LANGUAGE" ] || [ -z "$SHOW_TIPS" ] \
        || [ -z "$SHOW_TIP_HELP" ] || [ -z "$SHOW_TIP_EXIT" ]; then

        if [ -f "$GCM_INI" ]; then
            rm -f "$GCM_INI"
        fi

        initPathsAndConfigs
        generateGCMStaticFiles
        updateDialogSettings
        updateDictionary
    fi
}

# ========================================================================================= #
# SECONDARY_FUNCTIONS - Configuration and shared functions in this script                   #
# ========================================================================================= #

# ===== GENERATE FUNCTIONS ===== #

### adjustLinesMenuSize - Limit LINES_MENU to a maximum of 28 lines
adjustLinesMenuSize() {
    if [ "$LINES_MENU" -gt 28 ]; then
        LINES_MENU=28
        PARAM_3=21
    fi
}

### generateHeader - Generate the header of the dialog menu
generateHeader() {
    # ARGUMENTS:
    # $1 = width of the dialog
    # $2 = size of the inner window frame (inside the dialog box)
    # $3 = total number of lines in the dialog
    # $4 = increase options: e.g., LINES_MENU=$((COUNTER_LINES + LINES_MENU))
    # $5 = additional options (e.g., --no-cancel)
    # $6 = message to display in the --menu
    if [ "$1" != "" ]; then
        if [ "$1" != "null" ]; then
            PARAM_2=$1
            PARAM_3=$2
        fi

        if [ "$3" != "null" ]; then
            LINES_MENU=$3
        fi

        if [ "$4" = "increase" ]; then
            LINES_MENU=$((COUNTER_LINES + LINES_MENU))
        fi

        if [ "$5" != "null" ]; then
            EXTRA_OPTIONS="$5"
        else
            EXTRA_OPTIONS=""
        fi

        if [ "$6" != "" ]; then
            MESSAGE_MENU="$6"
        fi
    fi

    adjustLinesMenuSize
    TITLE_FORMATTED="$(printf "%s - %s - %s" "$SLOGAN" "$MODEL_CUT" "$ID")"
    message="$(printf " %s" "$MESSAGE_MENU")"

    DIALOG="dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear $EXTRA_OPTIONS --no-tags --stdout \\
        --title \"$TITLE_FORMATTED\" \\
        --menu \"$message\" $LINES_MENU $PARAM_2 $PARAM_3 \\"
}

### generateHeaderOnDisk - Generate dialog menu header on disk
generateHeaderOnDisk() {
    # ARGUMENTS:
    MESSAGE_MENU="$1"

    LINES_MENU=$((COUNTER_SLOTS + 8))
    PARAM_2=75
    PARAM_3=$((LINES_MENU - 7))
    EXTRA_OPTIONS=""
    adjustLinesMenuSize
    rm -f "${TMP_MENU}.sh" 2>/dev/null

    {
        echo "#!/bin/bash" 2>/dev/null
        echo "TMP_MENU=$TMP_MENU" 2>/dev/null
        echo "TITLE_FORMATTED=\"$(printf "%s - %s - %s" "$CORE_DISPLAY" "$MODEL_CUT" "$ID")"\" 2>/dev/null
        echo "message=\"$(printf " %s" "$MESSAGE_MENU")"\" 2>/dev/null
        echo "dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --clear $EXTRA_OPTIONS --no-tags \\" 2>/dev/null
        echo "--title \"\$TITLE_FORMATTED\" \\" 2>/dev/null
        echo "--menu \"\$message\" $LINES_MENU $PARAM_2 $PARAM_3 \\" 2>/dev/null
    } >"${TMP_MENU}.sh" 2>/dev/null
}

### checkOneSlot - Show message if one slot exists
checkOneSlot() {
    if [ "$COUNTER_SLOTS" -eq 1 ]; then
        TITLE=("$INFORMATION")
        MESSAGE_LN1=("$ONLY_ONE_1")
        MESSAGE_LN2=("$ONLY_ONE_2")
        showDialogMessage

        menuCoreMain
    fi
}

### generateLayoutsOnDiskRun - Generate LAYOUTS (Button Maps) on disk and run the menu
generateLayoutsOnDiskRun() {
    local option_exclude_input
    local first_slot
    local index
    local output
    local position

    # ARGUMENTS:
    option_exclude_input="$1"

    index=0

    if [ "$2" != "" ]; then
        first_slot="$2"
    fi

    {
        echo "- \"     $LAYOUT_TAG ------ $COMMENTS ------\" \\" 2>/dev/null

        for ((i = 1; i <= COUNTER_SLOTS; i++)); do
            if [ "$index" = 20 ]; then
                echo "" >>"$TMP_FILE" 2>/dev/null
                echo "  SLOT  $LAYOUT_TAG        $COMMENTS" >>"$TMP_FILE" 2>/dev/null
                echo "  ----  ------------------------------------------ --------------------" >>"$TMP_FILE" 2>/dev/null
                index=0
            fi

            ((index++))

            if [ "$i" != "$first_slot" ] || [ "$option_exclude_input" != "EXCLUDE" ]; then
                output=$(cat "${CORE_DIR}/SLOT_${i}/LAYOUT.cfg" 2>/dev/null)
                position=$(printf "%3d" $i)
                echo "$i \"$position) $output\" \\" 2>/dev/null
            else
                position=$(printf "%3d" $i)
                echo "- \"$position) $SELECTED\" \\" 2>/dev/null
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
    local last_line
    local cut_line
    local line_type
    local output
    local output_menu

    # ARGUMENTS:
    array_name="$1"    # Store the array name to be accessed dynamically
    variable_name="$2" # Store the name of the variable to be accessed indirectly
    last_line="$3"     # Only generate a trailing '\' on the last line if the option is 'EXCLUDE_LAST_BACKSLASH'
    cut_line="$4"      # Limit output to first 60 characters
    line_type="$5"     # Determine if a new line should be added to DIALOG

    for ((i = 1; i <= $(eval echo "\$$variable_name"); i++)); do
        output=$(eval echo "\${${array_name}[$((i - 1))]}")

        if [ "$cut_line" = "CUT_OUTPUT" ]; then
            output_menu=$(echo "$output" | cut -c1-60 2>/dev/null)
        fi

        if [ "$last_line" = "EXCLUDE_LAST_BACKSLASH" ] && [ "$i" = "$(eval echo "\$$variable_name")" ]; then
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

    sed -i '1{/^[[:space:]]*$/d}' "$dir_target"
    COUNTER_LINES=0
    LINES_ARRAY=()

    while IFS= read -r line; do
        LINES_ARRAY[COUNTER_LINES]="$line"
        ((COUNTER_LINES++))
    done <"$dir_target"
}

# ====== RUN AND STORE MENU FUNCTIONS ====== #

### runDialog - Execute the generated dialog menu and store CHOICE, STATUS_MESSAGE and CORE
runDialog() {
    local function_parameter

    # ARGUMENTS:
    function_parameter="$1"

    CHOICE=$(eval "$DIALOG")
    STATUS_MESSAGE="$?"

    if [ "$function_parameter" != "NO_CORE_CHOICE" ]; then
        if [ "$CHOICE" != "-" ] && [ "$CHOICE" != "X" ]; then
            CORE=$(sed -n "${CHOICE}p" "$TMP_MENU" 2>/dev/null)
        fi
        rm -f "$TMP_MENU" 2>/dev/null
    fi
}

### storeChoiceAndClean - Store selection and delete temporary files
storeChoiceAndClean() {
    if [ "$MENU_STATUS" -eq 1 ]; then
        rm -f "${TMP_MENU}.sh" "$TMP_MENU" 2>/dev/null

        menuCoreMain
    fi

    CHOICE=$(<"$TMP_MENU")
    rm -f "${TMP_MENU}.sh" "$TMP_MENU" 2>/dev/null
}

# ====== GAMEPAD FUNCTIONS ===== #

### prepareGamepadMenu - Start generating the menu with registered gamepads
prepareGamepadMenu() {
    local message_gamepad_menu
    local add_lines

    # ARGUMENTS:
    message_gamepad_menu="$1"

    if [ "$2" = "" ]; then
        add_lines=0
    else
        add_lines="$2"
    fi

    checkRegisteredGamepads
    generateLinesArray "$GCM_RGP"
    LINES_MENU=$((COUNTER_LINES + 7 + add_lines))
    MESSAGE_MENU="$message_gamepad_menu"
    PARAM_2=67
    PARAM_3=$((LINES_MENU - 7))
    EXTRA_OPTIONS=""
}

### importControllerData - Import the ID and MODEL of the registered controller
importControllerData() {
    source "$GCM_SGP"
    MODEL_CUT=$(echo "$MODEL" | cut -c1-28 2>/dev/null)
}

### recordGamepadID - Register the gamepad, update SELECTED_GAMEPAD ID and MODEL, and sort
recordGamepadID() {
    {
        echo "ID=\"$ID_CHOICE\""
        echo "MODEL=\"$MODEL_CHOICE\""
    } >"$GCM_SGP" 2>/dev/null

    grep "$ID_CHOICE" "$GCM_RGP" >"$TMP_FILE" 2>/dev/null
    grep -v "$ID_CHOICE" "$GCM_RGP" >>"$TMP_FILE" 2>/dev/null
    mv "$TMP_FILE" "$GCM_RGP" 2>/dev/null
}

### countGamepads - Count registered gamepads (COUNTER_GAMEPADS)
countGamepads() {
    if [ ! -f "$GCM_RGP" ] || ! grep -q "_" "$GCM_RGP"; then
        COUNTER_GAMEPADS=0
        updateNoGamepadMessage
        messageNoGamepadConfigured
        menuRegisterGamepad
    else
        COUNTER_GAMEPADS=$(wc -l <"$GCM_RGP" 2>/dev/null)
    fi
}

### checkGamepads - 0: menuRegisterGamepad; >=1 & none: menuSelectGamepad
checkGamepads() {
    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        messageNoGamepadConfigured
        menuRegisterGamepad
    elif [ "$COUNTER_GAMEPADS" -ge 1 ] && [ "$ID" = "" ]; then
        menuSelectGamepad
    fi
}

### checkRegisteredGamepads - Check COUNTER_GAMEPADS; if 0, go to menuGamepads
checkRegisteredGamepads() {
    if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        menuGamepads
    fi
}

### organizeGamepadIDs - Remove duplicate records and sort them for prevention
organizeGamepadIDs() {
    awk '!seen[$1]++' "$GCM_LGI" | sort >"$TMP_FILE" 2>/dev/null
    mv "$TMP_FILE" "$GCM_LGI" 2>/dev/null
}

### runDialogRegisteredGamepads - show dialog with registered gamepads and/or save MODEL and ID
runDialogRegisteredGamepads() {
    local flag_record_id_model
    local flag_choice

    # ARGUMENTS:
    flag_record_id_model="$1"
    flag_choice="$2"

    CHOICE=$(eval "$DIALOG") # Run the generated menu and save the selection to 'CHOICE'

    if [ "$?" -eq 1 ] || { [ "$CHOICE" = "1" ] && [ "$flag_choice" = "SKIP_IF_FIRST" ] \
        && [ "$FLAG_GAMEPAD_MESSAGE_MODE" -ne 0 ] && [ "$ID" != "" ]; }; then
        FLAG_GAMEPAD_SHOW_MESSAGE=1
        menuGamepads
    fi

    if [ "$flag_record_id_model" = "ID_MODEL" ]; then
        ID_CHOICE=$(sed -n "${CHOICE}p" "$GCM_RGP" | cut -c1-9 2>/dev/null)
        MODEL_CHOICE=$(sed -n "${CHOICE}p" "$GCM_RGP" | cut -c13- 2>/dev/null)
    fi
}

### showUpdateList - show updated gamepad list
showUpdateList() {
    local flag_show_list
    local flag_counter_gamepads

    # ARGUMENTS:
    flag_show_list="$1"
    flag_counter_gamepads="${2:-0}"

    if [ "$flag_show_list" = "SHOWLIST" ] || [ "$flag_counter_gamepads" -ne 0 ]; then
        MODEL_CUT="$MESSAGE_UPDATE_LIST"
        ID=""
        menuListGamepads RETURN
        importControllerData
    fi

    if [ "$flag_show_list" = "SHOWLIST" ]; then
        menuHome
    else
        menuGamepads
    fi
}

### updateNoGamepadMessage - Update NO_GAMEPAD message in selected language
updateNoGamepadMessage() {
    if [ ! -f "$GCM_RGP" ] || [ "$COUNTER_GAMEPADS" -eq 0 ]; then
        {
            echo "ID=\"\""
            echo "MODEL=\"$NO_GAMEPAD\""
        } >"$GCM_SGP" 2>/dev/null

        importControllerData
    fi
}

### messageNoGamepadConfigured - Show message if no gamepad is registered
messageNoGamepadConfigured() {
    dialog --title "$SLOGAN - $ATTENTION" --textbox "${GCM_DAT}/NO_GAMEPAD_${LANGUAGE}.txt" 15 75
}

# ===== VERIFY FUNCTIONS ===== #

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
        echo "${LAYOUT_TAG[1]}" >"${GAMEPAD_DIR}/gamepad_tag.txt" 2>/dev/null
    fi
}

### verifyTipsFlagsHOME - Verify flags and variables and set tip text in HOME menus
verifyTipsFlagsHome() {
    # If SHOW_TIPS is 1, check the other conditions
    if [ "$SHOW_TIPS" -eq 1 ]; then
        if [ "$COUNTER_CORES" -eq 0 ]; then
            MESSAGE_MODE_1="TIPS"
        else
            MESSAGE_MODE_1="DEFAULT"
        fi

        if [ "$COUNTER_GAMEPADS" -eq 0 ]; then
            MESSAGE_MODE_2="TIPS"
            MESSAGE_MODE_4="TIPS"
        else
            MESSAGE_MODE_2="DEFAULT"
            MESSAGE_MODE_4="DEFAULT"
        fi

        if [ "$SHOW_TIP_HELP" -eq 1 ]; then
            MESSAGE_MODE_3="TIPS"
        else
            MESSAGE_MODE_3="DEFAULT"
        fi

        if [ "$SHOW_TIP_EXIT" -eq 1 ]; then
            MESSAGE_MODE_5="TIPS"
        else
            MESSAGE_MODE_5="DEFAULT"
        fi
    else
        MESSAGE_MODE_1="DEFAULT"
        MESSAGE_MODE_2="DEFAULT"
        MESSAGE_MODE_3="DEFAULT"
        MESSAGE_MODE_4="DEFAULT"
        MESSAGE_MODE_5="DEFAULT"
    fi
}

### verifyTipsFlagsCore - Verify flags and variables and set tip text in CORE menu
verifyTipsFlagsCore() {
    if [ "$SHOW_TIPS" -eq 1 ]; then
        if [ "$COUNTER_SLOTS" -eq 0 ]; then
            MESSAGE_MODE_6="TIPS"
        else
            MESSAGE_MODE_6="DEFAULT"
        fi

        if [ "$SHOW_TIPS_EDIT_LAYOUTS" -eq 1 ]; then
            MESSAGE_MODE_7="TIPS"
        else
            MESSAGE_MODE_7="DEFAULT"
        fi

        if [ "$SHOW_TIPS_EDIT_GAMES" -eq 1 ]; then
            MESSAGE_MODE_8="TIPS"
        else
            MESSAGE_MODE_8="DEFAULT"
        fi
    else
        MESSAGE_MODE_6="DEFAULT"
        MESSAGE_MODE_7="DEFAULT"
        MESSAGE_MODE_8="DEFAULT"
    fi
}

# ===== SLOT ACTION FUNCTIONS (SLOT = .map + GAMES LIST + BUTTON MAP) =====

### moveSlot - Move the SLOT
moveSlot() {
    local slot_1
    local slot_2

    # ARGUMENTS:
    slot_1="$1"
    slot_2="$2"

    mv "${CORE_DIR}/SLOT_${slot_1}" "${CORE_DIR}/SLOT_${slot_2}" 2>/dev/null
}

### reorganizeSlotsOrder - Reorganize the order of SLOTS after changes
reorganizeSlotsOrder() {
    local first_slot_rso
    local condition_rso
    local inc_rso

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

    if [ "$TYPE" = "v3" ] || [ "$TYPE" = "v3_jk" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_v3.map "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null || fileSystemError
    fi

    if [ "$TYPE" = "jk" ] || [ "$TYPE" = "v3_jk" ]; then
        cp "$INPUT_MISTER"/"$CORE"_input_"$ID"_jk.map "${CORE_DIR}/SLOT_${new_slot}" 2>/dev/null || fileSystemError
    fi

    touch "${CORE_DIR}/SLOT_${new_slot}/GAMES.cfg" 2>/dev/null
    touch "${CORE_DIR}/SLOT_${new_slot}/LAYOUT.cfg" 2>/dev/null
}

# ====== MESSAGE AND DIALOG FUNCTIONS ===== #

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
}

### toggleYesNoDialog - Temporarily toggle Yes/No buttons, run dialog, then restore them
toggleYesNoDialog() {
    if [ "$LANGUAGE" = "en" ]; then
        YES="NO"
        NO="YES"
    else
        YES="NÃO"
        NO="SIM"
    fi

    yesNoDialog

    if [ "$LANGUAGE" = "en" ]; then
        YES="YES"
        NO="NO"
    else
        YES="SIM"
        NO="NÃO"
    fi
}

### inputDialog - Open an input box in the dialog
inputDialog() {
    formatMessage
    adjustMenuSize
    formatDialogMessage
    SIZE_LINES=$((SIZE_LINES + 2))

    DIALOG="dialog --ok-label \"$OK\" --cancel-label \"$CANCEL\" --title --stdout \"$TITLE_FORMATTED\" --inputbox \"$OUTPUT\" $SIZE_LINES $SIZE_DIALOG"

    TMP_INPUT=$(eval "$DIALOG")
    resetDialogMessage
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
    LINES=$(($(wc -l <"${GCM_DAT}/ALERT_NO_MAPS_${LANGUAGE}.txt") + 5))
    dialog --title "$SLOGAN - $ATTENTION" --textbox "${GCM_DAT}/ALERT_NO_MAPS_${LANGUAGE}.txt" "$LINES" 73
}

### actionCanceled - Display a message when the action is canceled
actionCanceled() {
    local msg_canceled

    # ARGUMENTS:
    msg_canceled="$1"

    TITLE=("$CANCELED")
    MESSAGE_LN1=("$msg_canceled")
    showDialogMessage
}

### messageSlotsNotFound - Show message if no SLOTS is found
messageSlotsNotFound() {
    TITLE=("$CORE_DISPLAY - $MODEL_CUT - $LAST_LOAD:[$CURRENT]")
    MESSAGE_LN1=("$SLOTS_NOT_FOUND")
    showDialogMessage
}

### showCancelMessageAndExit - Show cancellation message and exit to the specified MENU
showCancelMessageAndExit() {
    local message_dialog
    local exit_to

    # ARGUMENTS:
    message_dialog="$1"
    exit_to="$2"

    actionCanceled "$message_dialog"
    "$exit_to"
}

### showDialogMessage - Display a message in the dialog
showDialogMessage() {
    formatMessage
    adjustMenuSize
    formatDialogMessage
    dialog --ok-label "$OK" --title "$TITLE_FORMATTED" \
        --msgbox "$OUTPUT" "$SIZE_LINES" "$SIZE_DIALOG"
    resetDialogMessage
}

### showNoInputMessage - Display a message when no input is provided
showNoInputMessage() {
    TITLE=("$ATTENTION")
    MESSAGE_LN1=("$MSG_BLANK")
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

# ===== BACKUP FUNCTIONS ===== #

### generateMenuBackup - Generate the menu from the backup files found on disk
generateMenuBackup() {
    local backup_message
    local backups_found
    local line
    local output

    # ARGUMENTS:
    backup_message="$1"
    backups_found=$(find "$INPUTS" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' | wc -l 2>/dev/null)

    if [ "$backups_found" -eq 0 ]; then
        TITLE=("$ATTENTION")
        MESSAGE_LN1=("$NO_BACKUP_FILES")
        showDialogMessage

        menuBackup
    fi

    find "$INPUTS" -maxdepth 1 -name 'Backup-GCM-MiSTer-*' >"$TMP_MENU"
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
- \"---------------------------------------\" \\"

    for ((i = 0; i < ${#BACKUPS[@]}; i++)); do
        output=$(basename "${BACKUPS[$i]}")

        if [ "$i" -lt $((${#BACKUPS[@]} - 1)) ]; then
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\" \\"
        else
            DIALOG+="$((i + 1)) \"$((i + 1))) $output\""
        fi
    done

    runDialog NO_CORE_CHOICE
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

    if [ -d "$GCM_CFG" ] && [ "$GCM_CFG" != "/" ]; then
        rm -rf "$GCM_CFG" 2>/dev/null
    fi

    if [ -d "$GCM_DAT" ] && [ "$GCM_DAT" != "/" ]; then
        rm -rf "$GCM_DAT" 2>/dev/null
    fi

    if [ -d "$GCM_GPD" ] && [ "$GCM_GPD" != "/" ]; then
        rm -rf "$GCM_GPD" 2>/dev/null
    fi

    bkp_dir="${GCM_TMP}/Backup-GCM-MiSTer"
    mkdir -p "$bkp_dir" 2>/dev/null
    extraction_dir="$bkp_dir/$(basename "$zip_file" .zip)"

    if [ "$backup_type" -eq 1 ]; then
        extraction_dir="${extraction_dir//full-/}"
    fi

    if [[ "$extraction_dir" != *Backup-GCM-MiSTer* ]]; then
        return
    fi

    rm -rf "$extraction_dir" 2>/dev/null
    unzip "$zip_file" -d "$bkp_dir" >/dev/null 2>&1

    mv "$extraction_dir"/gamepads "$INPUTS/" 2>/dev/null
    mv "$extraction_dir"/configs "$INPUTS/" 2>/dev/null
    mv "$extraction_dir"/data "$INPUTS/" 2>/dev/null

    if [ "$backup_type" -eq 1 ]; then
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

# ====== CORE FUNCTIONS ====== #

### generateCoreConfig - Generate the CORE configuration file
generateCoreConfig() {
    local core

    # ARGUMENTS:
    core="$1"

    if [ ! -f "${GAMEPAD_DIR}/${core}/${core}.cfg" ]; then
        {
            echo "show_tips_edit_games=$SHOW_TIPS"
            echo "show_tips_edit_layouts=$SHOW_TIPS"
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

### counterCores - count added CORES
counterCores() {
    if ! ls -d "$GAMEPAD_DIR"/*/ 1>/dev/null 2>&1; then
        COUNTER_CORES=0
        return
    fi

    if [ "$FLAG_COUNTER_CORES" -eq 1 ]; then
        find "$GAMEPAD_DIR" -maxdepth 1 -type d ! -path "$GAMEPAD_DIR" -exec basename {} \; | grep -v '^$' >"$TMP_COUNTER" 2>/dev/null
        sed -i '/-stored$/d' "$TMP_COUNTER" 2>/dev/null
        COUNTER_CORES=$(wc -l <"$TMP_COUNTER")
        rm -f "$TMP_COUNTER" 2>/dev/null
        FLAG_COUNTER_CORES=0
    fi
}

### loadCoreConfigContents - Loads CORE config contents and stores variables in the script
loadCoreConfigContents() {
    CURRENT=$(grep -o '^[[:space:]]*selected_SLOT=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" \
        | cut -d'=' -f2 2>/dev/null)
    SHOW_TIPS_EDIT_GAMES=$(grep -o '^[[:space:]]*show_tips_edit_games=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" \
        | cut -d'=' -f2 2>/dev/null)
    SHOW_TIPS_EDIT_LAYOUTS=$(grep -o '^[[:space:]]*show_tips_edit_layouts=[^[:space:]]*' "${CORE_DIR}/${CORE}.cfg" \
        | cut -d'=' -f2 2>/dev/null)
}

### checkSloteMapFiles
checkMapFiles() {
    local category
    local path
    local slot
    local test_v3
    local test_jk

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

    if [ -f "${path}/${CORE}_input_${ID}_v3.map" ]; then
        test_v3=1
    fi
    if [ -f "${path}/${CORE}_input_${ID}_jk.map" ]; then
        test_jk=1
    fi

    if [ "$test_v3" -eq 1 ] && [ "$test_jk" -eq 0 ]; then
        TYPE="v3"
    elif [ "$test_v3" -eq 0 ] && [ "$test_jk" -eq 1 ]; then
        TYPE="jk"
    elif [ "$test_v3" -eq 1 ] && [ "$test_jk" -eq 1 ]; then
        TYPE="v3_jk"
    fi
}

### checkCounterCores - Check COUNTER_CORES; if 0, return to the menuHome
checkCounterCores() {
    if [ "$COUNTER_CORES" -eq 0 ]; then
        menuHome
    fi
}

### renameCoreIfNeeded - If a rename exists in rename.cfg (CORE@%DISPLAY), return DISPLAY; otherwise return original CORE
renameCoreIfNeeded() {
    local line
    local rename_file
    local result

    # ARGUMENTS:
    line="$1"

    rename_file="${GAMEPAD_DIR}/rename.cfg"
    result=$(awk -F'@%' -v core="$line" '$1==core {print $2; exit}' "$rename_file")

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

    new_name=$(awk -F'@%' -v core="$line" '$1==core {print $2; exit}' "${GAMEPAD_DIR}/rename.cfg")

    if [ -n "$new_name" ]; then
        CORE_DISPLAY="$new_name"
    else
        CORE_DISPLAY="$line"
    fi
}

# ====== SLOTS FUNCTIONS ===== #

### countSlots - Verify and restore CORE config files and SLOTS, generate COUNTER_SLOTS
countSlots() {
    if [ "$FLAG_COUNTER_SLOTS" -ne 1 ]; then
        return
    fi

    COUNTER_SLOTS=$(find "$CORE_DIR" -type d -name "SLOT_*" 2>/dev/null | wc -l)
    FLAG_COUNTER_SLOTS=0
}

### checkCounterSlots - Verify COUNTER_SLOTS before opening CORE menu
checkCounterSlots() {
    if [ "$COUNTER_SLOTS" -eq 0 ]; then
        messageSlotsNotFound
        menuCoreMain
    fi
}

### checkCurrentSlotStatus - Verifies if the SLOT matches MiSTer's current config
checkCurrentSlotStatus() {
    local test_md5sum_current
    local test_md5sum_mister
    local type

    if [ "$FLAG_SLOT_CURRENT_CHECK" -eq 0 ] || [ "$CURRENT" = "X" ]; then
        return
    fi

    FLAG_SLOT_CURRENT_CHECK=0

    for type in v3 jk; do
        if [ -f "${INPUT_MISTER}/${CORE}_input_${ID}_${type}.map" ]; then
            test_md5sum_mister=$(md5sum "${INPUT_MISTER}/${CORE}_input_${ID}_${type}.map" | awk '{print $1}')

            if [ -f "${CORE_DIR}/SLOT_${CURRENT}/${CORE}_input_${ID}_${type}.map" ]; then
                test_md5sum_current=$(md5sum "${CORE_DIR}/SLOT_${CURRENT}/${CORE}_input_${ID}_${type}.map" | awk '{print $1}')
                if [ "$test_md5sum_current" != "$test_md5sum_mister" ]; then
                    CURRENT="X"
                fi
            fi
        fi
    done

    if [ "$CURRENT" = "X" ]; then
        sed -i "s/^selected_SLOT=[^ ]*/selected_SLOT=$CURRENT/" "${CORE_DIR}/${CORE}.cfg" 2>/dev/null
    fi
}

### exitScript - End the script
exitScript() {
    clear

    if [ "$1" != "NO_GAMEPAD" ]; then
        EXIT_MESSAGE_LN1="$EXIT_QUESTION"
    else
        EXIT_MESSAGE_LN1="$EXIT_GAMEPAD_CONFIGURE"
    fi

    TITLE=("$CONFIRMATION")
    MESSAGE_LN1=("$EXIT_MESSAGE_LN1")
    yesNoDialog

    if [ "$STATUS_MESSAGE" -eq 1 ]; then
        menuHome
    fi

    clear
    echo "finished... script gamepad_config_manager.sh v1.0 26.04.23" 2>/dev/null
    exit 0
}

# ========================================================================================= #
#                     SCRIPT_INIT - Start execution from this point                         #
# ========================================================================================= #

scriptInit() {
    initPathsAndConfigs    # Set essential PATHs and initialize required configurations
    generateGCMStaticFiles # Check and create static files
    updateDialogSettings   # Update visual settings of the dialog
    updateDictionary       # Update language and menu messages
    checkAndFixGCM         # Check and restore integrity of gcm.ini

    # Script executed on first launch to select language and help visual option
    if [ "$FIRST_RUN" -eq 1 ]; then
        firstRUN
    fi

    FLAG_GAMEPAD_SHOW_MESSAGE=0 # Show message after gamepad selection (0 = hide, 1 = show)
    FLAG_GAMEPAD_MESSAGE_MODE=0 # 0 = startup message / 1 = default message
    FLAG_COUNTER_CORES=1        # enable CORE counter on Home menu access
    countGamepads        # Count registered gamepads (COUNTER_GAMEPADS) - If equal to 0, open menuRegisterGamepad
    importControllerData # Check the ID and model of the registered controller

    # Check if exactly one gamepad is registered
    if [ "$COUNTER_GAMEPADS" -eq 1 ]; then
        # If no gamepad is registered, open menuSelectGamepad (empty ID = no gamepad registered)
        if [ "$ID" = "" ]; then
            menuSelectGamepad
        else
            menuHome
        fi
    # More than one gamepad registered
    else
        # If multiple gamepads and one is selected, enable default message
        if [ "$ID" != "" ]; then
            FLAG_GAMEPAD_MESSAGE_MODE=1
        fi

        menuSelectGamepad
    fi
}

scriptInit
# === END OF SCRIPT === #
