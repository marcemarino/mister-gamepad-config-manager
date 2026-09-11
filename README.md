# Gamepad Config Manager (GCM)

Manage, save and load multiple gamepad/controller configurations per CORE in **MiSTer FPGA**.

## Installation

To install the script, simply copy it to the `Scripts` folder of your **MiSTer FPGA**.

To run it, access the **Scripts** menu and click on `gamepad_config_manager`.

On the first run, the `gcm` directory will be created inside the `/media/fat/Scripts` folder.

All files required for the script to function will be placed in this folder. They will be created automatically on the first run and during script execution.

## How to use

---

# GCM - Gamepad Config Manager

*@MM 2026.09.15*

---

Script for managing gamepad configurations on `MiSTer FPGA`.

Configurations are saved in SLOTS that can be loaded later, allowing multiple configurations per gamepad and CORE.

The script is mainly used via gamepad.

The keyboard is required only for editing and configuration tasks (explained in this HELP).

Gamepad refers to any controller (joystick, gamepad, keyboard, etc.). Any device used as a controller can be managed.

In this tutorial, whenever we refer to the `/media/fat/config/inputs` or `smb://IP/sdcard/config/inputs` folders, we will simply use `inputs`. Similarly, for `/media/fat/Scripts` or `smb://IP/sdcard/Scripts`, we will simply use `Scripts`.

HELP file location: `Scripts/gcm/data/HELP_en.txt`

---

INDEX

---

## 1) MiSTer Files

## 2) The GCM Script

## 3) Script Usage Guide

## 4) Script Functions

## 5) Quick Guide

## 6) Important Information

## 7) Usage Flowchart - Super-Quick Guide

---

## 1) MiSTer Files

---

On MiSTer, gamepad configuration files are located in the `inputs` folder.

When a gamepad is connected via USB, Bluetooth, or 2.4G and configured, a file isgenerated.

This file uses the prefix 'input' followed by a unique gamepad identifier (example: 1234_abcd), the suffix `v3` for configurations made in the `Define joystick buttons` menu, or `jk` for traditional remappings, or `advanced_input_*_v1` for advanced remappings, and the `.map` extension.

Examples:

1. input_1234_abcd_v3.map

2. Intellivision_input_1234_abcd_v3.map

3. MSX_input_1234_abcd_jk.map or MSX_advanced_input_1234_abcd_v1.map

### File 1

Configuration made in MiSTer `Define joystick buttons`:

input - file prefix 1234_abcd - gamepad ID (hexadecimal) v3 - joystick button definition .map - extension

### File 2

Configuration made in CORE menu 'Intellivision' in `Define Intellivision buttons`:

The only difference is the CORE name 'Intellivision', which appears as prefix, followed by `input_1234_abcd_v3.map`.

The suffix `v3` indicates a 'joystick button definition' for the CORE 'Intellivision'.

### File 3

Configuration made in CORE menu 'MSX' in `Button/Key remap`:

In this case, the prefix will be 'MSX' and the suffix will be `jk` or 'v1' (the latter preceded by 'advanced_input'), indicating a `button/key remap` for the CORE 'MSX'.

---

## 2) The GCM Script

---

The MiSTer saves only one gamepad configuration per CORE.

The GCM script allows these configurations to be saved in numbered SLOTS, which can be loaded later.

Each registered gamepad can have multiple associated CORES, with different configurations.

It works like a 'SAVE STATE' of the gamepad, allowing it to include the 'joystick button definition (v3)' and/or the `button/key mapping (jk, advanced_input_*_v1, or both)` for the selected CORE, all handled automatically by the script.

```text
                               Tree structure:
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

## 3) Script Usage Guide

---

Before anything else, you must configure at least one gamepad on the MiSTer.

For a gamepad to be added to the script, it is necessary to have at least one configuration created through `Define joystick buttons` in the MiSTer menu. When this configuration is saved, a file containing the gamepad ID will be created in the `inputs` folder. This file allows the gamepad to be identified and made available for registration in the script.

To add a CORE to the script, it is necessary to have at least one configuration created through 'Define CoreName buttons' and/or `Button/Key remap` in the CORE menu. After one of these configurations is saved, a file with the CORE name will be generated and identified by the script, allowing the CORE to be added through the ADD/EASY menu. This is the easiest way to add a CORE to the gamepad.

Another way to add a CORE is by using the ADD/EXPERT menu. In this case, it is not necessary to have a configuration previously created in the CORE, but you must know the real name of the CORE, which must be typed when requested. The script will search for the CORE in the folders configured in the FOLDERS menu and, if the CORE is found and validated, it will be added to the gamepad.

Due to its complexity, the Arcade folder cannot be used in this mode. To add Arcade CORES, use the EASY menu. For this, you only need to have a gamepad configuration already created for the desired CORE.

In the following example, we assume that the gamepad was configured on MiSTer and also on the Intellivision CORE.

### STEPS

1. Configure the gamepad in MiSTer in `Define joystick buttons`.

2. Still in MiSTer, configure this same gamepad in the CORE menu.

For example, for 'Intellivision', click `Define Intellivision buttons`.

3. Open this GCM script.

4. In the script, click 'MANAGE(GAMEPADS)' and `REGISTER`. Register

the gamepad.

5. In the main MENU, click `ADD - ADD CORE / EASY`. Select the CORE

name, in this case, 'Intellivision'.

6. With the CORE already added, click on the `CORES` menu and select

the 'Intellivision' CORE."

7. In the `CORE MENU`, click 'SAVE CONFIG - CORE --> NEW SLOT'.

The current configuration for gamepad 1234_abcd in the 'Intellivision CORE' will be saved to SLOT 1. In this case, the configuration identified by the script was only the 'joystick button definition (v3)' and it will be identified by the letter J.

Each SLOT includes two additional files that can be edited for identification purposes. Editing is optional.

  a. The first is 'LAYOUTS - button map', where you can define the relation between gamepad buttons and CORE controls.

The first line can be edited using the button configuration, while the second line serves as a default reference.

INFO: 'The Intellivision controller also includes a numeric keypad, in addition to the directional pad and action buttons.'

Example: Edit screen 'LAYOUTS - [EDIT] BUTTON MAP (SLOT 1)':

```text
┌───────────────────────────────────────────────────────────┐
│                                                           │
│ ← ↓ ↑ → L U R  3 4 5  1  2        EN CL    A B C = Action │
│ ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL |---- OTHERS ----|│
│                                                           │
└───────────────────────────────────────────────────────────┘
```

Note: In the examples, we will be using an 8BitDo M30 controller and the `Mega/Saturn` TAG, which has a LAYOUT suitable for this controller.

Mega/Saturn controller TAG: ← ↓ ↑ → A B C X Y Z L1 R1 EXT ST SL (You can choose the TAG that best suits your gamepad.)

In the TAGs, ST = Start and SL = Select.

You can edit your own TAG and use any symbols you prefer.

EN = ENTER on the Intellivision controller CL = CLEAR on the Intellivision controller

  b. The second is 'GAMES - game list', where you can edit the games associated with SLOT 1.

Each game name must be on a separate line.

Example: Edit screen 'GAMES - [EDIT] GAME LIST (SLOT 1)':

```text
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│ Burgertime                                                    │
│ Bump'n'Jump                                                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

8. Afterwards, in MiSTer, you can reconfigure the gamepad for

another game that requires different button settings.

Just repeat STEP 7, and the new configuration will be saved in a new SLOT.

You can view 'button maps' and 'game lists' in the `LAYOUTS` and `GAMES` menus.

Example with 3 SLOTS for 'Intellivision':

  a. `MENU` / `LAYOUTS`

Example: Viewing screen 'LAYOUTS - [VIEW] BUTTON MAP':

```text
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  SLOT  ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL       OTHERS      │
│  ----  --------------------------------------- ------------------│
│J   1)  ← ↓ ↑ → L U R  3 4 5  1  2        EN CL    A B C = Action │
│J   2)  ← ↓ ↑ → 7 8 9  1 2 3  4  6        5  CL  No Action Buttons│
│J   3)  ← ↓ ↑ → U 0 R  4 5 6  7  9        1   3      A C = Action │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

Note that the letter J indicates that the SLOT configuration refers to 'joystick button definitions' for each game.

  b. `MENU` / `GAMES`

Example: Viewing screen 'GAMES - [VIEW] GAME LIST':

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

This list is sorted alphabetically by game name.

Note that the 'button map' and 'game list' indicate the SLOT, making the next step easier.

Note: The example uses the Intellivision CORE, but the same procedure can be used for any other CORE.

Another example:

CORE Apple-II - Games Lode Runner and Karateka

  a. `MENU` / `LAYOUTS`

Example: Viewing screen 'LAYOUTS - [VIEW] BUTTON MAP':

```text
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  SLOT  ← ↓ ↑ → A B C  X Y Z  L1 R1  EXT  ST SL       OTHERS      │
│  ----  --------------------------------------- ------------------│
│R   1)  J K I L U O                       CT       CTL+k=keyboard │
│A   2)  ← ↓ ↑ → X S W  Z A S  B  SP       EN    DP=arrows SP=space│
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

Note: EN = ENTER on the keyboard CT = CONTROL on the keyboard SP = SPACE on the keyboard

DP = DPad on the gamepad / arrows = directions, arrow keys on the keyboard

Note that the letter R indicates that SLOT 1 contains a `button/key remap` configuration for game Lode Runner.

The second SLOT is identified by letter A, meaning it contains both 'joystick button definition' and `button/key remap` for game Karateka.

This classification J, R or A is used throughout SAVE operations.

You can remember them like this: J = Joystick/Gamepad (v3) R = Button/Key Remap (jk / advanced_input_*_v1) A = Both (J + R)

  b. `MENU` / `GAMES`

Example: Viewing screen 'GAMES - [VIEW] GAME LIST':

```text
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│ Karateka - 2                                                  │
│ Lode Runner - 1                                               │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

Note: In the LAYOUTS and GAMES selection and viewing menus, the ⇒ symbol indicates the last selected and currently active SLOT.

9. `MENU` / `LOAD`: Click 'LOAD - SLOT --> CORE' and select a

SLOT to load the saved configuration and overwrite the CORE configuration.

The only files modified in MiSTer are the `v3` and/or the `jk` and/or `advanced_input_*_v1` remapping files of the CORE, which will be replaced when LOAD is executed.

  - If the SLOT is identified as J:

files replaced: `CORE_input_ID_v3.map`

Example:

Intellivision_input_1234_abcd_v3.map

  - If R (Remap):

files replaced: `CORE_input_ID_jk.map` and/or `CORE_advanced_input_ID_v1.map`.

Example:

ZX81_input_1234_abcd_jk.map ZX81_advanced_input_1234_abcd_v1.map

  - If A (Both):

files replaced: `CORE_input_ID_v3.map` and the remapping files `CORE_input_ID_jk.map` and/or `CORE_advanced_input_ID_v1.map`.

Example:

MSX_input_1234_abcd_v3.map, MSX_input_1234_abcd_jk.map and/or MSX_advanced_input_1234_abcd_v1.map

---

## 4) Script Functions

---

The script GCM includes the following functions:

  - Manage CORES:

  - CORES - select one of the CORES previously added to GCM

  - ADD - Add a CORE:

    - EASY - select from a list a CORE already configured in MiSTer

    - EXPERT - type the real CORE name

    - FOLDERS - configure the folders to search for CORES in EXPERT menu

    - LIST - list the CORES installed in configured folders

  - VIEW - view names.txt - real CORE names and menu names

  - RENAME - rename a CORE already added to GCM:

    - RENAME - type the new name for the CORE

    - LIST - show a list of renamed CORES

  - DELETE - remove a CORE from GCM

  - Manage SLOTS in the selected CORE (CORE MENU):

  - LOAD - overwrite the current CORE configuration in MiSTer with one saved in the selected SLOT

  - LAYOUTS - view 'button map'

  - GAMES - view 'game list'

  - SAVE CONFIG - save the current CORE configuration in MiSTer to a new SLOT

  - EDIT LAYOUT - edit 'button map'

  - EDIT GAMES - edit 'game list'

  - MOVE - move a SLOT position

  - SWITCH - switch positions between two SLOTS

  - DELETE - delete SLOT

  - OVERWRITE - overwrite SLOT configuration with CORE configuration

  - COPY - copy SLOT to new SLOT

  - NOTES - write notes for a specific gamepad/CORE

  - Manage GAMEPADS:

  - SELECT - select one of the registered gamepads

  - LIST - show a list of all registered gamepads

  - RENAME - rename a registered gamepad in GCM

  - DELETE - remove a registered gamepad from GCM

  - EDIT TAG - edit label for `LAYOUTS` and `EDIT LAYOUT` menus

  - REGISTER - register a new gamepad in GCM

  - CLONE - clone configuration from one gamepad to another in GCM

  - Customization, Settings and Backup:

  - SETTINGS:

    - COLOR SCHEMES - choose a color scheme for menus

    - COLOR STYLE - choose a color style for selections and buttons

    - LANGUAGE - choose language: English or Portuguese

    - TEXT CASE - set uppercase/lowercase letters for menus

    - TEXT ACCENTS - enable/disable accents in text

    - FONT SIZE - set menu font size

    - TIPS - enable or disable visual hints in menus

  - ADVANCED - SETTINGS:

    - DELETE - joystick definitions & button/key remaps

      - JOYSTICK - delete joystick definitions (v3)

      - REMAP - delete button/key remaps (v1/jk)

    - RESET - reset settings, keeping gamepad folders

    - BACKUP:

      - SAVE - save GCM and/or MiSTer configurations to a file

      - RESTORE - restore configurations from a saved file

      - DELETE - delete a backup file from the `Scripts/gcm` folder

    - UNINSTALL - remove the script and program folder

The only functions that modify MiSTer files are:

1 - LOAD Rewrites the current gamepad/CORE configuration with a previously saved version.

2 - RESTORE Restores a backup and overwrites the configurations if it is a `full` backup. See topic 6, section III.

3 - DELETE (ADVANCED - SETTINGS) Deletes joystick definition and remapping files (v3/v1/jk) from the MiSTer `inputs` folder and from GCM SLOTS. SLOTS that are left without at least one configuration will be deleted and cannot be recovered.

All other functions create and manipulate files only within the `Scripts/gcm` folder. Backup files are stored in the root directory of the SD card.

---

## 5) Quick Guide

---

Here is a quick guide of the main functions.

First, configure the gamepad in MiSTer and in the desired CORE.

These are the main functions in the MENU, executed in order:

  1. `GAMEPADS / REGISTER`: Register a new gamepad.

  2. `ADD`: Add a CORE to a registered gamepad.

  3. `CORES`: Select the desired CORE.

  4. `SAVE CONFIG`: Save the gamepad/CORE configuration to a SLOT.

(example: SLOT 1)

You can create another configuration for the same gamepad in the CORE menu under 'Define CoreName buttons' and/or `Button/Key remap`, and repeat steps 1–4, saving the configuration to a different SLOT. (example: SLOT 2)

  5. `LOAD`: Load SLOT and overwrite CORE configuration.

Optional but useful functions:

  6. `EDIT LAYOUT` and `EDIT GAMES`: Edit visual SLOT representations (keyboard required).

  7. `LAYOUTS` and `GAMES`: View visual indicators.

With these six functions, you already have everything you need to use the script. The other functions are mainly used to organize SLOTS, CORES, GAMEPADS, and for customizations or backups.

TIP: Once everything is configured, the script can be used entirely with the gamepad, using the MiSTer's 'Select' and 'Return' buttons to access the LOAD, LAYOUTS, and GAMES menus — the main functions of the GCM menu. To finish, click EXIT to return to the MiSTer menu.

---

## 6) Important Information

---

### I. GCM Folder

- The script stores all configuration inside `Scripts/gcm`.

- Inside this folder, you will find:

  - 'configs' folder   - script configuration files

  - 'data' folder      - language files

  - 'fonts folder'     - font files `.psf.gz`

  - 'tmp' folder       - temporary script files

  - 'gamepads' folder  - contains the folders of registered gamepads:

```text
     example: '1234_abcd' - the name is the gamepad ID
```

  - Inside each registered gamepad folder, we have the folders for the `CORES`:

```text
     MSX, Intellivision, Apple-II, etc.

      Examples of full paths:

       Scripts/gcm/gamepads/1234_abcd/MSX Scripts/gcm/gamepads/1234_abcd/Intellivision Scripts/gcm/gamepads/1234_abcd/Apple-II
```

### II. ADD Menu - Add CORES

- The GCM script searches for previously configured CORES. Any CORE with a valid configuration can be added and will then appear in the ADD menu.

### III. Backup

### Backup File Types

- Backup .zip files have the following names:

```text
  Backup-GCM-MiSTer-26_09_15-12_30.zip Backup-GCM-MiSTer-full-26_09_15-12_35.zip
```
  
- The prefix `Backup-GCM-MiSTer` identifies the GCM backup file.

- Backups with `full` in the name also include the .map files from the MiSTer `inputs` folder.

- Backups are created in the root of the SD card (/media/fat). They can be moved to a computer or copied back to the same folder.

- All backup files in `/media/fat` can be restored.

- Restoring the `Scripts/gcm` folder is not incremental. It contains a complete copy of all script files.

- Restoring .map files from `inputs` (in a `full` backup) will overwrite only the files present in both the folder and the backup. Other files are not deleted or modified.

### Backup of GCM Script Files

Example: Backup-GCM-MiSTer-26_09_15-12_30.zip

- The 'SAVE' and `RESTORE` options in the `BACKUP` menu allow saving and restoring `Scripts/gcm`, which contains GAMEPAD, CORE, and SLOT configurations used by the script.

- Note: .map files from `inputs` are not included.

- After restoring a backup, make sure that the joystick (.v3) and/or remap (.jk / advanced_input_*_v1) files are properly configured in MiSTer if they do not already exist:

  1. Go to `Define joystick buttons` in MiSTer and configure the gamepad.

  2. In the CORE menu, configure the joystick buttons (Define CoreName buttons) and keyboard remapping (Button/Key remap) if necessary.

- To copy GCM backups, use FTP or Samba to access `/media/fat`. You can transfer them between the MiSTer and your PC.

### Backup with 'full' in the filename

Example: Backup-GCM-MiSTer-full-26_09_15-12_35.zip

- Includes script files + .map files with control configurations.

- Restoring a **`full` backup** will overwrite the current MiSTer configurations if they are present.

### Restore on fresh MiSTer install

- On first execution, if a backup is found in the root of the SD card (/media/fat), it can be automatically restored with confirmation.

- Attention! Place only one backup file in the root of the SD card (/media/fat) if you intend to restore the files on first execution.

- If the file is a `full` backup, MiSTer system files will also be restored.

### IV. Uninstallation

- To uninstall, use the UNINSTALL menu or delete `Scripts/gcm` and the 'gamepad_config_manager.sh' script from the `Scripts` folder.

### V. Font Size

- You can choose from 4 font sizes: small, medium, big, and huge, depending on the screen size and type of TV you use. The small size is suitable for CRT TVs, while the big and large sizes are better suited for modern TVs.

- If you select a font size that exceeds the screen size and a button becomes inaccessible, don't worry. Simply turn off the MiSTer while GCM is still open. The next time you run GCM, the font size will be reset to small. Whenever the script is not closed using the EXIT button in the menu, the font size will be reset to small.

---

## 7) Usage Flowchart - Super-Quick Guide

---

```text
         Do you already have a gamepad configured in MiSTer?
                           |
         No                |                    Yes
          _________________|______________________
          |                                       |
          |                          Do you already have a gamepad
 Close GCM and configure            configuration in the MiSTer CORE
 the gamepad in MiSTer before       you intend to use?
 opening GCM again.                               |
                           Yes                    |            No
                           _______________________|____________
                           |                                   |
                           |<--------------        Open the CORE in
                           |               |    MiSTer and configure
                   Do you already have a   |         the gamepad.
                   gamepad registered      |__________
                   in GCM?                            |
                           |  No                      |
                           |-----> Register a gamepad_|
                           |
                       Yes |
                           |
                           |
                     Select a Gamepad
                           |
                           |<-------------------------------
                           |                                |
                    Have you already added a CORE           |
                    to the selected gamepad?                |
                           |                                |
                           | No                             |
                           |-------------> Add a CORE       |
                           |               to the gamepad___|
                       Yes |
                           |
                    Select a CORE
                           |
                           |
                   What do you want to do?
          _________________|_______________________
          |                                       |
 1- Load a configuration               2- Save a configuration from
    saved in a GCM SLOT                   MiSTer to a GCM SLOT.
    for the MiSTer CORE.                          |
          |                                       |
          |<------------------------       Do you want to create a
          |                         |       new SLOT with the CORE
  Do you want to view the LAYOUT    |        configuration saved in
  and GAME LIST before              |____    MiSTer, or just update
  loading the SLOT?                      |    the configuration of
          |                              |    an existing SLOT?
          | Yes                          |        |
          |------- Select [VIEW]         |        |
          |        LAYOUT or GAMES_______|        |
      No  |                                       |
          |                                       |
    Select a SLOT                    _____________|_________
    using the LOAD menu.             |                     |
          |                    Create New SLOT         Update SLOT
          |                          |                     |
   Configuration loaded!             |                     |
  Exit GCM and enjoy!     Use the SAVE function   Use the OVERWRITE
                              to create a new        function to
                                   SLOT.            overwrite the
                                     |           configuration of an
                       Use the EDIT LAYOUT        existing SLOT. The
                       and EDIT GAMES functions     LAYOUT and GAMES
                      to create visual information   configurations
                       that makes it easier to        are preserved.
                       identify the created SLOT.
```

--- END ---
