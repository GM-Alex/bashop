# Bashop

Bashop is a bash framework which makes your life easier if you want to write an bash application. It comes with the following features:

* Argument parser
* Automated help pages


### Global variables

* _BASHOP_ROOT_ The dir where bashop is stored.
* _BASHOP_APP_ROOT_ The dir where the app is stored.
* _BASHOP_APP_COMMAND_ROOT=


### Global Functions

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
* bashop::printer::framework_error
* bashop::printer::help_formater


### Restrictions

Don't let the name of your app functions start with _bashop::_ and don't let your global variable names start with _BASHOP_ or _\_BASHOP_.
No there is no way, expect you want to break something, don't even think about it. :)


### Coding conventions

The coding conventions which are (mostly) used are: https://google-styleguide.googlecode.com/svn/trunk/shell.xml


### License

Licensed under the MIT License. See LICENSE for details.