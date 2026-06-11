# AI Coding Setup

## Gemma 4 12B

This is is how I got Gemma 4 12B running on a M1 MacBook Air with 8-Cores and 16GB of RAM. It'll get around 4 tokens a second doing coding tasks that are reasonably complex. That said, if you're running on similar hardware you might want to try the E4B variant for general coding tasks and use this for more complex ones. This setup does account for the article posted by Google on optimizing for lower speced machines. From what I can tell, the bottleneck is the memory bandwith. This might be the limit (currently) for a model this big on this hardware.

- [https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/)

> **Note**: Before beginning, be sure to make sure you have homebrew installed and install Hugging Face CLI and Llama.cpp. After the Hugging Face CLI is installed, be sure to create a token and authenicate the CLi by running `hf auth login` and passing in your token created on the Hugging Face website.

- `brew install hf`
- `brew install llama.cpp`

### 1. Ensure your local models directory exists
`mkdir -p ~/Development/ai/models`

### 2. Download the main Gemma 4 12B QAT GGUF model
`hf download google/gemma-4-12B-it-qat-q4_0-gguf gemma-4-12b-it-qat-q4_0.gguf --local-dir ~/Development/ai/models`

### 3. Download the matching MTP Assistant / Speculative Head
`hf download Janvitos/gemma-4-12B-it-qat-assistant-MTP-Q8_0-GGUF gemma-4-12B-it-qat-assistant-MTP-Q8_0.gguf --local-dir ~/Development/ai/models`

### 4 Run the Model

Two options. Option 1 has a tiny bit better performance with a larger context window. Option 2 should be a little more accurate.

#### Option 1
```
llama-server \
  -m ~/Development/ai/models/gemma-4-12b-it-qat-q4_0.gguf \
  --model-draft ~/Development/ai/models/gemma-4-12B-it-qat-assistant-MTP-Q8_0.gguf \
  --spec-type draft-mtp \
  --spec-draft-n-max 4 \
  -ngl 99 \
  -c 16384 \
  -ctk q4_0 \
  -ctv q4_0 \
  --cache-ram 2048 \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  --reasoning on \
  --fit off \
  --flash-attn on \
  --jinja \
  --port 8080
```

#### Option 2
```
llama-server \
  -m ~/Development/ai/models/gemma-4-12b-it-qat-q4_0.gguf \
  --model-draft ~/Development/ai/models/gemma-4-12B-it-qat-assistant-MTP-Q8_0.gguf \
  --spec-type draft-mtp \
  --spec-draft-n-max 4 \
  --parallel 1 \
  -ngl 99 \
  -c 8192 \
  -ctk q8_0 \
  -ctv q8_0 \
  --cache-ram 2048 \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  --reasoning on \
  --fit off \
  --flash-attn on \
  --jinja \
  --port 8080
```

## Gemma 4 E4B

This is is how I got Gemma 4 E4B running on a M1 MacBook Air with 8-Cores and 16GB of RAM. It'll get around 8 tokens a second doing coding tasks. If you're running on similar hardware you might want to try the 12B variant (above) for more complex coding tasks (it is slower). This setup does account for the article posted by Google on optimizing for lower speced machines. From what I can tell, the bottleneck is the memory bandwith. This might be the limit (currently) for a model this big on this hardware.

- [https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/)

> **Note**: Before beginning, be sure to make sure you have homebrew installed and install Hugging Face CLI and Llama.cpp. After the Hugging Face CLI is installed, be sure to create a token and authenicate the CLi by running `hf auth login` and passing in your token created on the Hugging Face website.

- `brew install hf`
- `brew install llama.cpp`

### 1. Ensure your local directory exists
`mkdir -p ~/Development/ai/models`

### 2. Download the main E4B QAT model
`hf download google/gemma-4-E4B-it-qat-q4_0-gguf gemma-4-E4B_q4_0-it.gguf --local-dir ~/Development/ai/models`

### 3. Download the matching E4B QAT Assistant model 
`hf download cascade-tech/gemma-4-E4B-it-qat-q4_0-unquantized-assistant-gguf gemma-4-E4B-it-qat-assistant-q4_0.gguf --local-dir ~/Development/ai/models`

### 4 Run the Model
```
llama-server \
  -m ~/Development/ai/models/gemma-4-E4B_q4_0-it.gguf \
  --model-draft ~/Development/ai/models/gemma-4-E4B-it-qat-assistant-q4_0.gguf \
  --spec-type draft-mtp \
  --spec-draft-n-max 4 \
  --parallel 1 \
  -ngl 99 \
  -c 32768 \
  -ctk q8_0 \
  -ctv q8_0 \
  --cache-ram 2048 \
  --temp 0.1 \
  --reasoning off \
  --fit off \
  --flash-attn on \
  --jinja \
  --port 8080
```

## JetBrains Mellum2

This is is how I got JetBrains Mellum2 running on a M1 MacBook Air with 8-Cores and 16GB of RAM. It'll get around 13 tokens a second doing coding tasks.

> **Note**: Before beginning, be sure to make sure you have homebrew installed and install Hugging Face CLI and Llama.cpp. After the Hugging Face CLI is installed, be sure to create a token and authenicate the CLi by running `hf auth login` and passing in your token created on the Hugging Face website.

- `brew install hf`
- `brew install llama.cpp`

### 1. Ensure your local directory exists
`mkdir -p ~/Development/ai/models`

### 2. Download the main E4B QAT model
`hf download JetBrains/Mellum2-12B-A2.5B-Instruct-GGUF-Q4_K_M --include "*.gguf" --local-dir ~/Development/ai/models`

### 3 Run the Model
```
llama-server \
  -m ~/Development/ai/models/Mellum2-12B-A2.5B-Instruct-Q4_K_M.gguf \
  -ngl 99 \
  -fa on \
  -c 32768 \
  -b 2048 \
  -ub 2048 \
  -ctk q4_0 \
  -ctv q4_0 \
  --cache-ram 2048 \
  --temp 0.1 \
  --jinja \
  --port 8080
```
