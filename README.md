# perfconv
Простой скрипт Python / PowerShell для исправления заголовков csv-файла с метриками perfmon

При выгрузке метрик perfmon в csv-файл с помощью relog заголовки csv-файла часто бывают повреждены (непарная скобка, проблемы с кодировкой), и с ними не могут работать различные GUI-утилиты для анализа метрик (например, [NMONVisualizer](https://nmonvisualizer.github.io/nmonvisualizer/)). 

Этот небольшой скрипт заменяет русские названия perfmon-счётчиков на английские (банальным поиском по идентификатору perfmon-счётчика).

Возможно, необходимость в исправлении csv-файла возникает не только при использовании русской локализации Windows. 

Используемые словарные файлы eng_counters.txt и rus_counters.txt взяты из реестра - значения ключей `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009\Counter` (eng) и `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\019\Counter` (rus)

## Пример запуска
```python perfconv.py app.csv```

```./perfconv.ps1 -Path app.csv```
