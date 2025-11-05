#!/usr/bin/env python3
"""
GitHub Secrets API - Secret erstellen/aktualisieren
Verwendet die GitHub API für verschlüsselte Secret-Verwaltung
"""

import base64
import json
import sys
import requests
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
from nacl import encoding, public

def get_public_key(token, owner, repo):
    """Hole den Public Key des Repositories"""
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/public-key"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "Authorization": f"token {token}"
    }
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def encrypt_secret(public_key_dict, secret_value):
    """Verschlüssle das Secret mit dem Public Key"""
    # GitHub verwendet LibSodium (NaCl) für Verschlüsselung
    public_key = public_key_dict["key"]
    key_id = public_key_dict["key_id"]
    
    # Public Key dekodieren
    public_key_bytes = base64.b64decode(public_key)
    public_key_obj = public.PublicKey(public_key_bytes)
    
    # Secret mit Public Key verschlüsseln
    box = public.SealedBox(public_key_obj)
    encrypted = box.encrypt(secret_value.encode())
    
    return base64.b64encode(encrypted).decode(), key_id

def create_or_update_secret(token, owner, repo, secret_name, encrypted_value, key_id):
    """Erstelle oder aktualisiere ein Secret"""
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/secrets/{secret_name}"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "Authorization": f"token {token}"
    }
    data = {
        "encrypted_value": encrypted_value,
        "key_id": key_id
    }
    
    response = requests.put(url, headers=headers, json=data)
    response.raise_for_status()
    return response.status_code == 201 or response.status_code == 204

def main():
    if len(sys.argv) < 6:
        print("Usage: create-github-secret.py <token> <owner> <repo> <secret_name> <secret_value>")
        sys.exit(1)
    
    token = sys.argv[1]
    owner = sys.argv[2]
    repo = sys.argv[3]
    secret_name = sys.argv[4]
    secret_value = sys.argv[5]
    
    try:
        # Public Key abrufen
        print(f"Fetching public key for {owner}/{repo}...")
        public_key = get_public_key(token, owner, repo)
        
        # Secret verschlüsseln
        print(f"Encrypting secret '{secret_name}'...")
        encrypted_value, key_id = encrypt_secret(public_key, secret_value)
        
        # Secret erstellen/aktualisieren
        print(f"Creating/updating secret '{secret_name}'...")
        success = create_or_update_secret(token, owner, repo, secret_name, encrypted_value, key_id)
        
        if success:
            print(f"✅ Secret '{secret_name}' successfully created/updated!")
        else:
            print(f"❌ Failed to create/update secret '{secret_name}'")
            sys.exit(1)
            
    except requests.exceptions.HTTPError as e:
        print(f"❌ HTTP Error: {e}")
        print(f"Response: {e.response.text}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

