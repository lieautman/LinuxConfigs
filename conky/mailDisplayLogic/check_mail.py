#!/usr/bin/env python3

import imaplib
import os
import socket

CONKY_YHAOO1_EMAIL = os.getenv("CONKY_YHAOO1_EMAIL")
CONKY_YHAOO1_PASSWORD = os.getenv("CONKY_YHAOO1_PASSWORD")
IMAP_SERVER = os.getenv("CONKY_IMAP_SERVER", "imap.mail.yahoo.com")
IMAP_PORT = 993

#print(f"Connecting to: {IMAP_SERVER}")
print(f"Email: {CONKY_YHAOO1_EMAIL}")

try:
    with imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT) as mail:
        mail.login(CONKY_YHAOO1_EMAIL, CONKY_YHAOO1_PASSWORD)
        mail.select("inbox")
        result, data = mail.search(None, 'UNSEEN')
        unread_count = len(data[0].split())
        result, data = mail.search(None, 'ALL')
        total_count = len(data[0].split())
        print(f"Yahoo: {unread_count} unread / {total_count} total")
except Exception as e:
    print(f"{e}")

