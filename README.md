Docker Symfony
==============

Provide a bootstrap Symfony 4.1 with docker and docker-compose

# Installation

    make          # self documented makefile
    make install  # install and start the project

# Stack

    - PHP 7.2 with APCu
    - Symfony 4.1
    - Enum library
    - Ramsey uuid
    - Codeception
    - Phpstan
    - Container running as current host user (batman) thanks to gosu
    - zsh
