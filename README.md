# Bashop

Bashop is a bash framework which makes your life easier if you want to write an bash application. It comes with the following features:

* Argument parser based on docopt.org
 * Mostly all is implemented expect the stacking of short options and the | operator for options.
 * In addition there is a option to mark options repeatable with _--all..._.
* Automated help pages
* Done in pure bash, no grep, sed etc. used.


## TODO

- [ ] Maximize compatibility (here your help is appreciated)
- [ ] Auto completion for commands



## The argument parser

The argument parser returns an associative array with the parameters and the options as key.
Repeatable options or arguments are defined by args[NAME,#] for the number of elements and args[NAME,0] for the elements itself.
If an option has an short and an long option name the key is the long option name. See the exampleapp for more information.


## Global variables

* _args_
 * This is the most important global variable, which is set from the parser.
* _BASHOP_ROOT_ The dir where bashop is stored.
* _BASHOP_APP_ROOT_ The dir where the app is stored.
* __BASHOP_APP_COMMAND_ROOT_ The dir where the app command scripts are stored.

All other global options which start it an \_ should be not used. The are for internal stuff.


## HowTo use it

### Suggested folder structure

.
+-- src
|   +-- commands
|   +-- yourapp
+-- vendor
|   +-- bashop

The _commands_ folder holds all commands. _yourapp_ is the main app file.


### The app file

```bash
#!/usr/bin/env bash
bashop::init() {
  bashop::printer::info "init: ${BASHOP_ROOT}";
}

bashop::destroy() {
  bashop::printer::info "destroy: ${BASHOP_ROOT}";
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
  echo "Command"
}
```

The _#?d_ comment describes the command itself and is parsed for the help page.
The _#?c_ comment is parsed by the argument parser and defines the command parameters, it's also used for the help.
The _#?o_ comment is pareed by the argument parser and defines the command options, it's also used for the help.


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
* bashop::printer::help_formater

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