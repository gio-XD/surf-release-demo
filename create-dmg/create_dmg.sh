#!/usr/bin/env bash

# 设置严格模式
set -e
set -o pipefail

# 配置变量
APP_NAME="cryptogpt"
DMG_FILE_NAME="${APP_NAME}-Installer.dmg"
VOLUME_NAME="${APP_NAME} Installer"
VOLUME_ICON="logo.icns"
SOURCE_FOLDER_PATH="source_folder"
TEMP_DMG="temp_${DMG_FILE_NAME}"
MOUNT_POINT="/Volumes/${VOLUME_NAME}"
BACKGROUND_FILE="bg.png"
TEMP_SIZE=50 # MB

# 窗口和图标设置
WINDOW_POS_X=200
WINDOW_POS_Y=120
WINDOW_WIDTH=600
WINDOW_HEIGHT=300
ICON_SIZE=100
TEXT_SIZE=14
APP_ICON_POS_X=150
APP_ICON_POS_Y=150
APP_LINK_POS_X=450
APP_LINK_POS_Y=150

# 清理先前的DMG
echo "清理先前的DMG文件..."
[[ -f "${DMG_FILE_NAME}" ]] && rm "${DMG_FILE_NAME}"
[[ -f "${TEMP_DMG}" ]] && rm "${TEMP_DMG}"

# 卸载已存在的DMG
if [ -d "${MOUNT_POINT}" ]; then
    echo "卸载已存在的挂载点..."
    hdiutil detach "${MOUNT_POINT}" -force || true
fi

# 创建临时DMG
echo "创建临时DMG..."
hdiutil create -size ${TEMP_SIZE}m -fs HFS+ -volname "${VOLUME_NAME}" "${TEMP_DMG}"

# 挂载DMG
echo "挂载DMG..."
hdiutil attach "${TEMP_DMG}" -mountpoint "${MOUNT_POINT}"

# 拷贝内容
echo "拷贝内容到DMG..."
cp -R "${SOURCE_FOLDER_PATH}/"* "${MOUNT_POINT}/"

# 创建应用程序链接
echo "创建应用程序链接..."
ln -s /Applications "${MOUNT_POINT}/Applications"

# 添加背景图片
echo "添加背景图片..."
if [ -f "${BACKGROUND_FILE}" ]; then
    mkdir -p "${MOUNT_POINT}/.background"
    cp "${BACKGROUND_FILE}" "${MOUNT_POINT}/.background/"
    echo "背景图片已复制到: ${MOUNT_POINT}/.background/${BACKGROUND_FILE}"
else
    echo "警告: 背景图片 ${BACKGROUND_FILE} 不存在!"
fi

# 设置Finder外观和图标位置
echo "配置DMG外观和图标位置..."
osascript <<EOF
tell application "Finder"
  tell disk "${VOLUME_NAME}"
    open
    
    -- 设置窗口基本属性
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {${WINDOW_POS_X}, ${WINDOW_POS_Y}, ${WINDOW_POS_X} + ${WINDOW_WIDTH}, ${WINDOW_POS_Y} + ${WINDOW_HEIGHT}}
    
    -- 设置视图选项
    set theViewOptions to the icon view options of container window
    set icon size of theViewOptions to ${ICON_SIZE}
    set text size of theViewOptions to ${TEXT_SIZE}
    set arrangement of theViewOptions to not arranged
    
    -- 尝试设置背景图片
    try
      set bgFile to (POSIX file "${MOUNT_POINT}/.background/${BACKGROUND_FILE}") as alias
      set background picture of theViewOptions to bgFile
    end try
    
    -- 尝试设置字体颜色为白色
    try
      set text color of theViewOptions to {65535, 65535, 65535}
    end try
    
    -- 设置图标位置
    set position of item "${APP_NAME}.app" to {${APP_ICON_POS_X}, ${APP_ICON_POS_Y}}
    set position of item "Applications" to {${APP_LINK_POS_X}, ${APP_LINK_POS_Y}}
    
    -- 隐藏文件扩展名
    set extension hidden of item "${APP_NAME}.app" to true
    
    -- 保存设置并确保应用
    delay 1
    update without registering applications
    delay 2
    close
    
    -- 确保设置真的应用了
    open
    delay 1
    close
  end tell
end tell
EOF

echo "等待Finder完成操作..."
sleep 2

# 添加卷图标
if [ -f "${VOLUME_ICON}" ]; then
    echo "添加卷图标..."
    cp "${VOLUME_ICON}" "${MOUNT_POINT}/.VolumeIcon.icns"
    # 设置卷图标文件属性
    SetFile -c icnC "${MOUNT_POINT}/.VolumeIcon.icns"
    # 设置卷自身的图标属性
    SetFile -a C "${MOUNT_POINT}"
    echo "卷图标已设置: ${VOLUME_ICON}"
else
    echo "警告: 卷图标文件 ${VOLUME_ICON} 不存在!"
fi

# 清理不必要的文件（保留.DS_Store）
echo "清理临时文件..."
rm -rf "${MOUNT_POINT}/.fseventsd"
rm -rf "${MOUNT_POINT}/.Trashes"

# 卸载DMG
echo "卸载DMG..."
hdiutil detach "${MOUNT_POINT}" -force || true

# 转换为最终格式
echo "创建最终DMG..."
hdiutil convert "${TEMP_DMG}" -format UDZO -o "${DMG_FILE_NAME}"

# 清理临时文件
rm -f "${TEMP_DMG}"

echo "DMG创建完成: ${DMG_FILE_NAME}"