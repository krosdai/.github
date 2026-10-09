import anthropic
from anthropic import WorkloadIdentityCredentials
import os


def fetch_github_oidc_token() -> str:
    # Set by the "Fetch GitHub OIDC token" step in the workflow tab.
    return os.environ["JWT"]

client = anthropic.Anthropic(
    credentials=WorkloadIdentityCredentials(
        identity_token_provider=fetch_github_oidc_token,
        federation_rule_id="fdrl_01BBPmSXaBsAQnwaAZ1Cs4Eg",
        organization_id="129ad6b6-9e42-4f3b-ace4-491b511b4e16",
        service_account_id="svac_01EZxVahQ3AYDooGEXAsdMTd",
        workspace_id="wrkspc_01Mv6JrzFA2DeSDZviJGbtCh",
    ),
)

message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello, Claude"}],
)
print(message.content[0].text)
