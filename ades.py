import code
import json
import os

import click
import pyeodh
from dotenv import load_dotenv
from requests import HTTPError
import yaml

load_dotenv()
pyeodh.set_log_level(10)

username = os.getenv("ADES_USER")
token = os.getenv("ADES_TOKEN")

client = pyeodh.Client(username=username, token=token, s3_token=token)
ades = client.get_ades()

CWL_FILE = "resize-collection.cwl"
WF_ID = CWL_FILE.removesuffix(".cwl")


@click.group()
def cli():
    pass


@cli.command()
@click.argument("file", default=CWL_FILE, type=click.Path(exists=True))
@click.option("-i", "interact", help="End in interactive shell", is_flag=True)
def deploy(file, interact):
    wf_id = file.removesuffix(".cwl")
    print("Workflow ID:", wf_id)

    with open(CWL_FILE, "r") as f:
        cwl_yaml = f.read()

    try:
        ades.get_process(wf_id).delete()
    except HTTPError:
        print("Process not found, no need to undeploy.")

    proc = ades.deploy_process(cwl_yaml=cwl_yaml)

    print(proc.id, proc.description)

    if interact:
        code.interact(local={**globals(), **locals()})


@cli.command()
@click.argument("wf", default=WF_ID)
@click.option("--inputs", "inputs_file", type=click.Path(exists=True))
@click.option("-i", "interact", help="End in interactive shell", is_flag=True)
def exec(wf: str, inputs_file: str, interact):
    print("ID", wf)

    inputs = {}
    if inputs_file:
        print(f"Loading inputs from {inputs_file}")

        with open(inputs_file, "r") as f:
            if inputs_file.endswith((".yml", ".yaml")):
                inputs = yaml.safe_load(f)
            else:
                inputs = json.load(f)

    print("Inputs:")
    print(json.dumps(inputs, indent=2))

    job = ades.get_process(wf).execute(inputs)

    if interact:
        code.interact(local={**globals(), **locals()})


if __name__ == "__main__":
    cli()
