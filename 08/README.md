# Praca domowa 8 – Wprowadzenie do obrazów i kontenerów Docker

źródło: https://github.com/serwus79/labahomeworks/tree/main/08

## Opis

Termin: 3 paź, 23:59

- Utwórz obraz Docker dla prostego serwera HTTP.
- Uruchom kontener z utworzonym obrazem w Azure Container Instances.
- Zarządzaj siecią i danymi w kontenerze.

## Zawartość

- folder `nginx` - pliki potrzebne do zbudowania obrazu `labahomeworknginx` wykorzystanego w kontenerze
- folder `www` - przykładowe pliki do Azure Storage, można wykorzystać `Storage browser` do wgrania zawartości w `File shares\imageshare`
- `build.sh` - skrypt do zbudowania obrazu `labahomeworknginx` lokalnie do testów
- `cleanup.sh` - skrypt do usunięcia grupy zaosbów po zakończonej pracy
- `setup.sh` - skrypt tworzący odpowiednie zasoby w Azure

## Setup.sh

Główne kroki:

1. Utworzenie Resource Group
2. Utworzenie Container Registry
3. Utworzenie Storage Account
   - odczytanie kluczy używanych później do zapewnienia dostępu
   - utworzenie File share o nazwie `imageshare`
4. Rejestracja `Microsoft.ContainerInstance`
5. Zalogowanie i zbudownaie obrazu w Container Registry
6. Utworzenie Container Instance
