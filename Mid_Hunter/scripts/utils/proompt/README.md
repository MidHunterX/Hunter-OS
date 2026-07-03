# PROOMPT

## USAGE

CLI:

```bash
proompt filename
```

NVIM:

```lua
:!proompt %
```

### Expansion Syntax

```
<code> echo "Hello, world!" </code>
./lib/Proompt.pm
```

## INSTALL

```bash
mkdir -p ~/.local/bin/lib
ln -sf "$PWD/proompt.pl" ~/.local/bin/proompt
ln -sf "$PWD/lib/Proompt.pm" ~/.local/bin/lib/Proompt.pm
```

## RESEARCH

### Claude

Anthropic is the most vocal about its structure. They explicitly train Claude to understand XML tags.

```xml
<context>
  <project_description>This is a React dashboard project.</project_description>
  <files>
    <file name="src/App.js">
      // Code here
    </file>
    <file name="src/components/Button.js">
      // Code here
    </file>
  </files>
</context>

<user_query>
  Please refactor the Button component to use Tailwind.
</user_query>
```

XML tags are "low-entropy" markers that are rare in natural language but common in training data. This makes it mathematically easier for the model to distinguish.

### Llama 3

```
<|begin_of_text|> | Specifies the start of the prompt.
<|end_of_text|> | Specifies the end of the prompt.
<|start_header_id|> | These tokens enclose the role for a particular message, always paired with <|end_header_id|>. The possible roles are: [system, user, assistant, and ipython]
<|end_header_id|> | Pairs with <|start_header_id|> to define role for a particular message
<|eot_id|> | End of turn. Represents when the model has determined that it has finished interacting with the user message that initiated its response. This token signals to the executor that the model has finished generating a response.
```

```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are an expert assistant who provides concise and accurate answers.<|eot_id|>

<|start_header_id|>user<|end_header_id|>
What is the capital of Canada?<|eot_id|>

<|start_header_id|>assistant<|end_header_id|>
```

### Mistral

```
<s> | Marks the start of a sentence or sequence.
<\s> | Marks the end of a sentence or sequence.
[INST] | Signifies the start of an instructional message or command. Typically used for instructions.
[/INST] | Marks the end of the instructional message.
```

```
<s>[INST]
You are a highly specialized assistant. You only provide answers based on facts and logic. [/INST]

[INST] What is the capital of France? [/INST] </s>
```

### Granite (IBM)

```
<|system|> | Identifies the instruction, commonly referred to as the system prompt for the foundation model.
<|user|> | The query text to be answered.
<|assistant|> | A cue at the end of the prompt that indicates that a generated answer is expected.
```

```
<|system|>
You are an expert assistant who provides concise and accurate answers.
<|user|>
What is the capital of France?
<|assistant|>
```
