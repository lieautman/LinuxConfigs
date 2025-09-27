#!/bin/bash

# Wait for X session to start (adjust delay if needed)
sleep 10

# Set DISPLAY to the correct X session
export DISPLAY=:0

# Start conky in quiet mode
conky -c ~/.config/conky/conkyHeader.conf -q
conky -c ~/.config/conky/conkyCPU.conf -q
conky -c ~/.config/conky/conkyDetails.conf -q
