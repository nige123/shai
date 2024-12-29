unit module SHAI::CLI;

use LLM::DWIM;
use JSON::Fast;

#| Prompt an LLM with a natural language request for a shell command. Only execute the command if confirmed.
multi sub MAIN (*@args) is export {
    
    my $spoken-command-request = @args.join(' ');

    return USAGE() unless $spoken-command-request;

    my $prompt = render-prompt();
        
    my $json-data = dwim $prompt ~ ' ' ~ $spoken-command-request;

    if %*ENV{'SHAI_DEBUG'} {
        say "PROMPT:\n" ~ $prompt;
        say "RESPONSE:\n" ~ $json-data;
    }
  
    # handle the response record
    my %llm-response = from-json($json-data);

    my ($explanation, $shell-command, $warning) = %llm-response<explanation shell_command warning>;

    die "No command found." unless $shell-command and $explanation;

    show-header();
    
    say $explanation;
    say "";
    
    if $warning {
        say in-red($warning);
    }
    say "\t" ~ in-yellow($shell-command);
    say "";

    my $confirmed = prompt("Do you want to execute the command? (y/N) ");
    say "";

    # IMPORTANT - make sure the user confirms first!
    if $confirmed.uc eq 'Y' or $confirmed.uc eq 'YES' {
        # execute the command with the shell - /sh
        shell $shell-command;
    }
    else {       
        say in-yellow("Command NOT executed.");
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

#| show the version
multi sub MAIN ('version') is export {
    say "5";
}

sub CONFIG is export {

    show-header();

    say q:to"CONFIG";
    Set the following config to change LLM settings
    
    Config:
    
        See rakudoc LLM::DWIM to swap LLMs. 

        Set the shell environment variables:

        SHAI_DEBUG=1        -- to see the prompt text and raw LLM response.
        SHAI_NO_COLOR=1     -- to remove coloured output.

    CONFIG
}


sub USAGE is export {

    show-header();

    say q:to"USAGE";    
    LLM-powered utility for requesting and executing shell commands. 

    Make a request using natural language and shai prompts an LLM for a shell command to fulfil your request. 

    It's OK to feel shy about executing the suggested command.
    
    The command will not execute without your confirmation. Please be careful when confirming. 

    Usage:

        shell> shai ask for what you want              -- in natural language
        
        shell> shai what processes are using the most memory 
        shell> shai how much disk space is left
        shell> shai what programs have ports open
        shell> shai remove .tmp files larger than 100 meg 
        
        shell> shai config                             -- change LLM settings
        shell> shai help                               -- show this help
       
    USAGE
    
}


sub show-header {
    say "";
    say "shai (shell ai)";
    say "_______________";
    say "";
}


sub in-yellow($string) {
    return $string if %*ENV{'SHAI_NO_COLOR'};
    return "\e[33m" ~ $string ~ "\e[0m";
}

sub in-red($string) {
    return $string if %*ENV{'SHAI_NO_COLOR'};
    return "\e[31m" ~ $string ~ "\e[0m";
}


sub render-prompt {

    return qq:to"PROMPT";
    
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
    
}


