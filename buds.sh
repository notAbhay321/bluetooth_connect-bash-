#!/bin/bash

# Bluetooth MAC address of the earbuds
buds_mac="48:D8:45:D2:55:4B"

# Function to connect to Bluetooth earbuds
connect_buds() {
    # Check if the earbuds are already connected
    if bluetoothctl info $buds_mac | grep -q "Connected: yes"; then
        echo "Earbuds ($buds_mac) are already connected."
    else
        # Connect to the specified Bluetooth earbuds
        echo "Connecting to Bluetooth earbuds ($buds_mac)..."
        bluetoothctl connect $buds_mac
    fi
}

# Function to disconnect Bluetooth earbuds
disconnect_buds() {
    # Check if the earbuds are connected
    if bluetoothctl info $buds_mac | grep -q "Connected: yes"; then
        # Disconnect the specified Bluetooth earbuds
        echo "Disconnecting Bluetooth earbuds ($buds_mac)..."
        bluetoothctl disconnect $buds_mac
    else
        echo "Earbuds ($buds_mac) are not currently connected."
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
                get_battery_level
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
        "h"|"help")
            echo "Usage: $0 <command>"
            echo "Commands:"
            echo "  c, connect       - Connect to Bluetooth earbuds"
            echo "  d, disconnect    - Disconnect Bluetooth earbuds"
            echo "  bt, toggle-bluetooth - Toggle Bluetooth on/off and connect to earbuds"
            echo "  mac              - Print Bluetooth MAC address"
            echo "  h, help          - Show this help message"
            ;;
        *)
            echo "Invalid command. Use '$0 help' for usage instructions."
            exit 1
            ;;
    esac
}

# Run the main function with command-line arguments
main "$@"

