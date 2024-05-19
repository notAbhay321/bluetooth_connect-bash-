#!/bin/bash

# Bluetooth MAC address of the earbuds
buds_mac="48:D8:45:D2:55:4B"

# Function to get the earbuds name from the MAC address
get_buds_name() {
    local buds_name=$(bluetoothctl info "$buds_mac" | awk -F ': ' '/Name/ {print $2}')
    if [ -z "$buds_name" ]; then
        buds_name="Unknown"
    fi
    echo "$buds_name"
}

# Function to list paired Bluetooth devices with their MAC addresses
list_paired_devices() {
    echo "Paired Bluetooth devices:"
    local device_number=1
    bluetoothctl paired-devices | awk '/Device/{print device_number++ ". " $3 " (" $2 ")"}'
}

# Function to prompt the user to choose a paired device and update the MAC address
choose_device() {
    list_paired_devices
    read -p "Enter the number of the device you want to connect to: " device_number
    local selected_mac=$(bluetoothctl paired-devices | awk 'NR=='$device_number' {print $2}')
    if [[ -n "$selected_mac" ]]; then
        buds_mac="$selected_mac"
        echo "Bluetooth MAC address updated: $buds_mac"
    else
        echo "Invalid device number. Please enter a valid number."
    fi
}

# Function to connect to Bluetooth earbuds
connect_buds() {
    local buds_name=$(get_buds_name)
    
    if [[ -z "$buds_mac" ]]; then
        echo "Bluetooth device not selected. Please pair a device using 'pair' command."
        return
    fi

    # Check if the earbuds are already connected
    if bluetoothctl info "$buds_mac" | grep -q "Connected: yes"; then
        echo "Earbuds ($buds_name) are already connected."
    else
        # Connect to the specified Bluetooth earbuds
        echo "Connecting to Bluetooth earbuds..."
        echo "Attempting to connect to $buds_name..."
        bluetoothctl connect "$buds_mac" &> /dev/null
        if bluetoothctl info "$buds_mac" | grep -q "Connected: yes"; then
            echo "Connection successful."
            adjust_volume 50
            switch_audio_output
        else
            echo "Failed to connect to $buds_name."
        fi
    fi
}

# Function to disconnect Bluetooth earbuds
disconnect_buds() {
    local buds_name=$(get_buds_name)

    if [[ -z "$buds_mac" ]]; then
        echo "Bluetooth device not selected. Please pair a device using 'pair' command."
        return
    fi

    # Check if the earbuds are connected
    if bluetoothctl info "$buds_mac" | grep -q "Connected: yes"; then
        # Disconnect the specified Bluetooth earbuds
        bluetoothctl disconnect "$buds_mac" &> /dev/null
        if ! bluetoothctl info "$buds_mac" | grep -q "Connected: yes"; then
            echo "Disconnected from $buds_name."
        else
            echo "Failed to disconnect from $buds_name."
        fi
    else
        echo "Earbuds ($buds_name) are not currently connected."
    fi
}

# Function to adjust volume
adjust_volume() {
    local volume="$1"
    
    if [[ -n "$buds_mac" ]]; then
        if bluetoothctl info "$buds_mac" | grep -q "Connected: yes"; then
            pactl set-sink-volume @DEFAULT_SINK@ "$volume"%
            echo "Earbuds volume adjusted to $volume%."
        else
            echo "Buds are not connected. Use 'buds vs' to adjust system volume."
        fi
    else
        pactl set-sink-volume @DEFAULT_SINK@ "$volume"%
        echo "System volume adjusted to $volume%."
    fi
}

# Function to adjust system volume for earbuds not connected
adjust_system_volume() {
    local volume="$1"
    
    pactl set-sink-volume @DEFAULT_SINK@ "$volume"%
    echo "System volume adjusted to $volume%."
}

# Function to switch audio output to Bluetooth device
switch_audio_output() {
    local sink_name="bluez_sink.$(echo "$buds_mac" | tr ':' '_')"
    pacmd set-default-sink "$sink_name" &> /dev/null
    echo "Audio output switched to Bluetooth device."
}

check_battery() {
  local battery_info=$(bluetoothctl info "$buds_mac" | awk '/Battery/ {print $2}')
  if [[ -n "$battery_info" ]]; then
    echo "Earbuds battery level: $battery_info%"
  else
    echo "Failed to retrieve battery level. Ensure the earbuds are connected."
  fi
}


# Main function
main() {
    case "$1" in
        "c"|"connect")
            connect_buds
            ;;
        "d"|"disconnect")
            disconnect_buds
            ;;
        "s"|"status")
            bluetooth_status=$(bluetoothctl show | grep "Powered: yes")
            if [[ -n "$bluetooth_status" ]]; then
                echo "Bluetooth is on."
                check_battery
            else
                echo "Bluetooth is off."
            fi
            ;;
        "bt"|"toggle-bluetooth")
            if bluetoothctl show | grep -q "Powered: yes"; then
                echo "Turning off Bluetooth..."
                bluetoothctl power off
            else
                echo "Turning on Bluetooth..."
                bluetoothctl power on
                sleep 2
                connect_buds
            fi
            ;;
        "mac")
            echo "Bluetooth MAC address: $buds_mac"
            ;;
        "pair")
            choose_device
            ;;
        "h"|"help")
            echo "Usage: $0 <command>"
            echo "Commands:"
            echo "  c, connect       - Connect to Bluetooth earbuds"
            echo "  d, disconnect    - Disconnect Bluetooth earbuds"
            echo "  bt, toggle-bluetooth - Toggle Bluetooth on/off and connect to earbuds"
            echo "  mac              - Print Bluetooth MAC address"
            echo "  pair             - Manually select a paired Bluetooth device to connect"
            echo "  h, help          - Show this help message"
            echo "  v, volume <level> - Adjust the volume to the specified level (0-100)"
            echo "  batt             - Check battery level of the earbuds"
            ;;
        "v"|"volume")
            # Handle volume adjustment command
            shift
            adjust_volume "$@"
            ;;
        "batt"|"b")
            check_battery
            ;;
        *)
            echo "Invalid command. Use '$0 help' for usage instructions."
            exit 1
            ;;
    esac
}

# Run the main function with command-line arguments
main "$@"

