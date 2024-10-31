compress_files.ps1 

Aby uruchomić ręcnzie skrypt należy najpierw go zaimportować do sesji powershella następującym poleceniem 

`` . .\compress_files.ps1 ``
Od tego momentu będizemy mieli dostęp do funkcji "Compress-Files"

Compress-Files musi mieć zdefiniowane 3 parametry 
SourcePath - Definiuje katalog z którego chcemy czerpać pliki do kompresji 
DestinationPath* - Definiuje ścieżkę do której przeniesie pliki po kompresji - ta funkcja zostanie zastąpiona usuwaniem plików
OutputPath - Definiuje gdzie mają trafiać archiwa.

Compress-Files zadziałało w katalogu źródłowym musi znajdować sięconajmniej 10 plików. Funkcja pobieraz zawsze 10 plików i kompresuje je. Skompresowane archiwum przenosi do OutputPath a pliki do DestinationPath.

*DestinationPath - ten parametr jest tymczasowy wkrótce zostanie usunięty i zamiast przenoszenia pliki zostaną usunięte.

==========================================================
==========================================================

hashes_counter.ps1
skrypt można uruchomić za pomocą .\hashes_counter.ps1

Skrypt tworzy plik JSON z polami
Name - Nazwa pliku
Create - Data utworzenia pliku
LastWrite - Data ostatniej edycji
Hash - Hash MD5