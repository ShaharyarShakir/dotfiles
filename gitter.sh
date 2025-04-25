#!/bin/bash
git status
read -p "Git commit messsage: " Commit 
git add .
git commit -m "$Commit"
git push

read -p "Press any key to exit"

