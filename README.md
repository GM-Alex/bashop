# Bashop

Bashop is a bash framework which makes your life easier if you want to write an bash application. It comes with the following features:

* Argument parser based on docopt.org
** Mostly all is implemented expect the stacking of short options and the | operator for options.
** In addition there is a option to mark options repeatable with _--all..._.
* Automated help pages

## The argument parser

The argument parser returns an associative array with the parameters and the options as key.
Repeatable options or arguments are defined by args[NAME,#] for the number of elements and args[NAME,0] for the elements itself.
If an option has an short and an long option name the key is the long option name. See the exampleapp for more information.


## Global variables

* _args_
** This is the most important global variable, which is set from the parser.
* _BASHOP_ROOT_ The dir where bashop is stored.
* _BASHOP_APP_ROOT_ The dir where the app is stored.
* _BASHOP_APP_COMMAND_ROOT=

All other global options which start it an \_ should be not used. The are for internal stuff.


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


## License

Licensed under the MIT License. See LICENSE for details.