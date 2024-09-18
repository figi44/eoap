# eoap

EO Application package example

## Usage

Create virtual environment

```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Create `.env` file containing ADES secrets containing `ADES_USER` and `ADES_TOKEN` variables.

Deploy the workflow to your workspace

```
python ades.py deploy
```
