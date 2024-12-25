unit module SHAI::CLI;

use LLM::DWIM;
use JSON::Fast;

#| Turn a spoken command request into a shell command and explanation. Prompt the user before executing.
multi sub MAIN (*@args) is export {
    
    my $spoken-command-request = @args.join(' ');

    return USAGE() unless $spoken-command-request;
    
    # keep the prompt short and sweet
    my $prompt = qq:to"PROMPT";
    
    You are an expert shell programmer for the {$*KERNEL.name} {$*KERNEL.release} kernel running {$*DISTRO.name} on {$*KERNEL.hardware} hardware. 

    Provide output as a JSON document. Here are some output examples:

    Example 1:
    
    \{
        "shell_command": "ls -l",
        "explanation": "The 'ls' command lists files in the current directory, and the '-l' flag displays detailed information about each file.",
        "warning": ""
    \}


    Example 2:

    \{
        "shell_command": "find . -type f -size +1M -delete",
        "explanation": "The 'find' command searches for files in the current directory, the '-type f' flag specifies to find only files, the '-size +1M' flag filters for files larger than 1 megabyte, and the '-delete' flag removes the found files.",
        "warning": "Be cautious when using the delete option as it permanently removes files."
    \}
    
    
    1. The shell_command:
    
    - is an executable shell script command
    - may contain piped subcommands when required
    - attempts to fully solve the command_request
    
    2. The explanation:
    
    - is a short, single sentence
    - describes the result of running the shell_command
    - highlights any interesting shell_command arguments
    - has a friendly tone

    3. The warning:

    - contains an empty string when the shell_command does not change anything 
    - is a single sentence
    - is only included if really necessary
    
    The shell_command should solve the following command_request:

    PROMPT

    my $json-data = dwim $prompt ~ ' ' ~ $spoken-command-request;

    say $prompt;
    say $json-data;

    # parse the JSON with JSON::Fast
    my $llm-response = from-json($json-data);

    die "No command found." unless $llm-response;

    say "shai (Shell AI)";
    say "---------------";
    say "";
    say $llm-response<explanation>;
    say "";
    if ($llm-response<warning>) {
        # highlight the warning in red  
        say "\e[31m" ~ $llm-response<warning> ~ "\e[0m";
        say "";
    }
    say "\t" ~ "\e[33m" ~ $llm-response<shell_command> ~ "\e[0m";
    say "";

    my $confirmed = prompt("Do you want to execute the command? (y/N) ");

    say "";
    
    if $confirmed.uc eq 'Y' or $confirmed.uc eq 'YES' {
        shell $llm-response<shell_command>;
    }
    else {       
        say "\e[33m" ~ "Command NOT executed." ~ "\e[0m";
    }
    say "";
}


#| show this help
multi sub MAIN ('help') is export {
    USAGE();
}


#| configure defaults
multi sub MAIN ('config') is export {
    CONFIG();
}


sub CONFIG is export {

    say q:to"CONFIG";

    shai - set the following config to change LLM settings
    
    Config:
    
        See LLM::DWIM to swap LLMs. 

    CONFIG
    
}


sub USAGE is export {

    say q:to"USAGE";

    shai (Shell AI)

    LLM-powered utility for generating and executing shell commands.

    It's OK to feel shy about executing a command suggested by an LLM.

    The command does not execute without your confirmation. Be careful when confirming. 

    Usage:

        shai ask for what you want              -- in plain spoken language
        
        shai what processes are using the most memory 
        shai how much disk space is left
        shai what programs have ports open
        shai remove .tmp files larger than 100 meg 
        
        shai config                             -- change LLM settings
        shai help                               -- show this help
       
    USAGE
    
}

