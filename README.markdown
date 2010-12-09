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
`strongspace help`

    === General Commands
    help                                              # show this usage
    version                                           # show the gem version

    upload <local_file> <remote_path>                 # upload a file
    download <remote_path>                            # download a file from Strongspace to the current directory
    mkdir <remote_path>                               # create a folder on Strongspace
    delete <remote_path>                              # delete a file or recursively delete a folder on Strongspace

    === SSH Keys
    keys                                              # show your user's public keys
    keys:add [<path to keyfile>]                      # add a public key
    keys:remove <id>                                  # remove a key by id
    keys:clear                                        # remove all keys

    === Spaces
    spaces                                            # show your user's spaces
    spaces:create <space_name> [type]                 # add a new space. type => (normal,public,backup)
    spaces:delete <space_name> [type]                 # remove a space by and destroy its data
    spaces:snapshots <space_name>                     # show a space's snapshots
    spaces:create_snapshot <space_name@snapshot_name> # take a space of a space.
    spaces:delete_snapshot <space_name@snapshot_name> # remove a snapshot from a space





Meta
-----

Many thanks to the Heroku team, whose fantastic Heroku gem provided the basis for this project.

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
