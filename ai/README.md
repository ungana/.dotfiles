# AI Coding Setup

Make sure you have homebrew installed and install Hugging Face CLI and Llama.cpp.

`bash
brew install hf
`
`bash
brew install llama.cpp
`

## Model Storage

Create a place to store your models and navigate there in your terminal.

`bash
mkdir ~/Development/ai/models
`
`bash
cd ~/Development/ai/models
`

## Download Gemma 4 12B

This setup will work on a lower speced machine. I have a M1 MacBook Air with 16GB of RAM.

`bash
hf download bartowski/gemma-4-12B-it-GGUF --include "gemma-4-12B-it-Q4_0.gguf" --local-dir .
`

## Running the Model

To run the model, run the following command to from the model directory (above).

`bash
llama-server -m gemma-4-12B-it-Q4_0.gguf -ngl 99 -c 16384 -ctk q4_0 -ctv q4_0 --flash-attn on --port 8080
`

