# Bluetooth Connect (buds) - Bash Script

A Bash script to connect/disconnect and perform various operations with your Bluetooth devices on your Linux machine.

## Features

- Connect/disconnect Bluetooth earbuds
- Toggle Bluetooth on/off
- Check Bluetooth status and battery level
- Display Bluetooth device information

## Usage

### Prerequisites

- Linux machine with Bluetooth support
- Bash shell
- `bluetoothctl` utility

### Installation

1. Clone the repository: ctrl +alt + T 
   ```bash
   git clone https://github.com/notAbhay321/bluetooth_connect-bash-
2.a. execute these comands
   ```bash
   nano ~/.bashrc
```
2.b. GNU nano opens up, scroll down at the buttom and paste(ctrl+shift+v) the next comand
    Note-if u are crently running the terminal in home$ then dont need to worry, just copy and paste in the GNU nano at the end
    
    alias buds='$HOME/buds.sh'

  after pasting it sucesfully 
  enter these shortcuts to save the file sucessfully 
  ``` 
  ctrl + x
 Save modified buffer? click 'y' for yes
and then press Enter.
```
3. <details><summary>Making the script executable </summary> its because</details>
    Now, either close and reopen your terminal or run the following command to apply the changes to your current session:
    
    ```
    source ./buds.sh
    ```
    ./ will run the script
   if it doesnt run, Give the file a executable permission by using chmod +x buds.sh or chmods 777 buds.sh
    ```
    chmod +x buds.sh
    ```
   <details>  <summary>chmod does this</summary>This command grants execute permissions to the owner, group, and others.

After that, you can simply type buds in your terminal to execute the buds.sh script from anywhere in your system.

If you wnat to change the mac address of your bt device then follow these steps 
```
nano buds.sh
```
in the code, replace the dummy mac addres {buds_mac=""}
and you are good to go!!!
