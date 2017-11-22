GeometryFactory Services Monitoring With Shinken 
================================================

Largely inspired by https://github.com/rohit01/docker_shinken

Usage:
------
- docker build -t [name:tag] [path do Dockerfile]
- docker run [--name shinken]  --rm -d -p 587:587 -p 80:80 -e SMTP_USERNAME=[address] -e SMTP_PASSWORD=[password] -e CGAL_USER=[usual cgal user] -e CGAL_PASSWD=[usual cgal password] -v [path to .ssh]:/tmp/.ssh ubuntu:shinken

port 587 is used by smtp to send mail via ovh's host, and port 80 is the one used by nginx.
    
Then wait ~30-60sec before going to http://localhost
the .ssh volume must contain a valid rsa_key pair for the user mgimeno on cgal.geometryfactory.com

 default username and password: admin admin

If you get 502 bad gateway, wait a little longer, it's just shinken getting ready.
