import code
import json
import os

import click
import pyeodh
from dotenv import load_dotenv
from requests import HTTPError

load_dotenv()


username = os.getenv("ADES_USER")
token = os.getenv("ADES_TOKEN")
s3_token = os.getenv("ADES_S3_TOKEN")

client = pyeodh.Client(username=username, token=token, s3_token=s3_token)
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

    # ades.deploy_process(cwl_yaml=cwl_yaml)

    if interact:
        code.interact(local={**globals(), **locals()})


@cli.command()
@click.argument("wf", default=WF_ID)
@click.option("--inputs", "inputs_file", type=click.Path(exists=True))
@click.option("-i", "interact", help="End in interactive shell", is_flag=True)
def exec(wf: str, inputs_file, interact):
    print("ID", wf)

    inputs = {}
    if inputs_file:
        print(f"Loading inputs from {inputs_file}")

        with open(inputs_file, "r") as f:
            inputs = json.load(f)

    print("Inputs:")
    print(json.dumps(inputs, indent=2))

    job = ades.get_process(wf).execute(inputs)

    if interact:
        code.interact(local={**globals(), **locals()})


if __name__ == "__main__":
    cli()
