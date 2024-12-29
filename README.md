# shai (shell ai)

LLM-powered utility for requesting and executing shell commands. 

Make a request using natural language and shai prompts an LLM for a shell command to fulfil your request. 

It's OK to feel shy about executing the suggested command.

The command will not execute without your confirmation. Please be careful when confirming. 

## Usage

    shell> shai ask for what you want              -- in natural language
    
    shell> shai what processes are using the most memory 
    shell> shai how much disk space is left
    shell> shai what programs have ports open
    shell> shai remove .tmp files larger than 100 meg 
    
    shell> shai config                             -- change LLM settings
    shell> shai help                               -- show this help


## Install

shai is a Raku command-line utility.

    1. Install Raku

        [https://raku.org/downloads/](https://raku.org/downloads/)

    2. Install shai 
    
        shell> zef install SHAI

    3. Set up your LLM with LLM::DWIM

        shell> rakudoc LLM::DWIM
        
