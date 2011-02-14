Strongspace Ruby Library and Command-line interface
===================================================

This is a Ruby library and command line interface to Strongspace online storage.

For more about Strongspace see <http://www.strongspace.com>.

For full documentation see <http://www.strongspace.com/help>.


Usage
-----

Install:
    `gem install strongspace`

Run via command line:
`strongspace help` or `ss help`

    === General Commands
    help                                          # show this usage
    version                                       # show the gem version

    upload <local_path> <remote_path>             # upload a file
    download <remote_path>                        # download a file from Strongspace to the current directory
    mkdir <remote_path>                           # create a folder on Strongspace
    delete <remote_path>                          # delete a file or recursively delete a folder on Strongspace
    quota                                         # Show the filesystem quota information

    === SSH Keys
    keys                                          # show your user's public keys
    keys:add [<keyfile_path>]                     # Add an public key or generate a new SSH keypair and add
    keys:generate                                 # Generate a new SSH keypair
    keys:remove <id>                              # remove a key by id
    keys:clear                                    # remove all keys

    === Spaces
    spaces                                        # show your user's spaces
    spaces:create <name> [type]                   # add a new space. type => (normal,public,backup)
    spaces:delete <name> [type]                   # remove a space by and destroy its data
    spaces:snapshots <name>                       # show a space's snapshots
    spaces:create_snapshot <name> [snapshot_name] # take a space of a space - snapshot_name defaults to current date/time.
    spaces:delete_snapshot <name> <snapshot_name> # remove a snapshot from a space

    === Plugins
    plugins                                       # list installed plugins
    plugins:install <url>                         # install the plugin from the specified git url
    plugins:uninstall <url/name>                  # remove the specified plugin


Plugins
------
Check out our sample [Rsync Plugin](https://github.com/expandrive/strongspace-rsync) as an example of how to add functionality


Meta
-----

Many thanks to the Heroku team, whose fantastic Heroku gem provided the basis for this project.

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
