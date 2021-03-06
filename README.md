Flappy is a command-line tool for [Flapjack](http://flapjack.io/) that relies heavily on [Flapjack-Diner](https://github.com/flpjck/flapjack-diner).

### Main Usage

```
Commands:
  flappy checks <entity>                        # List checks for a given entity
  flappy config SUBCOMMAND ...ARGS              # Create a ~/.flapjack.rc file that can be used by this CLI tool.
  flappy contacts SUBCOMMAND ...ARGS            # Manage contacts.
  flappy entities SUBCOMMAND ...ARGS            # Manage entities.
  flappy help [COMMAND]                         # Describe available commands or one specific command
  flappy maintenance SUBCOMMAND ...ARGS         # Enable maintenance mode for entities and checks.
  flappy notification_rules SUBCOMMAND ...ARGS  # Manage notification rules.
  flappy status <entity>[:<check>[,<check>]]    # List status of checks for a given entity

Options:
  -u, [--uri=URI]        # Specify the Flapjack URI.
  -c, [--config=CONFIG]  # Specify the Flapjack config file.
```

### Checks

```
Usage:
  flappy checks <entity>

Description:
  List the checks for a given entity.

  Example:

  $ flappy checks <fqdn>
```

### Status

```
Usage:
  flappy status <entity>[:<check>[,<check>]]

Description:
  List the status of checks for a given entity.

  Example:

  $ flappy status <fqdn>
```

### Maintenance Mode

```
Commands:
  flappy maintenance disable <entity>[:<check>[,<check>]] [options]  # Disable maintenance mode for an entity and check.
  flappy maintenance enable <entity>[:<check>[,<check>]] [options]   # Enable maintenance mode for an entity and check.
  flappy maintenance get <entity>[:<check>[,<check>]] [options]      # Gets maintenance mode status for an entity (and checks).
  flappy maintenance help [COMMAND]                                  # Describe subcommands or one specific subcommand
```

### Contacts

```
Commands:
  flappy contacts create [options]  # Create contacts in Flapjack.
  flappy contacts help [COMMAND]    # Describe subcommands or one specific subcommand
```

### Entities

```
Commands:
  flappy entities create [options]  # Create entities in Flapjack.
  flappy entities help [COMMAND]    # Describe subcommands or one specific subcommand
```

### Notification Rules

```
Commands:
  flappy notification_rules clean [options]   # Cleanup the default notification_rules in Flapjack.
  flappy notification_rules create [options]  # Create notification_rules in Flapjack.
  flappy notification_rules help [COMMAND]    # Describe subcommands or one specific subcommand
  flappy notification_rules list [options]    # List notification_rules in Flapjack.
```

### Configuration File

```
Commands:
  flappy config create          # Create a flapjack.rc file.
  flappy config display         # Display the contents of the flapjack.rc file.
  flappy config help [COMMAND]  # Describe subcommands or one specific subcommand
```
