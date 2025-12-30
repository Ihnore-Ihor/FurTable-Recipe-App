#!/bin/bash

# Назва вихідного файлу
OUTPUT_FILE="project_code_combined.txt"

# Очистити файл виводу перед початком
> "$OUTPUT_FILE"

echo "Розпочато вилучення коду з каталогу 'lib'..."

# Знайти всі файли .dart, починаючи з каталогу lib.
# -type f: тільки файли
# -name "*.dart": тільки файли, що закінчуються на .dart
find lib -type f -name "*.dart" | while read -r FILE_PATH; do
    
    echo "Опрацювання: $FILE_PATH"
    
    # Записати заголовок файлу до кінцевого текстового файлу
    echo "--- FILE: $FILE_PATH ---" >> "$OUTPUT_FILE"
    
    # Додати вміст файлу
    cat "$FILE_PATH" >> "$OUTPUT_FILE"
    
    # Додати два нові рядки для кращого розділення
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
done

echo "Завершено. Зведений код збережено у '$OUTPUT_FILE'."
