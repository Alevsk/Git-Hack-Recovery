The MIT License (MIT)

Copyright (c) 2014 Lenin Alevski (www.alevsk.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Git-Hack-Recovery
=================

This scripts allow you to automatically recover your company website or blog in case of being hacked. Using
a Infraestructure similar to this: 

_______________                ________________________                ____________________
|     DB      |   read/write   |	  cpy db.sql.gz   |      read	   |   cpy db.sql.gz   |
|   Files     | <------------> |		cpy Files     | <------------> | 	 cpy Files     |
| 127.0.0.0   |                |Private Git Repository|                | Production Server |
|_____________|                |______________________|                |___________________|

Instructions: 

  ###############################
  # Configuring the environment #
  ###############################
  
  -> Create two git accounts (example: admin & slave)
  -> Create a private repository to track your files (bitbucket.org is a good option)
  -> Add read/write permisson to admin account
  -> Add only read permissions to slave account
  -> Create your ssh keys using ssh-keygen in every server you want to access the repository and add them to your Git
     server for public key authentication
  
  ##################################
  # Configuring the trusted system #
  ##################################
  
  -> On your trusted system (usually your localhost) clone the git repository using your admin account (the one that have read/write permissions), 
     don't forget to check the .htaccess file provided
  -> If you install a blog like wordpress, virtual-host configuration and /etc/hosts domain addition is strongly recommended
  -> When you finish setting are your files and database configuration in your trusted system you must run db_checksum_backup.sh script
     in order to generate a backup of your database tables and the file that hold checksums
  -> When your are done just run auto_commit.sh and you will have a copy of your files and database in your Git repository
  
  #####################################
  # Configuring the production server #
  #####################################
  
  -> On your production server clone the git repository using your slave account (the one that have only read permissions
  -> Configure your virtual-host correctly (blogs like wordpress store domain url's in the database)
  -> Create a database with the credentials so the blog can have access information stored
  -> You can use cron jobs to automatically run the following scripts: 
    * deface_recovery.sh: if a local file is modified, deleted or a new file is added, this script will rollback the files involved
      to its last trusted state
    * auto_update.sh: This script will check for updates on the Git repository, if you have a blog or dynamic website you can update
      your site in your trusted system (example: publish some new post with image) and this script will take care of properly update your blog
      in the production server
    * db_checksum_validator.sh: This script will check your database integrity, in the case that someone hack your database and
      insert some malicious code such as XSS the script will detect the change and restore the tables to its last trusted state
      
    */1 * * * * cd /var/www/production-repository/; /bin/bash deface_recovery.sh --arguments > /path/deface_recovery.txt
    */1 * * * * cd /var/www/production-repository/; /bin/bash auto_update.sh --arguments > /path/auto_update.txt
    */1 * * * * cd /var/www/production-repository/; /bin/bash db_checksum_validator.sh --arguments > /path/db_checksum_validator.txt