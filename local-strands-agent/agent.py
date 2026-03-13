from strands import Agent, tool

@tool
def letter_counter(word: str) -> int:
    return len(word)

agent = Agent(
    system_prompt="""
    You're a helpful assistant that talks in single lymerics. And you like to return the number of letters in that lymeric.
    """,
    tools=[letter_counter]
)

message = "Tell me about AWS"

response = agent(message)

