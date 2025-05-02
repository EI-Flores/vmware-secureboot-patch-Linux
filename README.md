
# VMware Secure Boot Module Signer for Linux

This script helps sign the required VMware kernel modules (`vmmon` and `vmnet`) to work under Secure Boot on Fedora and other Linux distributions.

## 📁 Environment Preparation

1. Install required tools:

    ```bash
    sudo dnf install mokutil openssl
    ```

2. Create the working folder and generate signing keys:

    ```bash
    mkdir -p ~/vmware-signing
    cd ~/vmware-signing

    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VMware Kernel Module Signing/"
    ```

3. Register the certificate so Secure Boot allows signed modules:

    ```bash
    sudo mokutil --import MOK.der
    ```

Reboot your system, select `Enroll MOK`, and confirm using the password you just created.

## 🛠️ Using the script

1. Download or clone this repository:

    ```bash
    git clone https://github.com/EI-Flores/vmware-secureboot-helper.git
    cd vmware-secureboot-helper
    ```

2. Make the script executable:

    ```bash
    chmod +x firmar_vmware_modulos.sh
    ```

3. Run it after installing VMware or upgrading your kernel:

    ```bash
    ./firmar_vmware_modulos.sh
    ```

4. Load the modules if not automatically loaded:

    ```bash
    sudo modprobe vmmon
    sudo modprobe vmnet
    ```

## 👨‍💻 Author

John Flower – [GitHub](https://github.com/EI-Flores)

## 📄 License

This project is licensed under the MIT License.


---


# Asistente para firmar módulos de VMware en Linux con Secure Boot

Este script ayuda a firmar los módulos `vmmon` y `vmnet` requeridos por VMware para que funcionen con Secure Boot activado en Fedora u otras distribuciones Linux.

## 📁 Preparación del entorno

1. Instala las herramientas necesarias:

    ```bash
    sudo dnf install mokutil openssl
    ```

2. Crea la carpeta de trabajo y genera las claves:

    ```bash
    mkdir -p ~/vmware-signing
    cd ~/vmware-signing

    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VMware Kernel Module Signing/"
    ```

3. Registra el certificado para que el sistema lo acepte con Secure Boot:

    ```bash
    sudo mokutil --import MOK.der
    ```

Reinicia el equipo, elige `Enroll MOK`, acepta con la contraseña que configuraste.

## 🛠️ Uso del script

1. Descarga o clona este repositorio:

    ```bash
    git clone https://github.com/youruser/vmware-secureboot-helper.git
    cd vmware-secureboot-helper
    ```

2. Dale permisos de ejecución:

    ```bash
    chmod +x firmar_vmware_modulos.sh
    ```

3. Ejecuta el script después de instalar VMware o actualizar el kernel:

    ```bash
    ./firmar_vmware_modulos.sh
    ```

4. Carga los módulos si no están cargados:

    ```bash
    sudo modprobe vmmon
    sudo modprobe vmnet
    ```

## 👨‍💻 Autor

John Flower – [GitHub](https://github.com/EI-Flores)

## 📄 Licencia

Este proyecto está bajo licencia MIT.


---


# VMware Secure Boot Modulsignierer für Linux

Dieses Skript hilft dabei, die benötigten VMware-Kernelmodule (`vmmon` und `vmnet`) zu signieren, damit sie unter Secure Boot auf Fedora und anderen Linux-Distributionen funktionieren.

## 📁 Vorbereitung der Umgebung

1. Installiere die benötigten Pakete:

    ```bash
    sudo dnf install mokutil openssl
    ```

2. Erstelle den Arbeitsordner und generiere die Signaturschlüssel:

    ```bash
    mkdir -p ~/vmware-signing
    cd ~/vmware-signing

    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VMware Kernel Module Signing/"
    ```

3. Registriere das Zertifikat, damit Secure Boot signierte Module akzeptiert:

    ```bash
    sudo mokutil --import MOK.der
    ```

Starte dein System neu, wähle `Enroll MOK` und bestätige mit dem erstellten Passwort.

## 🛠️ Verwendung des Skripts

1. Lade das Repository herunter oder klone es:

    ```bash
    git clone https://github.com/youruser/vmware-secureboot-helper.git
    cd vmware-secureboot-helper
    ```

2. Mache das Skript ausführbar:

    ```bash
    chmod +x firmar_vmware_modulos.sh
    ```

3. Führe das Skript nach der Installation von VMware oder nach einem Kernel-Update aus:

    ```bash
    ./firmar_vmware_modulos.sh
    ```

4. Lade die Module, falls sie nicht automatisch geladen wurden:

    ```bash
    sudo modprobe vmmon
    sudo modprobe vmnet
    ```

## 👨‍💻 Autor

John Flower – [GitHub](https://github.com/EI-Flores)

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
