import boto3
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
l = logging.getLogger()

CODE_INTERPRETER_ID = Path("./../tmp/code_interpreter_id.txt").read_text().strip()
COMMAND_TO_EXECUTE = "pwd && ls -la && uname -a"

l.info("CODE_INTERPRETER_ID=%s", CODE_INTERPRETER_ID)
l.info("COMMAND_TO_EXECUTE=%s", COMMAND_TO_EXECUTE)

agentcore_client = boto3.client("bedrock-agentcore")

def main():
    l.info("Starting the demo....")

    input("\nPress ENTER to create a new Code Interpreter Session\n")

    l.info("> Starting a new Code Interpreter Session...")
    start_session_response = agentcore_client.start_code_interpreter_session(
        codeInterpreterIdentifier=CODE_INTERPRETER_ID,
        name="my_session",
        sessionTimeoutSeconds=30
    )
    session_id = start_session_response["sessionId"]
    l.info("> Started a new Code Interpreter Session, session_id=%s", session_id)

    input("\nPress ENTER to send COMMAND_TO_EXECUTE to the Code Interpreter Session\n")

    execute_response = agentcore_client.invoke_code_interpreter(
        codeInterpreterIdentifier=CODE_INTERPRETER_ID,
        sessionId=session_id,
        name="executeCommand",
        arguments={
            "command": COMMAND_TO_EXECUTE
        }
    )

    for event in execute_response['stream']:
        if 'result' in event:
            result = event['result']
            l.info("> Invocation result:")
            if 'content' in result:
                for content_item in result['content']:
                    if content_item['type'] == 'text':
                        l.info(content_item['text'])

    input("\nPress ENTER to close the Code Interpreter Session\n")

    agentcore_client.stop_code_interpreter_session(
        codeInterpreterIdentifier=CODE_INTERPRETER_ID,
        sessionId=session_id
    )

    l.info("> Session terminated. All done!")

if __name__ == "__main__":
    main()
