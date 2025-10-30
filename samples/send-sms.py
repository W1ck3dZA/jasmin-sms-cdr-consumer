#!/usr/bin/python3
# Author Quinten Rowland <quinten@imgroup.co.za>
# Usage: python3 send_sms.py

import requests

# Jasmin HTTP API endpoint
JASMIN_URL = "http://<server>:1401/send"

# Jasmin user credentials
USERNAME = ""
PASSWORD = ""

# Message parameters
sms_data = {
    "to": "",                      # Destination number
    "from": "",                    # Optional: sender
    "content": "Hello world!",     # Message content
    "coding": 1,                   # Optional: default is 0
    "priority": 2,                 # Optional
    "username": USERNAME,          # Mandatory
    "password": PASSWORD,          # Mandatory
    "dlr": "yes",                  # Optional
    "dlr-url": "",                 # Mandatory if dlr=yes
    "dlr-level": 2,                # Mandatory if dlr=yes
    "dlr-method": "POST",          # Mandatory if dlr=yes
}

try:
    response = requests.get(JASMIN_URL, params=sms_data, timeout=10)
    response.raise_for_status()
    print(f"Message sent successfully! Response: {response.text}")
except requests.exceptions.RequestException as e:
    print(f"Failed to send message: {e}")
