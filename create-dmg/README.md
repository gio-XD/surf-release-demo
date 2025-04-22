# Creating Surf Application Installer

This directory contains scripts and resources for creating a beautiful DMG installer for the Surf application.

## Introduction

The `create_dmg.sh` script creates a custom, branded DMG installer for the Surf application, designed to be visually appealing and allow users to easily drag and drop the application to the Applications folder for installation.

## Prerequisites

- macOS operating system
- The Surf application to be packaged (placed in the `source_folder` directory)

## File Structure

- `create_dmg.sh`: Main script file
- `bg.png`: DMG background image
- `logo.icns`: Volume icon file
- `source_folder/`: Contains the application to be packaged
  - `Surf.app/`: Surf application

## Usage

1. Ensure the latest version of Surf.app is placed in the `source_folder` directory
2. Run the script in terminal:

```bash
cd /path/to/create
./create_dmg.sh
```

3. The script will create an installer named `Surf-Installer.dmg`

## Customization Options

To customize the DMG, you can modify the following variables in the `create_dmg.sh` script:

- `APP_NAME`: Application name
- `DMG_FILE_NAME`: Output DMG filename
- `VOLUME_NAME`: Volume label
- `BACKGROUND_FILE`: Background image file
- `WINDOW_WIDTH` / `WINDOW_HEIGHT`: Window dimensions
- `ICON_SIZE`: Icon size
- `APP_ICON_POS_X` / `APP_ICON_POS_Y`: Application icon position
- `APP_LINK_POS_X` / `APP_LINK_POS_Y`: Applications link position

## How It Works

The script performs the following steps:

1. Creates a temporary DMG
2. Copies the contents from `source_folder` to the DMG
3. Adds a symbolic link to Applications
4. Sets up the background image
5. Configures window appearance and icon positions
6. Adds the volume icon
7. Converts the DMG to a compressed read-only format

## Notes

- Ensure you have sufficient disk space
- The script needs execution permission, run `chmod +x create_dmg.sh` if needed
- If you encounter issues, make sure the `SetFile` command is available (part of macOS developer tools)
