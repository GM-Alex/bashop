# Bashop [![Build Status](https://travis-ci.org/GM-Alex/bashop.svg?branch=master)](https://travis-ci.org/GM-Alex/bashop)

Bashop is a bash framework which makes your life easier if you want to write a bash application. It comes with the following features:

* Argument parser based on docopt.org
 * Mostly all is implemented expect the stacking of short options and the | operator for options.
 * In addition there is an option to mark options repeatable with _--all..._.
* Automated help pages
* Done in pure bash, no grep, sed etc. used.


## TODO

- [ ] Maximize compatibility (here your help is appreciated)
- [ ] Auto completion for commands


### Already tested environments

* Ubuntu 14.04 - bash 4.3.11
* Fedora 20, Fedora 21 -  bash 4.2.47 and fishshell 2.1.0


## The argument parser

The argument parser returns an associative array with the parameters and the options as key.
Repeatable options or arguments are defined by args[NAME,#] for the number of elements and args[NAME,0] for the elements itself.
If an option has a short and a long option name the key is the long option name. See the exampleapp for more information.


## Global variables

* _args_ This is the most important global variable, which is set from the parser.
* _BASHOP_ROOT_ The dir where bashop is stored.
* _BASHOP_APP_ROOT_ The dir where the app is stored.
* _BASHOP_APP_COMMAND_ROOT_ The dir where the app command scripts are stored.
* _BASHOP_CONFIG_FILE_ If set the config will be written to the file. In addition if the file exists bashop will always load the variables to the _BASHOP_CONFIG_ array.
* _BASHOP_CONFIG_ The bashop config array.

All other global options which start with a \_ should be not used. They are for internal stuff.


## HowTo use it

### Suggested folder structure

* src
 * commands
 * yourapp
* vendor
 * bashop

The _commands_ folder holds all commands. _yourapp_ is the main app file.


### The app file

```bash
#!/usr/bin/env bash
bashop::init() {
  bashop::printer::info "init";
}

bashop::destroy() {
  bashop::printer::info "destroy";
}

source "../vendor/bashop/bootstrap.sh"
```

The file must source the bashop _bootstrap.sh_ file.
The functions _bashop::init_ (is executed at the startup) and _bashop::destroy_ (is executed at the before shutdown) are optional.


### The command file

```bash
#?d The example command
#?c --coption -z <name> <version> [<extra>...]
#?o -a  Short option
#?o -b --boption  Short and long option.
#?o -r..., --roption...  A repeatable option with shortcut.
#?o -x... <arg>, --xoption...=<arg>  A repeatable option with requrired argument.
#?o -y... <arg>, --yoption...=<arg>  A repeatable option with requrired argument [default: test].

bashop::run_command() {
  bashop::printer::info "Command"
}
```

The _#?d_ comment describes the command itself and is parsed for the help page.
The _#?c_ comment is parsed by the argument parser and defines the command parameters, it's also used for the help.
The _#?o_ comment is parsed by the argument parser and defines the command options, it's also used for the help.


## Build in option

* -v, --verbose Used for verbose output. Add the _bashop::printer::verbose_ function to your app.
* -h, --help Shows the help.


## Public functions

* bashop::utils::isset
* bashop::utils::contains_element
* bashop::utils::key_exists
* bashop::utils::is_option
* bashop::utils::function_exists
* bashop::utils::string_repeat
* bashop::utils::min_string_length
* bashop::utils::max_string_length
* bashop::utils::string_length
* bashop::utils::check_version
* bashop::printer::echo
* bashop::printer::info
* bashop::printer::user
* bashop::printer::success
* bashop::printer::error
* bashop::printer::verbose
* bashop::printer::help_formatter
* bashop::config::parse
* bashop::config::write
* bashop::config::read_var_from_user

All functions which start with an \_\_ double dash for example _bashop::printer::__framework_error_ are for internal stuff and should not use by your application.


## Restrictions

Don't let the name of your app functions start with _bashop::_ and don't let your global variable names start with _BASHOP_ or _\_BASHOP_.
No there is no way, expect you want to break something. :)


## Coding conventions

The coding conventions which are (mostly) used are: https://google-styleguide.googlecode.com/svn/trunk/shell.xml
Extensions related to the document above are using __ for internal functions, which should not used by your application.


## Contribute

* Fork the project
* Make your changes
* Check if you keep the coding conventions, all tests are ok and add new test / adjust the existing tests for your changes
* Create a pull request


## License

Licensed under the MIT License. See LICENSE for details.
