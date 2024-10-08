# Praca domowa 9 – Azure Kubernetes Service (AKS)

źródło: https://github.com/serwus79/labahomeworks/tree/main/09

## Opis

Termin: 08.10 23:59

- Utwórz klaster AKS z kontenerami Linux i Windows Server.
- Wdróż aplikację do klastra AKS.
- Skonfiguruj skalowanie aplikacji w AKS.

## Zawartość

- folder `app_linux` - prosta aplikacja node:20
- folder `HelloWorld` - prosta aplikacja dotnet:9
- folder `deployment` - szablony plików konfiguracyjnych kubernetes
- `cleanup.sh` - przykładowy plik do czyszczenia zasobów
- `setup_linux.sh` - skrypt tworzący odpowiednie zasoby w Azure dla aplikacji w node
- `setup_windows.sh` - skrypt tworzący odpowiednie zasoby w Azure dla aplikacji dotnet

## setup_*.sh

1. Utworzenie Resource Group
2. Utworzenie Container Registry
3. Zbudowanie obrazu node/dotnet
4. Utworzenie Kubernetes Service
5. Konfiguracja według pliku oraz autoskaling

## Materiały

- https://github.com/MicrosoftLearning/deploy-and-manage-containers-with-azure-kubernetes-service