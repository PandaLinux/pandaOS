# Change Log

### Friday, 15. January 2016
- This branch contains the bare minimum.
- The packages related to GUI have been stripped off.
- Fixed md5sum file not found

### Sunday, 10. January 2016
- Removed `TODO.md` and moved it to github.
- Added user input for downloading packages in the `install.sh` file.

### Monday, 04. January 2016
- Removed `set -e`. As it was uncessarily exiting the scripts upon compilation.
- Completed `phase 1` of the setup.

### Sunday, 03. January 2016

- Scripts re-written for better management.
- Fixed gcc compilation bugs.
- Added entry scripts for every phase.
- Added `set -e` in the scripts (scripts exit when encountered with an error).
- Added prompts to gain more control over the installation process.