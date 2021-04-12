# Calibre-Web

Calibre-web needs a little extra configuration. 

Since it can't create a book database alone, you need to create an empty one with Calibre or use the one provided here.

Copy *metadata.db* in the `books/` folder (check where you placed it in the *docker-compose* file)
After that, you'll need to change ownership of the folder and its file

`sudo chown -R :docker books/`

if there are still problems, check the *metadata.db* permissions with `ls -l` and change them with `sudo chmod 664`. If you always get errors while uploading books, experiment with these permissions.

__Important:__ Reading and uploading books from the web need to be manually activated first in the admin settings.
